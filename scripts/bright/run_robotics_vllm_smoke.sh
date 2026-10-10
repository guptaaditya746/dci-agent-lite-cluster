#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

# Auto-load .env from repo root if present
if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    source "$REPO_ROOT/.env"
    set +a
fi

uv run python "$REPO_ROOT/scripts/bcplus_eval/run_bcplus_eval.py" \
  --enable-ir \
  --dataset "$REPO_ROOT/data/dci-bench/data/bright_robotics/bright_robotics.jsonl" \
  --output-root "$REPO_ROOT/outputs/bright/robotics_vllm_smoke" \
  --corpus-dir "$REPO_ROOT/corpus/bright_corpus/robotics" \
  --package-dir "$REPO_ROOT/pi-mono/packages/coding-agent" \
  --agent-dir "$REPO_ROOT/pi-mono/.pi/agent" \
  --provider vllm \
  --model qwen-chat \
  --tools read,bash \
  --max-turns 80 \
  --max-concurrency 1 \
  --runtime-context-level level3 \
  --pi-thinking-level high \
  --node-max-old-space-size-mb 8192 \
  --limit 3
