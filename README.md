# my-agent-plugins

[English version](README.en.md)

Cursor / Codex / Claude Code で共通利用している設定を、[Agent Plugins 仕様 1.0.0](https://agent-plugins.org/)（[agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)）にならって一元管理する個人リポジトリ。

Agent Plugins v1 がポータブル対象と定めるのは **skills（[Agent Skills 仕様](https://agentskills.io/specification)）** と **MCP サーバ（`mcp.json`）** の2種類だけである。rules・hooks・commands などはクライアント固有領域（拡張ネームスペース）に留まるため、本リポジトリでもこの線引きに従う。

## 構成

```text
my-agent-plugins/
├── AGENTS.md                   # このリポジトリ自体を編集するエージェント向け指示
├── .cursor-plugin/
│   └── marketplace.json        # Cursor 用マーケットプレイスマニフェスト
├── .claude-plugin/
│   └── marketplace.json        # Claude Code 用マーケットプレイスマニフェスト
├── .agents/
│   └── plugins/
│       └── marketplace.json    # Codex 用マーケットプレイスマニフェスト
└── plugins/
    ├── development-rules/      # Git開発共通ルール
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   └── skills/git-development-rules/
    ├── frontend-ui-development/ # GUI/UI開発ガードレール
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/frontend-ui-guardrails.mdc   # Cursor 固有の常駐ルール
    │   └── skills/frontend-ui-development/
    │       ├── SKILL.md
    │       └── assets/AGENTS.frontend.md      # 対象リポジトリ用テンプレート
    ├── japanese-writing/       # 日本語ライティング規範スキル集
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── claude/                        # Claude Code 固有の SessionStart hook と共通ルール
    │   └── skills/
    │       ├── japanese-tech-writing/SKILL.md
    │       ├── cognitive-rhythm-writing/SKILL.md
    │       └── semantic-generation/SKILL.md
    └── shared-mcp/             # 共通 MCP サーバ定義
        ├── plugin.json
        ├── mcp.json
        ├── .cursor-plugin/plugin.json
        ├── .codex-plugin/plugin.json
        ├── .claude-plugin/plugin.json   # Claude Code 用に MCP を直接記述
        └── .mcp.json
```

各プラグインは Agent Plugins 標準の root `plugin.json` を正とし、Cursor（`.cursor-plugin/plugin.json`）、Codex（`.codex-plugin/plugin.json`）、Claude Code（`.claude-plugin/plugin.json`）のクライアント別マニフェストを併置する。skills は共通形式のまま共有する。Cursor 固有の rules は `rules/` に置き、`.cursor-plugin/plugin.json` からのみ配布する。Claude Code 固有の hook は `claude/` に置き、`.claude-plugin/plugin.json` からのみ配布する。MCP はクライアント間のスキーマ差分を吸収するために形式別ファイルを持つ。

## プラグイン一覧

| プラグイン | 内容 |
| :-- | :-- |
| `development-rules` | Git開発で共通利用する最小限のルール（Conventional Commits、TDD、PR運用など） |
| `frontend-ui-development` | GUI/UIの実装・モック・安定化・視覚的不具合修正で、既存component / design token / layoutを優先しパッチワーク化を防ぐ。Cursorでは `.mdc` rule も同梱 |
| `japanese-writing` | `japanese-tech-writing`（技術文書の文章規範）、`cognitive-rhythm-writing`（認知リズム設計）、`semantic-generation`（対応表先行生成）。Claude Code では SessionStart hook で共通ルール（「正本」という語を使わない、など）を毎セッションに読み込ませる |
| `shared-mcp` | `chrome-devtools`（stdio, npx）、`bigquery`（streamable-http）、`huggingface`（streamable-http） |

## 導入方法

### Cursor

`~/.cursor/plugins/local/` 配下に各プラグインディレクトリをシンボリックリンク（またはコピー）し、Cursor を再起動する（**Developer: Reload Window** でもよい）。

```bash
ln -s /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/development-rules
ln -s /path/to/my-agent-plugins/plugins/frontend-ui-development ~/.cursor/plugins/local/frontend-ui-development
ln -s /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/japanese-writing
ln -s /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/shared-mcp
```

読み込まれたか確認するには、サイドバーの **Customize** で rules・skills・MCP サーバの一覧を見る。

`frontend-ui-development` では、ポータブルな `SKILL.md` に加えて Cursor 用の `rules/frontend-ui-guardrails.mdc` を配布する。対象プロジェクト固有の情報は、skill に含まれる `assets/AGENTS.frontend.md` を元に、そのプロジェクトの `AGENTS.md` へ適応して記述する。

チームに配布する場合は、Teams / Enterprise プランの Team Marketplace（**Dashboard → Plugins** で本リポジトリを Import from Repo）を使う。root の `.cursor-plugin/marketplace.json` がプラグイン一覧を提供する。

### Codex

リポジトリルートをローカルマーケットプレイスとして登録し、CLI からインストールする。

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin list --marketplace my-agent-plugins --json --available   # カタログ確認
codex plugin add development-rules@my-agent-plugins
codex plugin add frontend-ui-development@my-agent-plugins
codex plugin add japanese-writing@my-agent-plugins
codex plugin add shared-mcp@my-agent-plugins
```

`codex` 内の `/plugins`（プラグインブラウザ）や ChatGPT デスクトップアプリのプラグイン画面からもインストールできる。バンドルされたskills・MCPサーバは、インストール後に**新しいセッションを開始してから**有効になる。

Codex では Agent Plugins のポータブルskillを利用する。Cursor固有の `.mdc` ruleはCodexには配布せず、プロジェクト固有の常駐指示が必要な場合は `AGENTS.md` を使う。

インストールされたプラグインはキャッシュ（`~/.codex/plugins/cache/`）へのコピーなので、プラグインの内容を更新したら再インストール（`codex plugin remove` → `codex plugin add`）で反映する。なお `codex plugin marketplace upgrade` は Git ソースのマーケットプレイス専用で、ローカル登録には効かない。

### Claude Code

リポジトリルートをローカルマーケットプレイスとして登録し、プラグインをインストールする。

```bash
claude plugin marketplace add /path/to/my-agent-plugins
claude plugin install development-rules@my-agent-plugins
claude plugin install frontend-ui-development@my-agent-plugins
claude plugin install japanese-writing@my-agent-plugins
claude plugin install shared-mcp@my-agent-plugins
```

`claude` 内の `/plugin` からも同じ操作ができる。既定の user スコープでインストールすれば、どのプロジェクトでもskillsが使える。

Claude Code にはポータブルなskillsをそのまま配布する。`japanese-writing` は加えて SessionStart hook（`claude/hooks.json`）を持ち、`claude/common-rules.md` を毎セッションのコンテキストに追加する。skillが起動しない場面でも共通ルールが効くようにするためである。`shared-mcp` は、プラグイン直下の `.mcp.json` が Codex 形式なので、Claude Code では `.claude-plugin/plugin.json` に直接記述したサーバ定義を使う。

インストールされたプラグインはキャッシュ（`~/.claude/plugins/cache/`）へのコピーである。内容を変えて `version` を上げたら、`claude plugin marketplace update my-agent-plugins` の後に `claude plugin update <plugin>@my-agent-plugins` で反映する。

## ライセンスと出典

- `japanese-tech-writing` と `cognitive-rhythm-writing` の原型は [k16shikano 氏の public gist](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d)（[認知リズム編](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)）に、ローカルでの調整を加えたもの。作者は [public gist 全体に Unlicense（パブリックドメイン献呈）を適用すると宣言している](https://gist.github.com/k16shikano/67625f2a7d96e3bbdfae8d571a936063)ため、public リポジトリでの再配布・改変に制約はない。
- `semantic-generation` は自作。
- `frontend-ui-development` は自作。

## 運用ルール

- スキルの更新はこのリポジトリで行い、各クライアントへはプラグイン経由で配布する。
- クライアント固有要素を Agent Plugins のポータブル要素として偽装しない。Cursor rule は Cursor plugin 側だけで、Claude Code の hook は Claude Code plugin 側だけで扱う。
- シークレットや認証情報をプラグイン内（`mcp.json` の `env` / `headers` を含む）に置かない。仕様上も禁止されている。
- プラグインを変更したら該当 `plugin.json` の `version` を上げる。
