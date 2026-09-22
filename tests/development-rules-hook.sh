#!/usr/bin/env bash
# development-rules の SessionStart hook（claude/hooks.json）の出力を検証する。
# 実行: bash tests/development-rules-hook.sh
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
plugin_root="$repo_root/plugins/development-rules"
skill_rel="skills/git-development-rules/SKILL.md"

command=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["hooks"]["SessionStart"][0]["hooks"][0]["command"])' \
  "$plugin_root/claude/hooks.json")

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

# $1 に SKILL.md を置いたプラグインルートで hook を実行する
run_hook() {
  CLAUDE_PLUGIN_ROOT="$1" bash -c "$command"
}

# fixture を作り、hook の出力を $work/<name>.out に書く
prepare() {
  local name=$1
  mkdir -p "$work/$name/$(dirname "$skill_rel")"
  cat > "$work/$name/$skill_rel"
  run_hook "$work/$name" > "$work/$name.out"
}

expect_contains() {
  if ! grep -qF -- "$2" "$work/$1.out"; then
    echo "FAIL [$1] 出力に含まれない: $2"; failures=$((failures + 1))
  fi
}

expect_absent() {
  if grep -qF -- "$2" "$work/$1.out"; then
    echo "FAIL [$1] 出力に含まれている: $2"; failures=$((failures + 1))
  fi
}

# 実際の SKILL.md
prepare actual < "$plugin_root/$skill_rel"
expect_absent actual "name: git-development-rules"
expect_absent actual "SKILL.en.md"
expect_contains actual "# Git開発共通ルール"
expect_contains actual "Conventional Commits"

# CRLF に変換した SKILL.md
sed 's/$/\r/' "$plugin_root/$skill_rel" | prepare crlf
expect_absent crlf "name: git-development-rules"
expect_absent crlf "SKILL.en.md"
expect_contains crlf "Conventional Commits"

# 区切り行の末尾に空白がある
printf -- '---  \nname: x\n--- \n\n# body\n' | prepare trailing_space
expect_absent trailing_space "name: x"
expect_contains trailing_space "# body"

# 本文中の水平線は残す
printf -- '---\nname: x\n---\n\nbefore\n\n---\n\nafter\n' | prepare body_rule
expect_absent body_rule "name: x"
expect_contains body_rule "before"
expect_contains body_rule "---"
expect_contains body_rule "after"

if [ "$failures" -ne 0 ]; then
  echo "$failures 件失敗"
  exit 1
fi
echo "OK"
