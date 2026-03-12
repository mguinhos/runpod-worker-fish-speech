#!/bin/bash

cleanup() {
    echo "Cleaning up..."
    pkill -P $$
    exit 0
}

trap cleanup SIGINT SIGTERM

source /app/.venv/bin/activate

python3 /app/tools/api_server.py \
    --llama-checkpoint-path /app/checkpoints/s2-pro \
    --decoder-checkpoint-path /app/checkpoints/s2-pro \
    --device cuda \
    2>&1 | tee /tmp/fish.server.log &

FISH_PID=$!

check_server_is_running() {
    echo "Waiting for fish-speech server..."
    if grep -q "Uvicorn running" /tmp/fish.server.log 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

while ! check_server_is_running; do
    sleep 3
done

echo "Fish-speech server is up. Starting RunPod handler..."
python3 -u /app/src/handler.py