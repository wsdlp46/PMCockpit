#!/usr/bin/env bash
# ============================================================
# AI 资产安装脚本
# 作用：把 .ai/skills 和 .ai/agents 软链到各 AI 工具的全局目录
#       （skill 全部内置于本仓库 .ai/skills/，无需联网克隆）
# 兼容：ZCode、Claude Code、WorkBuddy、Codex (OpenAI CLI)
# 用法：
#   bash .ai/install.sh                 # 自动检测 AI 工具
#   bash .ai/install.sh /path/to/skills # 手动指定 skills 目录
# ============================================================
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$ROOT/.ai/skills"
AGENTS_SRC="$ROOT/.ai/agents"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "✗ 找不到 $SKILLS_SRC，请在仓库根目录执行本脚本"
  exit 1
fi

LINKED=0

link_skills_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  for s in "$SKILLS_SRC"/*/; do
    [ -d "$s" ] || continue
    local name; name="$(basename "$s")"
    # 软链，仓库更新（git pull）后全局自动同步；去掉源尾斜杠避免 ln 把链接建进目录内部
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

echo "== 第一步：安装 skills（内置 $(ls -d "$SKILLS_SRC"/*/ 2>/dev/null | wc -l | tr -d ' ') 个） =="

# --- ZCode：读 ~/.zcode/skills、~/.zcode/agents ---
if [ -d "$HOME/.zcode" ] || command -v zcode >/dev/null 2>&1; then
  link_skills_to "$HOME/.zcode/skills"
  link_agents_to "$HOME/.zcode/agents"
  echo "✓ ZCode        → ~/.zcode/skills, ~/.zcode/agents"
fi

# --- Claude Code：读 ~/.claude/skills、~/.claude/agents ---
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  link_skills_to "$HOME/.claude/skills"
  link_agents_to "$HOME/.claude/agents"
  echo "✓ Claude Code  → ~/.claude/skills, ~/.claude/agents"
fi

# --- WorkBuddy（CodeBuddy 分身）：skill 机制与 ZCode 兼容 ---
# agent 不要手动放文件：WorkBuddy 是 Electron GUI 应用，Win/Mac 路径不同，
# agent 注册可能涉及内部数据库，交给 WorkBuddy 自己创建。
if [ -d "$HOME/.workbuddy" ] || [ -d "/Applications/WorkBuddy.app" ]; then
  link_skills_to "$HOME/.workbuddy/skills"
  echo "✓ WorkBuddy    → ~/.workbuddy/skills"
  echo "⚠ WorkBuddy    → agent 需在 WorkBuddy 内创建：打开 WorkBuddy 指到本仓库根，"
  echo "                  对它说：读 .ai/agents/solution-designer.md，按这份文件创建 agent"
fi

# --- Codex (OpenAI CLI)：无 skill 自动加载机制，软链后仅供 @ 显式引用 ---
if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  link_skills_to "$HOME/.codex/skills"
  echo "⚠ Codex        → ~/.codex/skills（Codex 不自动触发 skill，需手动 @.ai/skills/xxx/SKILL.md 引用，详见 TOOL-MAPPING.md）"
fi

# --- 以上都没检测到：支持手动指定 skills 目录 ---
if [ "$LINKED" -eq 0 ]; then
  if [ -n "$1" ]; then
    link_skills_to "$1"
    echo "✓ 已链接到用户指定目录：$1"
  else
    echo "⚠ 未检测到已安装的 AI 工具（ZCode / Claude Code / WorkBuddy / Codex）。"
    echo "  先安装其中一个再重跑；或手动指定 skills 目录："
    echo "    bash .ai/install.sh /path/to/your/skills-dir"
    exit 0
  fi
fi

echo ""
echo "== 完成：共链接 $LINKED 个 skill 到各工具目录 =="
echo "软链特性：仓库 git pull 更新后，各工具内的 skill 自动同步最新版。"
echo "下一步：重启 AI 工具使链接生效。首次使用建议读 AGENTS.md 和 .ai/TOOL-MAPPING.md。"
