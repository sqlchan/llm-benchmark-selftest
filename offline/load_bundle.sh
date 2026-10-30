#!/usr/bin/env bash
# 公司（Linux，断网）机器上执行：校验 SHA256 → docker load 镜像 → 生成配置模板
#
# 用法：
#   ./offline/load_bundle.sh /path/to/bench-bundle
#   SKIP_VERIFY=1 ./offline/load_bundle.sh /path/to/bench-bundle   # 跳过校验（不建议）
set -euo pipefail

BUNDLE="${1:-}"
if [ -z "$BUNDLE" ]; then
  echo "用法: $0 <离线包目录>（应包含 images/、SHA256SUMS）" >&2
  exit 2
fi
IMAGES="$BUNDLE/images"
[ -d "$IMAGES" ] || { echo "找不到 $IMAGES，请确认离线包路径" >&2; exit 2; }

echo "== 0. Docker 检查 =="
docker info --format 'docker daemon: {{.ServerVersion}}' >/dev/null 2>&1 || {
  echo "无法连接 docker daemon：确认已启动 dockerd，且当前用户在 docker 组（groups 查看）" >&2
  exit 1
}
echo "docker daemon OK"

if [ "${SKIP_VERIFY:-}" != "1" ] && [ -f "$BUNDLE/SHA256SUMS" ]; then
  echo "== 1. SHA256 校验 =="
  ( cd "$IMAGES" && sha256sum -c "$BUNDLE/SHA256SUMS" )
elif [ "${SKIP_VERIFY:-}" = "1" ]; then
  echo "== 1. 已跳过 SHA256 校验 =="
else
  echo "== 1. 未找到 SHA256SUMS，跳过校验 =="
fi

echo "== 2. 加载镜像 =="
count=0
for tar in $(ls -1 "$IMAGES"/*.tar | sort); do
  echo "[load] $(basename "$tar") ($(du -h "$tar" | cut -f1))"
  docker load -i "$tar"
  count=$((count + 1))
done
echo "已加载 $count 个镜像。"

echo "== 3. 准备配置 =="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$SCRIPT_DIR/env"
mkdir -p "$ENV_DIR"
if [ ! -f "$ENV_DIR/company.env" ]; then
  cp "$ENV_DIR/example.env" "$ENV_DIR/company.env"
  echo "[config] 已生成 $ENV_DIR/company.env，请填内网端点（不要提交 git）"
fi

echo
cat <<'EOF'
下一步：
  1. 编辑 offline/env/company.env（OPENAI_API_BASE / OPENAI_API_KEY / MODEL_NAME）
  2. docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d
  3. docker compose -f offline/docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh

可选自检（加载后立刻验证 docker.sock 是否允许挂载）：
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock bench-eval-runner:local docker ps
EOF
