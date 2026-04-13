#!/bin/sh
# check-completion.sh — Stop hook
# Warns about incomplete pipelines before session ends.
# Also saves pipeline state (delegates to save-pipeline-state.sh logic).

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

# Check stop_hook_active to prevent infinite loops
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

[ ! -d "$CWD/.docs" ] && exit 0

# Save state (same logic as PreCompact)
sh "$(dirname "$0")/save-pipeline-state.sh" << EOF
$INPUT
EOF

# Check for incomplete pipelines: draft artifacts without retros
INCOMPLETE=""
for dir in sketches blueprints; do
  [ -d "$CWD/.docs/$dir" ] || continue
  for f in "$CWD/.docs/$dir"/*.md; do
    [ -f "$f" ] || continue
    if head -15 "$f" | grep -qi "status:.*draft"; then
      SLUG=$(basename "$f" .md)
      if [ ! -f "$CWD/.docs/retros/$SLUG.md" ]; then
        INCOMPLETE="${INCOMPLETE}${SLUG} "
      fi
    fi
  done
done

[ -z "$INCOMPLETE" ] && exit 0

ESCAPED=$(printf '%s' "$INCOMPLETE" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"decision":"block","reason":"[agentic-kit] Incomplete pipeline(s): %s — run /yo to resume or complete the retro before ending."}' "$ESCAPED"
