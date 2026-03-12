# runpod-worker-fish-speech

A [RunPod](https://runpod.io) serverless worker that exposes [Fish Speech S2 Pro](https://huggingface.co/fishaudio/s2-pro) as a TTS API endpoint.

## How it works

On startup, the worker launches the Fish Speech API server in the background, waits for it to be ready, then starts the RunPod handler. Incoming jobs are forwarded to the internal Fish Speech server and the generated audio is returned as base64.

## Usage

### Request

```json
{
  "input": {
    "text": "Hello, world!",
    "format": "wav",
    "reference_audio": [],
    "reference_text": [],
    "temperature": 0.8,
    "top_p": 0.8,
    "repetition_penalty": 1.1,
    "max_new_tokens": 1024,
    "chunk_length": 300,
    "seed": null,
    "use_memory_cache": "off"
  }
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `text` | string | required | Text to synthesize |
| `format` | string | `wav` | Output format: `wav`, `mp3`, `flac` |
| `reference_audio` | list[base64] | `[]` | Reference audio clips for voice cloning |
| `reference_text` | list[string] | `[]` | Transcripts matching each reference audio |
| `reference_id` | string | `null` | ID of a pre-loaded reference model |
| `temperature` | float | `0.8` | Sampling temperature |
| `top_p` | float | `0.8` | Top-p sampling |
| `repetition_penalty` | float | `1.1` | Repetition penalty |
| `max_new_tokens` | int | `1024` | Max tokens to generate |
| `seed` | int | `null` | Fixed seed for deterministic output |

### Response

```json
{
  "audio_base64": "<base64 encoded audio>",
  "format": "wav"
}
```

### Example (curl)

```bash
curl -X POST https://api.runpod.ai/v2/ENDPOINT_ID/run \
     -H "authorization: Bearer RUNPOD_API_KEY" \
     -H "content-type: application/json" \
     -d '{
       "input": {
         "text": "Hello, world!"
       }
     }'
```

## Deployment

### Build

```bash
docker build -t fish-worker .
```

### Run locally (requires NVIDIA GPU)

```bash
docker run --gpus all fish-worker
```

### Deploy to RunPod

1. Push the image to a container registry (Docker Hub, GHCR, etc.)
2. Create a new **Serverless Endpoint** on RunPod
3. Set the container image to your pushed image
4. Set GPU to any CUDA-capable GPU (A4000 or better recommended)

## License

[MIT](LICENSE.md)

## Project structure

```
.
├── src/
│   ├── handler.py   # RunPod serverless handler
│   └── run.sh       # Startup script
├── checkpoints/     # Downloaded at build time (gitignored)
└── Dockerfile
```
