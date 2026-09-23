# my-agent-plugins

[English version](README.en.md)

Cursor / Codex / Claude Code で共通利用するエージェント向け設定（スキル・MCP）を、[Agent Plugins 仕様 1.0.0](https://agent-plugins.org/)（[agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)）に基づいて一元管理する個人リポジトリです。

---

## 主な特徴

- **マルチクライアント対応**: Cursor、Codex、Claude Code の3大エージェント環境にワンストップでプラグインを配布。
- **仕様準拠のクリーンな設計**: 移植可能なポータブル機能（Agent Skills / MCP）とクライアント固有拡張（ルール / フック）を明確に分離。
- **実践的なスキル集を同梱**: Git開発規約、フロントエンドガードレール、日本語ライティング規範、共通MCPを初期提供。

---

## プラグイン一覧

| プラグイン | 概要 | 主な機能 / スキル |
| :-- | :-- | :-- |
| [`development-rules`](plugins/development-rules/) | Git開発共通ルール & 証拠駆動検証 | `git-development-rules`, `evidence-driven-engineering` |
| [`frontend-ui-development`](plugins/frontend-ui-development/) | フロントエンドUI実装ガードレール | `frontend-ui-development`, Cursor rules, テンプレート |
| [`japanese-writing`](plugins/japanese-writing/) | 日本語技術文書の品質向上 & 共通規約 | `japanese-tech-writing`, `cognitive-rhythm-writing`, `semantic-generation`, 共通ルール |
| [`shared-mcp`](plugins/shared-mcp/) | 共通 MCP サーバ定義 | Chrome DevTools, BigQuery, Hugging Face |

各プラグインの詳細な機能・動作仕様については [プラグイン詳細仕様 (docs/plugins.md)](docs/plugins.md) を参照してください。

---

## クイックスタート

各クライアントでの最小限の導入手順です。詳細な設定手順、フックの挙動、アップデート方法については [クライアント別詳細導入ガイド (docs/installation.md)](docs/installation.md) をご覧ください。

### Cursor

リンク先が `~/.cursor/plugins/local/` 内に解決する場合だけシンボリックリンクを使用してください。外部パスを指す場合はコピーし、Cursor を再起動します。

```bash
mkdir -p ~/.cursor/plugins/local
cp -R /path/to/my-agent-plugins/plugins/<plugin-name> ~/.cursor/plugins/local/
```

### Codex

リポジトリルートをローカルマーケットプレイスとして登録し、CLI からプラグインを追加します。

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin add <plugin-name>@my-agent-plugins
```

### Claude Code

リポジトリルートをローカルマーケットプレイスとして登録し、プラグインをインストールします。

```bash
claude plugin marketplace add /path/to/my-agent-plugins
claude plugin install <plugin-name>@my-agent-plugins
```

---

## リポジトリ構成

```text
my-agent-plugins/
├── docs/                # 詳細ドキュメント群（設計・導入ガイド・仕様・運用ルール）
├── plugins/             # 各プラグインの実装本体（skills, rules, hooks, mcp）
├── .cursor-plugin/      # Cursor 用マーケットプレイスマニフェスト
├── .claude-plugin/      # Claude Code 用マーケットプレイスマニフェスト
└── .agents/plugins/     # Codex 用マーケットプレイスマニフェスト
```

設計思想や各マニフェストの管理方針については [アーキテクチャと設計方針 (docs/architecture.md)](docs/architecture.md) を参照してください。

---

## ドキュメント一覧

- [アーキテクチャと設計方針](docs/architecture.md) - プラグイン設計思想、境界線、完全なディレクトリツリー
- [クライアント別詳細導入ガイド](docs/installation.md) - 各エディタでの詳しい設定、フックの仕様、更新手順
- [プラグイン詳細仕様](docs/plugins.md) - 収録されている各プラグインおよびスキルの詳細解説
- [リポジトリ運用ルールと規約](docs/guidelines.md) - 開発・更新手順、チェックリスト、用語規約

---

## ライセンスと出典

- 各スキルのライセンスおよび原著作者クレジット（k16shikano 氏、Lauren Tan 氏等）の詳細は、各プラグインディレクトリおよび [プラグイン詳細仕様](docs/plugins.md) を参照してください。
- リポジトリ全体としての運用ルールは [リポジトリ運用ルールと規約 (docs/guidelines.md)](docs/guidelines.md) をご覧ください。
