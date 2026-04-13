#!/bin/sh
# run-test.sh — Run a single skill triggering test
# Usage: ./run-test.sh <expected-type> <prompt-file> [timeout]
#
# Runs claude with the prompt via /yo and checks classification output.
# Requires: claude CLI installed and authenticated.

set -e

EXPECTED_TYPE="$1"
PROMPT_FILE="$2"
TIMEOUT="${3:-120}"

if [ -z "$EXPECTED_TYPE" ] || [ -z "$PROMPT_FILE" ]; then
  echo "Usage: $0 <BUILD|FIX|EXPLORE|REVIEW> <prompt-file> [timeout]"
  exit 1
fi

[ ! -f "$PROMPT_FILE" ] && echo "Prompt file not found: $PROMPT_FILE" && exit 1

PROMPT=$(cat "$PROMPT_FILE")
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_NAME=$(basename "$PROMPT_FILE" .txt)

echo "Testing: $TEST_NAME (expected: $EXPECTED_TYPE)"

# Run claude with the plugin, capture output
OUTPUT=$(timeout "$TIMEOUT" claude -p "/yo $PROMPT" \
  --plugin "$PLUGIN_ROOT" \
  --output-format json \
  2>/dev/null || true)

# Check classification in output
if echo "$OUTPUT" | grep -qi "type.*${EXPECTED_TYPE}\|classified.*${EXPECTED_TYPE}\|pipeline.*${EXPECTED_TYPE}"; then
  echo "  PASS: Classified as $EXPECTED_TYPE"
  exit 0
else
  # Show first 500 chars of output for debugging
  SNIPPET=$(echo "$OUTPUT" | head -c 500)
  echo "  FAIL: Expected $EXPECTED_TYPE"
  echo "  Output snippet: $SNIPPET"
  exit 1
fi
