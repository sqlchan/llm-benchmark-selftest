"""在 NL2Repo 官方测试镜像上预装构建后端与运行时依赖，使其能在断网环境完成评测。

用法（构建期）：
    FROM ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0
    COPY install_deps.py /tmp/install_deps.py
    RUN python /tmp/install_deps.py

原理：官方测试镜像只含测试骨架（pyproject + tests），缺构建后端（hatchling 等）
与项目依赖；官方评测命令 `pip install -e .` 会联网下载。
本脚本在构建期（有网）从 `/workspace/pyproject.toml` 读出 build-system.requires 与
project.dependencies 并安装，之后离线执行
`pip install --no-build-isolation --no-index -e .` 即可成功。
"""
import subprocess
import sys

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib  # type: ignore


def main() -> int:
    path = "/workspace/pyproject.toml"
    try:
        with open(path, "rb") as f:
            data = tomllib.load(f)
    except FileNotFoundError:
        print(f"WARN: {path} not found; nothing to install", file=sys.stderr)
        return 0

    build_req = (data.get("build-system") or {}).get("requires") or []
    project_deps = (data.get("project") or {}).get("dependencies") or []
    optional = (data.get("project") or {}).get("optional-dependencies") or {}
    # 测试常用额外依赖，装了能提高离线可跑率
    for extra in ("test", "tests", "dev", "testing"):
        project_deps = list(project_deps) + list(optional.get(extra) or [])

    reqs = list(dict.fromkeys(list(build_req) + list(project_deps)))
    if not reqs:
        print("no requirements found")
        return 0
    print("installing:", reqs)
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--no-cache-dir", *reqs])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
