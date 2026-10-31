# offline/config：宿主机并发 profile

本目录放「按宿主机规格调好的并发/超时参数」，由 `offline/run_batch2.sh` 在
source `offline/env/company.env`（端点/模型）**之后**按 `PROFILE` 叠加，同名变量
覆盖 `company.env`。只放资源与并发参数，**不要放 API key / 内网端点**（那些在
`offline/env/company.env`，已 gitignore）。

## 现有 profile

| profile | 适用机器 | 文件 |
| :-- | :-- | :-- |
| `32c64g` | 32 vCPU / 64GB RAM / 1TB 盘 Linux + Docker（公司机器） | [`32c64g.env`](32c64g.env) |

## 用法

```bash
# 推荐：wrapper 自动 export PROFILE=32c64g
./offline/run_batch2_32c64g.sh tb4|oracle|nl2repo|shell

# 等价写法
PROFILE=32c64g ./offline/run_batch2.sh tb4
```

`PROFILE=32c64g` 注入的关键值：`TB4_N_CONCURRENT=3`、
`TB4_AGENT_TIMEOUT_MULTIPLIER=1.0`、`NL2REPO_MAX_POOL=3`、
`NL2REPO_MAX_ITERATIONS=500`、`NL2REPO_PORT_BASE=3000`、`NL2REPO_TASKS`（10 题）。
容量/工期/降级规则见 [`report/company-32c64g-concurrency.md`](../../report/company-32c64g-concurrency.md)。

## 依赖（重要）

- **`run_batch2.sh` 需要 PROFILE 补丁**：sourcing `company.env` 之后判断 `PROFILE`，
  并 source `$BUNDLE/offline/config/$PROFILE.env`；缺失时报错退出。本仓库已合入
  （见 `run_batch2.sh` 的 `PROFILE` 段）。补丁不在时 wrapper 会报错退出，
  可用手工回退：`set -a; . offline/config/32c64g.env; set +a; ./offline/run_batch2.sh tb4`。
- **NL2Repo 并行**（`NL2REPO_MAX_POOL>1` / `NL2REPO_PORT_BASE`）还需要 harness 的
  并行补丁，说明见 `offline/nl2repo-harness/README.md`（随并行补丁交付，同目录有
  `apply_parallel_patch.sh`）。
- **profile 覆盖优先级**：`company.env` < `32c64g.env`。所以**冒烟参数不要经过
  wrapper**（会被 profile 里的正式值覆盖），冒烟直接调 `./offline/run_batch2.sh`，
  例如 `NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 ./offline/run_batch2.sh nl2repo`。
