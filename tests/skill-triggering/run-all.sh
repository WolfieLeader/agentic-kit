#!/bin/sh
# run-all.sh — Run all skill triggering tests
# Reports pass/fail for each prompt and exits with failure if any fail.
#
# Requires: claude CLI installed and authenticated.
# Note: Each test invokes claude, so this suite has real token cost.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
PASSED=0
FAILED=0
ERRORS=""

run_test() {
  TYPE="$1"
  FILE="$2"
  if sh "$SCRIPT_DIR/run-test.sh" "$TYPE" "$PROMPTS_DIR/$FILE" 60; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    ERRORS="${ERRORS}\n  - $FILE (expected $TYPE)"
  fi
  echo ""
}

echo "=== agentic-kit Skill Triggering Tests ==="
echo ""

# BUILD tests
run_test "BUILD" "build-feature.txt"
run_test "BUILD" "build-refactor.txt"

# FIX tests
run_test "FIX" "fix-bug.txt"
run_test "FIX" "fix-regression.txt"

# EXPLORE tests
run_test "EXPLORE" "explore-understanding.txt"
run_test "EXPLORE" "explore-comparison.txt"

# REVIEW tests
run_test "REVIEW" "review-module.txt"
run_test "REVIEW" "review-pr.txt"

echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ "$FAILED" -gt 0 ]; then
  printf "Failures:%b\n" "$ERRORS"
  exit 1
fi

echo "All tests passed."
exit 0
