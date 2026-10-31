#!/usr/bin/env bash
# 把 NL2Repo-Bench 并行化补丁应用到指定 harness 目录。
#
# 设计原则：默认不修改任何文件。只有显式给出 --apply-to <DIR> 才会落盘，
# 因此不会在本仓库 checkout 或离线包（E:\bench-bundle）上被误触发。
#
# 用法（在离线包根目录或本仓库根目录均可）：
#   ./offline/nl2repo-harness/apply_parallel_patch.sh
#       # 查看帮助、补丁路径、默认目标（离线包 data/nl2repo/harness），不修改文件
#   ./offline/nl2repo-harness/apply_parallel_patch.sh --check --apply-to "$BUNDLE/data/nl2repo/harness"
#       # 只做 dry-run 检查（不写盘）
#   ./offline/nl2repo-harness/apply_parallel_patch.sh --apply-to "$BUNDLE/data/nl2repo/harness"
#       # 应用补丁（默认 -p1；自动备份被改文件为 .bak-<时间戳>）
#   ./offline/nl2repo-harness/apply_parallel_patch.sh --revert --apply-to "$BUNDLE/data/nl2repo/harness"
#       # 回滚（反向应用；优先用 .bak-* 之外的反向 patch）
#
# 参数：
#   --apply-to DIR   目标 harness 根目录（含 main.py / openhands/）
#   --patch FILE     指定补丁文件（默认自动找 ../patches/nl2repo_parallel.patch）
#   --strip 0|1      0 = 用 p0 变体（默认文件名 *.p0.patch）；1 = 默认（默认值）
#   --check/--dry-run 只检查不写盘
#   --revert         反向应用（回滚）
#   --force          目标看起来已打过补丁时仍继续
#   -h/--help
#
# 注意：offline/run_batch2.sh 与 offline/run_batch2_inner.sh 的改动在
# offline/patches/nl2repo_offline_scripts.patch，让 Lead 直接同步文件或：
#   patch -p1 -d "$BUNDLE" < "$BUNDLE/offline/patches/nl2repo_offline_scripts.patch"
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="$(cd "$HERE/../.." && pwd)"
DEFAULT_TARGET="${BUNDLE_ROOT}/data/nl2repo/harness"
[[ -n "${BUNDLE_DIR:-}" ]] && DEFAULT_TARGET="${BUNDLE_DIR%/}/data/nl2repo/harness"

TARGET=""
PATCH_FILE=""
STRIP=1
MODE="apply"      # apply | check | revert
FORCE=0

usage() {
  sed -n '2,40p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  printf '\n当前解析：\n'
  printf '  脚本目录      : %s\n' "$HERE"
  printf '  默认目标(离线包): %s\n' "$DEFAULT_TARGET"
  printf '  默认补丁      : %s\n' "${HERE}/../patches/nl2repo_parallel.patch"
  printf '  默认目标是否存在: %s\n' "$([[ -e "$DEFAULT_TARGET" ]] && echo yes || echo no)"
  printf '  patch 工具    : %s\n' "$(command -v patch || echo '未找到（fallback: git apply）')"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply-to)  TARGET="${2:-}"; shift 2 ;;
    --patch)     PATCH_FILE="${2:-}"; shift 2 ;;
    --strip)     STRIP="${2:-}"; shift 2 ;;
    --check|--dry-run) MODE="check"; shift ;;
    --revert)    MODE="revert"; shift ;;
    --force)     FORCE=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "未知参数: $1（--help 查看用法）" >&2; exit 2 ;;
  esac
done

case "$STRIP" in
  0) DEF_PATCH="${HERE}/../patches/nl2repo_parallel.p0.patch" ;;
  1) DEF_PATCH="${HERE}/../patches/nl2repo_parallel.patch" ;;
  *) echo "--strip 只支持 0 或 1" >&2; exit 2 ;;
esac
PATCH_FILE="${PATCH_FILE:-$DEF_PATCH}"

if [[ -z "$TARGET" ]]; then
  usage
  echo >&2
  echo "未指定 --apply-to：默认不修改任何文件。确认目标后重跑，例如：" >&2
  echo "  bash '$HERE/apply_parallel_patch.sh' --check --apply-to '$DEFAULT_TARGET'" >&2
  echo "  bash '$HERE/apply_parallel_patch.sh'         --apply-to '$DEFAULT_TARGET'" >&2
  exit 2
fi

[[ -e "$TARGET" ]] || { echo "目标不存在: $TARGET" >&2; exit 2; }
[[ -d "$TARGET" ]] || { echo "目标不是目录: $TARGET" >&2; exit 2; }
[[ -f "$TARGET/main.py" ]] || { echo "目标不像 harness 根目录（缺 main.py）: $TARGET" >&2; exit 2; }
[[ -f "$PATCH_FILE" ]] || { echo "补丁文件不存在: $PATCH_FILE" >&2; exit 2; }

echo "[apply] 目标: $TARGET"
echo "[apply] 补丁: $PATCH_FILE (strip=$STRIP, mode=$MODE)"

# 判断是否已打过补丁
if grep -q 'NL2REPO_PORT_BASE' "$TARGET/openhands/openhands_app.py" 2>/dev/null; then
  ALREADY=1
else
  ALREADY=0
fi
if [[ "$MODE" == "apply" && "$ALREADY" == "1" && "$FORCE" != "1" ]]; then
  echo "[apply] 目标看起来已经打过并行补丁（openhands_app.py 含 NL2REPO_PORT_BASE）。" >&2
  echo "[apply] 跳过，未修改文件。确需重复应用请加 --force。" >&2
  exit 0
fi
if [[ "$MODE" != "apply" && "$ALREADY" == "1" && "$FORCE" != "1" ]]; then
  echo "[apply] 提示: 目标已包含并行补丁标记（MODE=$MODE 仍按补丁本身检查）。"
fi

run_patch() {
  local extra="$1"
  if command -v patch >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    patch $extra -p"$STRIP" -d "$TARGET" < "$PATCH_FILE"
  elif command -v git >/dev/null 2>&1; then
    local git_flag=""
    [[ "$MODE" == "check" ]] && git_flag="--check"
    [[ "$MODE" == "revert" ]] && git_flag="-R"
    ( cd "$TARGET" && git apply $git_flag -p"$STRIP" "$PATCH_FILE" )
  else
    echo "既没有 patch 也没有 git，无法应用补丁" >&2
    exit 2
  fi
}

if [[ "$MODE" == "check" ]]; then
  echo "--- dry-run（不写盘）"
  if [[ -n "$FORCE" ]] || true; then
    run_patch "--dry-run"
  fi
  echo "[apply] dry-run 通过"
  exit 0
fi

# 落盘前备份被补丁修改的文件
STAMP="$(date +%Y%m%d-%H%M%S)"
if [[ -f "$TARGET/openhands/openhands_app.py" ]]; then
  cp -p "$TARGET/openhands/openhands_app.py" "$TARGET/openhands/openhands_app.py.bak-$STAMP"
  echo "[apply] 已备份: $TARGET/openhands/openhands_app.py.bak-$STAMP"
fi

if [[ "$MODE" == "revert" ]]; then
  echo "--- 反向应用补丁（回滚）"
  patch -R -p"$STRIP" -d "$TARGET" < "$PATCH_FILE"
  echo "[apply] 回滚完成；如仍未回到预期版本，可从 .bak-$STAMP 恢复"
  exit 0
fi

echo "--- 应用补丁"
run_patch ""
echo "[apply] 完成。校验："
if grep -q 'NL2REPO_PORT_BASE' "$TARGET/openhands/openhands_app.py"; then
  echo "[apply]   openhands_app.py 已包含 NL2REPO_PORT_BASE（并发补丁已生效）"
else
  echo "[apply]   警告: 未找到 NL2REPO_PORT_BASE，请人工检查" >&2
  exit 1
fi
echo "[apply] 回滚方法: bash '$HERE/apply_parallel_patch.sh' --revert --apply-to '$TARGET'" >&2
