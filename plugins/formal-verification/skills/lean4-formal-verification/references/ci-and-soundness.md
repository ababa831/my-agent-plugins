# CI と証明健全性監査

Lean 4 を開発ループと CI に組み込むときは、「AI が証明を書いたつもりでも抜け道が残っていないか」を決定論的に検査する。

## なぜ素朴な `grep sorry` だけでは不十分か

1. コメント・文字列リテラル内の `"sorry"` で誤検知する。
2. `admit`（`sorry` と同様に証明を放棄するタクティク）を見逃す。
3. 新規の `axiom foo : ...` を宣言して使っても `sorry` は出現しない。
4. `unsafe`、`@[implemented_by ...]`、`@[extern ...]`、`Lean.ofReduceBool`（`native_decide` 由来）などの信頼境界を拡張する構文を見逃す。

## 推奨する多層ゲート

### 1. ツールチェイン固定（`lean-toolchain`）

- 対象プロジェクト直下（例: `specs/lean-toolchain`）に Lean 4 のバージョンを 1 行で固定する（例: `leanprover/lean4:v4.14.0`）。
- CI では `elan` を `--default-toolchain none` で導入し、`lean-toolchain` が指定する版を自動取得させる。

### 2. ビルド警告のエラー化

`lakefile.lean` / `lakefile.toml` で `warningAsError`（またはビルド引数 `-DwarningAsError=true`）を有効にすると、`declaration uses 'sorry'` 警告をコンパイラ自身がエラーとして落とす。

```toml
# lakefile.toml の例（プロジェクトの形式に合わせる）
[leanOptions]
warningAsError = true
```

探索中に一時的な `sorry` を使いたい場合は、ローカルビルド時だけオプションを外せるよう、CI 側で `lake build -- -DwarningAsError=true` を渡す構成にしてもよい。

### 3. 公理監査ファイル（`Audit.lean`）

公開したいすべての定理を列挙した監査用ファイルを置き、CI で実行・検査する。

```lean
-- specs/Specs/Audit.lean の例
import Specs.Allocate

#print axioms Specs.allocate_preserves_total
```

`lean --stdin` または `lake env lean Specs/Audit.lean` の出力を CI で検査し、次のルールで合否を判定する。

- **許可される標準公理のみを通す**: `propext`、`Classical.choice`、`Quot.sound`（および計算上必要な場合に明示合意された `Lean.ofReduceBool` / `Lean.trustCompiler`）。
- **即失敗とするもの**:
  - `sorryAx` が含まれている
  - プロジェクトが許可リストに載せていないカスタム `axiom` が含まれている
  - `theorem ... uses sorry` 等の警告が出ている

### 4. 仕様モジュール内の信頼境界スキャン（補助チェック）

純粋な仕様・証明モジュール（Level 2 の薄い CLI/IO ラッパーを除くディレクトリ）に対して、`axiom `、`unsafe`、`@[implemented_by`、`@[extern`、`admit` の出現を検査し、意図しない混入がないかを確認する。`#print axioms` 監査と併用することで、コメント誤検出を避けつつ抜け道を塞げる。

### 5. 空虚な真（vacuous truth）の確認

仕様ファイルに、仮定を実際に満たす具体的な入力例を最低 1 つ置く。

```lean
example : ([1, 2, 3] : List Nat).sum > 0 := by decide
```

仮定同士が矛盾していると、どんな定理も `exfalso` や `omega` 等で簡単に証明が通ってしまう。`example` / `#eval` が通ることで「前提を満たす正当なデータが存在する」ことを可視化できる。

## CI ワークフローとキャッシュの要点

- 雛形は [../assets/formal-verification.yml](../assets/formal-verification.yml) を参照する。
- Mathlib など重い依存を使わない小さな `specs/` では、`~/.elan` と `specs/.lake` のキャッシュだけでも十分高速に回る。Mathlib 等に依存する場合は `lake exe cache get || true` を併用する。
- CI では `permissions: contents: read` と `persist-credentials: false` を付け、必要最小限の権限で実行する。
