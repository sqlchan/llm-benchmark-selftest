# 来源与收录说明

## 来源

| 项 | 值 |
| :-- | :-- |
| 源仓库 | <https://github.com/sqlchan/hangzhou-agent-eval>（**私有**） |
| 收录 commit | `193246067434de4d051034699112de3c5e971c9e`（`main`，2026-11-01） |
| 收录日期 | 2026-11-01 |
| 收录方式 | 整篇复制 11 个 Markdown 文件，未改正文 |

## 收录范围与差异

- **收录**：`README.md` 之外的 11 篇正文 + 本目录的导航 README。
- **未收录**：`sync.ps1`。该脚本的 remote 指向源仓库（`git@github.com:sqlchan/hangzhou-agent-eval.git`），放进本仓库后一旦执行会把本仓库的提交推到源仓库，故排除。
- **格式调整**：
  1. 换行 CRLF → LF（符合本仓库 `.gitattributes` 的 `* text=auto eol=lf`）；
  2. 导航 README 中「维护与同步」「目录结构」两处涉及 `sync.ps1` 的段落改为归档说明，其余正文未动。
- **交叉引用**：导航 README 末尾加了一行指向本仓库 `report/eval-tools-offline-bundle.md` 与 `report/opencompass-offline-bundle.md`（源仓库没有这两个文件）。

## 用途与注意事项

- 内容为**个人学习与求职准备**资料，不代表任何公司官方招聘要求；JD 来自公开招聘渠道，含平台水印与重复片段。
- 原仓库是唯一维护源；本目录只是归档副本，更新时请整篇替换，避免两边漂移。
- 本仓库是公开仓库，收录即公开可见；如需撤回，删除本目录并提交即可（历史仍可在 git 记录中查到）。
