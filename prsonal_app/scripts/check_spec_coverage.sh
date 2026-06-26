#!/usr/bin/env bash
# Verifies every spec in specs/<category>/ has a test file AND that every
# AC-NNN id in the spec appears in that test file.
# Skips specs/_templates/ and top-level specs/ files (e.g. architecture.md).
# Exits 1 if any gap is found.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPECS_DIR="$ROOT/specs"
TESTS_DIR="$ROOT/test"
ERRORS=0

# Only process files exactly one level inside a category subdirectory.
while IFS= read -r spec; do
  category=$(basename "$(dirname "$spec")")
  base=$(basename "$spec" .md)

  case "$category" in
    screens)  test_file="$TESTS_DIR/$category/${base}_screen_test.dart" ;;
    widgets)  test_file="$TESTS_DIR/$category/${base}_widget_test.dart" ;;
    *)        test_file="$TESTS_DIR/$category/${base}_test.dart" ;;
  esac

  # 1. Test file must exist
  if [[ ! -f "$test_file" ]]; then
    echo "MISSING FILE : $test_file"
    echo "              (spec: ${spec#$ROOT/})"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # 2. Every AC-NNN in the spec must appear in the test file
  while IFS= read -r ac_id; do
    if ! grep -qF "$ac_id" "$test_file"; then
      echo "MISSING TEST : $ac_id not found in ${test_file#$ROOT/}"
      echo "              (spec: ${spec#$ROOT/})"
      ERRORS=$((ERRORS + 1))
    fi
  done < <(grep -oE 'AC-[0-9]+' "$spec" | sort -u)

done < <(find "$SPECS_DIR" -mindepth 2 -maxdepth 2 -name "*.md" \
           ! -path "$SPECS_DIR/_templates/*" \
           | sort)

echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "✗ $ERRORS coverage gap(s) found."
  exit 1
else
  echo "✓ All specs covered — test files present and all AC IDs matched."
fi
