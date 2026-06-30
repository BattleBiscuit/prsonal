#!/usr/bin/env bash
# Point this repo's git hooks at the committed, version-controlled hooks in
# prsonal_app/scripts/git-hooks. Run once per clone:
#
#   ./prsonal_app/scripts/install-hooks.sh
#
# This enables the pre-commit auto-formatter so unformatted Dart can't be
# committed (and the CI `format` job stops failing on it).
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
hooks_dir="prsonal_app/scripts/git-hooks"

chmod +x "$repo_root/$hooks_dir"/* 2>/dev/null || true
git -C "$repo_root" config core.hooksPath "$hooks_dir"

echo "✓ git hooks installed (core.hooksPath = $hooks_dir)"
echo "  pre-commit will auto-format staged Dart files in prsonal_app/lib."
