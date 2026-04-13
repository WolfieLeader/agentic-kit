#!/bin/sh
# save-pipeline-state.sh — PreCompact + Stop hook
# Snapshots active pipeline state to wiki/.pipeline-state.json.
# SessionStart reads this to restore context after compaction or resume.

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

[ ! -d "$CWD/.docs" ] && exit 0

# Find the most recent draft artifact to determine active pipeline
ACTIVE_SLUG=""
ACTIVE_TYPE=""
ACTIVE_TIER=""
ACTIVE_PHASE=""

# Check blueprints first (later phase = more specific)
if [ -d "$CWD/wiki/blueprints" ]; then
  for f in "$CWD/wiki/blueprints"/*.md; do
    [ -f "$f" ] || continue
    if head -15 "$f" | grep -qi "status:.*draft"; then
      ACTIVE_SLUG=$(basename "$f" .md)
      ACTIVE_PHASE="craft"
      ACTIVE_TIER=$(head -15 "$f" | grep -i "^tier:" | head -1 | sed 's/.*tier:[[:space:]]*//')
      break
    fi
  done
fi

# Check sketches (earlier phase, only if no blueprint found)
if [ -z "$ACTIVE_SLUG" ] && [ -d "$CWD/wiki/sketches" ]; then
  for f in "$CWD/wiki/sketches"/*.md; do
    [ -f "$f" ] || continue
    if head -15 "$f" | grep -qi "status:.*draft"; then
      ACTIVE_SLUG=$(basename "$f" .md)
      ACTIVE_PHASE="blueprint"
      ACTIVE_TYPE=$(head -15 "$f" | grep -i "^type:" | head -1 | sed 's/.*type:[[:space:]]*//')
      ACTIVE_TIER=$(head -15 "$f" | grep -i "^tier:" | head -1 | sed 's/.*tier:[[:space:]]*//')
      break
    fi
  done
fi

# Check diagnoses (FIX pipeline early stage)
if [ -z "$ACTIVE_SLUG" ] && [ -d "$CWD/wiki/diagnoses" ]; then
  for f in "$CWD/wiki/diagnoses"/*.md; do
    [ -f "$f" ] || continue
    SLUG=$(basename "$f" .md)
    # If diagnose exists but no sketch, we're between diagnose and sketch
    if [ ! -f "$CWD/wiki/sketches/$SLUG.md" ]; then
      ACTIVE_SLUG="$SLUG"
      ACTIVE_TYPE="fix"
      ACTIVE_PHASE="sketch"
      break
    fi
  done
fi

# Nothing active — remove stale state file
if [ -z "$ACTIVE_SLUG" ]; then
  rm -f "$CWD/wiki/.pipeline-state.json"
  exit 0
fi

# Infer phase from artifact presence (if not already set by blueprint check)
if [ "$ACTIVE_PHASE" = "craft" ] && [ -d "$CWD/wiki/retros" ]; then
  # If retro exists for this slug, we're in verify or done
  [ -f "$CWD/wiki/retros/$ACTIVE_SLUG.md" ] && ACTIVE_PHASE="done"
fi

# Write state snapshot
cat > "$CWD/wiki/.pipeline-state.json" << STATEOF
{"slug":"${ACTIVE_SLUG}","type":"${ACTIVE_TYPE}","tier":"${ACTIVE_TIER}","phase":"${ACTIVE_PHASE}","timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
STATEOF

exit 0
