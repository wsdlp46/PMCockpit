# PMCockpit

> 产品经理的 AI 协作驾驶舱 — One cockpit for the entire PM workflow, powered by AI.

把产品经理的完整工作流（需求 → 规格 → 原型 → 评审 → 复盘）封装成 AI 能自动执行的 skills。你不用背规范、不用手动贴提示词，跟 AI 说一句"开始新版本"，它就按你的标准建目录、写文档、画原型。

## 解决什么问题

产品经理用 AI 写 PRD、画原型，痛点是 **AI 不懂你的规范，产出不可控**：
- 同一个功能，今天让 AI 写和明天写，格式、字段、详略全不一样
- AI 凭"感觉"加按钮、加字段，跟你团队的标准对不上
- 写完要花大量时间手工校对、改格式、补漏项

PMCockpit 的解法是 **把规范变成 AI 能读的 skills**：不写零散提示词，而是把"PRD 怎么写、原型怎么画、评审查什么"固化成 7 个独立维护、可按关键词自动触发的 skill + 1 份统一的工作区规则（AGENTS.md）。AI 执行时强制遵守，产出稳定可控。

## 核心特色

- **7 个独立 skill 按关键词自动触发**：说"开始新版本"触发建目录骨架；说"画这个页面"触发原型生成；说"上传 TAPD"触发需求拆分。不用手动 @ 任何文件。每个 skill 独立仓库，可单独升级、按需安装。
- **AGENTS.md 统一写作纪律**：12 条文档生成纪律（完整性校验、编号一致性、角色带边界、页面编号前缀统一等）全局生效，AI 产出的文档天然规范。
- **三工具适配**：ZCode、Claude Code、Codex 都能用，一条 `install.sh` 自动软链到对应工具目录。
- **结构化规则而非提示词**：设计规范、检查清单、模板都是独立文件，AI 执行 skill 时编程式引用，不是塞进一段超长 prompt。

## Quick Start（3 步）

```bash
# 1. 克隆框架
git clone https://github.com/wsdlp46/PMCockpit.git 我的项目
cd 我的项目

# 2. 安装（自动检测你装了哪个 AI 工具，软链 agents，并引导克隆技能仓库）
bash .ai/install.sh

# 3. 打开 AI 工具，把工作目录指到这里，说一句
#    "开始新版本"
```

`install.sh` 会列出 7 个技能仓库地址，你可以一键全部克隆，或按需选装（技能仓库清单见下方"技能生态"章节）。

AI 会引导你确认版本号、复制上版资产、剥离出干净的目录骨架。然后你就可以开始写需求、画原型了。

> 前置条件：已安装 [ZCode](https://zcode.com) 或 [Claude Code](https://claude.ai/code)（skill 自动触发需要其中之一）。Codex CLI 也可用，但 skill 不会自动触发，需手动 @ 引用。

## 适合谁

- **B 端 / 政务产品经理**：内置 B 端原型 6 条准则、招投标驱动方法论、政务 APP 设计规范
- **带 AI 协作的 PM 团队**：框架统一，团队成员产出质量一致
- **独立 PM / 顾问**：一个人当一个团队用，AI 替你执行标准化流程

## 目录结构

clone 后你得到一个完整的工作区骨架，直接在里面建项目：

```
我的工作区/                      ← clone PMCockpit 得到
├── 00主页.md                   ← 工作区仪表盘
├── AGENTS.md                   ← 工作区级 AI 指令（写作纪律、硬约束）
├── .ai/
│   ├── install.sh              ← 一键安装，软链 agents 并引导克隆技能仓库
│   ├── TOOL-MAPPING.md         ← 三工具加载差异说明
│   └── agents/                 ← 文档撰写专用 agent（prd-writer、solution-designer）
│                                  注：7 个核心 skill 是独立仓库，不在本仓库内，
│                                  清单见下方"技能生态"，由 install.sh 引导克隆
├── 01-通用规则/                ← 方法层（被 skills 自动引用）
│   ├── 方法论/、检查清单/、模板/、设计库/、设计规范/
│   └── 项目工作流规范.md、助理上手指南.md 等
├── 02当前项目/                ← 你的项目放这里（每个项目一个子目录）
├── 03知识库/                  ← 知识沉淀（案例库、行业研究、竞品、政策）
├── 04历史项目/                ← 已结项归档
├── 06-对外材料/               ← 方案书、投标文档
└── _附件/                     ← 二进制文件归档（图片、PDF、Excel）
```

**建第一个项目**：进入 `02当前项目/`，对 AI 说"开始新版本"，它会在你指定的项目目录下建出完整的迭代结构（00-项目总览、01-项目基线、02-迭代/版本号/）。

> 建项目目录结构的详细规则见 `01-通用规则/项目工作流规范.md` 的四层结构定义。

## 工作流程

```
新版本启动 → 写 PRD（agent）→ 写规格（skill）→ 画原型（skill）
    → 评审落地 → 上传 TAPD（skill）→ 部署文档站（skill）→ 复盘（skill）
```

每个环节都有对应 skill 自动执行，AGENTS.md 保证全流程的写作纪律一致。

## 技能生态

7 个核心 skill 各自独立仓库维护，按需克隆到 AI 工具的 skills 目录（ZCode 是 `~/.zcode/skills/`，Claude Code 是 `~/.claude/skills/`）。每个 skill 可独立升级，互不影响。

| Skill | 仓库 | 触发词 | 职责 |
|-------|------|--------|------|
| `project-iteration` | [wsdlp46/project-iteration](https://github.com/wsdlp46/project-iteration) | "开始新版本""版本收尾" | 版本生命周期：初始化目录骨架、复制上版资产、收尾校正索引 |
| `project-intake-pm` | [wsdlp46/project-intake-pm](https://github.com/wsdlp46/project-intake-pm) | "入库""归档""整理这份会议记录" | 项目材料入库：二进制转 MD、会议时间线更新、关键决策提炼 |
| `proto-spec-generator` | [wsdlp46/proto-spec-generator](https://github.com/wsdlp46/proto-spec-generator) | "页面规格""功能规格""原型设计规格" | 页面级功能规格文档生成，按端到模块到页面四级结构输出 |
| `prototype-html-pin` | [wsdlp46/prototype-html-pin](https://github.com/wsdlp46/prototype-html-pin) | "原型""prototype""画这个页面" | 交互式 HTML 原型生成（scaffold + build 工作流，Pin 标注） |
| `tapd-requirement-upload` | [wsdlp46/tapd-requirement-upload](https://github.com/wsdlp46/tapd-requirement-upload) | "上传 TAPD""规划 TAPD" | 从 MVP 需求 + 规格文档生成 TAPD 规划并逐条上传 |
| `vitepress-deploy` | [wsdlp46/vitepress-deploy](https://github.com/wsdlp46/vitepress-deploy) | "部署文档站""同步到服务器" | VitePress 文档站部署、构建错误修复、内容同步 |
| `project-retrospective-pm` | [wsdlp46/project-retrospective-pm](https://github.com/wsdlp46/project-retrospective-pm) | "复盘""回顾项目""改进工作流" | 项目复盘：归因、五级联动修复、技能候选评估 |

**文档撰写 agent**（在 `.ai/agents/`，随本仓库分发）：
- `prd-writer`：调用独立的 [wsdlp46/prd-writer](https://github.com/wsdlp46/prd-writer) skill 执行 PRD 撰写
- `solution-designer`：技术方案 / 业务方案设计

**一键克隆全部技能**：

```bash
# 在仓库根执行（install.sh 内部也是这套逻辑）
for s in project-iteration project-intake-pm proto-spec-generator \
         prototype-html-pin tapd-requirement-upload vitepress-deploy \
         project-retrospective-pm prd-writer; do
  git clone "https://github.com/wsdlp46/$s.git" "$HOME/.zcode/skills/$s"
done
```

> Claude Code 用户把 `~/.zcode/skills/` 换成 `~/.claude/skills/`；Codex 用户换成 `~/.codex/skills/`。

## License

Apache License 2.0。本项目基于 [vagerent/prototype-html](https://github.com/vagerent/prototype-html)（Apache 2.0）深度改造原型生成方案，在此致谢。

## 致谢与作者

作者：青燃AI说（[GitHub @wsdlp46](https://github.com/wsdlp46)）

欢迎提 issue 反馈使用问题，或贡献新的 skill。参见 [CONTRIBUTING.md](CONTRIBUTING.md)。
