#!/usr/bin/env bash
set -e

: "${MODEL_FILE:?MODEL_FILE not set — point it to a GGUF inside /models, e.g. /models/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf}"

if [ ! -f "${MODEL_FILE}" ]; then
    echo "✗ Model file not found: ${MODEL_FILE}"
    echo "  Run 'make download' on the host first, or mount your GGUF into /models."
    exit 1
fi

# 16 GB VRAM defaults — tune via env vars at `docker run`.
# Qwen3-30B-A3B has 48 layers. n-cpu-moe pushes that many layers'
# expert blocks onto CPU; lower = more on GPU = faster but tighter VRAM.
N_GPU_LAYERS="${N_GPU_LAYERS:-999}"
N_CPU_MOE="${N_CPU_MOE:-12}"
CTX_SIZE="${CTX_SIZE:-131072}"
CACHE_TYPE_K="${CACHE_TYPE_K:-q4_0}"
CACHE_TYPE_V="${CACHE_TYPE_V:-q4_0}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
MODEL_ALIAS="${MODEL_ALIAS:-$(basename "${MODEL_FILE}" .gguf)}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

echo "▶ Starting llama-server"
echo "  model:         ${MODEL_FILE}"
echo "  ctx:           ${CTX_SIZE}"
echo "  n-gpu-layers:  ${N_GPU_LAYERS}"
echo "  n-cpu-moe:     ${N_CPU_MOE}"
echo "  kv cache:      k=${CACHE_TYPE_K} v=${CACHE_TYPE_V}"

exec llama-server \
    --host "${HOST}" \
    --port "${PORT}" \
    --model "${MODEL_FILE}" \
    --alias "${MODEL_ALIAS}" \
    --n-gpu-layers "${N_GPU_LAYERS}" \
    --n-cpu-moe "${N_CPU_MOE}" \
    --ctx-size "${CTX_SIZE}" \
    --cache-type-k "${CACHE_TYPE_K}" \
    --cache-type-v "${CACHE_TYPE_V}" \
    --flash-attn on \
    --no-mmap \
    --mlock \
    --jinja \
    ${EXTRA_ARGS}
