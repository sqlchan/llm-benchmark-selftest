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

if [ "${SKIP_VERIFY:-}" = "1" ]; then
  echo "== 1. 已跳过 SHA256 校验 =="
elif [ -f "$IMAGES/SHA256SUMS" ]; then
  # images/SHA256SUMS 里的路径相对 images/ 目录
  echo "== 1. SHA256 校验（images/SHA256SUMS） =="
  ( cd "$IMAGES" && sha256sum -c SHA256SUMS )
elif [ -f "$BUNDLE/SHA256SUMS" ]; then
  # 包根 SHA256SUMS 里的路径相对包根目录
  echo "== 1. SHA256 校验（SHA256SUMS） =="
  ( cd "$BUNDLE" && sha256sum -c SHA256SUMS )
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第二批 tar 里的 TB4 派生镜像缺少 mcp（LiteLLM 1.106 顶层导入需要），
# 这里用本地补丁层逐个修补（离线；~5.6MB/镜像，15 个镜像约 1-2 分钟）。
if [ "${SKIP_TB4_FIX:-}" != "1" ] && [ -f "$SCRIPT_DIR/fix_tb4_images.sh" ] \
   && docker image inspect tb4off/environment:html-js-filter >/dev/null 2>&1; then
  echo "== 2.5 TB4 派生镜像 mcp 补丁 =="
  BUNDLE_DIR="$BUNDLE" bash "$SCRIPT_DIR/fix_tb4_images.sh" || {
    echo "WARN: TB4 mcp 补丁失败，可稍后手动执行：BUNDLE_DIR=$BUNDLE ./offline/fix_tb4_images.sh" >&2
  }
fi

echo "== 3. 准备配置 =="
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
  2. 第一批（跑 stage1）：
       docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d
       docker compose -f offline/docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh
  3. 第二批（TB4 + NL2Repo；runner 需以「相同绝对路径」挂载离线包）：
       BUNDLE_DIR=$PWD ./offline/run_batch2.sh oracle      # 离线自检，不需要模型
       BUNDLE_DIR=$PWD ./offline/run_batch2.sh tb4         # Terminal-Bench 4.0 子集
       BUNDLE_DIR=$PWD ./offline/run_batch2.sh nl2repo     # NL2Repo-Bench 子集

可选自检（加载后立刻验证 docker.sock 是否允许挂载）：
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock bench-eval-runner:v2 docker ps
EOF
