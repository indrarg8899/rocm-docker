# Getting Started with ROCm Docker

## Prerequisites

- AMD GPU (MI200, MI300, or RDNA series)
- Ubuntu 22.04+ (host)
- Docker 24.0+
- ROCm 6.3 drivers installed on host

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/indrarg8899/rocm-docker.git
cd rocm-docker
```

### 2. Setup GPU

```bash
sudo ./scripts/setup-gpu.sh
```

### 3. Build Images

```bash
# All images
./scripts/build.sh

# Specific image
./scripts/build.sh --target pytorch
./scripts/build.sh --target onnx
./scripts/build.sh --target minimal
./scripts/build.sh --target mlperf
```

### 4. Run Container

```bash
# Docker Compose
docker compose up -d rocm-pytorch

# Direct Docker
docker run --device=/dev/kfd --device=/dev/dri \
    --group-add video --shm-size=16g \
    -it rocm-docker/rocm-pytorch:latest
```

## Verify Installation

```bash
# Inside container
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python3 -c "import torch; print(f'GPU count: {torch.cuda.device_count()}')"
rocm-smi
```

## Common Workflows

### Training a Model

```bash
docker compose exec rocm-pytorch python3 train.py \
    --data /workspace/data \
    --epochs 100 \
    --batch-size 64
```

### ONNX Inference

```bash
docker compose exec rocm-onnx python3 -c "
import onnxruntime as ort
print(ort.get_available_providers())
# Expected: ['ROCMExecutionProvider', 'CPUExecutionProvider']
"
```

### MLPerf Benchmark

```bash
docker compose exec rocm-mlperf bash -c \
    "cd /opt/mlperf-training/recommendation && ./run_and_time.sh"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ROCM_PATH` | `/opt/rocm` | ROCm installation path |
| `HIP_VISIBLE_DEVICES` | `all` | Visible GPU devices |
| `GPU_MAX_HW_QUEUES` | `8` | Hardware queue count |
| `HSA_ENABLE_SDMA` | `0` | Disable SDMA for stability |
| `HSA_OVERRIDE_GFX_VERSION` | `11.0.0` | GFX ISA version override |
