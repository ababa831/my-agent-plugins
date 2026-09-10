---
name: frontend-ui-development
description: Web GUI/UIの実装、画面モック、スクリーンショット再現、視覚調整、UIリファクタリング、visual bug修正で使う。既存のコンポーネント・design token・layout規約を尊重しつつ、探索速度と長期保守性のバランスを取る。backend-onlyの変更には使わない。
---

# Frontend UI Development

## 目的

UIをその場しのぎのパッチの集合にせず、要求された速度と品質に応じて、既存の設計を活かした変更を行う。
このskillは判断のための既定値であり、固定手順ではない。

## 指示の扱い

- 明示的なタスク指示、適用される `AGENTS.md`、既存リポジトリのhard constraintを尊重する。
- このskillを理由に、不要な承認待ち、過剰な調査、要求範囲の拡大を行わない。
- 下記の確認項目を機械的にすべて実行せず、要求に必要な範囲だけ調査する。

## 開発フェーズ

必要な場合だけ、要求と既存コードからフェーズを判断する。明示されていなければ、通常は内部判断に留める。

- **EXPLORE**: 雰囲気、情報設計、導線、layoutを素早く試す。
- **STABILIZE**: 採用するUIが見えてきた段階で、繰り返しパターンと暫定実装を整理する。
- **PRODUCTION**: 長期保守、accessibility、responsive behavior、testabilityを重視する。

フェーズは手順ではなく最適化対象を変える判断材料である。

## コア原則

### 既存設計を優先する

既存UIを変更するときは、必要な範囲で周辺コードを調べ、次を壊さないようにする。

- 既存のUI primitive / component API
- design token / theme
- styling方式
- layout規約
- 既存の検証方法

同じ意味・責務のcomponentがあるなら再利用または自然に拡張する。見た目が似ているだけでは共通化しない。

### 適切なレイヤーへ変更を置く

基本の依存方向:

```text
Design Tokens
    ↓
Generic UI Primitives
    ↓
Domain / Feature Components
    ↓
Pages / Screens
```

共有される視覚的意思決定はtoken、汎用UIはprimitive、domain semanticsを持つ再利用UIはfeature、画面固有の組み合わせはpage/layoutを優先する。

### 局所パッチより構造を確認する

位置ずれや見た目の不具合では、すぐに `margin-*`、`top/left`、transform、selector overrideを足さず、関連する親layout、gap、padding、alignment、sizing、overflow、responsive rule、shared componentを必要に応じて確認する。

局所overrideが本当に画面固有の意図なら使用してよい。`!important`、深いselector chain、理由のないz-index増加、duplicate primitiveは原則避ける。

## フェーズ別の重み付け

### EXPLORE

速度、情報階層、visual direction、操作感を優先する。一度しか使わない実験値や小さな一時的重複は許容し、不安定なUIを早く抽象化しすぎない。消しやすく書き換えやすい構造を保つ。

新規GUIや大きなvisual redesignでは、必要に応じて `references/visual-design.md` を参照する。

### STABILIZE

モックへ継ぎ足す前に、安定した繰り返しパターンと暫定実装を整理する。詳細な監査観点は `references/stabilization.md` を参照する。

### PRODUCTION

既存tokenとshared primitiveを共有判断の基準にし、必要なaccessibility、responsive behavior、重要interactionの自動テストを確認する。

## 検証

変更とフェーズに比例した、最小限で意味のある検証を行う。

- リポジトリで必須とされるcheckは実行する。
- 小さく可逆なvisual changeのために、理由なく広いtest suiteを追加・実行しない。
- 見た目の変更は、利用可能なら対象範囲のbrowser / Storybook / screenshot確認を優先する。
- 関連checkが通ったら、具体的な理由なく検証範囲を広げたり繰り返したりしない。

## AGENTS.mdを整備するとき

`assets/AGENTS.frontend.md` はproject factsを記録するためのテンプレートとして使う。
一般的なfrontend設計原則を `AGENTS.md` に再掲せず、実際のpath、library、styling方式、検証command、repo固有constraintだけを記録する。

## 完了時

必要な場合だけ、変更したレイヤー、新しいtoken/component、例外的なlocal overrideなど、後から判断理由を理解するために有用な点を短く説明する。
