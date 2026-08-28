# PMCockpit

> 产品经理的 AI 协作驾驶舱 — One cockpit for the entire PM workflow, powered by AI.

把产品经理的完整工作流（需求 → 规格 → 原型 → 评审 → 复盘 → 总结 → 经验输出）封装成 AI 能自动执行的 skills。你不用背规范、不用手动贴提示词：新建项目时，主 Agent 按项目模板建立骨架；已有项目启动版本时，再由 Skill 按标准创建版本目录、写文档、画原型。

## 解决什么问题

产品经理用 AI 写 PRD、画原型，痛点是 **AI 不懂你的规范，产出不可控**：
- 同一个功能，今天让 AI 写和明天写，格式、字段、详略全不一样
- AI 凭"感觉"加按钮、加字段，跟你团队的标准对不上
- 写完要花大量时间手工校对、改格式、补漏项

PMCockpit 的解法是 **把规范变成 AI 能读的 skills**：不写零散提示词，而是把“PRD 怎么写、原型怎么画、评审查什么”固化成 8 个核心 Skill、测试与文档站两项可选能力，以及 1 份统一工作区规则（AGENTS.md）。

## 核心特色

- **8 个核心 Skill 默认内置**：覆盖版本、需求、规格、原型、调研、TAPD、入库和复盘；按任务目标路由，不靠关键词抢占。
- **可选测试与文档站能力**：测试按需启用；VitePress 仅在已有独立站点时启用，不携带 docs-site、服务器、密码或密钥。
- **AGENTS.md 统一约束**：最小上下文、确认门、三方联动和对外边界全局生效；详细规则按任务加载，避免上下文膨胀。
- **多工具适配**：ZCode、Claude Code、WorkBuddy、Codex 都能用，一条 `install.sh` 自动检测并软链到对应工具目录。
- **结构化规则而非提示词**：设计规范、检查清单、模板都是独立文件，AI 执行 skill 时编程式引用，不是塞进一段超长 prompt。
- **经验闭环**：复盘 → 项目总结 → 对外输出三级递进（`05经验总结/`），做完一个项目留下可复用的资产，而不只是一堆交付物。

## Quick Start（复制到独立工作区后 3 步）

```bash
# 1. 获取公开仓库
git clone https://github.com/wsdlp46/PMCockpit.git

# 2. 把仓库内容复制到独立工作区；不要直接在 PMCockpit 克隆目录中积累项目
mkdir -p ../我的工作区
rsync -a --exclude='.git' --exclude='.DS_Store' PMCockpit/ ../我的工作区/
cd ../我的工作区

# 3. 安装 8 个核心 Skill；仅 ZCode 额外链接方案设计 Agent
bash .ai/install.sh

# 需要测试规划、执行、报告或回归时，才执行：
# bash .ai/install.sh --with-test
# 如你已有独立 VitePress 文档站，并需要维护它，才执行：
# bash .ai/install.sh --with-vitepress

# 3. 打开 AI 工具，把工作目录指到这里。
#    首次使用：先按下方“十分钟演练”跑通样例；
#    建真实项目：说“新建项目”；已有项目再说“开始新版本”。
```

`install.sh` 会自动检测 ZCode / Claude Code / WorkBuddy / Codex，把 8 个核心 Skill 软链到对应目录。测试与 VitePress 都必须显式启用。模板更新由维护者按发行规范同步；已有真实项目的工作区不建议直接覆盖更新。

复制后，`AGENTS.md`、`.ai/`、通用规则和项目目录都位于独立工作区根目录，AI 工具才能按完整工作区规则工作。

> 前置条件：已安装 ZCode、WorkBuddy、Claude Code 或 Codex 中的一种。各工具的 Skill 发现与显式调用方式不同，以 `.ai/TOOL-MAPPING.md` 为准；若未自动识别，直接告诉 AI 要使用的 Skill 名称即可。

### 给 AI 工具（harness）的说明

如果你是读到本 README 的 AI 助手：本仓库的 8 个核心 Skill 内置于 `.ai/skills/`，可选测试与 VitePress Skill 位于 `.ai/optional-skills/`；仅当使用者明确启用时使用测试，VitePress 还要求已有独立站点。工作区规则见根目录 `AGENTS.md`，跨工具差异见 `.ai/TOOL-MAPPING.md`。

## 适合谁

- **B 端 / 政务产品经理**：内置 B 端原型 6 条准则、招投标驱动方法论、政务 APP 设计规范
- **希望建立个人工作标准的 PM**：将常用工作流和产物结构固定下来
- **独立 PM / 顾问**：一个人当一个团队用，AI 替你执行标准化流程

## 目录结构

初始化后你得到一个完整的工作区骨架，直接在里面建项目：

```
我的工作区/                      ← 由 PMCockpit 初始化脚本创建
├── AGENTS.md                   ← 工作区级 AI 指令（写作纪律、硬约束）
├── .ai/
│   ├── install.sh              ← 默认安装核心 Skills；可显式启用测试或文档站能力
│   ├── TOOL-MAPPING.md         ← 各工具加载差异说明
│   ├── skills/                 ← 8 个核心 Skill
│   ├── optional-skills/        ← 可选能力（默认不安装）
│   └── agents/                 ← 方案设计专用 agent（solution-designer）
├── 00环境配置/                 ← 工具链配置与凭证存放（凭证不入库）
├── 01通用规则/                 ← 方法层（被 skills 自动引用）
│   ├── 方法论/、检查清单/、模板/（含项目模板）、设计库/、设计规范/
│   └── 项目工作流规范.md、助理上手指南.md 等
├── 02当前项目/                 ← 你的项目放这里（每个项目一个子目录）
├── 03知识库/                   ← 知识沉淀（案例库框架、行业研究、竞品、政策）
├── 04历史项目/                 ← 已结项归档
├── 05经验总结/                 ← 复盘 → 项目总结 → 经验输出 三级闭环
├── 06治理文档/                 ← 工作区自身的资产盘点与巡检报告
├── examples/                   ← 不含真实数据的十分钟演练项目
└── _附件/                      ← 二进制文件归档（图片、PDF、Excel）
```

**建第一个项目**：对 AI 说"新建项目"。主 Agent 会按 `01通用规则/模板/项目模板/` 在 `02当前项目/` 建立项目骨架（项目总览、项目基线、迭代容器和对外材料目录），只填写已确认事实。项目建立后，再说"开始新版本"，`project-iteration` 才会创建首个迭代版本。

> 建项目目录结构的详细规则见 `01通用规则/项目工作流规范.md` 的四层结构定义。

## 十分钟演练

仓库内置了一个不含真实业务数据的模拟项目：[examples/模拟项目-智慧园区巡检/](examples/模拟项目-智慧园区巡检/)。它已提供项目骨架、原始需求、简版 PRD、页面规格和可构建的原型。

首次使用时，让 AI 按样例目录中的 `README.md` 带你完成一次“查看需求 → 核对规格 → 修改原型 → 构建验证”。跑通后再创建真实项目；不要直接在样例目录中做正式业务产出。

## 工作流程

```
新建项目 → 开始新版本 → 写 PRD（skill）→ 写规格（skill）→ 画原型（skill）
    → 评审落地 → 上传 TAPD（skill）→ 可选测试 → 可选文档站同步
    → 版本收尾 → 复盘（skill）→ 项目总结 → 经验输出
```

每个环节都有对应 skill 自动执行，AGENTS.md 保证全流程的写作纪律一致。

## 技能清单（全部内置于 .ai/skills/）

| Skill | 触发词 | 职责 |
|-------|--------|------|
| `project-iteration` | "开始新版本""版本收尾""索引同步" | 既有项目的版本生命周期：初始化版本目录、复制上版资产、收尾与索引校正 |
| `prd-writer` | "写 PRD""写需求文档""出需求" | PRD 撰写：判断改造类/新建类场景，驱动交互式需求收集，套模板输出 |
| `proto-spec-generator` | "页面规格""功能规格""原型设计规格" | 页面级功能规格文档生成，按端到模块到页面四级结构输出 |
| `prototype-html-pin` | "原型""prototype""画这个页面" | 交互式 HTML 原型生成（scaffold + build 工作流，Pin 标注） |
| `research-pm` | "调研""市场分析""客户分析""竞品调研" | 调研统一入口，先确认边界，再采集证据并形成结论 |
| `tapd-requirement-upload` | "上传 TAPD""规划 TAPD" | 从 MVP 需求 + 规格文档生成 TAPD 规划，用户确认后逐条上传 |
| `project-intake-pm` | "入库""归档""整理这份会议记录" | 项目材料入库：二进制转 MD、会议时间线更新、关键决策提炼 |
| `project-retrospective-pm` | "复盘""回顾项目""改进工作流" | 项目复盘：归因、五级联动修复、技能候选评估 |

另有 1 个专用 Agent：`solution-designer`（仅 ZCode 链接）。它优先参考使用者自建案例；框架初始没有历史案例时，必须按用户输入和通用方法设计，不能虚构先例。

> **文档站用户**：PMCockpit 不提供 docs-site 或部署配置。只有已有独立站点、明确授权范围并执行 `bash .ai/install.sh --with-vitepress` 后，才可使用可选文档站维护能力。

> **测试用户**：只有版本已提测或明确需要测试规划、用例、执行、报告或回归时，执行 `bash .ai/install.sh --with-test` 启用测试闭环能力。

> **迁移说明**：V2.2 之前 8 个 skill 曾拆分为独立 GitHub 仓库（wsdlp46/&lt;skill-name&gt;），V2.3（2026-08）起全部并回本仓库 `.ai/skills/` 统一维护，旧独立仓库停止维护。若你曾克隆过旧仓库，删除后改用本仓库即可。

## License

Apache License 2.0。本项目基于 [vagerent/prototype-html](https://github.com/vagerent/prototype-html)（Apache 2.0）深度改造原型生成方案，在此致谢。

## 致谢与作者

作者：青燃AI说（[GitHub @wsdlp46](https://github.com/wsdlp46)）

欢迎反馈使用问题和改进建议。
