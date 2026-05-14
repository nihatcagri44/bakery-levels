# bakery-levels

Remote level JSON content for **Bakery Factory** (gamejam1). Served via jsDelivr CDN, consumed by the Unity client's `RemoteLevelService`.

## Live URLs

- Manifest: `https://cdn.jsdelivr.net/gh/nihatcagri44/bakery-levels@main/manifest.json`
- Level: `https://cdn.jsdelivr.net/gh/nihatcagri44/bakery-levels@main/levels/level_016.json`

## How to update a level (drag-drop flow)

1. Open the level JSON on GitHub (e.g. `levels/level_016.json`)
2. Click the pencil ✏️ icon → paste new content → **Commit changes**
   (Or drag a new file over the existing one via "Add file → Upload files")
3. Update `manifest.json`:
   - Bump `version` (e.g. `1` → `2`)
   - Update `updatedAt` to current ISO timestamp
   - Update the hash entry for the changed level under `"levels"` (first 8 chars of SHA-1)
4. Commit → GitHub Action auto-purges jsDelivr cache (~10–30 s)
5. Next time the Unity client launches, it sees the new version and refreshes only the changed levels

## Manifest schema

```json
{
  "schemaVersion": 1,
  "version": 1,
  "updatedAt": "2026-05-14T00:00:00Z",
  "totalLevels": 200,
  "notes": "Free-form changelog",
  "levels": {
    "001": "5bdd5405",
    "002": "8652a32a"
  }
}
```

- `version` — global counter; the Unity client compares this to its cached `lastSeenVersion`
- `levels[NNN]` — per-file SHA-1 prefix (8 hex chars). The client uses this to detect which individual files changed when version bumps, so it only re-downloads what's different.

## Notes

- This repo is the **runtime source of truth** for level data, not the build-time `Resources/CVariantLevel/` snapshot. The bundled snapshot is kept in the Unity build so the game works fully offline.
- Don't add files outside `levels/` or `manifest.json` to root — the client doesn't know what to do with them.
