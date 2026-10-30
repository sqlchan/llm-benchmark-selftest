# 离线评测包（示例模板）

> 配套方案：[`report/offline-airgap-plan.md`](../report/offline-airgap-plan.md)。脚本是模板，标注 `TODO verify` 的位置需按实际环境确认后再放量。

## 目录

```
offline/
├─ build_bundle.ps1      # 有外网的机器：拉镜像/数据 → 导出 tar → 生成校验和
├─ load_bundle.ps1       # 公司机器：校验 → docker load → 写配置
├─ Dockerfile.runner     # 评测 runner 镜像（harness + 数据）
├─ docker-compose.yml    # runner 服务（挂载宿主机 docker.sock）
├─ images.manifest.txt   # 需要打包的镜像清单（MVP 先填少量）
└─ env/
   └─ example.env        # 模型端点模板（Ark / 公司内网），不要提交真实 key
```

## 步骤

### 1. 有外网的机器（构建）

```powershell
# 先按 env/example.env 填好想要的基准子集与数据版本，然后：
.\build_bundle.ps1 -Bundle D:\bench-bundle -Subset mvp
docker build -f .\Dockerfile.runner -t bench-eval-runner:local ..
docker save -o D:\bench-bundle\images\bench-eval-runner.tar bench-eval-runner:local
```

### 2. 断网自测（关键）

1. 关掉 Wi-Fi / 拔网线，保持 Docker Desktop 运行；
2. 只验证「任务能启动、判分能出、数据能读」，模型调用可临时指到 mock；
3. 把可离线题号写入 `env/offline-ok.txt`，到公司只用这批题。

### 3. 公司机器（加载 + 运行）

```powershell
.\load_bundle.ps1 -Bundle E:\bench-bundle
copy .\env\example.env .\env\company.env   # 填内网端点（不提交 git）
docker compose --env-file .\env\company.env up -d
docker compose exec runner bash /workspace/run_stage1.sh
```

## 注意

- **key 不要写进任何会提交的文件**：`env/company.env` 已加入 `.gitignore`（见根目录），只通过 `--env-file` 注入。
- 公司若禁止 `docker.sock` 挂载，改用宿主机直装 Python 的退化方案（见方案第 7 节）。
- 镜像清单先只放 MVP 所需项，体积可控后再扩；`images.manifest.txt` 每行是 `镜像名:tag`，脚本会拉取并 `docker save`。
- 数据目录（`data/`）建议按基准分子目录，并在 `manifest.json` 里记录 commit/tag/revision，保证到公司后能核对版本。
