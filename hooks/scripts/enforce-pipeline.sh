#!/bin/sh
# enforce-pipeline.sh — PreToolUse hook for Edit|Write
# Enforces DESIGN-THEN-CODE and INVESTIGATE-THEN-FIX hard gates.
#
# Blocks source-file writes when pipeline artifacts are out of order:
#   - Draft blueprint exists without matching sketch → skipped design
#   - Draft FIX sketch exists without matching diagnose → skipped investigation
#
# Slug-based matching (not date-based) so cross-day pipelines are covered.
# Only fires when positive evidence of a violation exists.

set -e

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

# Nothing to enforce without a file path
[ -z "$FILE_PATH" ] && exit 0

# No .docs = plugin not onboarded, skip enforcement
[ ! -d "$CWD/.docs" ] && exit 0

# --- Skip non-source files ---
# Artifacts, config, test files, framework files — all allowed freely.
case "$FILE_PATH" in
  */.docs/*|*/.claude/*|*/hooks/*|*/docs/*|*/agents/*|*/skills/*|*/references/*) exit 0 ;;
  *.md|*.json|*.yaml|*.yml|*.toml|*.lock|*.env*|*.txt|*.cfg|*.ini|*.conf) exit 0 ;;
  *.test.*|*.spec.*|*_test.*|*/test_*) exit 0 ;;
  */__tests__/*|*/test/*|*/tests/*|*/spec/*|*/fixtures/*) exit 0 ;;
esac

SKETCHES_DIR="$CWD/.docs/sketches"
BLUEPRINTS_DIR="$CWD/.docs/blueprints"
DIAGNOSES_DIR="$CWD/.docs/diagnoses"

# --- DESIGN-THEN-CODE ---
# Draft blueprint whose slug has no matching sketch = skipped design phase.
# Completed blueprints already passed through the pipeline — not checked.
if [ -d "$BLUEPRINTS_DIR" ]; then
  for bp in "$BLUEPRINTS_DIR"/*.md; do
    [ -f "$bp" ] || continue
    if head -15 "$bp" | grep -qi "status:.*draft"; then
      SLUG=$(basename "$bp" .md)
      if [ ! -f "$SKETCHES_DIR/$SLUG.md" ]; then
        echo "DESIGN-THEN-CODE: Blueprint '$SLUG' exists without a matching sketch. Complete the sketch phase before implementing." >&2
        exit 2
      fi
    fi
  done
fi

# --- INVESTIGATE-THEN-FIX ---
# Draft FIX sketch whose slug has no matching diagnose = skipped investigation.
if [ -d "$SKETCHES_DIR" ]; then
  for sketch in "$SKETCHES_DIR"/*.md; do
    [ -f "$sketch" ] || continue
    HEADER=$(head -15 "$sketch")
    if echo "$HEADER" | grep -qi "type:.*fix"; then
      if echo "$HEADER" | grep -qi "status:.*draft"; then
        SLUG=$(basename "$sketch" .md)
        if [ ! -f "$DIAGNOSES_DIR/$SLUG.md" ]; then
          echo "INVESTIGATE-THEN-FIX: FIX sketch '$SLUG' exists without a matching diagnosis. Run the diagnose phase before fixing." >&2
          exit 2
        fi
      fi
    fi
  done
fi

exit 0
