#!/bin/sh
# Enforces hard ban on placeholder text in .docs/ artifacts.
# Deterministic enforcement of a rule the model forgets ~30-40% of the time.

set -e

# Read tool input from stdin
INPUT=$(cat)

# Extract file path from tool input JSON
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

# Only check artifacts in .docs/ (all artifact directories)
case "$FILE_PATH" in
  */.docs/sketches/*|*/.docs/blueprints/*|*/.docs/retros/*|*/.docs/reviews/*|*/.docs/diagnoses/*|*/.docs/reports/*|*/.docs/research/*|*/.docs/evolve/*) ;;
  *) exit 0 ;;
esac

# Check for placeholder text (hard ban list from WHITEPAPER)
if grep -qiE '\bTBD\b|\bTODO\b|\bFIXME\b|\bHACK\b|\bXXX\b|to be determined|placeholder|not implemented|will decide later' "$FILE_PATH" 2>/dev/null; then
  MATCHES=$(grep -niE '\bTBD\b|\bTODO\b|\bFIXME\b|\bHACK\b|\bXXX\b|to be determined|placeholder|not implemented|will decide later' "$FILE_PATH" 2>/dev/null | head -5)
  echo "Placeholder text in artifact. Replace with specific content:"
  echo "$MATCHES"
  exit 2
fi
