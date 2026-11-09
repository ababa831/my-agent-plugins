---
name: frontend-ui-development
description: Web GUI/UIの実装、画面モック、スクリーンショット再現、視覚調整、UIリファクタリング、visual bug修正で使う。Astryx design systemを既定のデザイン規約とし、Astryx MCP（search/get）とCLIでtemplate・component・tokenを確認してから組み立て、継ぎ接ぎのUIを防ぐ。backend-onlyの変更には使わない。
---

# Frontend UI Development

## 目的

UIをその場しのぎのパッチの集合にしない。
既定のデザイン規約は [Astryx](https://github.com/meta/astryx) とし、画面ごとに独自のcomponent・余白・色を発明せず、Astryxのtemplate、component、design tokenで統一的に組み立てる。
このskillは判断のための既定値であり、固定手順ではない。

## 指示の扱い

- 明示的なタスク指示、適用される `AGENTS.md`、既存リポジトリのhard constraintを優先する。
- プロジェクトに `astryx init` が生成した `<!-- ASTRYX:START -->` ブロックがあれば、そのバージョンに合わせた内容としてこのskillより優先する。
- このskillを理由に、不要な承認待ち、過剰な調査、要求範囲の拡大を行わない。

## Astryxを使うかの判断

| プロジェクトの状態 | 方針 |
| :-- | :-- |
| `@astryxdesign/core` を使っている | Astryxの規約に従う。 |
| 新規UI、またはReact 19+でdesign systemがまだない | Astryxで作る。導入は `references/astryx.md` の「導入」を参照する。 |
| 別のdesign system / component libraryが定着している | Astryxを部分的に混ぜない。混在こそ継ぎ接ぎの原因になる。既存の規約に従い、移行はユーザーが求めたときに画面単位で行う。 |
| React以外（Vue、Svelteなど） | Astryxは使えない。既存のcomponentとtokenを基準に、下記の一般原則だけを適用する。 |

## Astryxの情報源

componentのpropやimport pathを記憶や推測で書かない。次の順で確認する。

1. **Astryx MCP**（このプラグインが `astryx` サーバとして接続する）: `search("<やりたいこと>")` で候補を探し、`get("<Name>")` でprops・例・install commandを読む。
2. **プロジェクトのCLI**: プロジェクトにinstall済みのバージョンを答えるので、MCPと食い違ったらこちらを優先する。`astryx build "<idea>"`、`astryx template`、`astryx component <Name>`、`astryx docs <topic>` を使う。
3. MCPもCLIも使えないときは、その旨を伝え、確認できないpropを推測で埋めない。

## Astryxの規約

詳細とCLI手順は `references/astryx.md` を参照する。中核は次のとおり。

- **ページはtemplateから始める**: 新しいページは `astryx build` が示すtemplateをscaffoldし、frame・gap・paddingを保って中身を置き換える。既存ページの変更ではtemplateを作り直さず、そのsectionの中にblock/componentを追加する。
- **componentが扱う範囲はcomponentで書く**: 生の `<div>` / `<span>` でlayoutや見た目を組まない。layoutと余白はStack系などのcomponentに任せる。
- **値はtokenで書く**: 色・余白・角丸・影に生のhex/pxを書かない。`style={{…}}` やimportした独自CSS、`:root` の上書きで見た目を変えない。色やpaletteの変更はthemeで行う。
- **スタイルの優先順**: componentのprop → プロジェクトで有効なstyling方式（StyleXなら `xstyle`、Tailwindならtokenに対応したutility、どちらもなければ `var(--color-*|--spacing-*|--radius-*)`）。
- **密なデータは行で表す**: 一覧は Table や List/Item で表し、各行をCardで包まない。Badgeは件数や列挙状態に限る。
- **propを発明しない**: 使う前に `get` / `astryx component` で読む。formは制御コンポーネント（`value` + `onChange`）、遷移は `useLinkComponent()` を使う。
- **仕上げのself-check**: 書き終えたファイルを読み直し、生の要素、`style={{…}}`、独自CSS、hex/pxの直書きをcomponentかtokenに置き換える。

## 構造で直す

位置ずれや見た目の不具合では、すぐに `margin-*`、`top/left`、transform、selector overrideを足さない。templateのframe、親のStack/gap、component propを先に確認する。templateのframeを変える前に `astryx docs layout` を読む。

Astryxで足りない部分を自作する場合は、次の依存方向を保つ。

```text
Astryx tokens / theme
    ↓
Astryx components（必要ならswizzleして所有する）
    ↓
Domain / Feature Components
    ↓
Pages / Screens（Astryx templateから始める）
```

同じ役割のAstryx componentがあるなら、似た汎用componentを自作しない。`!important`、深いselector chain、理由のないz-index増加は避ける。

## 開発フェーズ

必要な場合だけ、要求と既存コードからフェーズを判断する。フェーズはAstryxの規約を緩めるものではなく、どこまで作り込むかを変える。

- **EXPLORE**: templateとcomponentを差し替えながら、情報設計と導線を素早く試す。新規GUIや大きなredesignでは `references/visual-design.md` を参照する。
- **STABILIZE**: 採用するUIの暫定実装を整理する。観点は `references/stabilization.md` を参照する。
- **PRODUCTION**: accessibility、responsive behavior、状態（empty/loading/error）、重要interactionのテストを確認する。

## 検証

変更に比例した、最小限で意味のある検証を行う。

- リポジトリで必須とされるcheckは実行する。
- 納品前にプロジェクトのCLIが対応していれば `astryx doctor --built <dir>` を実行し、失敗したまま納品しない。
- 見た目の変更は、利用可能ならbrowser / Storybook / screenshotで対象範囲を確認する。
- 関連checkが通ったら、具体的な理由なく検証範囲を広げたり繰り返したりしない。

## AGENTS.mdを整備するとき

Astryxを使うプロジェクトでは `astryx init --features agents` でバージョンに合ったルールを `AGENTS.md`（Claude Codeでは `CLAUDE.md` にも）へ書き込む。
それ以外のproject factsは `assets/AGENTS.frontend.md` を雛形に、実際のpath、theme、styling方式、検証commandだけを記録する。一般原則を再掲しない。

## 完了時

必要な場合だけ、使ったtemplate、新しく自作したcomponent、tokenで表せず例外にした箇所など、後から判断理由を理解するために有用な点を短く説明する。
