#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
RELEASE_TAG="${RELEASE_TAG:-}"
GITHUB_REPO="justacalico/fnaf-flutter"
PROJECT_DIR="${CI_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR"
if [ -z "$RELEASE_TAG" ]; then
  RELEASE_TAG=$(gh release view -R "$GITHUB_REPO" --json tagName -q .tagName)
fi
echo "Syncing GitHub release: $RELEASE_TAG"
rm -rf release-assets
mkdir -p release-assets
gh release download "$RELEASE_TAG" -R "$GITHUB_REPO" --dir release-assets
cd release-assets && sha256sum * > "$PROJECT_DIR/SHA256SUMS.txt" && cd "$PROJECT_DIR"
cp SHA256SUMS.txt release-assets/
ls -la release-assets/
glab release delete "$RELEASE_TAG" -R "$CI_PROJECT_PATH" -y 2>/dev/null || true
glab release create "$RELEASE_TAG" \
  --name "FNAF Flutter $RELEASE_TAG" \
  --notes "See CHANGELOG.md. Assets mirrored from the GitHub release." \
  "$PROJECT_DIR/release-assets"/*
