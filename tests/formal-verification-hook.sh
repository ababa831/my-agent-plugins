#!/usr/bin/env bash
# formal-verification のガードレールを注入する PreToolUse hook（claude/inject_formal_verification_rule.py）を検証する。
# 実行: bash tests/formal-verification-hook.sh
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
plugin_root="$repo_root/plugins/formal-verification"

command=$(python3 -c '
import json, sys
entries = json.load(open(sys.argv[1], encoding="utf-8"))["hooks"]["PreToolUse"]
matched = []
for entry in entries:
    for hook in entry["hooks"]:
        if "inject_formal_verification_rule.py" in hook["command"]:
            assert entry.get("matcher") == "Write|Edit", f"unexpected matcher: {entry.get('matcher')}"
            matched.append(hook["command"])
assert len(matched) == 1, f"expected 1 hook entry, got {len(matched)}"
print(matched[0])
' "$plugin_root/claude/hooks.json")

# .mdc の globs と inject_formal_verification_rule.py の RULE_MAPPINGS の一致を検証する
python3 -c '
import ast, os, sys
rule_path, script_path = sys.argv[1], sys.argv[2]
lines = open(rule_path, encoding="utf-8").read().splitlines()
assert lines[0].strip() == "---"
globs = []
in_globs = False
for line in lines[1:]:
    if line.strip() == "---":
        break
    if line.strip() == "globs:":
        in_globs = True
        continue
    if in_globs:
        s = line.strip()
        if s.startswith("- "):
            g = s[2:].strip().strip("\x27\"")
            globs.append(os.path.basename(g))
        elif s and not s.startswith("#"):
            in_globs = False

tree = ast.parse(open(script_path, encoding="utf-8").read())
mappings = None
for node in tree.body:
    if isinstance(node, ast.Assign):
        for t in node.targets:
            if isinstance(t, ast.Name) and t.id == "RULE_MAPPINGS":
                mappings = ast.literal_eval(node.value)
assert mappings is not None
script_patterns = []
for patterns, rule_name in mappings:
    if rule_name == os.path.basename(rule_path):
        script_patterns.extend(patterns)
assert sorted(globs) == sorted(script_patterns), f"glob mismatch: {globs} != {script_patterns}"
' "$plugin_root/rules/lean4-verification-guardrails.mdc" "$plugin_root/claude/inject_formal_verification_rule.py"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

# $1 の plugin_root、$2 の tool_name、$3 の file_path で hook 出力を返す
run_hook_in() {
  local root=$1
  local tool=$2
  local path=$3
  python3 -c 'import json, sys; print(json.dumps({"tool_name": sys.argv[1], "tool_input": {"file_path": sys.argv[2], "content": "x"}}))' "$tool" "$path" |
    CLAUDE_PLUGIN_ROOT="$root" bash -c "$command"
}

expect_injected() {
  local root=$1
  local tool=$2
  local path=$3
  local label=${4:-"$tool:$path"}
  local out
  out=$(run_hook_in "$root" "$tool" "$path")
  if ! printf '%s' "$out" | python3 -c '
import json, sys
ctx = json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"]
assert not ctx.startswith("\ufeff"), "BOMが残っている"
assert "# Lean 4 形式検証ガードレール" in ctx
assert "alwaysApply" not in ctx
assert "globs" not in ctx
' 2>/dev/null; then
    echo "FAIL [$label] 規約が注入されない: $out"; failures=$((failures + 1))
  fi
}

expect_silent() {
  local root=$1
  local tool=$2
  local path=$3
  local label=${4:-"$tool:$path"}
  local out
  out=$(run_hook_in "$root" "$tool" "$path")
  if [ -n "$out" ]; then
    echo "FAIL [$label] 出力がある: $out"; failures=$((failures + 1))
  fi
}

expect_raw_silent() {
  local label=$1
  local payload=$2
  local out
  if ! out=$(printf '%s' "$payload" | CLAUDE_PLUGIN_ROOT="$plugin_root" bash -c "$command") || [ -n "$out" ]; then
    echo "FAIL [$label] 出力または非 0 終了: $out"; failures=$((failures + 1))
  fi
}

# 実プラグインでの基本・境界ケース
expect_injected "$plugin_root" "Write" "/repo/specs/Main.lean"
expect_injected "$plugin_root" "Edit" "specs/Allocate.lean"
expect_injected "$plugin_root" "Write" "/repo/specs/lakefile.lean"
expect_injected "$plugin_root" "Write" "/repo/specs/lakefile.toml"
expect_injected "$plugin_root" "Write" "/repo/specs/lean-toolchain"
expect_injected "$plugin_root" "Write" 'C:\repo\specs\lakefile.toml' "backslash_path"
expect_injected "$plugin_root" "Write" '/repo/specs/"quoted".lean' "quoted_path"

expect_silent "$plugin_root" "Write" "/repo/src/main.py"
expect_silent "$plugin_root" "Write" "/repo/README.md"
expect_silent "$plugin_root" "Write" "/repo/specs/Main.lean.bak"
expect_silent "$plugin_root" "Write" "/repo/specs/Protocol.tla"
expect_silent "$plugin_root" "Write" "/repo/specs/lakefile.toml.example"
expect_silent "$plugin_root" "Write" "/repo/specs/Main.LEAN" "uppercase_ext"
expect_silent "$plugin_root" "Write" "" "empty_path"

# 想定外ペイロードでも出力せず終了コード 0 で終わる
expect_raw_silent "invalid_json" 'not json'
expect_raw_silent "null_tool_input" '{"tool_name":"Write","tool_input":null}'
expect_raw_silent "non_string_file_path" '{"tool_name":"Write","tool_input":{"file_path":123}}'

# フィクスチャで frontmatter 解析・BOM・欠落の境界ケースを検証する
setup_fixture() {
  local name=$1
  local root="$work/$name"
  mkdir -p "$root/claude" "$root/rules"
  cp "$plugin_root/claude/inject_formal_verification_rule.py" "$root/claude/"
  printf '%s' "$root"
}

r=$(setup_fixture crlf)
printf '%s\r\n' '---' 'alwaysApply: false' 'globs:' '  - "**/*.lean"' '---' '' '# Lean 4 形式検証ガードレール' > "$r/rules/lean4-verification-guardrails.mdc"
expect_injected "$r" "Write" "/repo/Main.lean" "fixture_crlf"

r=$(setup_fixture bom)
python3 -c 'import sys; sys.stdout.buffer.write(b"\xef\xbb\xbf---\nalwaysApply: false\n---\n\n# Lean 4 \xe5\xbd\xa2\xe5\xbc\x8f\xe6\xa4\x9c\xe8\xa8\xbc\xe3\x82\xac\xe3\x83\xbc\xe3\x83\x89\xe3\x83\xac\xe3\x83\xbc\xe3\x83\xab\n")' > "$r/rules/lean4-verification-guardrails.mdc"
expect_injected "$r" "Write" "/repo/Main.lean" "fixture_bom"

r=$(setup_fixture body_hr)
printf '%s\n' '---' 'alwaysApply: false' '---' '' '# Lean 4 形式検証ガードレール' '' '---' '' 'after' > "$r/rules/lean4-verification-guardrails.mdc"
out_hr=$(run_hook_in "$r" "Write" "/repo/Main.lean")
if ! printf '%s' "$out_hr" | python3 -c 'import json,sys; c=json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"]; assert "# Lean 4 形式検証ガードレール" in c and "\n---\n" in c and "after" in c' 2>/dev/null; then
  echo "FAIL [fixture_body_hr] 本文中の水平線が欠落: $out_hr"; failures=$((failures + 1))
fi

r=$(setup_fixture no_fm)
printf '%s\n' '# Lean 4 形式検証ガードレール' '' 'body' > "$r/rules/lean4-verification-guardrails.mdc"
expect_injected "$r" "Write" "/repo/Main.lean" "fixture_no_fm"

r=$(setup_fixture unclosed_fm)
printf '%s\n' '---' 'alwaysApply: false' '# Lean 4 形式検証ガードレール' > "$r/rules/lean4-verification-guardrails.mdc"
expect_silent "$r" "Write" "/repo/Main.lean" "fixture_unclosed_fm"

r=$(setup_fixture missing_rule)
expect_silent "$r" "Write" "/repo/Main.lean" "fixture_missing_rule"

if [ "$failures" -ne 0 ]; then
  echo "$failures 件失敗"
  exit 1
fi
echo "OK"
