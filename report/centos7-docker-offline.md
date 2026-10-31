# CentOS 7 离线 Docker 安装包（docker-el7）

> 面向：公司评测机为 **CentOS 7.x x86_64**、Docker 版本偏低或尚未安装、且**不能联网**的情况。
> 离线包内位置：`docker-el7/`（含 RPM、安装脚本、自检脚本、SHA256SUMS 与 README）。
> 仓库源文件：`offline/centos7-docker/`。

## 1. 为什么是 Docker CE 20.10.24

Docker 官方对 CentOS 7 的仓库支持止于 **20.10.x**（本项目锁定 `20.10.24-3.el7`，是 el7 线最后一个版本）。
更高版本（23+/24+）不再提供 el7 RPM、依赖更新的 glibc/内核，不建议在 CentOS 7 上强行安装。
20.10.24 + containerd.io 1.6.33 + docker-compose-plugin 2.27.1 可以满足本离线包的全部评测需求。

## 2. 包内容（离线包 `docker-el7/`）

| 类别 | 内容 |
| :-- | :-- |
| 主包（`rpms/`，5 个） | docker-ce 20.10.24、docker-ce-cli 20.10.24、containerd.io 1.6.33、docker-ce-rootless-extras 20.10.24、docker-compose-plugin 2.27.1（全部 el7 x86_64） |
| 依赖（`deps/`，23 个） | container-selinux、SELinux 策略栈、libseccomp、libcgroup、iptables、device-mapper(-libs)、fuse3-libs、fuse-overlayfs、slirp4netns 等 |
| 脚本 | `install_docker_el7.sh`（离线安装）、`verify_docker_el7.sh`（自检，可 `--bundle` 做端到端） |
| 校验 | `SHA256SUMS`（31 项：5 主包 + 23 依赖 + 3 脚本/README） |

> `docker-buildx-plugin` 不需要单独装：docker-ce-cli 20.10.24 已自带 buildx 插件；再装独立 RPM 会因
> `/usr/libexec/docker/cli-plugins/docker-buildx` 文件冲突导致安装失败（已实测）。

## 3. 安装与自检

```bash
cd /path/to/bench-bundle/docker-el7
sha256sum -c SHA256SUMS
sudo bash install_docker_el7.sh --data-root /data/docker --user "$USER"
bash verify_docker_el7.sh --bundle /path/to/bench-bundle    # 端到端（含 docker load + runner 工具链）
```

期望：daemon `20.10.24`、API `1.41`、storage driver `overlay2`、`docker compose 2.27.1`、
`runner 工具链 + docker.sock + API 兼容：通过`、`RESULT: PASS`。

## 4. 兼容性实测结论（2026-10-31，Windows 构建机 + centos:7 容器）

| 项 | 结论 |
| :-- | :-- |
| `docker load` 离线包 4 个镜像 tar | ✅ Docker **20.10.24** 可加载（runner-v2 0.55 GiB、batch2 19.8 GiB 两个 tar 实测 load 成功；tar 为 OCI layout + 兼容 manifest.json） |
| CentOS 7 离线 RPM 安装 | ✅ 在 centos:7 容器内仅用本目录 RPM `yum localinstall` 成功（27 安装 + 2 升级），dockerd 20.10.24 正常启动 |
| runner 工具链（harbor 0.25.0 / pier 0.3.1 / python-on-whales / compose 2.40.3 / buildx 0.30.1） | ✅ 在 Docker 20.10 下运行通过；`docker build`、`docker buildx build`、`docker compose up/down`、python-on-whales 构建全部成功 |
| **API 版本兼容** | ⚠️ runner 内置 Docker CLI 29.x 默认 API 1.52，会被 20.10 daemon 拒绝（`client version 1.52 is too new`）。**必须给 runner 容器加 `-e DOCKER_API_VERSION=1.41`**（=宿主 daemon API）。已合入：`offline/run_batch2.sh` 自动探测并传入；`offline/docker-compose.yml` 默认 1.41；DeepSWE 手工 `docker run` 请自己加 |
| CentOS 7 内核 3.10 下的 TB4 任务 | ⚠️ 未实测。部分任务可能依赖较新内核特性；**先跑 `oracle` 自检**，过不了的题剔除并记录 |

## 5. 系统注意事项

- **XFS ftype**：overlay2 要求 XFS `ftype=1`；`xfs_info /data | grep ftype=1` 确认，否则把 `--data-root` 指到 ext4 分区。
- **SELinux**：`Enforcing` 时容器 bind mount 可能 permission denied；临时 `setenforce 0`（需安全团队允许）或调整策略。
- **firewalld**：容器网络/NAT 异常时临时 `systemctl stop firewalld` 验证（Docker 直接写 iptables）。
- **data-root**：建议放 1TB 数据盘（`--data-root /data/docker`），评测镜像 + 派生镜像峰值约 200 GB（详见并发文档 §5）。

## 6. 与其他文档的关系

- 完整安装/回滚/重打包说明：离线包 `docker-el7/README.md`（仓库 `offline/centos7-docker/README.md`）
- 到公司后的操作顺序：`company-day1-checklist-batch2.md`
- 并发与容量：`company-32c64g-concurrency.md`
- 断网方案总览：`offline-airgap-plan.md`
