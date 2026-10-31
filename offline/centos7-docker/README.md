# CentOS 7 离线 Docker 安装包（Docker CE 20.10.24 + compose 插件）

公司评测机若是 **CentOS 7.x x86_64**（内核 3.10），Docker 官方仓库在 CentOS 7 上最后支持的版本线是
**Docker CE 20.10.x**；再新的版本（23+/24+）不再提供 el7 包、依赖更新的 glibc，不建议强装。
本目录是给这类机器准备的**离线 RPM 安装包**与安装/自检脚本，全部在 Windows 构建机上下载，公司端零外网。

## 1. 包内容

```
centos7-docker/            # 离线包内路径：docker-el7/
├─ rpms/                   # 主包（6→5 个，见下）
│  ├─ docker-ce-20.10.24-3.el7.x86_64.rpm
│  ├─ docker-ce-cli-20.10.24-3.el7.x86_64.rpm
│  ├─ containerd.io-1.6.33-3.1.el7.x86_64.rpm
│  ├─ docker-ce-rootless-extras-20.10.24-3.el7.x86_64.rpm
│  └─ docker-compose-plugin-2.27.1-1.el7.x86_64.rpm
├─ deps/                   # 依赖（23 个：container-selinux、SELinux 策略栈、libseccomp、
│                          #   libcgroup、iptables、device-mapper-libs、fuse-overlayfs 等）
├─ install_docker_el7.sh   # 离线安装脚本（root）
├─ verify_docker_el7.sh    # 安装后自检（可选跑离线包镜像端到端）
├─ SHA256SUMS              # 本目录全部 RPM/脚本的校验和
└─ README.md               # 本文件
```

> `docker-buildx-plugin` **不需要**单独安装：`docker-ce-cli-20.10.24` 自带 `/usr/libexec/docker/cli-plugins/docker-buildx`
> （实测自带 buildx 0.10.4）；再装独立 buildx 插件 RPM 会因同路径文件冲突导致事务失败。
> `docker compose` 单独由 `docker-compose-plugin-2.27.1` 提供。

版本语义：`docker-ce 3:20.10.24`、`docker-ce-cli 1:20.10.24`、`containerd.io 1.6.33`、
`docker-compose-plugin 2.27.1`。全部 el7 构建，x86_64。

## 2. 安装

```bash
# 拷贝/挂载离线包后（假设在 /data/bench-bundle/docker-el7）
cd /data/bench-bundle/docker-el7
sha256sum -c SHA256SUMS          # 先校验（可选）
sudo bash install_docker_el7.sh --data-root /data/docker --user "$USER"
# --data-root 建议指向 1TB 数据盘；不传则默认 /var/lib/docker
# --no-start 只安装不启动；--user 把指定用户加入 docker 组（重新登录生效）
```

脚本做的事：
1. 移除 CentOS 自带旧 docker 包（`docker` / `docker-common` / `docker-client` / `docker-selinux` / `docker-engine` 等，如果有）；
2. `yum --disablerepo='*' localinstall deps/*.rpm rpms/*.rpm`（全程离线；失败时回退 `rpm -Uvh` 并打印缺失依赖）；
3. 加载 `br_netfilter` 并写 `/etc/sysctl.d/99-docker-bench.conf`（bridge/NAT/ip_forward）；
4. 写 `/etc/docker/daemon.json`：`data-root`、`storage-driver: overlay2`、json-file 日志轮转（100m×3）、`iptables: true`；
5. `systemctl enable --now docker`（除非 `--no-start`）。

## 3. 安装后自检

```bash
cd /data/bench-bundle/docker-el7
bash verify_docker_el7.sh
# 端到端（会 docker load 0.55GiB 的 runner 镜像并验证工具链 + docker.sock + API 兼容）：
bash verify_docker_el7.sh --bundle /data/bench-bundle
```

期望：`Daemon 20.10.24 / API 1.41`、`storage driver: overlay2`、`docker compose 2.27.1`、buildx 可用；
若传 `--bundle`，最后出现 `runner 工具链 + docker.sock + API 兼容：通过` 与 `RESULT: PASS`。

## 4. 与本离线评测包的兼容性（实测结论，2026-10-31）

| 项 | 结果 |
| :-- | :-- |
| `docker load` 本包 4 个镜像 tar | ✅ Docker **20.10.24** 实测可加载（runner-v2 与 batch2 两个 tar 已实际 load 成功；tar 为 OCI layout + 兼容 manifest.json） |
| 在 CentOS 7 容器里的离线安装 | ✅ `yum localinstall` 仅用本目录 RPM 成功（27 安装 + 2 升级），dockerd 20.10.24 正常启动 |
| runner 镜像内工具链（harbor 0.25.0 / pier 0.3.1 / python-on-whales / compose 2.40.3 / buildx 0.30.1） | ✅ 在 Docker 20.10 上运行通过（build、`docker buildx build`、`docker compose up/down` 全过） |
| **API 版本** | ⚠️ runner 内置 Docker CLI 版本较新（29.x），默认 API（1.52）会被 20.10 daemon 拒绝：`client version 1.52 is too new. Maximum supported API version is 1.41`。**必须**给 runner 容器加 `-e DOCKER_API_VERSION=1.41`（=宿主 daemon API）。本包 `offline/run_batch2.sh` 已自动探测并传入；`offline/docker-compose.yml` 默认 1.41；手工 `docker run`（如 DeepSWE Pier）需自己加 |
| 内核 3.10 下的 TB4 任务 | ⚠️ 未实测（公司环境）；部分任务可能依赖较新内核特性。**先跑 `oracle` 自检**，过不了的题剔除并记录 |

## 5. 系统注意事项（CentOS 7）

- **XFS ftype**：CentOS 7 默认 XFS；overlay2 要求 `ftype=1`。`xfs_info /data | grep ftype=1` 确认；
  若 `ftype=0`，请把 `data-root` 指到 ext4 分区（或重装时选 `-m ftype=1`）。
- **SELinux**：`getenforce` 为 `Enforcing` 时，容器 bind mount 可能报 permission denied。
  临时 `setenforce 0` 后再跑基准（需公司安全策略允许），或让安全团队加策略；不要直接改 `/etc/selinux/config` 了事。
- **firewalld**：Docker 直接写 iptables；若容器网络/NAT 异常，可临时 `systemctl stop firewalld` 验证。
- **内核**：CentOS 7 最新内核为 `3.10.0-1160`；Docker 20.10 要求 ≥3.10。若公司允许内核升级（elrepo kernel-lt），
  可显著降低新版镜像/任务在旧内核上的兼容风险（需另备内核 RPM，本包不含）。
- **docker.sock**：评测 runner 需要挂载 `/var/run/docker.sock`；当前用户在 docker 组即可。

## 6. 回滚 / 卸载

```bash
sudo systemctl stop docker
sudo yum -y remove docker-ce docker-ce-cli containerd.io docker-ce-rootless-extras docker-compose-plugin
# 保留镜像数据则不要删 /var/lib/docker（或你自定义的 data-root）
```

## 7. 重新生成（构建机有网时）

```bash
# 主包 + compose 插件（Aliyun 镜像；download.docker.com 在国内可能不可达）
BASE=https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages
curl -O $BASE/docker-ce-20.10.24-3.el7.x86_64.rpm
curl -O $BASE/docker-ce-cli-20.10.24-3.el7.x86_64.rpm
curl -O $BASE/containerd.io-1.6.33-3.1.el7.x86_64.rpm
curl -O $BASE/docker-ce-rootless-extras-20.10.24-3.el7.x86_64.rpm
curl -O $BASE/docker-compose-plugin-2.27.1-1.el7.x86_64.rpm
# 依赖闭包：在 centos:7 容器里用 CentOS 7.9 vault 源解析后 --downloadonly（见构建记录）
```

依赖闭包（共 23 个）包括：`container-selinux-2.119.2`、`selinux-policy(-targeted)-3.13.1`、`policycoreutils(-python)`、
`libselinux(-utils/-python)`、`libsemanage-python`、`setools-libs`、`checkpolicy`、`audit-libs-python`、`python-IPy`、
`libseccomp-2.3.1`、`libcgroup-0.41`、`iptables-1.4.21`、`libmnl`、`libnfnetlink`、`libnetfilter_conntrack`、
`device-mapper(-libs)-1.02.170`、`fuse3-libs`、`fuse-overlayfs`、`slirp4netns`。

## 8. 关联文档

- 公司第二批操作清单：[`report/company-day1-checklist-batch2.md`](../../report/company-day1-checklist-batch2.md)
- 并发/容量：[`report/company-32c64g-concurrency.md`](../../report/company-32c64g-concurrency.md)
- 离线包总入口：离线包内 `README.md` §0.5
