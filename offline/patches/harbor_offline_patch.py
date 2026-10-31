"""在 runner 镜像构建末尾修补 Harbor 0.25.0，使其能在断网任务容器里安装 agent。

两个补丁：
1. ``ca_certificates`` 的 ``always_install=True`` 改为 False。
   Harbor 的 ``ensure_system_dependencies`` 会无条件执行
   ``apt-get update && apt-get install ca-certificates``；断网时必然失败并抛错。
   任务镜像本身都带 CA 证书，跳过安全。
2. 若任务镜像已预装 mini-swe-agent（离线包派生的 ``/opt/tb4-agent``），
   ``MiniSweAgent.install`` 直接返回，跳过 ``curl astral.sh`` / ``uv tool install``。
"""
import pathlib
import re
import sys

TOOLS = pathlib.Path("/root/.local/share/uv/tools")
HARBOR = TOOLS / "harbor" / "lib" / "python3.12" / "site-packages" / "harbor"


def patch_ca_certificates() -> None:
    base = HARBOR / "agents" / "installed" / "base.py"
    src = base.read_text(encoding="utf-8")
    if "always_install=True" not in src:
        print(f"WARN: always_install=True not found in {base}", file=sys.stderr)
        return
    src = src.replace("always_install=True", "always_install=False")
    base.write_text(src, encoding="utf-8")
    print(f"patched {base}")


def patch_mini_swe_install() -> None:
    path = HARBOR / "agents" / "installed" / "mini_swe_agent.py"
    src = path.read_text(encoding="utf-8")
    marker = "    async def install(self, environment: BaseEnvironment) -> None:\n"
    if "OFFLINE-PATCH: preinstalled" in src:
        print("mini_swe_agent install already patched")
        return
    if marker not in src:
        print(f"WARN: install() signature not found in {path}", file=sys.stderr)
        return
    inject = (
        marker
        + "        # OFFLINE-PATCH: preinstalled agent toolchain from the offline bundle\n"
        + "        probe = await self.exec_as_agent(\n"
        + "            environment,\n"
        + "            command=(\n"
        + "                'export PATH=\"/opt/tb4-agent/bin:/usr/local/bin:$HOME/.local/bin:$PATH\"; '\n"
        + "                \"if command -v mini-swe-agent >/dev/null 2>&1; \"\n"
        + "                \"then echo PREINSTALLED; fi\"\n"
        + "            ),\n"
        + "        )\n"
        + "        if \"PREINSTALLED\" in (probe.stdout or \"\"):\n"
        + "            self.logger.info(\n"
        + "                \"mini-swe-agent preinstalled in task image; skipping network install\"\n"
        + "            )\n"
        + "            return\n"
    )
    src = src.replace(marker, inject, 1)
    path.write_text(src, encoding="utf-8")
    print(f"patched {path}")


def patch_system_dependencies() -> None:
    """让 ensure_system_dependencies 的 apt/apk 失败不致命（断网场景）。

    Harbor 在安装 agent 前会检查 curl/bash/git/gcc/make 等命令，缺失时调用
    apt-get install。断网时 apt 必然失败并抛 RuntimeError，导致 agent setup 失败。
    离线包的任务镜像已预装 uv + python + mini-swe-agent（/opt/tb4-agent），
    因此这里改成：失败时仅记 warning，继续走预装工具链。
    """
    path = HARBOR / "agents" / "installed" / "base.py"
    src = path.read_text(encoding="utf-8")
    if "OFFLINE-PATCH: tolerate dependency install failure" in src:
        print("system dependencies already patched")
        return
    old = """        await self.exec_as_root(environment, command=command, env=env)
"""
    new = """        try:
            await self.exec_as_root(environment, command=command, env=env)
        except Exception:  # OFFLINE-PATCH: tolerate dependency install failure
            if os.environ.get("HARBOR_OFFLINE") == "1":
                self.logger.warning(
                    "system dependency install failed (offline mode); "
                    "continuing with the preinstalled toolchain"
                )
            else:
                raise
"""
    if old not in src:
        print(f"WARN: ensure_system_dependencies install call not found in {path}", file=sys.stderr)
        return
    src = src.replace(old, new, 1)
    path.write_text(src, encoding="utf-8")
    print(f"patched {path}")


def main() -> None:
    if not HARBOR.is_dir():
        raise SystemExit(f"harbor package not found at {HARBOR}")
    patch_ca_certificates()
    patch_system_dependencies()
    patch_mini_swe_install()


if __name__ == "__main__":
    main()
