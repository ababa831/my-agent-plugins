# アーキテクチャと設計方針

本ドキュメントでは、本リポジトリにおけるプラグイン設計の思想、ディレクトリ構成、およびクライアント固有機能の境界について説明します。

[English version](architecture.en.md) | [README に戻る](../README.md)

---

## 基本思想

本リポジトリは、Cursor、Codex、Claude Code で共通利用するエージェント向け設定を、[Agent Plugins 仕様 1.0.0](https://agent-plugins.org/)（[agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)）に準拠して一元管理しています。

### 互換性の境界線

Agent Plugins v1 仕様において、クライアント間で移植可能（ポータブル）と定められているコンポーネントは以下の2種類のみです：

1. **skills**: [Agent Skills 仕様](https://agentskills.io/specification) に準拠したスキル群（`skills/`）
2. **MCP サーバ**: 共通 MCP 設定（`mcp.json`）

ルール（rules）、フック（hooks）、コマンド（commands）などは各クライアント固有の拡張領域に留まります。本リポジトリでは、クライアント固有の独自フォーマットを無理に共通化・擬似ポータブル化せず、仕様が定める境界線を厳格に守って分離しています。

- **ポータブル機能**: 各クライアントで同じスキルや MCP 定義を共有する。
- **クライアント固有拡張**: 各クライアントのマニフェストおよび専用ディレクトリ（Cursor の `rules/`、Claude Code の `claude/` など）に限定して配置する。

---

## ディレクトリ構成

リポジトリ全体の詳細なファイル構造は以下のとおりです：

```text
my-agent-plugins/
├── AGENTS.md                   # このリポジトリ自体を編集するエージェント向け指示
├── README.md                   # リポジトリの概要・クイックスタート
├── README.en.md                # (English)
├── docs/                       # 詳細ドキュメント群
│   ├── architecture.md         # 本ドキュメント（設計・アーキテクチャ）
│   ├── architecture.en.md      # (English)
│   ├── installation.md         # クライアント別詳細導入・設定ガイド
│   ├── installation.en.md      # (English)
│   ├── plugins.md              # プラグイン詳細解説
│   ├── plugins.en.md           # (English)
│   ├── guidelines.md           # 運用ルール・規約
│   └── guidelines.en.md        # (English)
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
    │   ├── claude/hooks.json              # Claude Code 固有の SessionStart hook
    │   └── skills/
    │       ├── git-development-rules/
    │       └── evidence-driven-engineering/
    ├── frontend-ui-development/ # GUI/UI開発ガードレール
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/frontend-ui-guardrails.mdc   # Cursor 固有の常駐ルール
    │   └── skills/frontend-ui-development/
    │       ├── SKILL.md
    │       └── assets/AGENTS.frontend.md
    ├── japanese-writing/       # 日本語ライティング規範スキル集
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/common-rules.mdc         # 常時適用の共通ルール（Cursor rule、Claude Code hook からも参照）
    │   ├── rules/readme-writing.mdc       # README 作成時の規約（Cursor rule）
    │   ├── claude/hooks.json              # Claude Code 固有の hook（SessionStart / PreToolUse）
    │   ├── claude/check_banned_words.py   # PreToolUse hook が呼ぶ禁止用語検出スクリプト
    │   └── skills/
    │       ├── japanese-tech-writing/SKILL.md
    │       ├── cognitive-rhythm-writing/SKILL.md
    │       └── semantic-generation/SKILL.md
    └── shared-mcp/             # 共通 MCP サーバ定義
        ├── plugin.json
        ├── mcp.json
        ├── .cursor-plugin/plugin.json
        ├── .codex-plugin/plugin.json
        ├── .claude-plugin/plugin.json   # Claude Code 用に MCP 定義をインライン記述
        └── .mcp.json
```

---

## マニフェストの管理方針

各プラグインは、標準仕様に準拠したプラグイン直下の `plugin.json` をメタデータの**定義元（一次情報源）**とします。

クライアントごとのマニフェスト（Cursor: `.cursor-plugin/plugin.json`、Codex: `.codex-plugin/plugin.json`、Claude Code: `.claude-plugin/plugin.json`）を併置し、以下の原則で同期・管理します：

1. **メタデータの一致**:
   - プラグイン名、バージョン、概要説明は、クライアント固有の差異が意図的である場合を除き、すべてのマニフェスト間で揃えます。
2. **スキルの共有**:
   - `skills/` 配下のポータブルなスキルは、各クライアントから共通フォーマットのまま参照・共有します。
3. **クライアント固有リソースの分離**:
   - **Cursor**: 固有のルールは `rules/*.mdc` に配置し、`.cursor-plugin/plugin.json` からのみ参照します。
   - **Claude Code**: 固有のフックは `claude/` に配置し、`.claude-plugin/plugin.json` からのみ参照します。
   - **Codex / MCP**: MCP 定義のスキーマ差分（例: Claude Code ではインライン形式を要求する等）を吸収するため、形式別のファイルを用意・参照します。
