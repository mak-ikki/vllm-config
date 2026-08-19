# vllm-node — NVIDIA DGX Spark (GB10 / Blackwell SM_100, CUDA 13.0)
# Base officielle NVIDIA avec optimisations Blackwell natives
FROM vllm/vllm-openai:v0.27.1-aarch64

# Qwen3.8 nécessite transformers >= 5.3.0 (hybrid attention; servi en --language-model-only pour l'instant)
RUN pip install -U "transformers>=5.3.0" "huggingface_hub>=0.27.0" --quiet

# Chat template unsloth pour Qwen3.8 (reasoning <think> + tool calling)
COPY unsloth.jinja /workspace/unsloth.jinja
