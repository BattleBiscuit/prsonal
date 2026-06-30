#!/usr/bin/env bash
# Run before marking any task complete or opening a PR.
# All checks must pass.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "── dart format (check) ─────────────────────────────"
# Mirrors the CI `format` job exactly (dart format --set-exit-if-changed lib).
# Catching it here means a formatting slip fails locally — before the push —
# instead of turning the pipeline red.
if ! dart format --output none --set-exit-if-changed lib; then
  echo ""
  echo "✗ lib/ is not formatted. Fix it with:  dart format lib"
  exit 1
fi

echo ""
echo "── flutter analyze ─────────────────────────────────"
flutter analyze --fatal-infos

echo ""
echo "── flutter test ────────────────────────────────────"
flutter test

echo ""
echo "── spec coverage ───────────────────────────────────"
./scripts/check_spec_coverage.sh

echo ""
echo "✓ Preflight passed."
