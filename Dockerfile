FROM docker-rocm:latest

# ------------------------------
# CONFIG
# ------------------------------
ENV ROCM_GPU=gfx1201
ENV HSA_OVERRIDE_GFX_VERSION=12.0.1
ENV LLAMA_CPP_REF=master

EXPOSE 8080

RUN apt-get update && apt-get install -y \
    cmake \
    git \
    curl \
    libcurl4-openssl-dev \
    aria2

RUN mkdir -p /app /models

# ------------------------
# llama.cpp (ROCm/HIP, RDNA4)
# ------------------------
RUN git clone https://github.com/ggml-org/llama.cpp /opt/llama.cpp && \
    cd /opt/llama.cpp && \
    git checkout ${LLAMA_CPP_REF} && \
    HIPCXX=/opt/rocm/llvm/bin/clang++ HIP_PATH=/opt/rocm \
    cmake -S . -B build \
        -DGGML_HIP=ON \
        -DAMDGPU_TARGETS=${ROCM_GPU} \
        -DGGML_HIP_ROCWMMA_FATTN=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_CURL=ON && \
    cmake --build build --config Release -j $(nproc) && \
    cmake --install build --prefix /usr/local && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/llama.conf && \
    ldconfig && \
    rm -rf /opt/llama.cpp/build

ENV LD_LIBRARY_PATH=/usr/local/lib

# ------------------------
# huggingface-cli for model downloads
# ------------------------
RUN pip install --no-cache-dir "huggingface_hub[cli]"

VOLUME ["/models"]
WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
COPY download-model.sh /usr/local/bin/download-model
RUN chmod +x /entrypoint.sh /usr/local/bin/download-model

CMD ["/entrypoint.sh"]
