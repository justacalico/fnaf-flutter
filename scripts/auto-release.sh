#!/bin/bash
set -euo pipefail
git fetch origin main "+refs/tags/*:refs/tags/*"
git checkout -B main origin/main
git clean -fd
if ! version=$(cog bump --dry-run --auto 2>/dev/null) || [ -z "$version" ]; then
  echo "No version bump required, skipping release"
  exit 0
fi
echo "Bumping to $version"
cog bump --auto --hook-profile ci
TAG=$(git tag --points-at HEAD | head -n1)
[ -n "$TAG" ] || { echo "cog bump did not create a tag" >&2; exit 1; }
push_bump() { git push -o ci.skip origin HEAD:main; }
if ! push_bump; then
  git fetch origin main "+refs/tags/*:refs/tags/*"
  git rebase origin/main
  git tag -f "$TAG"
  push_bump
fi
git push origin "$TAG"
echo "Released $TAG"
