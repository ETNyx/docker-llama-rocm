#!/usr/bin/env bash
# Downloads GGUF files from HuggingFace into /models using aria2c.
# Usage:
#   download-model <repo_id> <pattern>
# Example:
#   download-model unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF "*Q4_K_M*"
#
# Optional env vars:
#   RATE_LIMIT     download cap in KB/s (e.g. 5000 for ~5 MB/s). Empty = unlimited.
#   HF_TOKEN       HuggingFace token for gated repos.
#   SUBDIR         subdir under /models to download into (e.g. gemma-4-12b).
#                  Keeps each model's files — notably mmproj — separated.
set -e

REPO="${1:?repo id required, e.g. unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF}"
PATTERN="${2:?file pattern required, e.g. *Q4_K_M*}"

DEST="/models${SUBDIR:+/${SUBDIR}}"
mkdir -p "${DEST}"

# Resolve matching files → list of "filename<TAB>url" via HF API.
mapfile -t ENTRIES < <(python - "${REPO}" "${PATTERN}" <<'EOF'
import sys, fnmatch
from huggingface_hub import HfApi, hf_hub_url
repo, pattern = sys.argv[1], sys.argv[2]
api = HfApi()
files = [f for f in api.list_repo_files(repo) if fnmatch.fnmatch(f, pattern)]
if not files:
    sys.stderr.write(f"✗ No files in {repo} match pattern {pattern}\n")
    sys.exit(1)
for f in files:
    print(f"{f}\t{hf_hub_url(repo, f)}")
EOF
)

ARIA_ARGS=(
    --dir="${DEST}"
    --continue=true
    --max-connection-per-server=8
    --split=8
    --min-split-size=20M
    --auto-file-renaming=false
    --console-log-level=warn
    --summary-interval=5
)

if [ -n "${RATE_LIMIT}" ]; then
    echo "▶ Rate limiting download to ${RATE_LIMIT} KB/s"
    ARIA_ARGS+=(--max-overall-download-limit="${RATE_LIMIT}K")
fi

if [ -n "${HF_TOKEN}" ]; then
    ARIA_ARGS+=(--header="Authorization: Bearer ${HF_TOKEN}")
fi

for entry in "${ENTRIES[@]}"; do
    fname="${entry%%$'\t'*}"
    url="${entry#*$'\t'}"
    echo "▶ ${fname}"
    aria2c "${ARIA_ARGS[@]}" --out="${fname}" "${url}"
done

echo "✓ Done. Files in ${DEST}:"
ls -lh "${DEST}"/*.gguf 2>/dev/null || ls -lh "${DEST}"
