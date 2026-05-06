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

run-coder:
	$(MAKE) run MODEL_FILE="$(CODER_FILE)" MODEL_ALIAS="qwen3-coder-30b" N_CPU_MOE=24 CTX_SIZE=131072

run-3.6:
	$(MAKE) run MODEL_FILE="$(QWEN36_FILE)" MODEL_ALIAS="qwen3.6-35b" N_CPU_MOE=34 CTX_SIZE=262144
