# vllm-node — NVIDIA DGX Spark (GB10 / Blackwell SM_100, CUDA 13.0)
# Base officielle NVIDIA avec optimisations Blackwell natives
FROM vllm/vllm-openai:v0.27.1-aarch64

# Qwen3.6-35B-A3B (hybrid Gated DeltaNet + Gated Attention + MoE) necessite
# transformers recent avec les extras serving; servi en --language-model-only
RUN pip install -U "transformers[serving]>=5.3.0" "huggingface_hub>=0.27.0" --quiet

# Chat template officiel unsloth pour Qwen3.6-35B-A3B (system/developer fusionnes,
# preserve_thinking, reasoning <think> + tool calling)
COPY unsloth.jinja /workspace/unsloth.jinja
