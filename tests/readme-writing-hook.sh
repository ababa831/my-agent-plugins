#!/usr/bin/env bash
# japanese-writing の README 規約を注入する PreToolUse hook（claude/inject_readme_rule.py）を検証する。
# 実行: bash tests/readme-writing-hook.sh
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
plugin_root="$repo_root/plugins/japanese-writing"

command=$(python3 -c '
import json, sys
for entry in json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]:
    for hook in entry["hooks"]:
        if "inject_readme_rule.py" in hook["command"]:
            print(hook["command"])
' "$plugin_root/claude/hooks.json")

failures=0

# $1 の file_path で Write を呼んだときの hook 出力を返す
run_hook() {
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$1" |
    CLAUDE_PLUGIN_ROOT="$plugin_root" bash -c "$command"
}

expect_injected() {
  local out
  out=$(run_hook "$1")
  if ! printf '%s' "$out" | python3 -c '
import json, sys
ctx = json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"]
assert "# README の書き方" in ctx and "alwaysApply" not in ctx
' 2>/dev/null; then
    echo "FAIL [$1] 規約が注入されない: $out"; failures=$((failures + 1))
  fi
}

expect_silent() {
  local out
  out=$(run_hook "$1")
  if [ -n "$out" ]; then
    echo "FAIL [$1] 出力がある: $out"; failures=$((failures + 1))
  fi
}

expect_injected "/repo/README.md"
expect_injected "/repo/docs/README.en.md"
expect_injected "README.md"
expect_silent "/repo/docs/guide.md"
expect_silent "/repo/readme.md"
expect_silent "/repo/README.txt"
expect_silent "/repo/NOT_README.md"

# 想定外の入力でも出力せず終了コード 0 で終わる
if ! out=$(printf 'not json' | CLAUDE_PLUGIN_ROOT="$plugin_root" bash -c "$command") || [ -n "$out" ]; then
  echo "FAIL [invalid json] 出力または非 0 終了"; failures=$((failures + 1))
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures 件失敗"
  exit 1
fi
echo "OK"
