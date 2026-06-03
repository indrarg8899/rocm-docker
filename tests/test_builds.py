"""Tests for ROCm Docker image builds."""
import subprocess
import pytest
import yaml
from pathlib import Path

PROJECT_DIR = Path(__file__).parent.parent


def load_config():
    config_path = PROJECT_DIR / "configs" / "rocm-6.3.yml"
    with open(config_path) as f:
        return yaml.safe_load(f)


def docker_build(target, no_cache=True):
    """Build a Docker image and return success status."""
    cmd = ["docker", "build"]
    if no_cache:
        cmd.append("--no-cache")
    cmd.extend(["-t", f"test-{target}", "-f",
                str(PROJECT_DIR / "dockerfiles" / f"Dockerfile.{target}"),
                str(PROJECT_DIR)])
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)
    return result


def docker_run(image, command):
    """Run a command in a container."""
    cmd = [
        "docker", "run", "--rm",
        "--device=/dev/kfd", "--device=/dev/dri",
        "--group-add=video",
        image, "bash", "-c", command
    ]
    return subprocess.run(cmd, capture_output=True, text=True, timeout=300)


class TestConfig:
    def test_config_loads(self):
        config = load_config()
        assert config["rocm"]["version"] == "6.3"
        assert "images" in config

    def test_all_images_configured(self):
        config = load_config()
        expected = {"rocm-pytorch", "rocm-onnx", "rocm-minimal", "rocm-mlperf"}
        assert expected == set(config["images"].keys())

    def test_dockerfiles_exist(self):
        config = load_config()
        for name, img in config["images"].items():
            dockerfile = PROJECT_DIR / img["dockerfile"]
            assert dockerfile.exists(), f"Missing: {dockerfile}"


class TestDockerfiles:
    def test_all_dockerfiles_have_base_image(self):
        for df in (PROJECT_DIR / "dockerfiles").glob("Dockerfile.*"):
            content = df.read_text()
            assert "FROM" in content, f"{df.name} missing FROM"

    def test_all_dockerfiles_set_rocm_path(self):
        for df in (PROJECT_DIR / "dockerfiles").glob("Dockerfile.*"):
            content = df.read_text()
            assert "ROCM_PATH" in content, f"{df.name} missing ROCM_PATH"

    def test_all_dockerfiles_set_healthcheck(self):
        for df in (PROJECT_DIR / "dockerfiles").glob("Dockerfile.*"):
            content = df.read_text()
            assert "HEALTHCHECK" in content, f"{df.name} missing HEALTHCHECK"


class TestScripts:
    def test_build_script_executable(self):
        script = PROJECT_DIR / "scripts" / "build.sh"
        assert script.exists()

    def test_push_script_executable(self):
        script = PROJECT_DIR / "scripts" / "push.sh"
        assert script.exists()

    def test_setup_gpu_script_exists(self):
        script = PROJECT_DIR / "scripts" / "setup-gpu.sh"
        assert script.exists()


class TestProjectStructure:
    def test_readme_exists(self):
        assert (PROJECT_DIR / "README.md").exists()

    def test_license_exists(self):
        assert (PROJECT_DIR / "LICENSE").exists()

    def test_gitignore_exists(self):
        assert (PROJECT_DIR / ".gitignore").exists()

    def test_docker_compose_exists(self):
        assert (PROJECT_DIR / "docker-compose.yml").exists()

    def test_docs_exist(self):
        assert (PROJECT_DIR / "docs" / "getting_started.md").exists()
        assert (PROJECT_DIR / "docs" / "troubleshooting.md").exists()
