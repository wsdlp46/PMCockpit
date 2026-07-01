#!/usr/bin/env bash
# ============================================================
# AI 资产安装脚本
# 作用：把 .ai/skills 和 .ai/agents 链接到各 AI 工具的全局目录
# 兼容：ZCode、Claude Code、Codex (OpenAI CLI)
# 用法：在项目根执行  bash .ai/install.sh
# ============================================================
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$ROOT/.ai/skills"
AGENTS_SRC="$ROOT/.ai/agents"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "✗ 找不到 $SKILLS_SRC，请在项目根目录执行本脚本"
  exit 1
fi

LINKED=0

link_skills_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  for s in "$SKILLS_SRC"/*/; do
    [ -d "$s" ] || continue
    local name; name="$(basename "$s")"
    # 软链，源文件改了全局同步更新；去掉源尾斜杠避免 ln 把链接建进目录内部
    ln -sfn "${s%/}" "$target_dir/$name"
    LINKED=$((LINKED + 1))
  done
}

link_agents_to() {
  local target_dir="$1"
  [ -d "$AGENTS_SRC" ] || return 0
  mkdir -p "$target_dir"
  for a in "$AGENTS_SRC"/*.md; do
    [ -f "$a" ] || continue
    ln -sfn "$a" "$target_dir/$(basename "$a")"
  done
}

echo "== 安装 PM 工作流 skills =="

# --- ZCode：读 ~/.zcode/skills、~/.zcode/agents ---
if [ -d "$HOME/.zcode" ] || command -v zcode >/dev/null 2>&1; then
  link_skills_to "$HOME/.zcode/skills"
  link_agents_to "$HOME/.zcode/agents"
  echo "✓ ZCode    → ~/.zcode/skills, ~/.zcode/agents"
fi

# --- Claude Code：读 ~/.claude/skills、项目内 .claude/ ---
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  link_skills_to "$HOME/.claude/skills"
  echo "✓ Claude Code → ~/.claude/skills"
fi

# --- Codex (OpenAI CLI)：无 skill 自动加载机制，只链接到 ~/.codex 供 @ 显式引用 ---
if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  link_skills_to "$HOME/.codex/skills"
  echo "⚠ Codex    → ~/.codex/skills（Codex 不自动触发 skill，需手动 @.ai/skills/xxx/SKILL.md 引用，详见 TOOL-MAPPING.md）"
fi

echo ""
echo "== 完成：共链接 $LINKED 个 skill 到各工具目录 =="
echo "下一步：重启 AI 工具使链接生效。首次使用建议读 AGENTS.md 和 .ai/TOOL-MAPPING.md。"
