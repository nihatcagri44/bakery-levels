#!/usr/bin/env bash
# Regenerate manifest.json — schema v=3 — multi-variant.
#
# Scans these folders (each holds level_NNN.json files):
#   AVariantLevel/   BVariantLevel/   CVariantLevel/
#
# Output manifest groups level hashes per variant under "variants".
# repoSha is taken from git HEAD — clients use it to build cache-immutable
# jsDelivr URLs (cdn.jsdelivr.net/gh/USER/REPO@<repoSha>/<variant>/level_NNN.json).
#
# Usage:   ./regenerate-manifest.sh [version] [notes]
# Example: ./regenerate-manifest.sh                       # auto-bump version
#          ./regenerate-manifest.sh 10 "AVariant L042 hotfix"
set -euo pipefail

cd "$(dirname "$0")"

VARIANTS=(AVariantLevel BVariantLevel CVariantLevel)

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

write_variant_block() {
  local folder="$1"
  local first_inner=1
  echo "    \"$folder\": {"
  local count=0
  if [ -d "$folder" ]; then
    count=$(ls "$folder"/level_*.json 2>/dev/null | wc -l | tr -d ' ')
  fi
  echo "      \"totalLevels\": $count,"
  echo "      \"levels\": {"
  if [ "$count" -gt 0 ]; then
    for f in "$folder"/level_*.json; do
      hash=$(shasum -a 1 "$f" | cut -c1-8)
      num=$(basename "$f" .json | sed 's/level_//')
      if [ $first_inner -eq 1 ]; then
        first_inner=0
      else
        echo ","
      fi
      printf "        \"%s\": \"%s\"" "$num" "$hash"
    done
    echo ""
  fi
  echo "      }"
  echo -n "    }"
}

{
  echo "{"
  echo "  \"schemaVersion\": 3,"
  echo "  \"version\": $VERSION,"
  echo "  \"updatedAt\": \"$UPDATED_AT\","
  echo "  \"repoSha\": \"$REPO_SHA\","
  echo "  \"notes\": \"$NOTES\","
  echo "  \"variants\": {"
  first_variant=1
  for v in "${VARIANTS[@]}"; do
    if [ $first_variant -eq 1 ]; then
      first_variant=0
    else
      echo ","
    fi
    write_variant_block "$v"
  done
  echo ""
  echo "  }"
  echo "}"
} > manifest.json

echo "→ Wrote manifest.json (version=$VERSION, repoSha=${REPO_SHA:0:8})"
for v in "${VARIANTS[@]}"; do
  c=$(ls "$v"/level_*.json 2>/dev/null | wc -l | tr -d ' ')
  echo "    $v: $c levels"
done
