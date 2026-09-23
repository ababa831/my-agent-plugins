# リポジトリ運用ルールと規約

本リポジトリのプラグイン開発、更新、およびコントリビューションに関する運用指針について説明します。

[English version](guidelines.en.md) | [README に戻る](../README.md)

---

## 基本原則

1. **一元管理と配布**:
   - スキルの更新・追加はこのリポジトリで行い、各クライアント（Cursor, Codex, Claude Code）へはプラグイン経由で配布します。
2. **ポータブル境界の厳守**:
   - クライアント固有の拡張（Cursor rules, Claude Code hooks など）を、ポータブルな Agent Plugins 仕様の要素として偽装・混同させないでください。
   - Cursor 固有のルールは `rules/`、Claude Code 固有のフックは `claude/` に分離して配置します。
3. **認証情報・シークレットの排除**:
   - シークレット、API キー、トークン、個人情報をプラグイン内（`mcp.json` の `env` や `headers` を含む）にコミットしてはなりません。仕様では、設定された `env` と `headers` に認証情報やその他のシークレットを埋め込むことを禁止しています。
4. **バージョン管理の同期**:
   - プラグインを変更した場合は、該当プラグインのルート `plugin.json`、および各クライアント向けマニフェスト（`.cursor-plugin/`, `.codex-plugin/`, `.claude-plugin/`）の `version` を揃えて更新（bump）してください。
5. **用語規約の徹底**:
   - 日本語の文章において、読み手に馴染みの薄い不自然な直訳表現は使用しません。文脈に応じて「信頼できる唯一の情報源（SSOT）」「定義元」「管理元」「一次情報源」「元データ」「基準」などの分かりやすい語に言い換えてください。
   - 機械的なチェックは、`japanese-writing` の Claude Code 用 PreToolUse hook に留めます。不要な CI や過剰なリントチェックは追加しません。

---

## 変更チェックリスト

プラグインを追加または変更する際は、以下のチェックリストを順に確認してください：

- [ ] 対象プラグイン内のファイルを編集・更新する。
- [ ] 既存の公開済みプラグインに変更を加えた場合、すべてのマニフェスト（`plugin.json`, `.cursor-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.claude-plugin/plugin.json`）の `version` を更新する。
- [ ] プラグインカタログに変更がある場合、3つのマーケットプレイスマニフェスト（`.cursor-plugin/marketplace.json`, `.agents/plugins/marketplace.json`, `.claude-plugin/marketplace.json`）を同期する。
- [ ] ユーザー向けの挙動やインストール手順に変更がある場合、`README.md` と `README.en.md` の両方を更新する。
- [ ] 関連するテスト（例: `bash tests/development-rules-hook.sh`）および JSON バリデーションを実行し、正常終了することを確認する。
- [ ] feature ブランチを作成し、コミットメッセージは Conventional Commits に従い、Pull Request を作成してマージする（`main` へ直接コミットしない）。
