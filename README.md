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
5. **Wait 5–30 minutes** for jsDelivr's multi-CDN propagation. Edges in different regions sync from their internal git mirror on independent schedules — purge clears edge cache instantly, but the new GitHub content takes ~5–30 min to land on every node. This is jsDelivr's documented behavior for branch refs (`@main`), not a bug.
6. Once propagated, every Unity client sees the new manifest at next launch, hash-diffs against its cache, and re-downloads only the changed levels.

### Faster propagation options (future)

If you need updates to land in seconds rather than minutes:
- **Tag-based releases** — push a new git tag (e.g. `v3`) and update the Unity `remoteBaseUrl` to use `@v3`. jsDelivr caches tags as immutable so they appear instantly. Costs: client-side URL update OR an additional indirection file.
- **SHA-pinned levels + raw.githubusercontent manifest** — manifest fetched from `raw.githubusercontent.com` (instant), levels fetched from `cdn.jsdelivr.net/.../@<commit-sha>/...` (immutable, instant on first request). This is the production-grade architecture; requires modest code changes in `RemoteLevelService.cs`.

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
