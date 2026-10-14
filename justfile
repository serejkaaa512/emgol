# emgol tasks (Stage 0). Run with `just <task>`. Shell: fish-compatible (sh lines).

# Boot the engine (foreground, verbose). Ctrl-C to stop.
dev:
    emergent -c emergent.toml -v

# Smoke: boot engine 12s in background, show event-store log tail, then stop it.
tick:
    sh -c 'emergent -c emergent.toml > /tmp/emgol-tick.log 2>&1 & echo $! > /tmp/emgol-tick.pid; sleep 10; kill $(cat /tmp/emgol-tick.pid); sleep 1; echo "--- engine log ---"; tail -n 20 ~/.local/share/emergent/emgol/emergent.log 2>/dev/null || tail -n 20 /tmp/emgol-tick.log'

# Layout + config smoke test (no engine needed except --version record).
test:
    sh -c 'set -e; test -f emergent.toml; test -f rubrics/behavior_rubric.json; test -f docs/EVENT_CATALOG.md; test -f web/index.html; jq -e . rubrics/behavior_rubric.json > /dev/null; emergent --version; echo STAGE0-OK'

# TOML syntax check (python stdlib) + rubric JSON check.
lint:
    sh -c 'python3 -c "import tomllib; tomllib.load(open(\"emergent.toml\",\"rb\")); print(\"emergent.toml OK\")"; jq -e . rubrics/behavior_rubric.json > /dev/null && echo "rubric JSON OK"'

# Format check placeholder: no Python/Rust sources yet (Stage 2+ adds ruff/black/pytest or cargo fmt).
fmt:
    sh -c 'echo "Stage 0: nothing to format (no handlers yet)"'
