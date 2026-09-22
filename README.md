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
    ├── development-rules/      # Git開発共通ルールと証拠に基づく検証
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── claude/hooks.json              # Claude Code 固有の SessionStart hook（git-development-rules の本文を読み込む）
    │   └── skills/
    │       ├── git-development-rules/
    │       └── evidence-driven-engineering/   # references/ に詳細と評価用の例
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
    │   ├── rules/common-rules.mdc         # 常時適用の共通ルール（Cursor rule、Claude Code hook からも読む）
    │   ├── claude/hooks.json              # Claude Code 固有の hook（SessionStart / PreToolUse）
    │   ├── claude/check_banned_words.py   # PreToolUse hook が呼ぶ「正本」検出スクリプト
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
| `development-rules` | `git-development-rules`（Conventional Commits、TDD、PR運用など最小限のGit開発ルール）、`evidence-driven-engineering`（原因診断はコードと観測で裏付ける、実行中の挙動で検証する、検証を再現可能にする、繰り返す指摘を型・lint・CIなどの仕組みで防ぐ、委任とskill評価の進め方）。Claude Code では `git-development-rules` を SessionStart hook で毎セッションに読み込む |
| `frontend-ui-development` | GUI/UIの実装・モック・安定化・視覚的不具合修正で、既存component / design token / layoutを優先しパッチワーク化を防ぐ。Cursorでは `.mdc` rule も同梱 |
| `japanese-writing` | `japanese-tech-writing`（技術文書の文章規範）、`cognitive-rhythm-writing`（認知リズム設計）、`semantic-generation`（対応表先行生成）。常時適用の共通ルール（返信は日本語で書く、「正本」という語を使わない）も同梱し、Cursor では rule、Claude Code では SessionStart hook で読み込む。Claude Code では「正本」を新たに書き込もうとしたときに止める PreToolUse hook も持つ |
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

`japanese-writing` の共通ルール `rules/common-rules.mdc` は `alwaysApply: true` の rule として常に読み込まれる。

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

Codex のプラグインには常時適用の指示を配布する仕組みがない。`japanese-writing` の共通ルール（返信は日本語で書く、など）を Codex でも効かせるには、`plugins/japanese-writing/rules/common-rules.mdc` の本文（frontmatter を除く）をグローバル指示 `~/.codex/AGENTS.md` に追記する。

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

Claude Code にはポータブルなskillsをそのまま配布する。`japanese-writing` は加えて SessionStart hook（`claude/hooks.json`）を持ち、`rules/common-rules.mdc` を毎セッションのコンテキストに追加する。skillが起動しない場面でも共通ルールが効くようにするためである。さらに PreToolUse hook（`claude/check_banned_words.py`）が、Write / Edit / NotebookEdit で「正本」を新たに書き込もうとすると書き込みを止め、言い換えて再実行するよう Claude に伝える。Edit は変更前後の出現回数を比べるので、既存の「正本」を残したまま別の箇所を直す編集は止めない。語そのものに言及する「正本」（かぎ括弧付き）は対象外で、想定外の入力や `python3` がない環境では何もしない。返信本文はファイルに書かれないため検出できない。`development-rules` も SessionStart hook（`claude/hooks.json`）を持ち、`skills/git-development-rules/SKILL.md` の本文（frontmatter を除く）を毎セッションに追加する。`evidence-driven-engineering` は従来どおり skill として必要なときに読み込まれる。`shared-mcp` は、プラグイン直下の `.mcp.json` が Codex 形式なので、Claude Code では `.claude-plugin/plugin.json` に直接記述したサーバ定義を使う。

インストールされたプラグインはキャッシュ（`~/.claude/plugins/cache/`）へのコピーである。内容を変えて `version` を上げたら、`claude plugin marketplace update my-agent-plugins` の後に `claude plugin update <plugin>@my-agent-plugins` で反映する。

## ライセンスと出典

- `japanese-tech-writing` と `cognitive-rhythm-writing` の原型は [k16shikano 氏の public gist](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d)（[認知リズム編](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)）に、ローカルでの調整を加えたもの。作者は [public gist 全体に Unlicense（パブリックドメイン献呈）を適用すると宣言している](https://gist.github.com/k16shikano/67625f2a7d96e3bbdfae8d571a936063)ため、public リポジトリでの再配布・改変に制約はない。
- `semantic-generation` は自作。
- `evidence-driven-engineering` は [unicodef1wn/lauren-poteto-rules](https://github.com/unicodef1wn/lauren-poteto-rules)（MIT License、Copyright (c) 2026 unicodef1wn）を日本語化し、汎用のskillとして再構成したもの。元の原則は [Lauren Tan 氏（@poteto）](https://x.com/poteto)のコーディングエージェントに関する講演に基づく。ライセンス全文は skill 内の `LICENSE` にある。
- `frontend-ui-development` は自作。

## 運用ルール

- スキルの更新はこのリポジトリで行い、各クライアントへはプラグイン経由で配布する。
- クライアント固有要素を Agent Plugins のポータブル要素として偽装しない。Cursor rule は Cursor plugin 側だけで、Claude Code の hook は Claude Code plugin 側だけで扱う。
- シークレットや認証情報をプラグイン内（`mcp.json` の `env` / `headers` を含む）に置かない。仕様上も禁止されている。
- プラグインを変更したら該当 `plugin.json` の `version` を上げる。
- 「正本」禁止の機械的なチェックは、`japanese-writing` の Claude Code 用 PreToolUse hook だけとする。CI・lint・他クライアント向けの仕組みは、ルールと hook では防げない失敗が繰り返し観測されるまで追加しない。
