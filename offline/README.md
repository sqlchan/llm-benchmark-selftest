# 离线评测包（示例模板）

> 配套方案：[`report/offline-airgap-plan.md`](../report/offline-airgap-plan.md)。脚本是模板，标注 `TODO verify` 的位置需按实际环境确认后再放量。
> 环境已确认：**家里 Windows（构建）→ 公司 Linux（运行，Docker 可用）**；公司内网模型同时支持 OpenAI 兼容与 Anthropic 协议。

## 目录

```
offline/
├─ build_bundle.ps1      # 有外网的 Windows 机器：拉镜像/数据 → 导出 tar → 生成校验和
├─ load_bundle.ps1       # Windows 机器加载（家里自测用）
├─ load_bundle.sh        # 公司 Linux 机器加载：校验 → docker load → 写配置
├─ Dockerfile.runner     # 评测 runner 镜像（harness + 数据）
├─ docker-compose.yml    # runner 服务（挂载宿主机 docker.sock）
├─ tools/
│   └─ mock_openai_server.py  # 无 key 时验证链路的本地 mock 端点
├─ images.manifest.txt   # 需要打包的镜像清单（MVP 先填少量）
└─ env/
   └─ example.env        # 模型端点模板（Ark / 公司内网），不要提交真实 key
```

## 先用 mock 验证链路（不需要模型 key）

```powershell
# Windows（建议设 UTF-8，避免 rich 在 GBK 控制台报错）
$env:PYTHONUTF8="1"; $env:PYTHONIOENCODING="utf-8"
python offline\tools\mock_openai_server.py 8765

# 另一个终端，AutomationBench 仓库内（v1.0.6 要求 Python>=3.13，用 uv）
uv run auto-bench --model mock-model --base-url http://127.0.0.1:8765/v1 `
  --api-key dummy --api chat_completions --domains simple --num-examples 2 `
  --max-steps 3 --input-cost 0 --output-cost 0 --export-json ..\mock_simple2.json
```

预期结果：0 分（mock 不调用工具），但进程 exit=0、JSON 完整导出。验证记录见 [`report/stage2-automation-validation.md`](../report/stage2-automation-validation.md)。

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

### 3. 公司 Linux 机器（加载 + 运行）

```bash
# 校验 + docker load + 生成配置
./offline/load_bundle.sh /mnt/ssd/bench-bundle

# 可选自检：验证 docker.sock 挂载是否被允许
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock bench-eval-runner:local docker ps

# 配置内网端点后启动
cp offline/env/example.env offline/env/company.env   # 已存在则跳过
vi offline/env/company.env                            # 填 OPENAI_API_BASE/KEY/MODEL_NAME
docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d
docker compose -f offline/docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh
```

> Linux 前置：当前用户在 `docker` 组（`groups | grep docker`），否则需要 `sudo usermod -aG docker $USER` 并重新登录。若 `docker.sock` 挂载被安全策略禁止，见方案第 7 节退化方案（宿主机直装 Python）。

## 注意

- **key 不要写进任何会提交的文件**：`env/company.env` 已加入 `.gitignore`（见根目录），只通过 `--env-file` 注入。
- 公司若禁止 `docker.sock` 挂载，改用宿主机直装 Python 的退化方案（见方案第 7 节）。
- 镜像清单先只放 MVP 所需项，体积可控后再扩；`images.manifest.txt` 每行是 `镜像名:tag`，脚本会拉取并 `docker save`。
- 数据目录（`data/`）建议按基准分子目录，并在 `manifest.json` 里记录 commit/tag/revision，保证到公司后能核对版本。
