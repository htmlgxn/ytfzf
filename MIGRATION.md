# Migration Guide

## Compatibility Policy

This modernization cycle is strict-compat by default.

- Existing CLI flags continue to work.
- Existing config variables continue to work.
- Existing addon loading paths and function contracts continue to work.
- New behavior is additive and opt-in where possible.

## Deprecation Policy

Deprecations follow a two-step process.

1. Introduce additive replacement and keep legacy behavior.
2. Emit warnings and document migration before any removal.

No removals are planned in this cycle.

## New Backend Controls

The youtube search scraper now supports ordered backend fallback.

- `backend_order` (default: `invidious,youtube-html,yt-dlp`)
- `backend_timeout_seconds` (default: `12`)
- `invidious_cache_ttl_seconds` (default: `86400`)
- `backend_strict` (default: `0`)

CLI overrides:

- `--backend-order=<csv>`
- `--backend-strict`
- `--backend-timeout=<sec>`
- `--inv-cache-ttl=<sec>`

## Runtime Notes

- `--force-youtube` and `--force-invidious` are still supported.
- Backend failures are recorded in `backend-failures.log` under the session temp directory.
