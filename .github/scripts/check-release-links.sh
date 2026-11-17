#!/usr/bin/env bash
# Check that every release page under releases/ links the GitHub release tag
# it documents, e.g. https://github.com/os2ai/helm-deployments/releases/tag/0.5.0
# Pages for releases not yet published as stable may link an RC tag of the same
# version (0.8.0-rc.0 for a page titled "Release 0.8.0").
set -u

status=0
for page in releases/release*.md; do
  if [ ! -e "$page" ]; then
    echo "::error::No release pages found under releases/ (moved glob?)"
    exit 1
  fi
  if ! grep -Eq 'helm-deployments/releases/tag/[0-9]+\.[0-9]+' "$page"; then
    echo "::error file=$page::Missing link to the GitHub release tag (https://github.com/os2ai/helm-deployments/releases/tag/X.Y.Z)"
    status=1
    continue
  fi
  version=$(sed -n 's/^title: Release \([0-9][0-9.]*\).*/\1/p' "$page" | head -n1)
  if [ -z "$version" ]; then
    echo "::error file=$page::Cannot read release version from front matter title"
    status=1
    continue
  fi
  escaped=${version//./\\.}
  if ! grep -Eq "helm-deployments/releases/tag/${escaped}([^-0-9]|-[^-]|$)" "$page"; then
    echo "::error file=$page::Release tag link does not point to ${version} (or its RC)"
    status=1
  fi
done
exit "$status"
