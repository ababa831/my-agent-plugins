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
    │       └── cognitive-rhythm-writing/SKILL.md
    └── shared-mcp/             # 共通 MCP サーバ定義
        ├── plugin.json
        ├── mcp.json            # Agent Plugins 標準スキーマ（transport 明示）
        ├── .cursor-plugin/plugin.json   # Cursor 形式（inline mcpServers）
        ├── .codex-plugin/plugin.json
        └── .mcp.json           # Codex 形式（mcp_servers ラップ）
```

各プラグインは Agent Plugins 標準の root `plugin.json` を正とし、Cursor（`.cursor-plugin/plugin.json`）と Codex（`.codex-plugin/plugin.json`）のクライアント別マニフェストを併置する。スキルの形式は3者で共通なので二重管理は発生しない。MCP のみ各クライアントのスキーマ差分（transport の明示 / 推論、`mcpServers` / `mcp_servers`）を吸収するために形式別ファイルを持つ。

## プラグイン一覧

| プラグイン | 内容 | 元の場所 |
| :-- | :-- | :-- |
| `japanese-writing` | `japanese-tech-writing`（技術文書の文章規範）、`cognitive-rhythm-writing`（認知リズム設計）| `~/.codex/skills/`（Codex 専用だった自作スキルを共通化） |
| `shared-mcp` | `chrome-devtools`（stdio, npx）、`bigquery`（streamable-http）、`huggingface`（streamable-http） | `~/.cursor/mcp.json` と `~/.codex/config.toml` で二重管理されていた定義を統合 |

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

## 共通化の判断（棚卸し結果）

### 取り込んだもの

- `~/.codex/skills/japanese-tech-writing`・`cognitive-rhythm-writing`：自作（gist 由来 + ローカル調整）。Codex にしかなく、Cursor でも使うため共通化。
- `~/.cursor/mcp.json` の `chrome-devtools` / `bigquery` / `huggingface`：`chrome-devtools` は Codex の `config.toml` にも重複定義があった。プラグイン化で一元管理する。

### 取り込み待ち（ローカルマシンからのコピーが必要）

- `~/.codex/skills/semantic-generation/`：自作スキルだが出典がなく、この環境からは本文を復元できない。ローカルの当該ディレクトリを `plugins/japanese-writing/skills/semantic-generation/` にコピーすれば完了する（`agents/openai.yaml` を含む）。

### 意図的に除外したもの

- **ベンダー配布スキル**（`~/.codex/skills/` の Google Cloud 系・セキュリティレビュー系・pdf・playwright、`~/.cursor/skills-cursor/` の Cursor 組込スキル、各種プラグイン cache）：配布元から再インストール可能で、自分の成果物ではない。
- **`~/.agents/skills/agmsg`**：実行時状態（SQLite DB・run ディレクトリ）を内包し、Codex の `sandbox_workspace_write.writable_roots` が現在の絶対パスを参照している。移動すると動作が壊れるため現行配置のまま運用する（`~/.agents/skills/` 自体が両クライアント共通のスキル読込先であり、すでに共通化されている）。
- **`~/.codex/AGENTS.md`・Cursor User Rules・`config.toml` の承認ポリシー等**：Agent Plugins v1 は rules / hooks / commands を意図的にポータブル対象外としている（クライアント間で形式が収束していないため）。各クライアント側で管理を続ける。
- **MCP の `node_repl` / `openaiDeveloperDocs`**：ChatGPT アプリ同梱・Codex 固有のため対象外。

## 運用ルール

- スキルの更新はこのリポジトリで行い、各クライアントへはプラグイン経由で配布する（`~/.codex/skills/` 等の直置きコピーは段階的に削除する）。
- シークレットや認証情報をプラグイン内（`mcp.json` の `env` / `headers` を含む）に置かない。仕様上も禁止されている。
- プラグインを変更したら該当 `plugin.json` の `version` を上げる。
