#!/bin/sh
# enforce-pipeline.sh — PreToolUse hook for Edit|Write
# Enforces DESIGN-THEN-CODE and INVESTIGATE-THEN-FIX hard gates.
#
# Blocks source-file writes when pipeline artifacts are out of order:
#   - Blueprint exists without sketch → skipped design phase
#   - FIX-type sketch exists without diagnose → skipped investigation
#
# Only enforces when positive evidence of a pipeline violation exists.
# Casual edits outside /yo are never blocked.

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

TODAY=$(date +%y%m%d)
SKETCHES_DIR="$CWD/.docs/sketches"
BLUEPRINTS_DIR="$CWD/.docs/blueprints"
DIAGNOSES_DIR="$CWD/.docs/diagnoses"

# --- DESIGN-THEN-CODE ---
# Blueprint without sketch = skipped the design phase.
# Only fires for std/deep pipelines (lightweight never creates blueprints).
if [ -d "$BLUEPRINTS_DIR" ]; then
  BLUEPRINT_COUNT=$(find "$BLUEPRINTS_DIR" -name "${TODAY}-*" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$BLUEPRINT_COUNT" -gt 0 ]; then
    SKETCH_COUNT=$(find "$SKETCHES_DIR" -name "${TODAY}-*" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SKETCH_COUNT" -eq 0 ]; then
      echo "DESIGN-THEN-CODE: Blueprint exists for today (${TODAY}-*) but no sketch found. Complete the sketch phase before implementing." >&2
      exit 2
    fi
  fi
fi

# --- INVESTIGATE-THEN-FIX ---
# FIX-type sketch without a matching diagnose = skipped investigation.
if [ -d "$SKETCHES_DIR" ]; then
  for sketch in "$SKETCHES_DIR/${TODAY}-"*; do
    [ -f "$sketch" ] || continue
    if head -20 "$sketch" | grep -qi "type:.*fix"; then
      if [ -d "$DIAGNOSES_DIR" ]; then
        DIAGNOSE_COUNT=$(find "$DIAGNOSES_DIR" -name "${TODAY}-*" -type f 2>/dev/null | wc -l | tr -d ' ')
      else
        DIAGNOSE_COUNT=0
      fi
      if [ "$DIAGNOSE_COUNT" -eq 0 ]; then
        echo "INVESTIGATE-THEN-FIX: FIX sketch exists but no diagnosis artifact found. Run the diagnose phase before fixing." >&2
        exit 2
      fi
      break
    fi
  done
fi

exit 0
