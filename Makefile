ROCM_GPU = gfx1201
HSA_OVERRIDE_GFX_VERSION = 12.0.1

# Default model — override with: make run MODEL_FILE=...
# Each model lives in its own subdir under /models so per-model files
# (notably the identically-named mmproj-*.gguf) never collide.
MODEL_FILE ?= /models/qwen3-coder/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
HF_REPO    ?= unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
HF_PATTERN ?= *Q4_K_M*

PORT       ?= 8080
N_CPU_MOE  ?= 41
CTX_SIZE   ?= 131072

# ------------------------------------------------------------------
# Model presets — `make run-coder` / `make run-3.6` / `make download-*`
# ------------------------------------------------------------------
CODER_DIR     = qwen3-coder
CODER_REPO    = unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
CODER_PATTERN = *Q4_K_M*
CODER_FILE    = /models/$(CODER_DIR)/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf

QWEN36_DIR     = qwen3.6
QWEN36_REPO    = unsloth/Qwen3.6-35B-A3B-GGUF
QWEN36_PATTERN = *UD-Q4_K_XL*
QWEN36_FILE    = /models/$(QWEN36_DIR)/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf

GEMMA4_DIR     = gemma-4-e4b
GEMMA4_REPO    = unsloth/gemma-4-E4B-it-GGUF
GEMMA4_PATTERN = *Q8_0*
GEMMA4_FILE    = /models/$(GEMMA4_DIR)/gemma-4-E4B-it-Q8_0.gguf

# Multimodal projector — enables vision/image input for the gemma-4-E4B model.
GEMMA4_MMPROJ_PATTERN = *mmproj-F16*
GEMMA4_MMPROJ_FILE    = /models/$(GEMMA4_DIR)/mmproj-F16.gguf

GEMMA4_26B_DIR     = gemma-4-26b
GEMMA4_26B_REPO    = unsloth/gemma-4-26B-A4B-it-GGUF
GEMMA4_26B_PATTERN = *UD-Q4_K_XL*
GEMMA4_26B_FILE    = /models/$(GEMMA4_26B_DIR)/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf

# Multimodal projector — enables vision/image input for the gemma-4-26b model.
GEMMA4_26B_MMPROJ_PATTERN = *mmproj-F16*
GEMMA4_26B_MMPROJ_FILE    = /models/$(GEMMA4_26B_DIR)/mmproj-F16.gguf

GEMMA4_12B_DIR     = gemma-4-12b
GEMMA4_12B_REPO    = unsloth/gemma-4-12b-it-GGUF
GEMMA4_12B_PATTERN = *UD-Q6_K_XL*
GEMMA4_12B_FILE    = /models/$(GEMMA4_12B_DIR)/gemma-4-12b-it-UD-Q6_K_XL.gguf

# Multimodal projector — enables vision/image input for the gemma-4-12b models.
GEMMA4_12B_MMPROJ_PATTERN = *mmproj-F16*
GEMMA4_12B_MMPROJ_FILE    = /models/$(GEMMA4_12B_DIR)/mmproj-F16.gguf

GEMMA4_12B_Q4_PATTERN = *UD-Q4_K_XL*
GEMMA4_12B_Q4_FILE    = /models/$(GEMMA4_12B_DIR)/gemma-4-12b-it-UD-Q4_K_XL.gguf

GEMMA4_12B_Q5_PATTERN = *UD-Q5_K_XL*
GEMMA4_12B_Q5_FILE    = /models/$(GEMMA4_12B_DIR)/gemma-4-12b-it-UD-Q5_K_XL.gguf

# Qwen3-VL-8B-Instruct — dense 8B, trénovaný přímo na detekci/grounding objektů.
# TOP TIP pro CSV tagy (viz poznámky v ai.image.recognition.php). Q8_0 ~9 GB,
# vejde se celý na GPU. Instruct = non-thinking varianta.
QWEN3VL_8B_DIR     = qwen3-vl-8b
QWEN3VL_8B_REPO    = unsloth/Qwen3-VL-8B-Instruct-GGUF
QWEN3VL_8B_PATTERN = *Q8_0*
QWEN3VL_8B_FILE    = /models/$(QWEN3VL_8B_DIR)/Qwen3-VL-8B-Instruct-Q8_0.gguf

# Multimodal projector — enables vision/image input for the Qwen3-VL-8B model.
QWEN3VL_8B_MMPROJ_PATTERN = *mmproj-F16*
QWEN3VL_8B_MMPROJ_FILE    = /models/$(QWEN3VL_8B_DIR)/mmproj-F16.gguf

# Qwythos-9B-Claude-Mythos-5-1M — dense Qwen3.5-9B fine-tune (empero-ai).
# The MTP variant carries the NextN/MTP draft head → self-speculative decoding
# via --spec-type draft-mtp (single MTP block, supported for dense Qwen3.5 in this
# llama.cpp build; see src/models/qwen35.cpp graph_mtp). No separate draft model.
# DEFAULT Q6_K: near-lossless vs Q8 (+~0.2 % ppl, neměřitelné na benchmarcích), ale
# ~2.2 GB menší → víc VRAM na kontext / KV / sloty. dense → N_CPU_MOE=0.
QWYTHOS_DIR     = qwythos-9b
QWYTHOS_REPO    = empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF
QWYTHOS_PATTERN = *MTP-Q6_K*
QWYTHOS_FILE    = /models/$(QWYTHOS_DIR)/Qwythos-9B-Claude-Mythos-5-1M-MTP-Q6_K.gguf
# Q8_0 varianta (bezztrátová, ale +2.2 GB VRAM) — download-qwythos-q8 / run-qwythos-q8.
QWYTHOS_Q8_PATTERN = *MTP-Q8_0*
QWYTHOS_Q8_FILE    = /models/$(QWYTHOS_DIR)/Qwythos-9B-Claude-Mythos-5-1M-MTP-Q8_0.gguf

# Multimodal projector — enables vision/image input for the Qwythos model.
# llama.cpp podporuje jen QWEN2VL/QWEN25VL/QWEN3VL projektory — pokud tenhle mmproj
# není žádný z nich, server ho při startu odmítne → pak mmproj vynech (text-only).
QWYTHOS_MMPROJ_PATTERN = *mmproj*F16*
QWYTHOS_MMPROJ_FILE    = /models/$(QWYTHOS_DIR)/mmproj-Qwythos-9B-Claude-Mythos-5-1M-F16.gguf

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
# Target subdir:         make download SUBDIR=gemma-4-12b ...
# Limit speed (KB/s):    make download RATE_LIMIT=5000
download:
	mkdir -p $(PWD)/models
	docker run --rm \
		-v $(PWD)/models:/models \
		-e RATE_LIMIT="$(RATE_LIMIT)" \
		-e SUBDIR="$(SUBDIR)" \
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
		-e MMPROJ_FILE="$(MMPROJ_FILE)" \
		-e N_CPU_MOE=$(N_CPU_MOE) \
		-e CTX_SIZE=$(CTX_SIZE) \
		-e CACHE_TYPE_K="$(CACHE_TYPE_K)" \
		-e CACHE_TYPE_V="$(CACHE_TYPE_V)" \
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
	$(MAKE) download SUBDIR="$(CODER_DIR)" HF_REPO="$(CODER_REPO)" HF_PATTERN="$(CODER_PATTERN)"

download-3.6:
	$(MAKE) download SUBDIR="$(QWEN36_DIR)" HF_REPO="$(QWEN36_REPO)" HF_PATTERN="$(QWEN36_PATTERN)"

download-gemma4:
	$(MAKE) download SUBDIR="$(GEMMA4_DIR)" HF_REPO="$(GEMMA4_REPO)" HF_PATTERN="$(GEMMA4_PATTERN)"

download-gemma4-mmproj:
	$(MAKE) download SUBDIR="$(GEMMA4_DIR)" HF_REPO="$(GEMMA4_REPO)" HF_PATTERN="$(GEMMA4_MMPROJ_PATTERN)"

download-gemma4-26b:
	$(MAKE) download SUBDIR="$(GEMMA4_26B_DIR)" HF_REPO="$(GEMMA4_26B_REPO)" HF_PATTERN="$(GEMMA4_26B_PATTERN)"

download-gemma4-26b-mmproj:
	$(MAKE) download SUBDIR="$(GEMMA4_26B_DIR)" HF_REPO="$(GEMMA4_26B_REPO)" HF_PATTERN="$(GEMMA4_26B_MMPROJ_PATTERN)"

download-gemma4-12b:
	$(MAKE) download SUBDIR="$(GEMMA4_12B_DIR)" HF_REPO="$(GEMMA4_12B_REPO)" HF_PATTERN="$(GEMMA4_12B_PATTERN)"

download-gemma4-12b-q4:
	$(MAKE) download SUBDIR="$(GEMMA4_12B_DIR)" HF_REPO="$(GEMMA4_12B_REPO)" HF_PATTERN="$(GEMMA4_12B_Q4_PATTERN)"

download-gemma4-12b-mmproj:
	$(MAKE) download SUBDIR="$(GEMMA4_12B_DIR)" HF_REPO="$(GEMMA4_12B_REPO)" HF_PATTERN="$(GEMMA4_12B_MMPROJ_PATTERN)"

download-gemma4-12b-q5:
	$(MAKE) download SUBDIR="$(GEMMA4_12B_DIR)" HF_REPO="$(GEMMA4_12B_REPO)" HF_PATTERN="$(GEMMA4_12B_Q5_PATTERN)"

download-qwen3-vl-8b:
	$(MAKE) download SUBDIR="$(QWEN3VL_8B_DIR)" HF_REPO="$(QWEN3VL_8B_REPO)" HF_PATTERN="$(QWEN3VL_8B_PATTERN)"

download-qwen3-vl-8b-mmproj:
	$(MAKE) download SUBDIR="$(QWEN3VL_8B_DIR)" HF_REPO="$(QWEN3VL_8B_REPO)" HF_PATTERN="$(QWEN3VL_8B_MMPROJ_PATTERN)"

download-qwythos:
	$(MAKE) download SUBDIR="$(QWYTHOS_DIR)" HF_REPO="$(QWYTHOS_REPO)" HF_PATTERN="$(QWYTHOS_PATTERN)"

download-qwythos-q8:
	$(MAKE) download SUBDIR="$(QWYTHOS_DIR)" HF_REPO="$(QWYTHOS_REPO)" HF_PATTERN="$(QWYTHOS_Q8_PATTERN)"

download-qwythos-mmproj:
	$(MAKE) download SUBDIR="$(QWYTHOS_DIR)" HF_REPO="$(QWYTHOS_REPO)" HF_PATTERN="$(QWYTHOS_MMPROJ_PATTERN)"

run-coder:
	$(MAKE) run MODEL_FILE="$(CODER_FILE)" MODEL_ALIAS="Qwen3-Coder-30B-A3B-Instruct" N_CPU_MOE=24 CTX_SIZE=131072

run-3.6:
	$(MAKE) run MODEL_FILE="$(QWEN36_FILE)" MODEL_ALIAS="Qwen3.6-35B-A3B" N_CPU_MOE=30 CTX_SIZE=262144

# Loads the mmproj so the server accepts image input (vision).
run-gemma4:
	$(MAKE) run MODEL_FILE="$(GEMMA4_FILE)" MODEL_ALIAS="gemma-4-E4B-it" \
		MMPROJ_FILE="$(GEMMA4_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=131072 \
		CACHE_TYPE_K=q8_0 CACHE_TYPE_V=q8_0 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'

# Loads the mmproj so the server accepts image input (vision).
run-gemma4-26b:
	$(MAKE) run MODEL_FILE="$(GEMMA4_26B_FILE)" MODEL_ALIAS="gemma-4-26B-A4B-it" \
		MMPROJ_FILE="$(GEMMA4_26B_MMPROJ_FILE)" N_CPU_MOE=24 CTX_SIZE=131072 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'

# Dense 12B — fits fully on GPU, so no MoE offload (N_CPU_MOE=0).
# Same mmproj as Q4/Q5 (projector is independent of weight quantization) → vision enabled.
run-gemma4-12b:
	$(MAKE) run MODEL_FILE="$(GEMMA4_12B_FILE)" MODEL_ALIAS="gemma-4-12b-it" \
		MMPROJ_FILE="$(GEMMA4_12B_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=131072 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'

# Same model, Q4 quant — smaller/lighter than Q6, marginally lower quality.
# Full 256k context (model's n_ctx_train); Q4's smaller weights leave VRAM for the larger KV cache.
# Loads the mmproj so the server accepts image input (vision).
# Extra llama-server flags appendnutelné z příkazové řádky, např.:
#   make run-gemma4-12b-q4 EXTRA='--parallel 4'
EXTRA ?=
run-gemma4-12b-q4:
	$(MAKE) run MODEL_FILE="$(GEMMA4_12B_Q4_FILE)" MODEL_ALIAS="gemma-4-12b-it" \
		MMPROJ_FILE="$(GEMMA4_12B_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=262144 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64 $(EXTRA)'

# Same model, Q5 quant — middle ground between Q4 and Q6. 128k context (256k is tight on 16 GB at this size).
# Same mmproj as Q4/Q6 (projector is independent of weight quantization) → vision enabled.
run-gemma4-12b-q5:
	$(MAKE) run MODEL_FILE="$(GEMMA4_12B_Q5_FILE)" MODEL_ALIAS="gemma-4-12b-it" \
		MMPROJ_FILE="$(GEMMA4_12B_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=131072 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--temp 1.0 --top-p 0.95 --top-k 64'

# Qwen3-VL-8B-Instruct — dense 8B, vejde se celý na GPU (N_CPU_MOE=0).
# Loads the mmproj so the server accepts image input (vision).
# Instruct varianta nemá thinking → ENABLE_THINKING=false (--reasoning off).
# Sampling dle Qwen non-thinking doporučení (temp 0.7 / top_p 0.8 / top_k 20) —
# pozn.: PHP klient nastavuje sampling jen pro 'gemma-4', proto se řídí serverem.
# Detekce potřebuje jen ~300 tokenů → menší CTX kvůli VRAM (Q8 + mmproj).
# Extra flagy z příkazové řádky, např.: make run-qwen3-vl-8b EXTRA='--parallel 4'
run-qwen3-vl-8b:
	$(MAKE) run MODEL_FILE="$(QWEN3VL_8B_FILE)" MODEL_ALIAS="Qwen3-VL-8B-Instruct" \
		MMPROJ_FILE="$(QWEN3VL_8B_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=32768 \
		ENABLE_THINKING=false \
		EXTRA_ARGS='--temp 0.7 --top-p 0.8 --top-k 20 $(EXTRA)'

# Qwythos-9B — dense, vejde se celý na GPU (N_CPU_MOE=0).
# --spec-type draft-mtp zapne self-speculative dekódování přes vestavěnou MTP/NextN
#   hlavu (žádný samostatný draft model; MTP draft kontext běží na tomhle modelu).
#   POZOR: serverový flag je --spec-type draft-mtp; --mtp je jen download flag.
# Reasoning model → --reasoning on. Sampling dle model cardu.
#
# run-qwythos: TEXT-ONLY (bez mmproj), Q6_K váhy. 192K kontext při zachování MTP.
#   192K je pod n_ctx_train (1M) → žádný rope-scaling penalt. Model má hybridní
#   attention (qwen35.full_attention_interval=4 → 3/4 vrstev sliding-window), takže
#   KV cache roste sublineárně. S Q6 je na 16 GB rezerva ~4 GB → lze i 256K
#   (CTX_SIZE=262144) nebo upgrade KV na q8_0 (CACHE_TYPE_K/V=q8_0). KV default q4_0.
#   Default sloty (kv_unified) sdílí CTX → N souběžných agentů, každý ~CTX/N.
# Extra flagy z příkazové řádky: make run-qwythos EXTRA='--parallel 8'
run-qwythos:
	$(MAKE) run MODEL_FILE="$(QWYTHOS_FILE)" MODEL_ALIAS="Qwythos-9B-Claude-Mythos-5-1M" \
		N_CPU_MOE=0 CTX_SIZE=196608 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--spec-type draft-mtp --temp 0.6 --top-p 0.95 --top-k 20 --repeat-penalty 1.05 $(EXTRA)'

# run-qwythos-q8: stejné jako run-qwythos, ale Q8_0 váhy (bezztrátové, +2.2 GB VRAM).
#   Na 16 GB je 192K Q8 ~92 % VRAM; pro delší kontext použij Q6 default.
run-qwythos-q8:
	$(MAKE) run MODEL_FILE="$(QWYTHOS_Q8_FILE)" MODEL_ALIAS="Qwythos-9B-Claude-Mythos-5-1M" \
		N_CPU_MOE=0 CTX_SIZE=196608 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--spec-type draft-mtp --temp 0.6 --top-p 0.95 --top-k 20 --repeat-penalty 1.05 $(EXTRA)'

# run-qwythos-vision: S VISION (mmproj) — obraz na vstupu. Kratší kontext (32K)
#   kvůli VRAM (mmproj ~0.9 GB + KV). Projektor je Qwen-VL; pro grounding/detekci
#   zvaž EXTRA='--image-min-tokens 1024'. Pokud dojde VRAM, sniž CTX_SIZE nebo
#   vypni MTP (EXTRA_ARGS bez --spec-type draft-mtp).
run-qwythos-vision:
	$(MAKE) run MODEL_FILE="$(QWYTHOS_FILE)" MODEL_ALIAS="Qwythos-9B-Claude-Mythos-5-1M" \
		MMPROJ_FILE="$(QWYTHOS_MMPROJ_FILE)" N_CPU_MOE=0 CTX_SIZE=32768 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--spec-type draft-mtp --temp 0.6 --top-p 0.95 --top-k 20 --repeat-penalty 1.05 $(EXTRA)'

# run-qwythos-parallel: pro SOUBĚŽNÉ sub-agenty. Text-only, 192K, ale MTP VYPNUTÉ
#   (--spec-type none). MTP je optimalizace pro jeden stream — při víc slotech
#   nedokáže dávkovat draft přes sloty a agregátní propustnost naopak kolabuje
#   (sólo ~105 t/s vs 4 sloty s MTP jen ~40 t/s agregát). Bez spekulace se sloty
#   dávkují normálně → vyšší agregátní throughput při paralelní zátěži.
run-qwythos-parallel:
	$(MAKE) run MODEL_FILE="$(QWYTHOS_FILE)" MODEL_ALIAS="Qwythos-9B-Claude-Mythos-5-1M" \
		N_CPU_MOE=0 CTX_SIZE=196608 \
		ENABLE_THINKING=true \
		EXTRA_ARGS='--spec-type none --temp 0.6 --top-p 0.95 --top-k 20 --repeat-penalty 1.05 $(EXTRA)'
