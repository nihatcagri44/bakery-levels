#!/usr/bin/env bash
# Regenerate manifest.json from current levels/*.json contents.
# Usage:   ./regenerate-manifest.sh [new-version-number] [notes]
# Example: ./regenerate-manifest.sh 2 "L016 difficulty tweak"
set -euo pipefail

cd "$(dirname "$0")"

VERSION="${1:-}"
NOTES="${2:-Regenerated $(date -u +%Y-%m-%dT%H:%M:%SZ)}"

if [ -z "$VERSION" ]; then
  CUR=$(grep -m1 '"version"' manifest.json | grep -oE '[0-9]+' | head -1)
  VERSION=$((CUR + 1))
  echo "→ Auto-bumping version: $CUR → $VERSION"
fi

UPDATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "{"
  echo "  \"schemaVersion\": 1,"
  echo "  \"version\": $VERSION,"
  echo "  \"updatedAt\": \"$UPDATED_AT\","
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

echo "→ Wrote manifest.json (version=$VERSION, levels=$TOTAL)"
