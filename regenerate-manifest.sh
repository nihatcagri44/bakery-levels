#!/usr/bin/env bash
# Regenerate manifest.json from current levels/*.json contents.
# Sets repoSha to the current git HEAD — so the manifest immutably references
# the commit it was generated from. The Unity client uses this SHA to fetch
# level files from a cache-immutable jsDelivr URL.
#
# Usage:   ./regenerate-manifest.sh [new-version-number] [notes]
# Example: ./regenerate-manifest.sh                       # auto-bump version
#          ./regenerate-manifest.sh 5 "L016 difficulty tweak"
set -euo pipefail

cd "$(dirname "$0")"

VERSION="${1:-}"
NOTES="${2:-Regenerated $(date -u +%Y-%m-%dT%H:%M:%SZ)}"

REPO_SHA=$(git rev-parse HEAD 2>/dev/null || echo "")
if [ -z "$REPO_SHA" ]; then
  echo "WARNING: not in a git repo — repoSha will be empty (clients will fall back to @main)" >&2
fi

if [ -z "$VERSION" ]; then
  CUR=$(grep -m1 '"version"' manifest.json 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "0")
  VERSION=$((CUR + 1))
  echo "→ Auto-bumping version: $CUR → $VERSION"
fi

UPDATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "{"
  echo "  \"schemaVersion\": 2,"
  echo "  \"version\": $VERSION,"
  echo "  \"updatedAt\": \"$UPDATED_AT\","
  echo "  \"repoSha\": \"$REPO_SHA\","
  TOTAL=$(ls levels/level_*.json 2>/dev/null | wc -l | tr -d ' ')
  echo "  \"totalLevels\": $TOTAL,"
  echo "  \"notes\": \"$NOTES\","
  echo "  \"levels\": {"
  FIRST=1
  for f in levels/level_*.json; do
    hash=$(shasum -a 1 "$f" | cut -c1-8)
    num=$(basename "$f" .json | sed 's/level_//')
    if [ $FIRST -eq 1 ]; then
      FIRST=0
    else
      echo ","
    fi
    printf "    \"%s\": \"%s\"" "$num" "$hash"
  done
  echo ""
  echo "  }"
  echo "}"
} > manifest.json

echo "→ Wrote manifest.json (version=$VERSION, repoSha=${REPO_SHA:0:8}, levels=$TOTAL)"
