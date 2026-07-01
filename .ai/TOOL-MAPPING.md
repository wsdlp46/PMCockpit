# TOOL-MAPPING.md — 三工具适配说明

本文件说明本套 PM 工作流资产在 ZCode、Claude Code、Codex 三种 AI 工具下的加载差异，帮你选择工具或排查问题。

## 资产清单

| 类型 | 位置 | 内容 |
|------|------|------|
| 入口规则 | 项目根 `AGENTS.md` | 工作流触发、文件结构、写作风格、文档生成纪律、上下文加载顺序 |
| skills | `.ai/skills/` | project-intake-pm、project-iteration、project-retrospective-pm、prototype-html-pin、vitepress-deploy、proto-spec-generator、tapd-requirement-upload |
| agents | `.ai/agents/` | prd-writer、solution-designer（文档撰写专用，可选） |

## 三工具加载机制对比

| 工具 | 读 AGENTS.md | 自动加载 skills | 加载位置 | 本套体系可用度 |
|------|:---:|:---:|------|------|
| **ZCode** | 是 | 是 | `~/.zcode/skills`、`~/.zcode/agents`、项目内 `.claude/` | 完整可用，skill 按关键词自动触发 |
| **Claude Code** | 是（也读 CLAUDE.md） | 是 | `~/.claude/skills`、项目内 `.claude/` | 完整可用，体验与 ZCode 等价 |
| **Codex (OpenAI CLI)** | 是 | 否 | 仅 `~/.codex/`、`AGENTS.md` | 只有 AGENTS.md 规则生效，skill 不自动触发 |

## 安装方式

```bash
git clone <仓库地址> <项目目录>
cd <项目目录>
bash .ai/install.sh
```

脚本会自动检测已安装的工具，把 `.ai/skills` 软链到对应全局目录。

## 各工具注意事项

### ZCode（推荐，作者自用）
- skill 按关键词自动触发，例如说"开始新版本"会触发 `project-iteration`。
- agents 通过 `~/.zcode/agents/` 加载，安装后即可调用 `prd-writer` 等。

### Claude Code
- 与 ZCode 体验等价，skill 同样自动触发。
- 项目内 `.claude/` 目录会被读取，但本套体系已统一到 `.ai/`，`.claude/agents` 留空避免双份。

### Codex（OpenAI CLI）
- **重要限制**：Codex CLI 没有 skill 自动发现机制，只读 `AGENTS.md` 和 `~/.codex/`。
- 安装脚本仍会把 skill 链接到 `~/.codex/skills`，但 Codex 不会按关键词自动跑。
- 使用方式：手动 `@.ai/skills/xxx/SKILL.md` 显式引用对应 skill，Codex 才会读取执行。
- 若希望接近自动体验，可把常用 skill 的核心规则复制进 `AGENTS.md`（代价是文件变长）。
- **建议**：若条件允许，优先用 ZCode 或 Claude Code 体验完整流程。
