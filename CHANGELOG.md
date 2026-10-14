# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
project stages are defined in `PLAN.md`.

## [Unreleased]

## [0.1.0] — 2026-10-14 — Stage 0: Bootstrap & Decisions

### Added
- `emergent.toml`: `game-clock` heartbeat (exec-source, 2s) → `tick-log` sink (exec-sink + jq).
- `justfile` tasks: `dev`, `tick`, `test`, `lint`, `fmt` (fish-compatible).
- Layout stubs: `rubrics/behavior_rubric.json` (v0), `prompts/`, `handlers/`, `web/index.html`, `tests/`, `docs/EVENT_CATALOG.md`.
- `README.md`: Stage 0 decisions (emergent 0.15.0, Python handlers, static+SSE UI, local LLM + JEV fallback) and run path.
- `.gitignore`: tick logs, venv, event DB.

### Verified
- `emergent --version` → `emergent 0.15.0`.
- Live boot: 4 heartbeats observed over ~8s (`{"tick":"…"}` every 2s).

### Fixed
- `exec-source` requires `--shell sh` for the `date +%s` command (failed with `No such file or directory` without it).
