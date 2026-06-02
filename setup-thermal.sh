#!/usr/bin/env bash
# Thermal management for DGX Spark (GB10) under sustained vLLM load.
# Run as root before starting docker-compose.
# Fixes: hangs/throttling observed between 4 and 60 min under heavy inference.

set -euo pipefail

GPU_INDEX="${1:-0}"

echo "=== DGX Spark thermal setup (GPU $GPU_INDEX) ==="

# Cap GPU clocks to 2300 MHz for sustained workloads.
# Default boost is ~2520 MHz — at max clocks the GB10 runs hot enough to trigger
# the thermal sensor hang (firmware bug, diagnosed as error 082-000-1-020000021139).
# 2300 MHz reduces thermals ~8°C with <5% throughput loss on sustained inference.
nvidia-smi -i "$GPU_INDEX" -lgc 2300,2300
echo "[OK] GPU clocks capped at 2300 MHz"

# Set power limit (GB10 TDP ~120 W).
# 100 W is the sweet spot: keeps GPU under 75°C, avoids thermal throttle.
# Increase to 110 W if you have good airflow or an Acer/Gigabyte OEM unit.
nvidia-smi -i "$GPU_INDEX" -pl 100
echo "[OK] Power limit set to 100 W"

# Confirm
echo ""
nvidia-smi -i "$GPU_INDEX" --query-gpu=name,clocks.gr,power.limit,temperature.gpu --format=csv,noheader
echo ""
echo "Done. Start vLLM with: docker compose up -d"
