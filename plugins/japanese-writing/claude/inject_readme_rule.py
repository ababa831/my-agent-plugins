"""PreToolUse hook: add the README writing rule to context when writing a README.

When Write or Edit targets `README.md` or `README.*.md` (the same patterns as the
Cursor rule's globs), print the body of `rules/readme-writing.mdc` without its
frontmatter as `additionalContext`. The tool call itself is never blocked, and
any unexpected input exits 0 without output.
"""

import json
import os
import sys
from fnmatch import fnmatchcase

PATTERNS = ("README.md", "README.*.md")
RULE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "rules", "readme-writing.mdc")


def strip_frontmatter(text):
    lines = text.splitlines()
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], start=1):
            if line.strip() == "---":
                return "\n".join(lines[i + 1:]).strip() + "\n"
    return text


def main():
    try:
        payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
        path = (payload.get("tool_input") or {}).get("file_path") or ""
        if not any(fnmatchcase(os.path.basename(path), p) for p in PATTERNS):
            return 0
        with open(RULE, encoding="utf-8") as f:
            body = strip_frontmatter(f.read())
    except Exception:
        return 0
    output = {"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": body}}
    sys.stdout.buffer.write(json.dumps(output, ensure_ascii=False).encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
