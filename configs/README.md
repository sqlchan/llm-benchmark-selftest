# 配置模板

这些文件是 **API-only 评测的接入模板**，字段名来自官方文档/仓库，但具体网关地址、模型名、key 需要替换；标注 `TODO verify` 的字段请先用 1 题跑通再放量。

| 文件 | 用途 | 官方依据 |
| :-- | :-- | :-- |
| `mini-swe-model.example.yaml` | mini-swe-agent 系 harness（DeepSWE/Pier、ProgramBench、TB4 的 `-a mini-swe-agent`）接任意 OpenAI 兼容端点 | <https://mini-swe-agent.com/latest/models/local_models/> |
| `nl2repo-config.example.json` | NL2Repo-Bench 的 `config.json`（`startPro[].moduleName/baseUrl/sk/proNameList`） | <https://github.com/multimodal-art-projection/NL2RepoBench> |
| `model_registry.example.json` | 可选：LiteLLM 模型注册（让轨迹里能算出成本） | <https://mini-swe-agent.com/latest/models/local_models/> |

用法要点：

1. 环境变量放 key：`export OPENAI_API_KEY=...`（不要把 key 写进模板提交到 git）。
2. mini-swe 系入口用 `-c <config>`（或 Pier 配置里的 `kwargs.config_yaml`）引用 `model:` 段。
3. 未注册模型时保留 `cost_tracking: ignore_errors`，成本用第 5 节的方法自行统计；需要自动成本再用 registry。
4. 所有模板中的 `api_base` 是否带 `/v1` 取决于具体网关，先跑 1 题验证（TODO verify）。
