# emgol — Emergent Ecosystem: Implementation Plan

Source: `Idea.md` (Emergent Ecosystem / Digital Terrarium on Emergent event-driven engine + LLM agents).
Repo state: only `Idea.md`, `README.md`, `LICENSE`. No code yet.

Goal: web panel with living grid, event log, balance graphs; player injects text laws; per-entity LLM/JEV judges decide locally; behavior emerges from event topology, no monolith.

## Stage 0 — Bootstrap & Decisions

1. Decide runtime: real `emergent` binary; handlers in Python; UI static+SSE; LLM provider (OpenAI local) + local fallback for JEV.
2. Create layout: `emergent.toml`, `rubrics/behavior_rubric.json`, `prompts/`, `handlers/`, `web/`, `tests/`, `docs/EVENT_CATALOG.md`.
3. Add tasks: `dev`, `tick`, `test`, `lint`, `fmt`. Document run in `README.md`.
4. Done when: `emergent -c emergent.toml` version recorded, run path documented.

## Stage 1 — Event Catalog (Gate 1)

Formalize in `docs/EVENT_CATALOG.md` + JSON Schemas (past-tense names, `tick_id` everywhere, no private state):

- `world.tick_elapsed` `{tick_id, global_conditions}` — from `game-clock` (2s), to `grid-manager`.
- `entity.spawned` `{entity_id, species, gender, position, stats, traits, personality_context}` — from `ui-gateway` / mate engine, to `grid-manager`.
- `entity.perceived_environment` `{entity_id, current_biome, status, visible_entities, environmental_alerts}` — from `grid-manager`+splitter, to judges.
- `agent.decision_made` `{entity_id, tick_id, action: hunt|move|communicate|mate|idle, target_id?, dx?, dy?, message?}` — from judges, to `route-*`.
- `action.failed` `{entity_id, tick_id, reason, ...}` — from physics, feedback to `grid-manager`.
- `entity.confused` `{entity_id, tick_id, raw_output}` — from `route-invalid`, to `grid-manager`.
- `world.state_updated` `{tick_id, entities, diff}` — from join, to SSE sink.
- `player.law_injected` `{law_id, text, target?}` — from `ui-gateway`.
- `entity.reproduction_ready` `{entity_id, partner_id}` — from JEV scan, to `route-mate`.

## Stage 2 — Minimal Game Loop (tick → grid → join → UI)

1. `game-clock`: interval-source every 2s, monotonic `tick_id`.
2. `grid-manager`: 10x10 map + append-only `ecosystem_events.db`; handles spawn/deltas/failed.
3. `entity-splitter` (stream-runner): fan-out to N `entity.perceived_environment` (stub scan first).
4. Stub judges (always move-random) + `route-hunt/move/communicate/mate` as jq `.action==` filters + `route-invalid`.
5. Join on `tick_id` → `world.state_updated` → SSE. All exec-handlers with `set -o pipefail`; failures → `action.failed`, never crash tick.
6. Done when: 10 ticks with 2 stubs, SSE updates, DB replay matches.

## Stage 3 — Brains: fast-brain-jev + deep-brain-llm

1. `rubrics/behavior_rubric.json`: weights per species/gender/biome/enemy (e.g. Ragnar vs robot 0.9).
2. `fast-brain-jev`: prompt (role+status+options A/B/C) → single-line JSON `{action, target_id?, confidence}` with `--publish-as agent.decision_made`; malformed → `entity.confused`.
3. `deep-brain-llm`: LLM API with timeout+1 retry+JSON mode; for communicate, law reaction, JEV confidence<0.6 fallback. System prompt in `prompts/deep_brain_system.md`.
4. 10 personality files encoding matrix: robots trust humans/fear vikings; vikings respect centaurs/hate robots; humans seek turtles/fear centaurs; centaurs respect turtles/fear humans; turtles neutral, protect centaurs.
5. Done when: Ragnar attacks robot, Elena communicates, invalid output doesn't stall tick (mock LLM in tests).

## Stage 4 — Physics Engines (deterministic)

1. `physics-move`: bounds + biome cost (mountains 2 ticks except centaurs; lake -5HP robots; forest regen Kirena; factory charge robots).
2. `physics-attack`: range (Chiron 2-3, 4 on mountain; melee 1), damage (Ragnar x2 if HP<30, Tortuga reflect 25%, Lagerta block, Ada shield).
3. `physics-mate`: same species + opposite gender + adjacent (bonus in Valley) → new `entity.spawned`.
4. `physics-communicate`: danger/ally signals, Elena success bonus, visible next tick.
5. Pure `event_in → events_out`, no hidden state. Unit-test each + failed-feedback loop.



## Stage 5 — Map, Biomes & Seed

1. Fix 10x10 map: Lake (robot -5HP, turtle buff), Forest (centaur regen), Mountains (2-tick cost, Chiron range 4), Factory (`power_cells`+charge, Alex `scrap_metal`), Valley (neutral, diplomacy/mating bonus).
2. Seed script: 10 founders (all species x M/F) + resources. Inject `current_biome`+`environmental_alerts` into every perception (fixture: Idea.md L247-262).
3. Done when: seed + 20 ticks clean; biome behavior visible in logs.

## Stage 6 — Player Laws (ui-gateway)

1. `POST /api/law {text, target?}` → `player.law_injected`; grid tags cells; stream-runner injects text into alerts + deep-LLM context for N ticks.
2. UI input + presets (Drought, Fire, Poison grass, Predator afraid of blue).
3. Done when: "Grass in A poisonous" → damage + `action.failed` + danger broadcast + wolf migration with zero migration code (emergence demo).

## Stage 7 — Web UI

1. `web/index.html`: 10x10 grid (emoji per species/gender, biome colors, HP bars); tick counter, SSE event log, law input, spawn buttons.
2. `web/app.js`: `EventSource('/sse')` on `world.state_updated` + population graphs. Endpoints: `GET /sse`, `POST /api/spawn`, `POST /api/law`, `GET /api/state`.
3. Done when: 2 ticks/s visible, law/spawn work, <1s lag.

## Stage 8 — Persistence, Replay, Observability

1. `ecosystem_events.db` appends every event (`tick_id`, `ts`, `type`, `payload`); replay `--from-tick N` with mocked LLM; kill-9 restart gives identical state.
2. Metrics: tick latency, JEV/LLM counts, invalid rate, population/species. Checks: log test, concurrency-from-topology, pipefail.
3. Done when: replay test passes.

## Stage 9 — Milestones, QA, Balancing

- M1 walking skeleton (Stage 2, stubs wander). M2 smart keg (+JEV+physics, Ragnar hunts). M3 playable (+biomes+laws+UI, poison-grass migration).
- QA: `cargo fmt/clippy/test` (Rust) or `ruff/black/pytest` (Python), `shellcheck`, jq schema CI.
- Balance: no species extinct in 100 ticks unaided. Docs: `README.md`, `docs/ARCHITECTURE.md`, finalize catalog.

## Next Actions

- [ ] Choose engine + LLM provider, record in README.
- [ ] Write `docs/EVENT_CATALOG.md` schemas (Stage 1).
- [ ] Scaffold `emergent.toml`: clock → grid → splitter → stub → routes → physics → join → SSE (Stage 2).
- [ ] Add `behavior_rubric.json` + Ragnar JEV template (Idea.md L194-201).
- [ ] Stub `web/index.html` with SSE + seed script + replay test.
- First PR: Stages 0-1 only (docs + layout), no game logic.
