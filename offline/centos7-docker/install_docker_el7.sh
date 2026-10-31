#!/bin/bash
# CentOS 7.x x86_64 离线安装 Docker CE 20.10.24（Docker 官方支持 CentOS 7 的最后一条版本线）
#
# 用法（root 执行，在含有 rpms/ 与 deps/ 的目录下）：
#   sudo bash install_docker_el7.sh                     # 默认数据目录 /var/lib/docker
#   sudo bash install_docker_el7.sh --data-root /data/docker   # 数据盘
#   sudo bash install_docker_el7.sh --no-start          # 只装不启动
#   sudo bash install_docker_el7.sh --user alice        # 把 alice 加入 docker 组
#
# 说明：
# - 全部 RPM 已在本目录（rpms/ 主包 + deps/ 依赖），不访问外网、不需要 yum 源；
# - 会先移除 CentOS 自带的旧 docker 包（docker / docker-common / docker-client 等），
#   不会删除 /var/lib/docker 里已有的镜像数据（如需彻底重装请自行清理）；
# - 安装后写入 /etc/docker/daemon.json（数据目录、日志轮转、overlay2、iptables 默认值）。
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPMDIR="$HERE/rpms"
DEPSDIR="$HERE/deps"
DATA_ROOT="/var/lib/docker"
DO_START=1
DOCKER_USER=""

while [ $# -gt 0 ]; do
  case "$1" in
    --data-root) DATA_ROOT="$2"; shift 2 ;;
    --no-start) DO_START=0; shift ;;
    --user) DOCKER_USER="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

log() { echo -e "\n== $* =="; }
die() { echo "错误: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "请用 root 执行（sudo bash $0）"
[ "$(uname -m)" = "x86_64" ] || die "本包只含 x86_64 RPM；当前架构 $(uname -m)"
[ -d "$RPMDIR" ] && [ -d "$DEPSDIR" ] || die "找不到 $RPMDIR 或 $DEPSDIR（请在完整包目录执行）"

log "0. 系统检查"
. /etc/os-release 2>/dev/null || true
echo "OS: ${PRETTY_NAME:-unknown}  Kernel: $(uname -r)"
case "$(uname -r)" in
  *el7*) : ;;
  *) echo "WARN: 当前内核不是 el7（CentOS 7），请确认目标是 CentOS 7" ;;
esac
# CentOS 7 内核 3.10；Docker CE 20.10 要求 >= 3.10
kern_major=$(uname -r | cut -d. -f1)
[ "$kern_major" -ge 3 ] || die "内核过旧：$(uname -r)（Docker 20.10 需要 3.10+）"

log "1. 移除 CentOS 自带旧 docker（如有）"
OLD_PKGS="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine docker-engine-selinux"
for p in $OLD_PKGS; do
  if rpm -q "$p" >/dev/null 2>&1; then
    echo "移除冲突包: $p"
    yum -y remove "$p" || true
  fi
done

log "2. 离线安装 Docker CE 20.10.24 + containerd + compose/buildx 插件"
# 本地 RPM 目录作为唯一来源；--disablerepo='*' 防止误连外网/坏源
if ! yum -y --disablerepo='*' localinstall "$DEPSDIR"/*.rpm "$RPMDIR"/*.rpm --nogpgcheck; then
  echo "yum localinstall 失败，尝试 rpm 直接安装（依赖若不满足会报出缺失列表）"
  rpm -Uvh --replacepkgs "$DEPSDIR"/*.rpm "$RPMDIR"/*.rpm
fi

log "3. 内核参数（bridge 网络 / NAT 需要）"
modprobe br_netfilter 2>/dev/null || true
cat > /etc/sysctl.d/99-docker-bench.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system >/dev/null 2>&1 || true

log "4. daemon.json（data-root=$DATA_ROOT）"
mkdir -p "$DATA_ROOT" /etc/docker
if [ -f /etc/docker/daemon.json ]; then
  cp /etc/docker/daemon.json "/etc/docker/daemon.json.bak-$(date +%Y%m%d%H%M%S)"
  echo "已备份原 /etc/docker/daemon.json"
fi
cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "$DATA_ROOT",
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": { "max-size": "100m", "max-file": "3" },
  "iptables": true
}
EOF

log "5. 启动 docker 服务"
if [ "$DO_START" = "1" ]; then
  systemctl daemon-reload
  systemctl enable docker
  systemctl restart docker
  for i in $(seq 1 30); do
    if docker info >/dev/null 2>&1; then break; fi
    sleep 1
  done
  docker version --format 'Docker daemon: {{.Server.Version}}  API: {{.Server.APIVersion}}' || die "docker 启动失败，查看 journalctl -u docker"
else
  echo "已跳过启动（--no-start）"
fi

if [ -n "$DOCKER_USER" ]; then
  log "6. 用户组"
  groupadd -f docker
  usermod -aG docker "$DOCKER_USER"
  echo "已把 $DOCKER_USER 加入 docker 组（重新登录生效）"
fi

log "完成。下一步"
cat <<'EOF'
  1) 校验：bash verify_docker_el7.sh
  2) 加载离线包镜像（4 个 tar，约 20–40 分钟）：
       cd /path/to/bench-bundle && bash offline/load_bundle.sh "$PWD"
  3) 旧 Docker（20.10）上运行评测 runner 时，需要显式 API 版本：
       export DOCKER_API_VERSION=$(docker version --format '{{.Server.APIVersion}}')
     离线包的 run_batch2.sh 已自动处理；手工 docker run 时请带上 -e DOCKER_API_VERSION=1.41
  4) SELinux：若 getenforce 为 Enforcing 且容器挂载报 permission denied，
     临时 setenforce 0（或让安全团队调整策略）后再跑基准；详见 README.md。
EOF
