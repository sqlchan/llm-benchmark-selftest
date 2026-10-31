# TB4 离线 agent 载荷（在 ubuntu:24.04 上构建一次，随后 COPY 进每个 TB4 任务镜像）
# 目标：让 Harbor 0.25.0 的 mini-swe-agent 在断网任务容器里 `uv tool install` 直接命中本地缓存。
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates git build-essential xz-utils \
    && rm -rf /var/lib/apt/lists/*

# uv 二进制（astral 官方安装脚本，构建期有网）
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && install -m 0755 /root/.local/bin/uv /usr/local/bin/uv

# 与 Harbor 的 MiniSweAgent.install() 保持一致的工具目录
ENV UV_CACHE_DIR=/opt/tb4-agent/uv-cache \
    UV_PYTHON_INSTALL_DIR=/opt/tb4-agent/python \
    UV_TOOL_DIR=/opt/tb4-agent/tools \
    UV_TOOL_BIN_DIR=/opt/tb4-agent/bin

# 下载 CPython 3.12 + 预装 agent 工具链（与 Harbor 安装命令相同，另加 mcp：
# LiteLLM 1.106 的 litellm 顶层导入会加载 mcp，缺它时 agent 启动即 ModuleNotFoundError）
RUN uv python install 3.12 \
 && uv tool install --python 3.12 mini-swe-agent==2.4.6 \
        --with litellm --with orjson --with fastapi --with mcp

# 打包载荷（/opt/tb4-agent 整目录 + uv 二进制）
RUN mkdir -p /payload \
 && tar czf /payload/tb4-agent-payload.tar.gz -C / opt/tb4-agent \
 && install -m 0755 /usr/local/bin/uv /payload/uv \
 && du -sh /payload/*

CMD ["true"]
