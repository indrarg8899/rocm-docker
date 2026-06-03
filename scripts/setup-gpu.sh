#!/usr/bin/env bash
set -euo pipefail

echo "=== ROCm GPU Setup ==="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

# Install ROCm if not present
if ! command -v rocm-smi &>/dev/null; then
    echo "Installing ROCm 6.3..."
    wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -
    echo "deb [arch=amd64] https://repo.radeon.com/rocm/apt/6.3 jammy main" \
        > /etc/apt/sources.list.d/rocm.list
    apt-get update
    apt-get install -y rocm-hip-runtime rocm-smi-lib
fi

# Verify GPU detection
echo "Detecting GPUs..."
rocm-smi

# Load kernel modules
modprobe amdgpu
modprobe kvm_amd

# Set device permissions
chmod 666 /dev/kfd
chmod 666 /dev/dri/*

# Add current user to video/render groups
REAL_USER="${SUDO_USER:-$USER}"
usermod -aG video,render "$REAL_USER"

# Docker GPU support
if ! docker info 2>/dev/null | grep -q "Runtimes.*runc"; then
    echo "Docker not found or not running. Install Docker first."
fi

# Verify Docker can access GPU
echo "Testing Docker GPU access..."
docker run --rm --device=/dev/kfd --device=/dev/dri \
    --group-add video rocm/dev-ubuntu-22.04:6.3-complete \
    rocm-smi 2>/dev/null && echo "GPU access OK" || echo "GPU access FAILED - check /dev/kfd permissions"

# Environment variables
cat >> /etc/profile.d/rocm.sh << 'EOF'
export ROCM_PATH=/opt/rocm
export PATH=$ROCM_PATH/bin:$PATH
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$LD_LIBRARY_PATH
export HSA_OVERRIDE_GFX_VERSION=11.0.0
EOF

echo "=== Setup complete. Reboot recommended. ==="
