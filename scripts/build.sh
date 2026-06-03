#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-rocm-docker}"
TARGET="${TARGET:-all}"
PUSH="${PUSH:-false}"

DOCKERFILES=(
    "rocm-pytorch"
    "rocm-onnx"
    "rocm-minimal"
    "rocm-mlperf"
)

usage() {
    echo "Usage: $0 [--target <image>] [--tag <tag>] [--push] [--no-cache]"
    echo "  --target   Build specific image (pytorch|onnx|minimal|mlperf|all)"
    echo "  --tag      Image tag (default: latest)"
    echo "  --push     Push after build"
    echo "  --no-cache Disable Docker build cache"
    exit 1
}

NO_CACHE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift 2 ;;
        --tag) TAG="$2"; shift 2 ;;
        --push) PUSH="true"; shift ;;
        --no-cache) NO_CACHE="--no-cache"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

build_image() {
    local name=$1
    local dockerfile="${PROJECT_DIR}/dockerfiles/Dockerfile.${name}"
    local image="${REGISTRY}/${name}:${TAG}"

    echo "=== Building ${image} ==="
    docker build ${NO_CACHE} -t "${image}" -f "${dockerfile}" "${PROJECT_DIR}"
    echo "=== Built ${image} ==="

    if [[ "$PUSH" == "true" ]]; then
        docker push "${image}"
    fi
}

if [[ "$TARGET" == "all" ]]; then
    for name in "${DOCKERFILES[@]}"; do
        build_image "$name"
    done
else
    build_image "rocm-${TARGET}"
fi

echo "Done."
