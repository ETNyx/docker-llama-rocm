ROCM_GPU = gfx1201
HSA_OVERRIDE_GFX_VERSION = 12.0.1

# Default model — override with: make run MODEL_FILE=...
MODEL_FILE ?= /models/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
HF_REPO    ?= unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
HF_PATTERN ?= *Q4_K_M*

PORT       ?= 8080
N_CPU_MOE  ?= 41
CTX_SIZE   ?= 131072

# ------------------------------------------------------------------
# Model presets — `make run-coder` / `make run-3.6` / `make download-*`
# ------------------------------------------------------------------
CODER_REPO    = unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
CODER_PATTERN = *Q4_K_M*
CODER_FILE    = /models/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf

QWEN36_REPO    = unsloth/Qwen3.6-35B-A3B-GGUF
QWEN36_PATTERN = *UD-Q4_K_XL*
QWEN36_FILE    = /models/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf

GEMMA4_REPO    = unsloth/gemma-4-E4B-it-GGUF
GEMMA4_PATTERN = *Q8_0*
GEMMA4_FILE    = /models/gemma-4-E4B-it-Q8_0.gguf

GEMMA4_26B_REPO    = unsloth/gemma-4-26B-A4B-it-GGUF
GEMMA4_26B_PATTERN = *UD-Q4_K_XL*
GEMMA4_26B_FILE    = /models/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf

build:
	docker build \
		-t docker-llama-rocm \
		-f Dockerfile .

rebuild:
	docker build --no-cache \
		-t docker-llama-rocm \
		-f Dockerfile .

# Download GGUF into ./models on host.
# Override repo/pattern: make download HF_REPO=... HF_PATTERN='*Q5_K_M*'
# Limit speed (KB/s):    make download RATE_LIMIT=5000
download:
	mkdir -p $(PWD)/models
	docker run --rm \
		-v $(PWD)/models:/models \
		-e RATE_LIMIT="$(RATE_LIMIT)" \
		--entrypoint download-model \
		docker-llama-rocm \
		"$(HF_REPO)" "$(HF_PATTERN)"

# Run the inference server.
# Override anything via env: make run N_CPU_MOE=8 CTX_SIZE=262144
run:
	mkdir -p $(PWD)/models
	docker run -it --rm \
		--device=/dev/kfd \
		--device=/dev/dri \
		--group-add video \
		--ipc=host \
		--cap-add=IPC_LOCK \
		--ulimit memlock=-1:-1 \
		-e MODEL_FILE=$(MODEL_FILE) \
		-e MODEL_ALIAS="$(MODEL_ALIAS)" \
		-e N_CPU_MOE=$(N_CPU_MOE) \
		-e CTX_SIZE=$(CTX_SIZE) \
		-e EXTRA_ARGS="$(EXTRA_ARGS)" \
		-e ENABLE_THINKING="$(ENABLE_THINKING)" \
		-p $(PORT):8080 \
		-v $(PWD)/models:/models \
		--name llama \
		docker-llama-rocm

# Drop into a shell inside the image (for debugging, manual llama-server runs, etc.)
bash:
	docker run -it --rm \
		--device=/dev/kfd \
		--device=/dev/dri \
		--group-add video \
		--ipc=host \
		--cap-add=IPC_LOCK \
		--ulimit memlock=-1:-1 \
		-v $(PWD)/models:/models \
		--entrypoint bash \
		docker-llama-rocm

stop:
	-docker stop llama

# ------------------------------------------------------------------
# Convenience: download / run for each model
# ------------------------------------------------------------------
download-coder:
	$(MAKE) download HF_REPO="$(CODER_REPO)" HF_PATTERN="$(CODER_PATTERN)"

download-3.6:
	$(MAKE) download HF_REPO="$(QWEN36_REPO)" HF_PATTERN="$(QWEN36_PATTERN)"

download-gemma4:
	$(MAKE) download HF_REPO="$(GEMMA4_REPO)" HF_PATTERN="$(GEMMA4_PATTERN)"

download-gemma4-26b:
	$(MAKE) download HF_REPO="$(GEMMA4_26B_REPO)" HF_PATTERN="$(GEMMA4_26B_PATTERN)"

run-coder:
	$(MAKE) run MODEL_FILE="$(CODER_FILE)" MODEL_ALIAS="qwen3-coder-30b" N_CPU_MOE=24 CTX_SIZE=131072

run-3.6:
	$(MAKE) run MODEL_FILE="$(QWEN36_FILE)" MODEL_ALIAS="qwen3.6-35b" N_CPU_MOE=34 CTX_SIZE=262144

run-gemma4:
	$(MAKE) run MODEL_FILE="$(GEMMA4_FILE)" MODEL_ALIAS="gemma-4-e4b" N_CPU_MOE=0 CTX_SIZE=32768 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'

run-gemma4-26b:
	$(MAKE) run MODEL_FILE="$(GEMMA4_26B_FILE)" MODEL_ALIAS="gemma-4-26b" N_CPU_MOE=24 CTX_SIZE=131072 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'
