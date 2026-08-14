# PMCockpit

> 产品经理的 AI 协作驾驶舱 — One cockpit for the entire PM workflow, powered by AI.

把产品经理的完整工作流（需求 → 规格 → 原型 → 评审 → 复盘 → 总结 → 经验输出）封装成 AI 能自动执行的 skills。你不用背规范、不用手动贴提示词，跟 AI 说一句"开始新版本"，它就按你的标准建目录、写文档、画原型。

## 解决什么问题

产品经理用 AI 写 PRD、画原型，痛点是 **AI 不懂你的规范，产出不可控**：
- 同一个功能，今天让 AI 写和明天写，格式、字段、详略全不一样
- AI 凭"感觉"加按钮、加字段，跟你团队的标准对不上
- 写完要花大量时间手工校对、改格式、补漏项

PMCockpit 的解法是 **把规范变成 AI 能读的 skills**：不写零散提示词，而是把"PRD 怎么写、原型怎么画、评审查什么"固化成 10 个可按关键词自动触发的 skill + 1 份统一的工作区规则（AGENTS.md）。AI 执行时强制遵守，产出稳定可控。

## 核心特色

- **10 个 skill 全部内置，按关键词自动触发**：说"开始新版本"触发建目录骨架；说"画这个页面"触发原型生成；说"上传 TAPD"触发需求拆分；说"写 PRD"触发需求文档撰写。不用手动 @ 任何文件，不用联网克隆任何仓库。
- **AGENTS.md 统一写作纪律**：12 条文档生成纪律（完整性校验、编号一致性、角色带边界、页面编号前缀统一等）全局生效，AI 产出的文档天然规范。
- **多工具适配**：ZCode、Claude Code、WorkBuddy、Codex 都能用，一条 `install.sh` 自动检测并软链到对应工具目录。
- **结构化规则而非提示词**：设计规范、检查清单、模板都是独立文件，AI 执行 skill 时编程式引用，不是塞进一段超长 prompt。
- **经验闭环**：复盘 → 项目总结 → 对外输出三级递进（`05经验总结/`），做完一个项目留下可复用的资产，而不只是一堆交付物。

## Quick Start（3 步）

```bash
# 1. 克隆框架
git clone https://github.com/wsdlp46/PMCockpit.git 我的工作区
cd 我的工作区

# 2. 安装（把内置的 10 个 skill 和 agent 软链到你所用 AI 工具的目录）
bash .ai/install.sh

# 3. 打开 AI 工具，把工作目录指到这里，说一句
#    "新建项目"（首次）或 "开始新版本"（已有项目）
```

`install.sh` 会自动检测 ZCode / Claude Code / WorkBuddy / Codex，把 `.ai/skills/` 下的全部 skill 软链到对应目录；仓库以后 `git pull` 更新，skill 自动跟着更新，无需重装。

> 前置条件：已安装 ZCode、Claude Code、WorkBuddy 其中之一（skill 自动触发需要这三者之一）。Codex CLI 也可用，但 skill 不会自动触发，需手动 @ 引用。

### 给 AI 工具（harness）的说明

如果你是读到本 README 的 AI 助手：本仓库的全部 skill 内置于 `.ai/skills/`（10 个），agent 在 `.ai/agents/`。安装方式是在仓库根执行 `bash .ai/install.sh`；若无法执行脚本，直接读取 `.ai/skills/<skill名>/SKILL.md` 按其指引执行同样有效。工作区规则见根目录 `AGENTS.md`，跨工具加载差异见 `.ai/TOOL-MAPPING.md`。

## 适合谁

- **B 端 / 政务产品经理**：内置 B 端原型 6 条准则、招投标驱动方法论、政务 APP 设计规范
- **带 AI 协作的 PM 团队**：框架统一，团队成员产出质量一致
- **独立 PM / 顾问**：一个人当一个团队用，AI 替你执行标准化流程

## 目录结构

clone 后你得到一个完整的工作区骨架，直接在里面建项目：

```
我的工作区/                      ← clone PMCockpit 得到
├── AGENTS.md                   ← 工作区级 AI 指令（写作纪律、硬约束）
├── .ai/
│   ├── install.sh              ← 一键安装：软链 skills + agents 到各 AI 工具
│   ├── TOOL-MAPPING.md         ← 各工具加载差异说明
│   ├── skills/                 ← 10 个 skill 全部内置在这里
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
├── 探索项目/                   ← 未立项的早期探索 / POC
└── _附件/                      ← 二进制文件归档（图片、PDF、Excel）
```

**建第一个项目**：对 AI 说"新建项目"，`project-iteration` skill 会从 `01通用规则/模板/项目模板/` 复制出完整骨架（00-项目总览、01-项目基线、02-迭代、03-对外材料）到 `02当前项目/`；然后说"开始新版本"启动第一个迭代。

> 建项目目录结构的详细规则见 `01通用规则/项目工作流规范.md` 的四层结构定义。

## 工作流程

```
新建项目 → 开始新版本 → 写 PRD（skill）→ 写规格（skill）→ 画原型（skill）
    → 评审落地 → 上传 TAPD（skill）→ 部署文档站（skill）
    → 版本收尾 → 复盘（skill）→ 项目总结 → 经验输出
```

每个环节都有对应 skill 自动执行，AGENTS.md 保证全流程的写作纪律一致。

## 技能清单（全部内置于 .ai/skills/）

| Skill | 触发词 | 职责 |
|-------|--------|------|
| `project-iteration` | "新建项目""开始新版本""版本收尾" | 项目初始化（从项目模板建基线）、版本生命周期：初始化目录骨架、复制上版资产、收尾校正索引 |
| `prd-writer` | "写 PRD""写需求文档""出需求" | PRD 撰写：判断改造类/新建类场景，驱动交互式需求收集，套模板输出 |
| `proto-spec-generator` | "页面规格""功能规格""原型设计规格" | 页面级功能规格文档生成，按端到模块到页面四级结构输出 |
| `prototype-html-pin` | "原型""prototype""画这个页面" | 交互式 HTML 原型生成（scaffold + build 工作流，Pin 标注） |
| `competitor-analysis-pm` | "调研竞品""市场分析""选型对比" | 竞品调研全流程，内置六个质量闸门（假设确认、竞品分层、数据校验等） |
| `tapd-requirement-upload` | "上传 TAPD""规划 TAPD" | 从 MVP 需求 + 规格文档生成 TAPD 规划，用户确认后逐条上传 |
| `vitepress-deploy` | "部署文档站""同步到服务器" | VitePress 文档站部署、构建错误修复、内容同步 |
| `project-intake-pm` | "入库""归档""整理这份会议记录" | 项目材料入库：二进制转 MD、会议时间线更新、关键决策提炼 |
| `project-retrospective-pm` | "复盘""回顾项目""改进工作流" | 项目复盘：归因、五级联动修复、技能候选评估 |
| `ppt-master` | "生成PPT""做PPT""制作演示文稿" | 通用演示文稿生成流水线（源文档到 SVG 到 PPTX），不属于 PM 主链路，按需使用 |

另有 1 个 agent 随仓库分发：`solution-designer`（`.ai/agents/solution-designer.md`，触发词"写方案""方案设计"），调用 `03知识库/工作案例库/` 的历史方案案例做技术/业务方案设计。

> **WorkBuddy 用户**：skill 由 install.sh 软链后自动触发；agent 创建交给 WorkBuddy 自己做——打开 WorkBuddy，把工作目录指到本仓库根，对它说："读 `.ai/agents/solution-designer.md`，按这份文件创建对应的 agent"。WorkBuddy 会自己处理 agent 的落点、格式和注册（Win/Mac 路径不同，手动放很可能不生效）。

> **迁移说明**：V2.2 之前 8 个 skill 曾拆分为独立 GitHub 仓库（wsdlp46/&lt;skill-name&gt;），V2.3（2026-08）起全部并回本仓库 `.ai/skills/` 统一维护，旧独立仓库停止维护。若你曾克隆过旧仓库，删除后改用本仓库即可。

## License

Apache License 2.0。本项目基于 [vagerent/prototype-html](https://github.com/vagerent/prototype-html)（Apache 2.0）深度改造原型生成方案，在此致谢。

## 致谢与作者

作者：青燃AI说（[GitHub @wsdlp46](https://github.com/wsdlp46)）

欢迎提 issue 反馈使用问题，或贡献新的 skill。
