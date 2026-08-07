# my-agent-plugins

Cursor / Codex で共通利用している設定を、[Agent Plugins 仕様 1.0.0](https://agent-plugins.org/)（[agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)）にならって一元管理する個人リポジトリ。

Agent Plugins v1 がポータブル対象と定めるのは **skills（[Agent Skills 仕様](https://agentskills.io/specification)）** と **MCP サーバ（`mcp.json`）** の2種類だけである。rules・hooks・commands などはクライアント固有領域（拡張ネームスペース）に留まるため、本リポジトリでもこの線引きに従う。

## 構成

```
my-agent-plugins/
├── .cursor-plugin/
│   └── marketplace.json        # Cursor 用マーケットプレイスマニフェスト
├── .agents/
│   └── plugins/
│       └── marketplace.json    # Codex 用マーケットプレイスマニフェスト
└── plugins/
    ├── japanese-writing/       # 日本語ライティング規範スキル集
    │   ├── plugin.json         # Agent Plugins 標準マニフェスト
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   └── skills/
    │       ├── japanese-tech-writing/SKILL.md
    │       ├── cognitive-rhythm-writing/SKILL.md
    │       └── semantic-generation/SKILL.md
    └── shared-mcp/             # 共通 MCP サーバ定義
        ├── plugin.json
        ├── mcp.json            # Agent Plugins 標準スキーマ（transport 明示）
        ├── .cursor-plugin/plugin.json   # Cursor 形式（inline mcpServers）
        ├── .codex-plugin/plugin.json
        └── .mcp.json           # Codex 形式（mcp_servers ラップ）
```

各プラグインは Agent Plugins 標準の root `plugin.json` を正とし、Cursor（`.cursor-plugin/plugin.json`）と Codex（`.codex-plugin/plugin.json`）のクライアント別マニフェストを併置する。スキルの形式は3者で共通なので二重管理は発生しない。MCP のみ各クライアントのスキーマ差分（transport の明示 / 推論、`mcpServers` / `mcp_servers`）を吸収するために形式別ファイルを持つ。

## プラグイン一覧

| プラグイン | 内容 |
| :-- | :-- |
| `japanese-writing` | `japanese-tech-writing`（技術文書の文章規範）、`cognitive-rhythm-writing`（認知リズム設計）、`semantic-generation`（対応表先行生成） |
| `shared-mcp` | `chrome-devtools`（stdio, npx）、`bigquery`（streamable-http）、`huggingface`（streamable-http） |

## 導入方法

### Cursor

リポジトリを Cursor のプラグインとして読み込む。ローカル開発中は次のいずれか。

- `~/.cursor/plugins/local/` 配下に各プラグインディレクトリ（`plugins/japanese-writing` など）をシンボリックリンクまたはコピーする
- リポジトリを Git ホスティングに置き、マーケットプレイスとして参照する（root の `.cursor-plugin/marketplace.json` が一覧を提供する）

### Codex

リポジトリルートをローカルマーケットプレイスとして登録する。

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin list --marketplace my-agent-plugins --json --available
```

その後 `/plugins`（TUI）または ChatGPT デスクトップアプリのプラグイン画面からインストールする。

## ライセンスと出典

- `japanese-tech-writing` と `cognitive-rhythm-writing` の原型は [k16shikano 氏の public gist](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d)（[認知リズム編](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)）に、ローカルでの調整を加えたもの。作者は [public gist 全体に Unlicense（パブリックドメイン献呈）を適用すると宣言している](https://gist.github.com/k16shikano/67625f2a7d96e3bbdfae8d571a936063)ため、public リポジトリでの再配布・改変に制約はない。
- `semantic-generation` は自作。

## 運用ルール

- スキルの更新はこのリポジトリで行い、各クライアントへはプラグイン経由で配布する。
- シークレットや認証情報をプラグイン内（`mcp.json` の `env` / `headers` を含む）に置かない。仕様上も禁止されている。
- プラグインを変更したら該当 `plugin.json` の `version` を上げる。
