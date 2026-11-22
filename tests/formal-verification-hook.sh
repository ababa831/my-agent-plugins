#!/usr/bin/env bash
# formal-verification のガードレールを注入する PreToolUse hook（claude/inject_formal_verification_rule.py）を検証する。
# 実行: bash tests/formal-verification-hook.sh
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
plugin_root="$repo_root/plugins/formal-verification"

command=$(python3 -c '
import json, sys
for entry in json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]:
    for hook in entry["hooks"]:
        if "inject_formal_verification_rule.py" in hook["command"]:
            print(hook["command"])
' "$plugin_root/claude/hooks.json")

failures=0

# $1 の tool_name と $2 の file_path で hook 出力を返す
run_hook() {
  printf '{"tool_name":"%s","tool_input":{"file_path":"%s","content":"x"}}' "$1" "$2" |
    CLAUDE_PLUGIN_ROOT="$plugin_root" bash -c "$command"
}

expect_injected() {
  local tool=$1
  local path=$2
  local out
  out=$(run_hook "$tool" "$path")
  if ! printf '%s' "$out" | python3 -c '
import json, sys
ctx = json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"]
assert "# Lean 4 形式検証ガードレール" in ctx
assert "alwaysApply" not in ctx
assert "globs" not in ctx
' 2>/dev/null; then
    echo "FAIL [$tool:$path] 規約が注入されない: $out"; failures=$((failures + 1))
  fi
}

expect_silent() {
  local tool=$1
  local path=$2
  local out
  out=$(run_hook "$tool" "$path")
  if [ -n "$out" ]; then
    echo "FAIL [$tool:$path] 出力がある: $out"; failures=$((failures + 1))
  fi
}

expect_injected "Write" "/repo/specs/Main.lean"
expect_injected "Edit" "specs/Allocate.lean"
expect_injected "Write" "/repo/specs/lakefile.lean"
expect_injected "Write" "/repo/specs/lakefile.toml"
expect_injected "Write" "/repo/specs/lean-toolchain"

expect_silent "Write" "/repo/src/main.py"
expect_silent "Write" "/repo/README.md"
expect_silent "Write" "/repo/specs/Main.lean.bak"
expect_silent "Write" "/repo/specs/Protocol.tla"
expect_silent "Write" "/repo/specs/lakefile.toml.example"
expect_silent "Write" ""

# 想定外の入力でも出力せず終了コード 0 で終わる
if ! out=$(printf 'not json' | CLAUDE_PLUGIN_ROOT="$plugin_root" bash -c "$command") || [ -n "$out" ]; then
  echo "FAIL [invalid json] 出力または非 0 終了"; failures=$((failures + 1))
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures 件失敗"
  exit 1
fi
echo "OK"
