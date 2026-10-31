#!/bin/bash
# CentOS 7 上安装完 Docker 后的自检脚本（不联网；可选加载离线包镜像做端到端验证）
#
# 用法：
#   bash verify_docker_el7.sh
#   bash verify_docker_el7.sh --bundle /data/bench-bundle        # 额外测试 docker load + runner 工具链
set -uo pipefail

BUNDLE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --bundle) BUNDLE="$2"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

FAIL=0
ok()   { echo "OK   $*"; }
warn() { echo "WARN $*"; }
bad()  { echo "FAIL $*"; FAIL=1; }

echo "== 1. 版本与 API =="
if docker info >/dev/null 2>&1; then
  ok "docker daemon: $(docker version --format '{{.Server.Version}}')  API: $(docker version --format '{{.Server.APIVersion}}')  client: $(docker version --format '{{.Client.Version}}')"
  SERVER_VER=$(docker version --format '{{.Server.Version}}')
  API_VER=$(docker version --format '{{.Server.APIVersion}}')
else
  bad "docker daemon 不可用（systemctl status docker / journalctl -u docker）"
  SERVER_VER=""; API_VER=""
fi

echo "== 2. 存储驱动 / cgroup =="
if [ -n "$SERVER_VER" ]; then
  DRIVER=$(docker info --format '{{.Driver}}' 2>/dev/null)
  [ "$DRIVER" = "overlay2" ] && ok "storage driver: overlay2" || warn "storage driver: $DRIVER（建议 overlay2）"
  docker info --format '{{.CgroupDriver}}' 2>/dev/null | grep -q systemd \
    && ok "cgroup driver: systemd" \
    || warn "cgroup driver: $(docker info --format '{{.CgroupDriver}}' 2>/dev/null)（CentOS 7 上 cgroupfs 也可用）"
fi

echo "== 3. 插件 =="
docker compose version >/dev/null 2>&1 && ok "docker compose: $(docker compose version --short 2>/dev/null || docker compose version)" || warn "docker compose 插件不可用（第一批 compose 方式需要；第二批 run_batch2.sh 不需要）"
docker buildx version >/dev/null 2>&1 && ok "docker buildx: $(docker buildx version | head -1)" || warn "docker buildx 不可用（NL2Repo 后处理构建需要；如缺请检查 RPM）"

echo "== 4. 旧 daemon API 兼容提示 =="
if [ -n "$API_VER" ]; then
  echo "    宿主 daemon API = $API_VER"
  echo "    在离线包 runner 容器里跑评测时，请加：-e DOCKER_API_VERSION=$API_VER"
  echo "    （bench-eval-runner:v2 内置 CLI 较新，不指定会报 client version too new）"
fi

echo "== 5. 系统风险项 =="
KERNEL=$(uname -r)
case "$KERNEL" in
  *el7*) ok "内核 $KERNEL（CentOS 7）" ;;
  *) warn "内核不是 el7：$KERNEL" ;;
esac
if command -v getenforce >/dev/null 2>&1; then
  SE=$(getenforce 2>/dev/null || echo Unknown)
  [ "$SE" = "Enforcing" ] && warn "SELinux=Enforcing：容器 bind mount 可能报 permission denied；可临时 setenforce 0 或调整策略" || ok "SELinux=$SE"
fi
if systemctl is-active firewalld >/dev/null 2>&1; then
  warn "firewalld 正在运行：Docker 会直接写 iptables，若容器网络异常可临时 systemctl stop firewalld"
else
  ok "firewalld 未运行"
fi
DF_T=$(df -T /var/lib/docker 2>/dev/null | tail -1 | awk '{print $2}')
if [ "$DF_T" = "xfs" ]; then
  if command -v xfs_info >/dev/null 2>&1; then
    if xfs_info /var/lib/docker 2>/dev/null | grep -q 'ftype=1'; then ok "XFS ftype=1（overlay2 可用）"; else bad "XFS ftype=0：overlay2 不可用，请改用 ext4 数据盘或调整 data-root"; fi
  else
    warn "无法检查 XFS ftype（xfsprogs 未安装）"
  fi
fi

echo "== 6. 离线包端到端（可选） =="
if [ -n "$BUNDLE" ] && [ -n "$SERVER_VER" ]; then
  TAR="$BUNDLE/images/bench-images-runner-v2.tar"
  if [ -f "$TAR" ]; then
    echo "    docker load runner 镜像（约 0.55 GiB）..."
    if docker load -i "$TAR" >/dev/null 2>&1; then
      ok "docker load 成功（OCI tar 在 Docker 20.10 上兼容已实测）"
      echo "    在 runner 里验证工具链（挂宿主 docker.sock）..."
      if docker run --rm -e DOCKER_API_VERSION="$API_VER" \
           -v /var/run/docker.sock:/var/run/docker.sock \
           bench-eval-runner:v2 bash -lc \
           'docker version --format "  runner->daemon: client={{.Client.Version}} server={{.Server.Version}}"; harbor --version; pier --version; docker compose version' 2>/dev/null; then
        ok "runner 工具链 + docker.sock + API 兼容：通过"
      else
        bad "runner 工具链验证失败（检查 docker.sock 权限 / DOCKER_API_VERSION）"
      fi
    else
      bad "docker load 失败"
    fi
  else
    warn "找不到 $TAR（跳过）"
  fi
else
  echo "    跳过（未传 --bundle）"
fi

echo
if [ "$FAIL" = "0" ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL"; exit 1; fi
