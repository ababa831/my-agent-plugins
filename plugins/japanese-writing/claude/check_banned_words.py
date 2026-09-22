"""PostToolUse hook: flag the word 「正本」 in text Claude Code just wrote.

Only newly written text is checked (Write content, Edit/MultiEdit new_string,
NotebookEdit new_source), so removing the word or editing a file that already
contains it elsewhere does not trigger. Mentions of the term itself, written
with corner brackets as 「正本」, are ignored.
"""

import json
import sys

WORD = "\u6b63\u672c"  # 「正本」, escaped so editing this file does not trigger the hook
QUOTED = "「" + WORD + "」"


def written_texts(tool_input):
    for key in ("content", "new_string", "new_source"):
        value = tool_input.get(key)
        if isinstance(value, str):
            yield value
    for edit in tool_input.get("edits") or []:
        if isinstance(edit, dict) and isinstance(edit.get("new_string"), str):
            yield edit["new_string"]


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        return 0
    tool_input = payload.get("tool_input") or {}
    hits = [
        line.strip()
        for text in written_texts(tool_input)
        for line in text.splitlines()
        if WORD in line.replace(QUOTED, "")
    ]
    if not hits:
        return 0
    path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    lines = "\n".join("- " + hit[:200] for hit in hits[:5])
    print(
        f"{path} に「{WORD}」が書き込まれた。共通ルールに従い、"
        "「定義元」「元データ」「基準」など文脈に合う語に言い換えること。"
        "ユーザーの原文の引用など意図的な場合はそのままでよい。\n" + lines,
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
