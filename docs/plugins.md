# プラグイン詳細仕様

本リポジトリに含まれる各プラグインの目的、含まれるスキル、ルール、フック、および動作仕様について解説します。

[English version](plugins.en.md) | [README に戻る](../README.md)

---

## 目次

1. [development-rules](#1-development-rules)
2. [frontend-ui-development](#2-frontend-ui-development)
3. [japanese-writing](#3-japanese-writing)
4. [shared-mcp](#4-shared-mcp)

---

## 1. development-rules

### 概要

Git 開発における基本規約と、仮説や推測に依存しない「証拠駆動（evidence-driven）」のエンジニアリング規約を提供するプラグインです。

### 含まれるコンポーネント

- **`git-development-rules` (スキル)**:
  - [Conventional Commits](https://www.conventionalcommits.org/) に準拠したコミット運用。
  - テスト駆動開発（TDD）の遵守。
  - `main` への直接 push を禁止し、作業ブランチと Pull Request を経由した変更運用。
  - シークレットや個人情報の混入防止。
- **`evidence-driven-engineering` (スキル)**:
  - 原因診断をコードと観測結果（ログ・出力）で確実に裏付ける規約。
  - 実行中の挙動確認による検証と、その再現性の担保。
  - 繰り返される指摘・ミスを型システム、lint、CI などの仕組みで恒久的に予防。
  - サブエージェントへの委任判断およびスキル評価の進め方。
- **Claude Code 固有フック (`claude/hooks.json`)**:
  - `SessionStart` フックにより、セッション開始時に `git-development-rules` の本文が自動的にコンテキストへ読み込まれます。

---

## 2. frontend-ui-development

### 概要

Web / GUI アプリケーションのフロントエンド開発において、既存のコンポーネントやデザイントークンを無視した場当たり的なスタイル追加（パッチワーク化）を防ぎ、一貫性のある UI 実装を保つためのガードレールです。

### 含まれるコンポーネント

- **`frontend-ui-development` (スキル)**:
  - 既存の UI コンポーネント、デザインシステム、トークン、レイアウト構造の優先利用を徹底。
  - プロトタイピングから安定化・視覚的不具合の修正までをガイド。
- **`rules/frontend-ui-guardrails.mdc` (Cursor 向けルール)**:
  - Cursor 環境で常時または特定ファイル編集時に UI ガードレールを強制適用するルール。
- **`assets/AGENTS.frontend.md` (テンプレート)**:
  - 対象プロジェクトの `AGENTS.md` に組み込んで使用する、プロジェクト固有 UI 指示用テンプレート。

---

## 3. japanese-writing

### 概要

エージェントが生成する日本語文章の品質を向上させ、技術文書としての明確さと読み手の認知負荷軽減を両立させるためのスキルおよび共通ルール集です。

### 含まれるスキル

- **`japanese-tech-writing`**:
  - 技術文書・README・解説文向けの文章規範。曖昧表現の排除や文構造の明瞭化。
- **`cognitive-rhythm-writing`**:
  - 読み手の認知リズムを最適化し、長文の壁を避けて要点をテンポよく伝えるためのライティング手法。
- **`semantic-generation`**:
  - 意味対応表（キー・値の対応や用語定義）を先行して生成し、ブレのない文章を組み立てる手法。

### 共通ルールとフック

- **`rules/common-rules.mdc`**:
  - ユーザーへの返信を常に日本語で行う規約。
  - 日本語として馴染みの薄い不自然な直訳表現を禁止し、文脈に応じて「信頼できる唯一の情報源（SSOT）」「定義元」「一次情報源」「管理元」「元データ」「基準」などの分かりやすい語に言い換える規約。
  - Cursor では `alwaysApply: true` ルールとして、Claude Code では `SessionStart` フックとして自動注入されます。
- **禁止用語検出フック (`claude/check_banned_words.py`)**:
  - Claude Code の `PreToolUse` フックとして動作し、ファイル書き込み・編集時に読者の理解を妨げる不適切な禁止用語が含まれていないかをチェックします。

---

## 4. shared-mcp

### 概要

開発時に頻繁に利用される MCP（Model Context Protocol）サーバを定義し、各クライアントから手軽に利用できるようにした設定集です。

### 含まれる MCP サーバ

- **`chrome-devtools`**: Chrome の開発者ツールと連携したブラウザ自動操作・デバッグ（stdio / npx）。
- **`bigquery`**: Google Cloud BigQuery との接続・クエリ実行（streamable-http）。
- **`huggingface`**: Hugging Face API との連携（streamable-http）。

各クライアント（Cursor, Codex, Claude Code）のスキーマ差分は、`mcp.json`, `.mcp.json`, `.claude-plugin/plugin.json` を通じて適切に吸収されます。
