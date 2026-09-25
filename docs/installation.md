# クライアント別詳細導入ガイド

本ドキュメントでは、各エディタ / クライアント（Cursor、Codex、Claude Code）における各プラグインの詳しい導入手順、フックやルールの動作仕様、アップデート方法、トラブルシューティングについて解説します。

[English version](installation.en.md) | [README に戻る](../README.md)

---

## 目次

- [Cursor](#cursor)
- [Codex](#codex)
- [Claude Code](#claude-code)

---

## Cursor

### ローカルプラグインとしての導入

各プラグインディレクトリを `~/.cursor/plugins/local/` 配下にコピーし、Cursor を再起動（または **Developer: Reload Window** を実行）します。
※Cursor は `~/.cursor/plugins/local/` の外部を指すシンボリックリンクを読み込まないため、コピー方式で配置します。

```bash
mkdir -p ~/.cursor/plugins/local
cp -R /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/frontend-ui-development ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/
```

### 反映確認

Cursor サイドバーの **Customize** を開き、各プラグインに含まれるルール（rules）、スキル（skills）、MCP サーバの一覧が表示されていることを確認します。

### ルールの適用動作

- **`japanese-writing`**:
  - `rules/common-rules.mdc` は `alwaysApply: true` として定義されており、セッション開始時に常にコンテキストへ読み込まれます。
  - `rules/readme-writing.mdc` は `README.md` と `README.*.md` を扱うときにだけ読み込まれます。
- **`frontend-ui-development`**:
  - ポータブルな `SKILL.md` に加えて Cursor 用の `rules/frontend-ui-guardrails.mdc` が配布されます。
  - プロジェクト固有の UI ルールを記述したい場合は、スキル内のテンプレート `assets/AGENTS.frontend.md` をコピーして、対象リポジトリの `AGENTS.md` に追記します。

### チームへの配布（Team Marketplace）

Cursor の Teams / Enterprise プランをご利用の場合、Team Marketplace 経由で配布可能です：
1. Cursor ダッシュボードの **Dashboard → Plugins** を開きます。
2. **Import from Repo** を選択し、本リポジトリの URL を登録します。
3. ルートディレクトリの `.cursor-plugin/marketplace.json` がプラグイン一覧を供給します。

---

## Codex

### マーケットプレイスの登録とプラグイン追加

リポジトリルートをローカルマーケットプレイスとして登録し、CLI からプラグインをインストールします。

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .

# カタログ一覧の確認
codex plugin list --marketplace my-agent-plugins --json --available

# 各プラグインのインストール
codex plugin add development-rules@my-agent-plugins
codex plugin add frontend-ui-development@my-agent-plugins
codex plugin add japanese-writing@my-agent-plugins
codex plugin add shared-mcp@my-agent-plugins
```

### GUI からの導入と有効化

`codex` 内の `/plugins`（プラグインブラウザ）や ChatGPT デスクトップアプリのプラグイン管理画面からもインストールが可能です。
インストールされたスキルや MCP サーバは、**新しいセッションを開始した時点**から有効になります。

### 宣言的常時適用ルールの制約と設定

Codex プラグインには、Cursor の `alwaysApply: true` のような**宣言的な常時適用ルール機能**がありません（Codex では SessionStart フックによるコンテキスト注入は可能ですが、フック実行時に信頼確認が必要です）。
`japanese-writing` の共通ルール（日本語での返信や用語制約）を Codex でも静的に常時有効化したい場合は、`plugins/japanese-writing/rules/common-rules.mdc` の本文（YAML frontmatter を除く）を、グローバル指示ファイル（`~/.codex/AGENTS.md`）に追記してください。

### プラグインの更新手順

Codex にインストールされたプラグインは、キャッシュディレクトリ（`~/.codex/plugins/cache/`）にコピーされて管理されます。
本リポジトリ側でプラグイン内容を変更した場合は、以下の手順で再インストールして変更を反映してください：

```bash
codex plugin remove <plugin-name>@my-agent-plugins
codex plugin add <plugin-name>@my-agent-plugins
```

※ `codex plugin marketplace upgrade` は Git リモート登録のマーケットプレイス向けコマンドであり、ローカルパス登録では機能しないため再インストールが必要です。

---

## Claude Code

### マーケットプレイスの登録とプラグイン追加

リポジトリルートをローカルマーケットプレイスとして登録し、プラグインをインストールします。

```bash
# マーケットプレイスの登録
claude plugin marketplace add /path/to/my-agent-plugins

# 各プラグインのインストール（既定の user スコープで全プロジェクトに適用）
claude plugin install development-rules@my-agent-plugins
claude plugin install frontend-ui-development@my-agent-plugins
claude plugin install japanese-writing@my-agent-plugins
claude plugin install shared-mcp@my-agent-plugins
```

`claude` 起動後の `/plugin` コマンドメニューからも同様に対話式でインストールできます。

### フック機能と動作仕様

Claude Code 向けには、ポータブルなスキルに加えて `claude/hooks.json` に定義されたフックが自動的に機能します：

1. **`development-rules` の SessionStart フック**:
   - セッション開始時に `skills/git-development-rules/SKILL.md` の本文（frontmatter を除く）をコンテキストに自動注入します。
   - ※ hook 内で `awk` コマンドを使用するため、Windows 環境では Git Bash の導入が推奨されます（Git Bash がない場合は PowerShell 実行となり hook はスキップされますが、スキル自体は利用可能です）。
2. **`japanese-writing` の SessionStart フック**:
   - `rules/common-rules.mdc` の内容を毎セッションのコンテキストに自動追加し、スキルが明示的に発火していない対話でも共通ルール（日本語返信・用語規約）を適用させます。
3. **`japanese-writing` の PreToolUse フック（禁止用語検出）**:
   - Claude がファイル作成・編集ツール（Write, Edit, NotebookEdit）を呼び出す直前に、`claude/check_banned_words.py` が自動実行されます。
   - 文章中に読者への配慮に欠ける不適切な禁止用語が含まれている場合、ツール実行をブロックして適切な代替表現（「信頼できる唯一の情報源」「定義元」「一次情報源」「管理元」など）への言い換えを促します。
   - 検出動作はツールごとに異なります：
     - `Edit`: `old_string` と `new_string` の出現回数を比較するため、既存の用語を残したまま別の箇所を直す編集はブロックされません。
     - `Write` / `NotebookEdit`: ファイル全文または新規セル全体（`content` / `new_source`）を走査するため、既存ファイルを上書きする場合でも対象用語が含まれているとブロックされます。
4. **`shared-mcp` の設定**:
   - Claude Code では `.claude-plugin/plugin.json` 内にインラインで定義された MCP サーバ設定を使用します。

### プラグインの更新手順

Claude Code のプラグインもキャッシュディレクトリ（`~/.claude/plugins/cache/`）にコピーされます。
プラグインの内容を変更し、該当プラグインの `plugin.json` の `version` を更新した後は、以下のコマンドで反映します：

```bash
claude plugin marketplace update my-agent-plugins
claude plugin update <plugin-name>@my-agent-plugins
```
