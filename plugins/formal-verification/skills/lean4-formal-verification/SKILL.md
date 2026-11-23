---
name: lean4-formal-verification
description: Lean 4 による形式検証の導入設計、仕様・不変条件のモデル化、証明の実装、実行可能オラクルを用いた差分テスト、および検証 CI の構築で使う。対象リポジトリに lean-toolchain または lakefile.lean / lakefile.toml があり Lean 4 の検証対象を扱うとき、または高リスクなコアロジック・状態遷移・権限/PIIポリシー・データ整合性ルールへの形式検証を明示的に求められたときに適用する。通常の機能開発、UI変更、typo修正、単体テストや型チェックで十分な変更には使わない。
---

# Lean 4 Formal Verification

## 目的

確率的にコードを生成する AI と、決定論的に正しさを検査する Lean 4 カーネルの役割を分離し、人間のレビュー対象を「仕様（定理文・参照する定義・前提条件）」へ集約する。
この skill は判断のための既定値であり、固定手順ではない。

## 適用の判断と手法の境界

- **使う場面**:
  - 対象リポジトリ（または作業対象サブディレクトリ）に `lean-toolchain`、`lakefile.lean`、`lakefile.toml` が存在し、Lean 4 の検証対象に関わる変更や確認を行うとき。
  - 壊れたときの損失が大きい最小核（金額保存則、課金・サブスク状態遷移、PII/アクセス制御ポリシー、パイプライン冪等性、ID 名寄せ整合性など）に対し、形式検証や数学的保証が明示的に求められているとき。
- **使わない場面**:
  - 通常の CRUD、UI 変更、設定ファイルやドキュメントの修正、typo 修正、型・lint・単体テスト・通常のプロパティベーステスト（PBT）で十分に防げる変更（リポジトリ内に Lean 4 プロジェクトが存在しても、無関係な通常変更には使わない）。
  - Lean 4 が未導入のリポジトリで、依頼なしに `lean-toolchain` や `specs/` を新設しない。
- **モデル検査（TLA+ 等）との境界**:
  - Lean 4 は純粋関数的な計算ロジック、代数的不変条件、状態遷移の安全性（safety）、実行可能バイナリを使ったオラクル差分テストに適する。
  - 分散合意、非同期メッセージのインターリーブ、分散相互排除などの並行プロトコルの安全性・活性（liveness）・デッドロックには、**TLA+ でモデルを記述し TLC モデル検査器で検査する**手法の方が低コストで有効なことが多い（TLC の結果は設定した有限構成と公平性の仮定に依存する）。無理に Lean 4 を当てはめず、手法の選定を先に確認する。
- **優先順位と重複回避**:
  - 明示的なタスク指示と対象リポジトリの `AGENTS.md` を優先する。
  - 制約を独断で緩めない原則や証拠に基づく検証の一般則は `git-development-rules` と `evidence-driven-engineering` に従い、ここでは繰り返さない。

## 3 段階の導入モデル

コードベース全体を形式化しようとせず、問題に見合う最小の段階を選ぶ。

| 段階 | 概要 | 主な用途・始めやすさ |
| :-- | :-- | :-- |
| **Level 1: 仕様・不変条件の検証** | 実装コードと独立して `specs/` 等に状態遷移・ポリシー・検証済みチェッカーを書き、`lake build --wfail` と公理監査を CI ゲートにする | 導入コスト最小。メタデータスナップショットの権限・PII 検査（DM）や状態設計の第一歩に最適 |
| **Level 2: オラクル差分テスト** | Level 1 で証明した計算可能な Lean 4 定義をバイナリ化し、同一のランダム入力・境界値に対する出力を実実装（Python / TS / SQL 等）と CI で突合する | 実務で最も投資対効果が高い。「仕様は正しいが実装がバグる」ギャップを潰す（AE / DE 等） |
| **Level 3: 実装コードの直接検証** | Rust 等の実装を Aeneas 等で Lean 4 へ持ち上げて証明する | 暗号・パーサー等の極限クリティカルパス限定。明示合意なしに選ばない |

## 人間とエージェントの責務境界

- **人間が確定・レビューする領域**: 切り出す最小核の範囲、定理文（型シグネチャと不変条件）、定理文が参照する主要定義（`def Invariant := True` 等の空洞化がないか）、モデル化で割り切った前提（浮動小数点→整数スケーリング、`NULL` 扱い等）。
- **エージェントが担う領域**: モデルと定理文の提案、補題分解とタクティク探索による証明完成（`lake build` 反復）、オラクル差分テスト基盤と CI の構築。
- **仕様変更時の事前合意**: 仕様を新しく設計するとき、または既存の定理文・前提を実質的に変えるときは、証明に着手する前に人間が読める形で定理文・主要定義・前提・対象外を提示して合意する（すでに確定済みの仕様に対する証明実装で不要な確認待ちを増やさない）。

## 証明の健全性（ごまかしの禁止）

- **未証明・回避手段の禁止**: 完了時点で `sorry`、`admit`、未承認のカスタム `axiom`、計算核や仕様モデル内の `unsafe` / `@[implemented_by]` / `@[extern]`、無断の `native_decide`、`set_option debug.skipKernelTC true` 等を残さない。
- **仕様変更の禁止**: ビルドを通すために定理の結論を弱めたり前提条件を勝手に強めたりしない。証明できない場合は、原因・反例候補・対応選択肢とトレードオフを示して判断を仰ぐ。
- **空虚な真（vacuous truth）の防止**: 仮定が矛盾してどんな結論も通ってしまう状態を防ぐため、対象定理の**全前提を同時に満たす `example` の証明**（および対象関数の具体値チェック）を用意する。`#eval` は `false` でも終了コード 0 になるため単独で証拠にしない。
- **CI ゲートの設計**: `lake build -- -DwarningAsError=true` は引数が渡らないため使わず、`lake build --wfail`（または `weakLeanArgs`）と、許可リスト（`propext`, `Classical.choice`, `Quot.sound`）完全一致による fail-closed な公理監査（`leanprover/lean-action` の `axiom-audit` や厳格な `#print axioms` 検査）を組み合わせる。

## 詳細リファレンスとテンプレート

- **CI と健全性監査**（`--wfail` / `weakLeanArgs`、`axiom-audit` / `#print axioms` 監査、実行時経路の確認）: [references/ci-and-soundness.md](references/ci-and-soundness.md)
- **Level 2 オラクル差分テスト**（計算可能定義と CLI/IO 境界、PBT 連携、整数・丸め・`NULL` の罠）: [references/differential-testing.md](references/differential-testing.md)
- **データ領域パターン（DE / DM / AE）**（冪等性・名寄せ、PII スナップショット検査、按分・MRR）: [references/data-domain-patterns.md](references/data-domain-patterns.md)
- **失敗例と評価ケース**: [references/examples.md](references/examples.md)
- **CI / `AGENTS.md` テンプレート**: [assets/lean4-verification.yml](assets/lean4-verification.yml)、[assets/AGENTS.formal-verification.md](assets/AGENTS.formal-verification.md)

## 検証と完了報告

- リポジトリにある実際のコマンドで `lake build --wfail`、公理監査、設定された差分テストを実行し、通過を確かめてから完了とする。
- 完了時はタクティクの細部ではなく、**証明した定理一覧（自然言語の仕様訳つき）**、**依存公理の監査結果**、**実装との突合方法（Level 1 / Level 2）**、**モデル化の前提と対象外**を報告する。
