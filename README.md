# bakery-levels

Remote level JSON content for **Bakery Factory** (gamejam1). Served via jsDelivr CDN + GitHub Contents API, consumed by the Unity client's `RemoteLevelService`. Source-of-truth for the **A, B, and C** AB-test variants.

## Live URLs

- Manifest (instant, no cache):
  `https://api.github.com/repos/nihatcagri44/bakery-levels/contents/manifest.json` (with `Accept: application/vnd.github.raw`)
- Level (SHA-pinned, immutable):
  `https://cdn.jsdelivr.net/gh/nihatcagri44/bakery-levels@<repoSha>/<VariantFolder>/level_NNN.json`

## How updates flow (drag-drop)

The **upstream** source-of-truth is `DawnbrightGames/gamejam1/gamejam1Unity/Assets/Resources/{A,B,C}VariantLevel/`. When a level designer pushes to that repo's `main` branch:

1. **gamejam1 Action** (`sync-bakery-levels.yml`) — copies the changed JSON files into the matching subfolder here.
2. **bakery-levels Action** (`purge-jsdelivr.yml`) — runs `regenerate-manifest.sh`, commits the new manifest with `[skip ci]`, purges jsDelivr cache.
3. Unity clients see the update on their next launch (~60–90 s end-to-end).

You can also edit JSONs directly via the GitHub web UI — the same pipeline kicks in (Action regenerates manifest), just without the upstream gamejam1 sync step.

## Repository layout

```
/AVariantLevel/level_001.json  …  level_200.json   (control group — pre-baked + procedural)
/BVariantLevel/level_001.json  …  level_200.json   (JSON-based variant)
/CVariantLevel/level_001.json  …  level_200.json   (lean honeymoon + new monetization)
/manifest.json                                     (single global manifest, schema v=3)
/regenerate-manifest.sh                            (multi-variant manifest generator)
```

## Manifest schema (v=3)

```json
{
  "schemaVersion": 3,
  "version": 100,
  "updatedAt": "2026-05-14T20:42:13Z",
  "repoSha": "ca8071a73ffa67f25de12fbc6b3060545725b139",
  "notes": "Free-form changelog",
  "variants": {
    "AVariantLevel": {
      "totalLevels": 200,
      "levels": {
        "001": "98d7cfe3",
        "002": "be027674"
      }
    },
    "BVariantLevel": { "totalLevels": 200, "levels": { } },
    "CVariantLevel": { "totalLevels": 200, "levels": { } }
  }
}
```

- `version` — global counter; the Unity client uses this to know when ANY variant changed.
- `repoSha` — the commit SHA the manifest was generated from; clients build cache-immutable level URLs as `cdn.jsdelivr.net/gh/USER/REPO@<repoSha>/<variant>/level_NNN.json`.
- `variants[FOLDER].levels[NNN]` — per-file SHA-1 prefix (8 hex chars); the client diffs this against its cached hash to know which levels need re-download.

## Notes

- This repo is the **runtime source of truth** for level data, not the build-time `Resources/<X>VariantLevel/` snapshot. The bundled snapshot is kept in the Unity build so the game works fully offline.
- Only edit files inside `AVariantLevel/`, `BVariantLevel/`, `CVariantLevel/`. Don't add other folders or rename — the client and workflow assume this structure.
