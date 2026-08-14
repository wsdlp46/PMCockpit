# TOOL-MAPPING.md — 各工具适配说明

> _版本：V2.3 ｜ 更新：2026-08-14_

本文件说明本套 PM 工作流资产在 ZCode、Claude Code、WorkBuddy、Codex 等多种 AI 工具下的加载差异，帮你选择工具或排查问题。

## 资产清单

| 类型 | 位置 | 内容 |
|------|------|------|
| 入口规则 | 项目根 `AGENTS.md` | 工作流触发、文件结构、写作风格、文档生成纪律、上下文加载顺序 |
| skills | `.ai/skills/`（**全部内置，随本仓库分发**） | 10 个 skill，见下表 |
| agents | `.ai/agents/`（随本仓库分发） | solution-designer（方案设计专用） |

### 内置技能清单（.ai/skills/）

| Skill | 触发词 | 职责 |
|-------|--------|------|
| project-iteration | "新建项目""开始新版本""版本收尾" | 项目初始化（从项目模板建基线）、版本生命周期、收尾校正索引 |
| prd-writer | "写 PRD""写需求文档""出需求" | PRD 撰写（候选方案驱动，含 PRD 模板） |
| solution-designer（agent） | "写方案""方案设计" | 技术方案 / 业务方案设计，调用案例库历史方案 |
| proto-spec-generator | "页面规格""功能规格""原型设计规格" | 页面级功能规格文档生成 |
| prototype-html-pin | "原型""prototype""画这个页面" | 交互式 HTML 原型（scaffold + build 工作流，Pin 标注） |
| competitor-analysis-pm | "调研竞品""市场分析""选型对比" | 竞品调研全流程（六节点质量闸门） |
| tapd-requirement-upload | "上传 TAPD""规划 TAPD" | 生成 TAPD 规划（用户确认后上传） |
| vitepress-deploy | "部署文档站""同步到服务器" | VitePress 文档站部署与维护 |
| project-intake-pm | "入库""归档""整理这份会议记录" | 项目材料入库五步法 |
| project-retrospective-pm | "复盘""回顾项目""改进工作流" | 项目复盘（归因 + 五级联动修复） |
| ppt-master | "生成PPT""做PPT""制作演示文稿" | PPTX 生成流水线（多格式源文档到 SVG 到 PPTX，含模板库） |

> 注：ppt-master 是通用演示文稿生成技能，不属于 PM 工作流主链路，按需使用。

## 各工具加载机制对比

| 工具 | 读 AGENTS.md | 自动加载 skills | skills 加载位置 | agent 处理 | 本套体系可用度 |
|------|:---:|:---:|------|------|------|
| **ZCode** | 是 | 是 | `~/.zcode/skills` | 软链 `.ai/agents/` 到 `~/.zcode/agents/` | 完整可用，skill 按关键词自动触发 |
| **Claude Code** | 是（也读 CLAUDE.md） | 是 | `~/.claude/skills` | 软链 `.ai/agents/` 到 `~/.claude/agents/` | 完整可用，体验与 ZCode 等价 |
| **WorkBuddy** | 是 | 是 | `~/.workbuddy/skills` | **交给 WorkBuddy 自己创建**（Win/Mac 路径不同，手动放文件可能不生效） | 完整可用，skill 机制与 ZCode 兼容 |
| **Codex (OpenAI CLI)** | 是 | 否 | 仅 `~/.codex/`、`AGENTS.md` | 无 agent 机制 | 只有 AGENTS.md 规则生效，skill 不自动触发 |

## 安装方式

```bash
git clone https://github.com/wsdlp46/PMCockpit.git <工作区目录>
cd <工作区目录>
bash .ai/install.sh
```

脚本会自动检测已安装的工具，把 `.ai/skills/`（软链每个 skill 目录）和 `.ai/agents/` 安装到对应全局目录。软链方式意味着：本仓库 `git pull` 更新后，各工具内的 skill 自动同步最新版，无需重跑安装。

> 历史说明：V2.2 之前 8 个 skill 曾拆分为独立 GitHub 仓库（wsdlp46/&lt;skill-name&gt;），V2.3 起已全部并回本仓库 `.ai/skills/`，旧独立仓库停止维护。

## 各工具注意事项

### ZCode（推荐，作者自用）

- skill 按关键词自动触发，例如说"开始新版本"会触发 `project-iteration`。
- agents 通过 `~/.zcode/agents/` 加载，安装后即可调用 `solution-designer`。
- skills 目录是 `~/.zcode/skills/`，install.sh 软链后即生效。

### Claude Code

- 与 ZCode 体验等价，skill 同样自动触发。
- skills 目录是 `~/.claude/skills/`，agents 目录是 `~/.claude/agents/`。

### WorkBuddy（CodeBuddy 分身）

- skill 机制与 ZCode 兼容，skills 目录是 `~/.workbuddy/skills/`，install.sh 软链后即自动触发。
- **agent 不要手动放文件**：WorkBuddy 是 Electron GUI 应用，Win/Mac 路径不同，且 agent 注册可能涉及内部数据库。正确做法是打开 WorkBuddy，把工作目录指到本仓库根，对它说："读 `.ai/agents/solution-designer.md`，按这份文件创建对应的 agent"。WorkBuddy 会自己处理落点和注册。
- agents 软链步骤 install.sh 会跳过 WorkBuddy 并打印上述提示。

### Codex（OpenAI CLI）

- **重要限制**：Codex CLI 没有 skill 自动发现机制，只读 `AGENTS.md` 和 `~/.codex/`。
- 即使把 skill 软链到 `~/.codex/skills/`，Codex 也不会按关键词自动跑。
- 使用方式：手动引用对应 skill 的 SKILL.md 路径（`@.ai/skills/xxx/SKILL.md`），Codex 才会读取执行。
- **建议**：若条件允许，优先用 ZCode 或 Claude Code 体验完整流程。
