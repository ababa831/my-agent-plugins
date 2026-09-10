---
name: frontend-ui-development
description: WebフロントエンドのGUI/UI実装、画面モック、スクリーンショット再現、デザイン調整、UIリファクタリング、視覚的不具合修正を行うときに適用する。既存コンポーネント、デザイントークン、レイアウト構造を調査し、局所的なCSSパッチの蓄積を防ぐ。EXPLORE / STABILIZE / PRODUCTION の段階に応じて設計の厳密さを調整する。
---

# Frontend UI Development

## 目的

画面を「その瞬間だけ正しく見せる」のではなく、変更を重ねても理解・修正しやすいUI構造を保つ。
ただし、探索用モックでは設計の完成度より試行錯誤の速度を優先し、早すぎる抽象化も避ける。

## 1. 最初に開発フェーズを決める

明示されていればその指定を使う。明示されていなければ要求から推定し、実装方針の中で短く示す。

- **EXPLORE**: 雰囲気、情報設計、導線、レイアウトを試すモック・プロトタイプ。捨てる可能性が高い。
- **STABILIZE**: UIの方向性が固まり、本格的に機能を増やす前に構造を整理する段階。
- **PRODUCTION**: 長期間保守する実装。再利用性、アクセシビリティ、レスポンシブ、テストを重視する。

EXPLORE だから雑でよい、PRODUCTION だから何でも共通化すべき、とは考えない。フェーズは最適化対象を変えるための判断材料である。

## 2. 実装前にコードベースを調査する

UIコードを書き始める前に、必要な範囲で次を確認する。

1. 適用される `AGENTS.md` やプロジェクト固有の指示
2. 使用中のフレームワークとスタイリング方式
3. 既存のUIライブラリ、primitive、共通コンポーネント
4. 色、余白、タイポグラフィ、角丸などのdesign tokenの所在
5. 親レイアウトの flex / grid / gap / padding / sizing
6. Storybook、visual regression、E2Eなど既存の検証方法

新しいUI部品を作る前に、同じ意味・役割を持つ既存部品がないか検索する。

## 3. 変更を置くレイヤーを選ぶ

基本の依存方向は次のとおり。

```text
Design Tokens
    ↓
Generic UI Primitives
    ↓
Domain / Feature Components
    ↓
Pages / Screens
```

判断基準:

- 複数箇所で共有する視覚的な意思決定 → design token
- ドメインを知らない汎用UI → primitive / shared UI component
- 特定ドメインの意味を持つ再利用UI → feature component
- その画面やrouteだけの組み合わせ → page / screen / layout

見た目が似ているだけでは共通化しない。同じ意味・責務で、一緒に進化すべきものを共通化する。

## 4. パッチワークを防ぐ

「3px下げる」「少し右に寄せる」「スクショに合わせる」といった要求でも、最初からローカルCSSを追加しない。

先に以下を確認する。

- 親の `gap` は正しいか
- paddingは正しいか
- flex/grid alignmentは正しいか
- width / min-width / max-width の制約は正しいか
- overflowが原因ではないか
- 共通コンポーネント側の仕様が原因ではないか
- breakpointやレスポンシブ規則が原因ではないか

局所的な `margin-*`、`top/left`、transform、overrideが本当に画面固有の意図なら使ってよい。その場合は局所解である理由を説明する。

原則として避けるもの:

- 既存primitiveと同じ役割の新規component
- 既存tokenで表せるのに追加する生の色・余白・角丸値
- `!important`
- 深いselector chain
- 理由のないz-index増加
- screenshotだけを合わせるための絶対配置やoffset

## 5. フェーズ別の実装方針

### EXPLORE

優先順位は、情報階層、レイアウト、視覚的リズム、操作感、比較の速さ。

- Button / Input / Cardなど既存primitiveがあれば再利用する。
- 一度しか使わない実験値までtoken化しなくてよい。
- 不安定なUIを早く共通化しすぎない。
- 消しやすい、書き換えやすい構造を保つ。
- 巨大な1ファイルや複雑なoverrideの連鎖は作らない。

### STABILIZE

モックへそのまま継ぎ足さず、まず監査する。

1. 重複する意味的UIパターン
2. 繰り返される色・余白・角丸・文字サイズ
3. magic number
4. 局所的なlayout hack
5. duplicate primitive
6. 巨大component
7. accessibility問題
8. responsive問題

監査後、token → primitive → feature → pageの順で必要な整理を行う。

### PRODUCTION

- shared visual decisionはtokenを優先する。
- generic UIはshared primitiveを優先する。
- keyboard操作、focus、label、semantic HTMLなどアクセシビリティを確認する。
- 主要なviewportでresponsive behaviorを確認する。
- 重要なinteractionには既存方針に沿ったテストを追加する。
- 視覚的変更は、利用可能ならStorybookやscreenshot testで確認する。

## 6. AGENTS.mdを整備するとき

ユーザーがフロントエンド用のプロジェクト指示を整備したい場合、`assets/AGENTS.frontend.md` をそのまま盲目的にコピーしない。

1. 対象リポジトリを調査する。
2. 実際のfrontend root、UI component path、token source、検証コマンドを特定する。
3. 既存 `AGENTS.md` があれば矛盾しないよう統合する。
4. monorepoなら必要に応じてfrontend配下のnested `AGENTS.md` として配置する。
5. 不明な項目は推測で固定せず、不要なら削除する。

テンプレート: `assets/AGENTS.frontend.md`

## 7. 完了前の確認

対象リポジトリに存在する範囲で、typecheck、lint、test、visual verificationを行う。

最後に短く説明する。

- 何を変更したか
- どのレイヤーを変更したか
- 新しいtoken / primitiveを作ったか
- 局所overrideを使った場合はなぜ必要だったか

要求達成と設計健全性の両方を確認して完了する。
