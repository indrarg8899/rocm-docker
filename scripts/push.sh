#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-ghcr.io/indrarg8899/rocm-docker}"
TAG="${TAG:-latest}"

IMAGES=(
    "rocm-pytorch"
    "rocm-onnx"
    "rocm-minimal"
    "rocm-mlperf"
)

echo "Logging in to ${REGISTRY}..."
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u indrarg8899 --password-stdin

for name in "${IMAGES[@]}"; do
    src="rocm-docker/${name}:${TAG}"
    dst="${REGISTRY}/${name}:${TAG}"

    echo "Tagging ${src} -> ${dst}"
    docker tag "${src}" "${dst}"

    echo "Pushing ${dst}"
    docker push "${dst}"
done

echo "All images pushed."
