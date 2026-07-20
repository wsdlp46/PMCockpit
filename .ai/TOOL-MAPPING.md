# TOOL-MAPPING.md — 三工具适配说明

本文件说明本套 PM 工作流资产在 ZCode、Claude Code、Codex 三种 AI 工具下的加载差异，帮你选择工具或排查问题。

## 资产清单

| 类型 | 位置 | 内容 |
|------|------|------|
| 入口规则 | 项目根 `AGENTS.md` | 工作流触发、文件结构、写作风格、文档生成纪律、上下文加载顺序 |
| agents | `.ai/agents/`（随本仓库分发） | prd-writer、solution-designer（文档撰写专用，软链到全局目录） |
| skills | **独立 GitHub 仓库**，不在本仓库内 | 7 个核心 skill + prd-writer skill，由 install.sh 引导克隆 |

### 技能仓库清单（独立维护）

| Skill | 仓库 |
|-------|------|
| project-iteration | github.com/wsdlp46/project-iteration |
| project-intake-pm | github.com/wsdlp46/project-intake-pm |
| proto-spec-generator | github.com/wsdlp46/proto-spec-generator |
| prototype-html-pin | github.com/wsdlp46/prototype-html-pin |
| tapd-requirement-upload | github.com/wsdlp46/tapd-requirement-upload |
| vitepress-deploy | github.com/wsdlp46/vitepress-deploy |
| project-retrospective-pm | github.com/wsdlp46/project-retrospective-pm |
| prd-writer | github.com/wsdlp46/prd-writer |

> 每个 skill 独立升级、互不影响。技能详细介绍见根目录 README.md 的「技能生态」章节。

## 三工具加载机制对比

| 工具 | 读 AGENTS.md | 自动加载 skills | skills 加载位置 | 本套体系可用度 |
|------|:---:|:---:|------|------|
| **ZCode** | 是 | 是 | `~/.zcode/skills` | 完整可用，skill 按关键词自动触发 |
| **Claude Code** | 是（也读 CLAUDE.md） | 是 | `~/.claude/skills` | 完整可用，体验与 ZCode 等价 |
| **Codex (OpenAI CLI)** | 是 | 否 | 仅 `~/.codex/`、`AGENTS.md` | 只有 AGENTS.md 规则生效，skill 不自动触发 |

## 安装方式

```bash
git clone https://github.com/wsdlp46/PMCockpit.git <项目目录>
cd <项目目录>
bash .ai/install.sh
```

脚本会：
1. 软链 `.ai/agents/` 到各 AI 工具的全局 agents 目录
2. 检测已安装的 AI 工具，引导你克隆 7 个技能仓库到对应 skills 目录（支持一键全装或按需选装）

## 各工具注意事项

### ZCode（推荐，作者自用）
- skill 按关键词自动触发，例如说"开始新版本"会触发 `project-iteration`。
- agents 通过 `~/.zcode/agents/` 加载，安装后即可调用 `prd-writer` 等。
- skills 目录是 `~/.zcode/skills/`，技能仓库 clone 到这里即生效。

### Claude Code
- 与 ZCode 体验等价，skill 同样自动触发。
- skills 目录是 `~/.claude/skills/`，agents 目录是 `~/.claude/agents/`。

### Codex（OpenAI CLI）
- **重要限制**：Codex CLI 没有 skill 自动发现机制，只读 `AGENTS.md` 和 `~/.codex/`。
- 即使把 skill 仓库 clone 到 `~/.codex/skills/`，Codex 也不会按关键词自动跑。
- 使用方式：手动引用对应 skill 的 SKILL.md 路径，Codex 才会读取执行。
- **建议**：若条件允许，优先用 ZCode 或 Claude Code 体验完整流程。
