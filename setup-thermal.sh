#!/usr/bin/env bash
# Thermal management for DGX Spark (GB10) under sustained vLLM load.
# Run as root before starting docker-compose.
# Fixes: hangs/throttling observed between 4 and 60 min under heavy inference.

set -euo pipefail

GPU_INDEX="${1:-0}"

echo "=== DGX Spark thermal setup (GPU $GPU_INDEX) ==="

# Persistence mode: keeps the driver loaded so clock settings survive between
# processes instead of resetting when no client is attached.
nvidia-smi -i "$GPU_INDEX" -pm 1
echo "[OK] Persistence mode enabled"

# Cap GPU clocks for sustained workloads. Default boost is ~2520-3003 MHz —
# at max clocks the GB10 runs hot enough to trigger the thermal sensor hang
# (firmware bug, diagnosed as error 082-000-1-020000021139), which has caused
# real unplanned shutdowns on this machine (2026-08-15, 2026-08-17).
# Power limiting (-pl) is NOT supported on GB10 (all power fields report N/A
# at the driver level, confirmed not a permission/scope issue) — clock capping
# is the only thermal lever available.
# IMPORTANT: the MIN clock matters as much as the MAX. A high floor (e.g.
# 2000,2200 as used until 2026-08-17) prevents the GPU's own software thermal
# slowdown state from ever engaging when it heats up, leaving the EC's hard
# power-off as the only remaining protection — this likely contributed to the
# 2026-08-17 shutdown (43 min uptime despite the cap being active). Use a low
# floor so the GPU can throttle itself down before the EC has to.
nvidia-smi -i "$GPU_INDEX" -lgc 300,2200
echo "[OK] GPU clocks capped at 300-2200 MHz"

# Confirm
echo ""
nvidia-smi -i "$GPU_INDEX" --query-gpu=name,clocks.gr,temperature.gpu,persistence_mode --format=csv,noheader
echo ""
echo "Done. Start vLLM with: docker compose up -d"
