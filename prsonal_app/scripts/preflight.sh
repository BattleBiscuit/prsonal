#!/usr/bin/env bash
# Run before marking any task complete or opening a PR.
# All three checks must pass.
set -euo pipefail

cd "$(dirname "$0")/.."

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
