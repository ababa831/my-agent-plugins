"""PostToolUse hook: flag the word 「正本」 in text Claude Code just wrote.

Only newly written text is checked, so removing the word or editing a file that
already contains it elsewhere does not trigger. Mentions of the term itself,
written with corner brackets as 「正本」, are ignored.

Checked keys are limited to those confirmed in real PostToolUse payloads
(Claude Code 2.1.280): Write `content`, Edit `new_string`, NotebookEdit
`new_source`. Any unexpected input exits 0 so the hook never blocks work.
"""

import json
import sys

WORD = "\u6b63\u672c"  # 「正本」, escaped so editing this file does not trigger the hook
QUOTED = "「" + WORD + "」"
TEXT_KEYS = ("content", "new_string", "new_source")


def main():
    try:
        payload = json.load(sys.stdin)
        tool_input = payload.get("tool_input") or {}
        texts = [tool_input.get(key) for key in TEXT_KEYS]
        hits = [
            line.strip()
            for text in texts
            if isinstance(text, str)
            for line in text.splitlines()
            if WORD in line.replace(QUOTED, "")
        ]
        path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    except Exception:
        return 0
    if not hits:
        return 0
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
