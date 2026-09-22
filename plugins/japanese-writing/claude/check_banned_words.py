"""PreToolUse hook: block writes that add the word 「正本」.

Only occurrences added by the tool call count. Write and NotebookEdit write
their whole text, so any occurrence counts. Edit counts only when `new_string`
has more occurrences than `old_string`, so keeping or removing an existing
occurrence does not trigger. Mentions of the term itself, written with corner
brackets as 「正本」, are ignored.

Checked keys are limited to those confirmed in real hook payloads
(Claude Code 2.1.280): Write `content`, Edit `old_string` / `new_string`,
NotebookEdit `new_source`. Any unexpected input exits 0 so the hook never
blocks work by mistake.
"""

import json
import sys

WORD = "\u6b63\u672c"  # 「正本」, escaped so editing this file does not trigger the hook
QUOTED = "「" + WORD + "」"


def count(text):
    return text.replace(QUOTED, "").count(WORD) if isinstance(text, str) else 0


def main():
    try:
        payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
        tool_input = payload.get("tool_input") or {}
        added = count(tool_input.get("content")) + count(tool_input.get("new_source"))
        added += max(0, count(tool_input.get("new_string")) - count(tool_input.get("old_string")))
        path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    except Exception:
        return 0
    if not added:
        return 0
    message = (
        f"{path} への書き込みに「{WORD}」が含まれるため止めた。"
        "共通ルールに従い、「定義元」「元データ」「基準」など文脈に合う語に言い換えて再実行すること。\n"
    )
    sys.stderr.buffer.write(message.encode("utf-8"))
    return 2


if __name__ == "__main__":
    sys.exit(main())
