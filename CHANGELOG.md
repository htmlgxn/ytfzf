# Changelog

## Unreleased

### Added

- Hybrid youtube backend fallback with ordered backend selection.
- New backend controls:
  - `--backend-order=<csv>`
  - `--backend-strict`
  - `--backend-timeout=<sec>`
  - `--inv-cache-ttl=<sec>`
- New config defaults:
  - `backend_order=invidious,youtube-html,yt-dlp`
  - `backend_timeout_seconds=12`
  - `invidious_cache_ttl_seconds=86400`
  - `backend_strict=0`
- `make check` quality gate.
- `MIGRATION.md`.

### Changed

- CI workflow updated to modern checkout action and check stage.
- Invidious instance cache now honors TTL before refresh.

### Fixed

- `addons/scrapers/scrape_list` now has a shell shebang.
- CI docs build now uses `make doc`.
