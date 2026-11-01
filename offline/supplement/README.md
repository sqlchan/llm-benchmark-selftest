# 第三批补充包的构建记录（2026-11-01）

本目录只放说明；实际构建脚本/日志在构建机的 `sandbox/supplement/`（不随仓库提交）。
补充内容：DeepSWE +10 题、NL2Repo +6 题、ProgramBench +2 题；产物是 3 个 gzip 镜像 tar，
随离线包放在 `images/bench-images-supplement-*.tar.gz`。完整记录见
[`report/third-batch-bundle.md`](../../report/third-batch-bundle.md)。

## 关键命令（复现用，需外网构建机 + Docker）

```powershell
# 1) 拉镜像（DeepSWE 10 个 ECR / NL2Repo 6 个 ghcr / ProgramBench 2 个；Docker Hub 直连不通时用镜像源）
#    DeepSWE 镜像 ref 见 data/deepswe_selected.json 第 11–20 项。
docker pull --platform linux/amd64 public.ecr.aws/d3j8x8q7/swe-bench-202605:<hash>-v1.1
docker pull --platform linux/amd64 ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0
docker pull --platform linux/amd64 docker.1ms.run/programbench/<instance>:task_cleanroom_v6
docker tag docker.1ms.run/programbench/<instance>:task_cleanroom_v6 programbench/<instance>:task_cleanroom_v6

# 2) NL2Repo 派生测试镜像（预装构建依赖；需网络）
docker build --build-arg BASE_IMAGE=ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0 `
  -f offline/nl2repo-test-fix/Dockerfile -t ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0 `
  offline/nl2repo-test-fix

# 3) ProgramBench 派生镜像（离线 eval 修复：COPY pytest_timeout + pip.conf）
docker build --build-arg BASE=programbench/<instance>:task_cleanroom_v6 `
  -f offline/programbench-eval-fix/Dockerfile -t programbench/<instance>:task_cleanroom_v6 `
  offline/programbench-eval-fix

# 4) ProgramBench 测试 blob（HF revision 5954a1957b5e0d770ec2c5523506abd212806315）
#    在 runner 容器里：HF_HUB_OFFLINE=0 PROGRAMBENCH_HF_REVISION=<rev> programbench blob sync <instance>
#    再把 HF snapshot 里的 <instance>/ 用 cp -rL（解引用 symlink）复制到 data/programbench_blobs/<instance>/

# 5) 打包：docker save 每组镜像 → gzip → 更新 images/SHA256SUMS、根 SHA256SUMS、image-list、manifest.json
```

> 已知坑：本构建机上 `docker save`/`docker build` 偶发 `unexpected EOF`（重试即可，层会续传）；
> ProgramBench 镜像里 `RUN pip install` 会「返回成功但文件不落盘」，所以 eval 修复改用 COPY。
