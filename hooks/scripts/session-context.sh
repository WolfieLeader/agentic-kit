#!/bin/sh
# session-context.sh — SessionStart hook (startup | resume | compact)
# Injects active pipeline context so the agent wakes up oriented.
# Reads .docs/ artifact state — no separate memory system needed.

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

[ ! -d "$CWD/.docs" ] && exit 0

LINES=""

# 1. Saved pipeline state (written by PreCompact or Stop)
if [ -f "$CWD/.docs/.pipeline-state.json" ]; then
  SLUG=$(grep -o '"slug"[[:space:]]*:[[:space:]]*"[^"]*"' "$CWD/.docs/.pipeline-state.json" 2>/dev/null | head -1 | sed 's/.*"slug"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
  PHASE=$(grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$CWD/.docs/.pipeline-state.json" 2>/dev/null | head -1 | sed 's/.*"phase"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
  TYPE=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$CWD/.docs/.pipeline-state.json" 2>/dev/null | head -1 | sed 's/.*"type"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
  TIER=$(grep -o '"tier"[[:space:]]*:[[:space:]]*"[^"]*"' "$CWD/.docs/.pipeline-state.json" 2>/dev/null | head -1 | sed 's/.*"tier"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
  if [ -n "$SLUG" ]; then
    LINES="${LINES}SAVED PIPELINE STATE: slug=${SLUG} type=${TYPE} tier=${TIER} phase=${PHASE}. "
  fi
fi

# 2. Active draft artifacts (fallback / supplement to saved state)
for dir in sketches blueprints; do
  [ -d "$CWD/.docs/$dir" ] || continue
  for f in "$CWD/.docs/$dir"/*.md; do
    [ -f "$f" ] || continue
    if head -15 "$f" | grep -qi "status:.*draft"; then
      SLUG=$(basename "$f" .md)
      LINES="${LINES}DRAFT: .docs/${dir}/${SLUG}.md. "
    fi
  done
done

# 3. Most recent retro (learning continuity)
if [ -d "$CWD/.docs/retros" ]; then
  LATEST=$(ls -t "$CWD/.docs/retros"/*.md 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    RSLUG=$(basename "$LATEST" .md)
    OUTCOME=$(head -20 "$LATEST" | grep -i "^outcome:" | head -1 | sed 's/.*outcome:[[:space:]]*//')
    LINES="${LINES}LATEST RETRO: ${RSLUG} (${OUTCOME}). "
  fi
fi

# 4. MAP.md exists indicator
[ -f "$CWD/.docs/MAP.md" ] && LINES="${LINES}MAP.md present — read it for project structure. "

# Nothing to inject
[ -z "$LINES" ] && exit 0

# Escape for JSON (content is controlled metadata, no raw user text)
ESCAPED=$(printf '%s' "$LINES" | sed 's/\\/\\\\/g; s/"/\\"/g')

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[agentic-kit] %s If resuming a pipeline, run /yo to continue from where you left off."}}' "$ESCAPED"
