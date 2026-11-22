"""PreToolUse hook: inject method-specific formal verification guardrails on Write/Edit.

When Write or Edit targets a file matching one of `RULE_MAPPINGS` (aligned with the
Cursor rule's globs), emit the matching rule body without YAML frontmatter as
`additionalContext`. The tool call itself is never blocked, and any unexpected input
exits 0 silently.
"""

import json
import os
import sys
from fnmatch import fnmatchcase

RULE_MAPPINGS = (
    (("*.lean", "lakefile.lean", "lakefile.toml", "lean-toolchain"), "lean4-verification-guardrails.mdc"),
)
RULES_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "rules")


def strip_frontmatter(text):
    """Return rule body without leading YAML frontmatter."""
    lines = text.splitlines()
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], start=1):
            if line.strip() == "---":
                return "\n".join(lines[i + 1:]).strip() + "\n"
    return text


def find_rule_file(path):
    """Return the matching rule filename for path, or None if unmatched."""
    basename = os.path.basename(path)
    if not basename:
        return None
    for patterns, rule_name in RULE_MAPPINGS:
        if any(fnmatchcase(basename, pattern) for pattern in patterns):
            return rule_name
    return None


def main():
    try:
        payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
        path = (payload.get("tool_input") or {}).get("file_path") or ""
        rule_name = find_rule_file(path)
        if not rule_name:
            return 0
        rule_path = os.path.join(RULES_DIR, rule_name)
        with open(rule_path, encoding="utf-8") as f:
            body = strip_frontmatter(f.read())
    except Exception:
        return 0
    output = {"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": body}}
    sys.stdout.buffer.write(json.dumps(output, ensure_ascii=False).encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
