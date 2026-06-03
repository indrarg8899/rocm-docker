# ROCm Docker Images

![ROCm](https://img.shields.io/badge/ROCm-6.3-red?style=flat-square&logo=amd)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker)
![Python](https://img.shields.io/badge/Python-3.10+-yellow?style=flat-square&logo=python)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

Production-ready Docker images for AMD ROCm GPU-accelerated ML workloads.

## Features

- **Multi-target builds**: PyTorch, ONNX Runtime, MLPerf, Minimal base
- **ROCm 6.3**: Latest stable release with full MI200/MI300 support
- **Optimized layers**: Caching, multi-stage builds, minimal image size
- **Docker Compose**: One-command GPU dev environment setup
- **CI-ready**: Automated build tests included

## Available Images

| Image | Tag | Description | Size |
|-------|-----|-------------|------|
| `rocm-pytorch` | `latest` | PyTorch 2.x + ROCm 6.3 | ~12 GB |
| `rocm-onnx` | `latest` | ONNX Runtime + ROCm 6.3 | ~8 GB |
| `rocm-minimal` | `latest` | Minimal ROCm base | ~4 GB |
| `rocm-mlperf` | `latest` | MLPerf benchmark suite | ~15 GB |

## Quick Start

```bash
# Build all images
./scripts/build.sh

# Build specific image
./scripts/build.sh --target pytorch

# Run PyTorch container with GPU
docker run --device=/dev/kfd --device=/dev/dri \
  --group-add video -it rocm-pytorch:latest python3 -c \
  "import torch; print(torch.cuda.is_available())"

# Docker Compose
docker compose up -d rocm-pytorch
```

## GPU Setup

```bash
# Verify ROCm installation on host
sudo ./scripts/setup-gpu.sh

# Check GPU detection
rocm-smi
```

## Documentation

- [Getting Started](docs/getting_started.md)
- [Troubleshooting](docs/troubleshooting.md)

## Image Details

### rocm-pytorch
- ROCm 6.3 + PyTorch 2.x + torchvision + torchaudio
- Flash Attention 2, Triton kernels
- Jupyter Lab pre-installed

### rocm-onnx
- ROCm 6.3 + ONNX Runtime with ROCm EP
- ONNX GraphSurgeon, Polygraphy
- Inference-optimized

### rocm-minimal
- ROCm 6.3 runtime only
- Base for custom image builds
- Minimal footprint

### rocm-mlperf
- Full MLPerf Training benchmark suite
- ResNet, BERT, GPT-3 reference implementations
- Pre-configured for MI300X

## CI/CD

```yaml
# .github/workflows/build.yml
build:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - run: ./scripts/build.sh --target minimal
    - run: python -m pytest tests/
```

## License

MIT License. See [LICENSE](LICENSE).
