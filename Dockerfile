# vllm-node — NVIDIA DGX Spark (GB10 / Blackwell SM_100, CUDA 13.0)
# Base officielle NVIDIA avec optimisations Blackwell natives
FROM vllm/vllm-openai:cu130-nightly

# Qwen3.6 nécessite transformers >= 5.3.0 (architecture qwen3_5 + hybrid attention)
RUN pip install -U "transformers>=5.3.0" "huggingface_hub>=0.27.0" --quiet

# Chat template unsloth pour Qwen3.6 (reasoning <think> + tool calling)
COPY unsloth.jinja /workspace/unsloth.jinja
