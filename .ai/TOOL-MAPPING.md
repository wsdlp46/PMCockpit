# TOOL-MAPPING.md — 多工具适配说明

本文件说明本套 PM 工作流资产在 ZCode、WorkBuddy、Codex、Claude Code 下的加载差异。业务规则以 `AGENTS.md` 和 `01通用规则/项目工作流规范.md` 为准，能力路由见 `01通用规则/AI能力路由规范.md`，权限与确认门见 `01通用规则/AI能力治理规范.md`；本文件只维护工具适配。

## 资产清单

| 类型 | 位置 | 内容 |
|------|------|------|
| 工作区规则 | 项目根 `AGENTS.md` | 工作流触发、文件结构、写入边界、上下文加载顺序 |
| 通用规范 | `01通用规则/` | 流程、设计、AI 能力与 MCP 治理 |
| 核心 Skills | `.ai/skills/` | 8 个通用执行流程的唯一权威源，四端默认以软链安装 |
| 可选 Skills | `.ai/optional-skills/` | 测试与 VitePress 均须显式安装；后者还要求已有独立站点 |
| Skill 资产登记表 | `.ai/SKILL-ASSETS.md` | 允许跨项目回收的 Skill 资产槽、准入、索引联动与验证方式 |
| 专用 Agent | `.ai/agents/solution-designer.md` | 仅 ZCode 软链安装的工具专属适配 |
| MCP 清单 | `00环境配置/MCP能力清单.md` | 非敏感能力登记、权限等级、确认门与降级方式 |

> 不分发 `ppt-master`、`component-flow` 和 `docs-site/`。禁止在各工具本地 Skill 目录维护工作区同名副本；本地记忆、计划、缓存和日志均非权威源。

## 受治理 Skill 清单

以下 8 个名称是默认发行清单，必须与 `.ai/skills/` 中含 `SKILL.md` 的目录逐项一致；`harness-audit.sh` 会检查缺失和多余项。

<!-- skill-inventory:start -->
| Skill | 用途 |
|------|------|
| `prd-writer` | PRD 撰写 |
| `project-intake-pm` | 项目材料入库 |
| `project-iteration` | 既有项目内的版本生命周期管理 |
| `project-retrospective-pm` | 项目复盘与优化 |
| `proto-spec-generator` | 页面原型设计规格 |
| `prototype-html-pin` | 交互式 HTML 原型 |
| `research-pm` | 调研工作流 |
| `tapd-requirement-upload` | TAPD 需求规划与上传 |
<!-- skill-inventory:end -->

### 可选能力

`test-flow-pm` 与 `vitepress-deploy` 均不属于默认安装集。测试仅在版本已提测或用户明确要求测试时启用；VitePress 还要求使用者具备独立的文档站、部署权限和站点路径。PMCockpit 不携带 `docs-site/`、服务器配置、账号、密码或密钥。需要时执行：

```bash
bash .ai/install.sh --with-test
bash .ai/install.sh --with-vitepress
```

## 工具加载机制对比

| 工具 | 共用 AGENTS.md | 工作区 Skill 安装位置 | 专用 Agent | MCP 配置与说明 |
|------|:---:|------|------|------|
| **ZCode** | 是 | `~/.zcode/skills/` | 仅 `~/.zcode/agents/solution-designer.md` | 工具自身配置；能力与权限以 MCP 清单为准 |
| **WorkBuddy** | 是 | `~/.workbuddy/skills/` | 不链接工作区 Agent | `~/.workbuddy/mcp.json`；不记录凭证到工作区 |
| **Codex** | 是 | `~/.codex/skills/` | 不链接工作区 Agent | 客户端或插件配置；调用前核对 MCP 清单 |
| **Claude Code** | 是（也读 `CLAUDE.md`） | `~/.claude/skills/` | 不链接工作区 Agent | 工具自身配置；能力与权限以 MCP 清单为准 |

## 安装方式

```bash
git clone <仓库地址> <项目目录>
cd <项目目录>
bash .ai/install.sh
# 仅当需要测试闭环时：
bash .ai/install.sh --with-test
# 仅当已有独立 VitePress 文档站时：
bash .ai/install.sh --with-vitepress
```

脚本默认对每个已检测到的端安装 8 个核心 Skill；每启用一个可选 Skill 增加 1 个，两个都启用时共 10 个。仅 ZCode 会链接 `.ai/agents/solution-designer.md`；其他三端不安装工作区 Agent。脚本分别汇总 Skill 与 Agent 的已链接、端未检测跳过、非软链冲突跳过数量，不覆盖任何已有实体文件。

## 各工具注意事项

### ZCode（推荐，作者自用）
- skill 按关键词自动触发，例如说"开始新版本"会触发 `project-iteration`。
- 仅 `solution-designer` 通过 `~/.zcode/agents/` 加载；它是工具专属方案设计适配，不是跨端流程入口。`prd-writer` 已升级为 Skill，按关键词自动触发。

### WorkBuddy
- 使用同一份 `AGENTS.md` 和同一套 `.ai/skills/` 权威源；执行安装脚本后，工作区 Skill 链接到 `~/.workbuddy/skills/`。
- `~/.workbuddy/memory/`、工作区 `.workbuddy/` 是运行资产，不得保存唯一的工作区规则、关键决策或 Skill 副本。
- MCP 实际配置留在 WorkBuddy 受控目录；工作区只登记能力、权限和确认门。

### Claude Code
- Skill 同样自动触发；项目内 `.claude/` 目录会被读取，但本套体系已统一到 `.ai/`，不安装 `.claude/agents` 避免双份。

### Codex
- Codex 可按任务匹配 Skill，也可显式调用 Skill；完整流程不需要复制到 `AGENTS.md`。
- Codex 客户端使用 `~/.codex/skills/` 安装路径；不得再在其他目录维护同名工作区 Skill 副本。
- `.ai/agents/` 内的工具专属 Agent 不应作为 Codex 的唯一流程依赖；跨工具任务由当前主 Agent 按 AGENTS.md 调用 Skill 执行。

## 变更与排障

1. 某工具的同名核心 Skill 与 `.ai/skills/` 不一致时，以 `.ai/skills/` 为准，先修复软链再运行任务；可选测试和 VitePress 能力以 `.ai/optional-skills/` 为准。
2. MCP 调用失败时，先检查接入工具、授权目标和 MCP 清单中的降级方式；不得将地址、令牌或完整日志复制进工单、记忆或 Git。
3. 新增或修改共享能力时，先改权威源，再运行安装脚本，并验证四端的 Skill 发现或触发状态；ZCode 另核对 `solution-designer` 的软链健康。
4. 从项目实践回收可复用资产时，先查 `.ai/SKILL-ASSETS.md`；登记表未允许的内容不得写入 Skill 资产目录。
