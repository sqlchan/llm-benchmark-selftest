#!/usr/bin/env bash
# TB4 派生任务镜像补丁：补齐 mcp 及其依赖（LiteLLM 1.106 顶层导入需要）。
#
# 背景：离线包里的 tb4off/environment:* 镜像分两批（15 基础 + 21 扩题），其中早期构建的
# 15 个缺少 mcp；断网 run 时必须各自追加一个 ~5.6MB 的补丁层。
# 本脚本自动枚举当前已加载的全部 tb4off/environment:*（继续扩题后无需改脚本），
# 在 load_bundle.sh 之后执行（不需要外网；docker build 只用本地镜像 + 本地文件）。
#
# 用法：
#   ./offline/fix_tb4_images.sh            # 自动定位离线包目录
#   BUNDLE_DIR=/mnt/ssd/bench-bundle ./offline/fix_tb4_images.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="${BUNDLE_DIR:-$(cd "$HERE/.." && pwd)}"
CTX="$BUNDLE/offline/tb4-agent-payload"

[ -f "$CTX/agent-extra.tar.gz" ] || { echo "缺少 $CTX/agent-extra.tar.gz" >&2; exit 2; }

mapfile -t TASKS < <(docker images --format '{{.Repository}}:{{.Tag}}' \
  | grep '^tb4off/environment:' | cut -d: -f2 | sort)
if [ "${#TASKS[@]}" -eq 0 ]; then
  echo "没有找到 tb4off/environment:* 镜像（先运行 load_bundle.sh）" >&2
  exit 2
fi
echo "已加载 TB4 派生镜像：${#TASKS[@]} 个"

# 已经打过补丁的镜像会包含 mcp；逐个检查，避免重复构建
need_fix=()
for t in "${TASKS[@]}"; do
  img="tb4off/environment:$t"
  if docker run --rm --network none --entrypoint python "$img" -c 'import mcp' >/dev/null 2>&1; then
    echo "[ok]   $img 已有 mcp"
  else
    need_fix+=("$t")
  fi
done

if [ "${#need_fix[@]}" -eq 0 ]; then
  echo "所有 TB4 派生镜像都已包含 mcp，无需修补。"
  exit 0
fi

echo "需要修补 ${#need_fix[@]} 个镜像：${need_fix[*]}"
for t in "${need_fix[@]}"; do
  img="tb4off/environment:$t"
  echo "== build $img"
  docker build --pull=false \
    --build-arg "BASE_IMAGE=$img" \
    -f "$CTX/Dockerfile.agent-mcp-fix" \
    -t "$img" "$CTX"
done
echo "TB4 mcp 补丁完成（${#need_fix[@]} 个）。"
