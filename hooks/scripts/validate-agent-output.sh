#!/bin/sh
# validate-agent-output.sh — SubagentStop hook
# Validates that framework agents return expected output sections.
# Injects a warning if output is malformed — does not block.

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

[ ! -d "$CWD/.docs" ] && exit 0

# Extract agent type from input
AGENT_TYPE=$(echo "$INPUT" | grep -o '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

# Only validate known framework agent types
case "$AGENT_TYPE" in
  code-explorer|docs-explorer|blueprint-reviewer|code-reviewer) ;;
  *) exit 0 ;;
esac

# Extract agent output/result
RESULT=$(echo "$INPUT" | grep -o '"result"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"result"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

[ -z "$RESULT" ] && exit 0

WARNINGS=""

# Explorer agents must return: Key Findings, Relevant Files, Open Questions
case "$AGENT_TYPE" in
  code-explorer|docs-explorer)
    echo "$RESULT" | grep -qi "Key Findings" || WARNINGS="${WARNINGS}Missing Key Findings section. "
    echo "$RESULT" | grep -qi "Relevant Files" || WARNINGS="${WARNINGS}Missing Relevant Files section. "
    echo "$RESULT" | grep -qi "Open Questions" || WARNINGS="${WARNINGS}Missing Open Questions section. "
    ;;
  blueprint-reviewer)
    echo "$RESULT" | grep -qi "PASS\|FAIL" || WARNINGS="${WARNINGS}Missing PASS/FAIL verdict. "
    ;;
  code-reviewer)
    echo "$RESULT" | grep -qiE "P[0-3]|Correctness|Testing|Maintainability" || WARNINGS="${WARNINGS}Missing severity-tagged findings or review passes. "
    ;;
esac

[ -z "$WARNINGS" ] && exit 0

ESCAPED=$(printf '%s' "$WARNINGS" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"SubagentStop","additionalContext":"[agentic-kit] Agent output validation: %s Agent should re-emit with required sections."}}' "$ESCAPED"
