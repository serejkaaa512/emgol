# emgol
Emergent Game of Life — Emergent Ecosystem / Digital Terrarium on the Emergent event-driven engine + LLM agents.

See `PLAN.md` (stages), `Idea.md` (concept), and `CHANGELOG.md` (history). This repo is at **Stage 0 — Bootstrap**.

## Stage 0 decisions

| Decision | Choice | Why |
|---|---|---|
| Runtime | Real `emergent` binary, v0.15.0 | Per PLAN.md: behavior lives in event topology, no monolith |
| Handlers | Python (`emergent-client` SDK) + `exec-*` marketplace primitives with `set -o pipefail` shell bodies | Stage 2 game loop is jq filters + small scripts; Python for brains/physics (Stages 3–4) |
| UI | Static `web/` + SSE (`sse-sink`) | No framework needed for 10x10 grid + event log |
| LLM provider | OpenAI-compatible local endpoint; local fallback for JEV (`jev-handler` marketplace primitive) | Keeps `deep-brain-llm` swappable; tests mock the LLM |
| Task runner | `just` (`justfile`) | `just` 1.34.0 available; fish-compatible recipes |

## Layout

```
emergent.toml                  # engine config (Stage 0: game-clock heartbeat + tick-log sink)
rubrics/behavior_rubric.json   # STUB v0 — real weights in Stage 3
prompts/                       # deep-brain-llm system prompt lands in Stage 3
handlers/                      # exec-handler bodies / python handlers land in Stage 2+
web/                           # 10x10 grid + SSE client lands in Stage 7
tests/                         # pytest suite lands in Stage 2+
docs/EVENT_CATALOG.md          # STUB — full schemas in Stage 1 (Gate 1)
```

## Run

Prerequisites: `emergent` binary + marketplace primitives (`exec-source`, `exec-sink`, …) installed.

```sh
# record engine version (Stage 0 done-criterion)
emergent --version            # emergent 0.15.0 (recorded 2026-10-14)

# boot engine (foreground)
just dev                      # = emergent -c emergent.toml -v

# 10s smoke: boots engine, tails event log
just tick

# layout/config smoke test
just test

# TOML + JSON syntax check
just lint
just fmt                      # no-op until Stage 2 sources exist
```

Engine event store: `~/.local/share/emergent/emgol/` (`events.db` + daily JSON logs).

## Stage 0 done-criterion

- [x] `emergent --version` → `emergent 0.15.0` (recorded above)
- [x] Run path documented (this file)
- [x] Live boot verified (`just tick` shows heartbeat events) — `exec.output` → `tick-log` ticks every 2s, verified 2026-10-14

