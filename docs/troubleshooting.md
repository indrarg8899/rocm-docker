# Troubleshooting

## GPU Not Detected

```
RuntimeError: No HIP GPUs are available
```

**Fix:**
```bash
# Check devices exist
ls -la /dev/kfd /dev/dri/

# Reload kernel module
sudo modprobe amdgpu
sudo modprobe -r amdgpu && sudo modprobe amdgpu

# Set permissions
sudo chmod 666 /dev/kfd /dev/dri/*
```

## Permission Denied on /dev/kfd

```
PermissionError: [Errno 13] Permission denied: '/dev/kfd'
```

**Fix:**
```bash
sudo usermod -aG video,render $USER
# Re-login or reboot
# OR run container with --privileged (not recommended for production)
```

## Out of Memory (OOM)

```
RuntimeError: HIP out of memory
```

**Fix:**
```bash
# Increase shared memory
docker run --shm-size=32g ...

# Limit GPU memory fraction in Python
import torch
torch.cuda.set_per_process_memory_fraction(0.9)

# Clear cache frequently
torch.cuda.empty_cache()
```

## Slow Training / Low GPU Utilization

```bash
# Check GPU usage
docker exec rocm-pytorch rocm-smi

# Monitor in real-time
watch -n 1 docker exec rocm-pytorch rocm-smi

# Verify ROCm version matches
docker exec rocm-pytorch rocminfo | grep "Marketing Name"
```

## GFX Version Mismatch

```
GPU does not support the ISA
```

**Fix:**
```bash
# Find your GPU architecture
rocm-smi --showproductname

# Set override
# MI250/MI250X: HSA_OVERRIDE_GFX_VERSION=9.4.0
# MI300X: HSA_OVERRIDE_GFX_VERSION=11.0.0
# RX 7900 XTX: HSA_OVERRIDE_GFX_VERSION=11.0.0

export HSA_OVERRIDE_GFX_VERSION=11.0.0
```

## Docker Build Fails at Package Install

```bash
# Clear Docker cache
docker builder prune -af

# Build with no cache
./scripts/build.sh --no-cache

# Check DNS
docker run --rm alpine ping -c 1 repo.radeon.com
```

## PyTorch Reports CPU Instead of GPU

```python
import torch
print(torch.version.hip)  # Should show ROCm version
print(torch.cuda.get_device_name(0))  # Should show AMD GPU
```

If HIP version is None, PyTorch was installed without ROCm support. Rebuild image.

## ONNX Runtime ROCM Provider Missing

```python
import onnxruntime as ort
providers = ort.get_available_providers()
assert 'ROCMExecutionProvider' in providers, f"Only: {providers}"
```

If missing, ONNX Runtime was built without ROCm EP. Check package version.

## Container Crashes on Start

```bash
# Check kernel logs
dmesg | tail -50

# Check container logs
docker logs rocm-pytorch --tail 100

# Run interactively for debug
docker run --rm -it --device=/dev/kfd --device=/dev/dri \
    --group-add video rocm-docker/rocm-minimal:latest bash
```
