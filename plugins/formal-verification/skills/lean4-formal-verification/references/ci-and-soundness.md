# CI と証明健全性監査

Lean 4 を開発ループと CI に組み込むときは、「AI が証明を書いたつもりでも抜け道が残っていないか」を決定論的に検査する。

## なぜ素朴な `grep sorry` だけでは不十分か

1. コメント・文字列リテラル内の `"sorry"` で誤検知する。
2. `admit`（`sorry` と同様に証明を放棄するタクティク）を見逃す。
3. 新規の `axiom foo : ...` を宣言して使っても `sorry` は出現しない。
4. `unsafe`、`@[implemented_by ...]`、`@[extern ...]`、`native_decide` が導入する補助公理、`set_option debug.skipKernelTC true` など、信頼境界を変える記述を見逃す。

## 推奨する多層ゲート

### 1. ツールチェイン固定（`lean-toolchain`）

- 対象パッケージ直下（例: `specs/lean-toolchain`）に Lean 4 のバージョンを 1 行で固定する（例: `leanprover/lean4:v4.14.0`）。

### 2. 警告のエラー化（`lake build --wfail` / `weakLeanArgs`）

`lake build -- -DwarningAsError=true` は誤りである。Lake の `build` サブコマンドは `--` 以降の引数を Lean コンパイラに渡さず無視するため、`sorry` 警告が出ても終了コード 0 で通る。

- **CI やコマンドラインで失敗させる**: `lake build --wfail` を使う（すべての警告でビルドを失敗させる）。
- **パッケージ設定で設定する場合（`lakefile.toml`）**:
  - ビルド時だけ警告をエラーにしたい場合は、ビルドトレースや `lake serve` の編集体験を変えない `weakLeanArgs` を使う。
  - `[leanOptions]` を使うとエディタ（`lake serve`）にも効く。TOML では `[leanOptions]` より後ろに書いたキーがそのテーブルに入るため、パッケージ直下のキーより後に配置する。

```toml
# 推奨: lake serve やトレースに影響させずビルド時に警告をエラー化する
weakLeanArgs = ["-DwarningAsError=true"]
```

なお、ファイル内で `set_option warningAsError false` や `set_option warn.sorry false` を書くと警告自体が抑止されるため、ビルド警告だけに頼らず必ず次の公理監査と併用する。

### 3. 公理監査（fail-closed の許可リスト方式）

#### CI での推奨: `leanprover/lean-action@v1`

公式アクションの `axiom-audit: "true"` はパッケージのルート名前空間配下にあるすべての宣言の依存公理を走査し、許可リスト外の公理（`sorryAx`、カスタム `axiom`、`native_decide` の生成公理など）を自動で落とす。手動列挙の漏れを防げるため CI ではこちらを第一選択にする（本番ではアクションをコミット SHA に固定する）。

```yaml
- uses: leanprover/lean-action@v1
  with:
    lake-package-directory: ${{ env.SPECS_DIR }}
    build: "true"
    build-args: "--wfail"
    use-mathlib-cache: "auto"
    use-github-cache: "true"
    axiom-audit: "true"
    axiom-audit-allow: "propext,Classical.choice,Quot.sound"
```

- 高保証が求められる場合は `leanchecker: "true"`（または外部の `lean4checker`）を有効化し、`set_option debug.skipKernelTC true` 等によるカーネル検査スキップを含めて環境全体を再検証する。
- `actions/cache` を手動設定する場合は、`hashFiles(format('{0}/lean-toolchain', env.SPECS_DIR), format('{0}/lake-manifest.json', env.SPECS_DIR))` のように実際の `SPECS_DIR` を渡し、別構成の `.lake` を誤復元する広すぎる `restore-keys` を避ける。`lake exe cache get` は Mathlib 依存時だけ実行する。

#### ローカル / 自前スクリプトでの監査フォールバック

`lean-action` を使わない環境では、`Specs/Audit.lean` 等に公開定理の `#print axioms <TheoremName>` を列挙して fail-closed に判定する（なお手動 `Audit.lean` に書き忘れた定理は監査対象外になるため、名前空間から自動収集する構成か「監査対象は列挙済み定理に限る」前提を明示する。より新しい Lean 環境なら `lake check` や `Lean.collectAxioms` の利用も検討できる）。

```bash
set -euo pipefail
test -f Specs/Audit.lean
audit_out=$(lake env lean Specs/Audit.lean 2>&1)
printf '%s\n' "$audit_out"
printf '%s\n' "$audit_out" | python3 -c '
import re, sys
allowed = {"propext", "Classical.choice", "Quot.sound"}
text = sys.stdin.read()
if re.search(r"uses .+sorry|sorryAx", text):
    sys.exit("incomplete proof (sorry) detected")
groups = re.findall(r"depends on axioms:\s*\[([^\]]*)\]", text)
has_clean = "does not depend on any axioms" in text
if not groups and not has_clean:
    sys.exit("no axiom audit output found")
for group in groups:
    names = {n.strip() for n in group.split(",") if n.strip()}
    bad = names - allowed
    if bad:
        sys.exit("disallowed axioms: " + ", ".join(sorted(bad)))
'
```

`native_decide` が生成する公理名は Lean のバージョンによって変わる（近年の Lean では計算ごとの公理名になり、旧 `Lean.ofReduceBool` 等に固定されない）。許可リスト完全一致にすれば、公理名を問わず未承認の公理をすべて拒否できる。

### 4. オラクル実行経路と信頼境界の確認（カーネル健全性との違い）

`@[implemented_by ...]`、`@[extern ...]`、`unsafe` は、定理証明のカーネル健全性（`#print axioms`）には必ずしも現れず、**証明した純粋定義とコンパイル後オラクルバイナリの実行時挙動を乖離させる**問題を引き起こす。

Level 2 で実行可能オラクルを使う場合は、オラクルの CLI から呼ばれる計算核とその依存モジュールにおいて、以下をレビュー候補として補助スキャンし、意図しない差し替えや検査回避がないか確認する（文字列スキャンはパーサではないため、人間レビューの補助に留める）。

- 計算核内の `axiom `、`unsafe`、`@[implemented_by`、`@[extern`、`admit`
- 検査回避のオプション：`set_option debug.skipKernelTC`、`set_option warningAsError`、`set_option warn.sorry`

### 5. 空虚な真（vacuous truth）の防止

仮定同士が矛盾していると、どんな定理も `exfalso` や `omega` 等で通ってしまう。`#eval` は `false` を表示しても終了コード 0 で通るため、証拠としては**対象定理の全前提を同時に満たす `example` の証明**と、**対象関数の具体値に対する証明可能な確認（`example` や `#guard`）**を残す。

```lean
-- 例: allocate_preserves_total の前提を満たし、関数自体も期待値を返す具体例
example : ([10, 20, 70] : List Nat).sum > 0 := by decide
example : allocate 100 [10, 20, 70] = [10, 20, 70] := by decide
```

CI ワークフローの雛形は [../assets/lean4-verification.yml](../assets/lean4-verification.yml) を参照する。
