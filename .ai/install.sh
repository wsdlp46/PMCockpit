#!/usr/bin/env bash
# ============================================================
# AI 资产安装脚本
# 作用：
#   1. 把 .ai/agents 链接到各 AI 工具的全局目录
#   2. 引导用户克隆 7 个独立技能仓库到对应工具的 skills 目录
# 兼容：ZCode、Claude Code、Codex (OpenAI CLI)
# 用法：在项目根执行  bash .ai/install.sh
# ============================================================
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_SRC="$ROOT/.ai/agents"

# 7 个独立维护的技能仓库（按需克隆，互不影响）
SKILL_REPOS=(
  project-iteration
  project-intake-pm
  proto-spec-generator
  prototype-html-pin
  tapd-requirement-upload
  vitepress-deploy
  project-retrospective-pm
  prd-writer
)
SKILL_GITHUB_USER="wsdlp46"

# ------------------------------------------------------------
# 检测用户安装了哪些 AI 工具，返回 skills 目录列表
# ------------------------------------------------------------
detect_skill_dirs() {
  local dirs=()
  # ZCode
  if [ -d "$HOME/.zcode" ] || command -v zcode >/dev/null 2>&1; then
    dirs+=("$HOME/.zcode/skills")
  fi
  # Claude Code
  if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
    dirs+=("$HOME/.claude/skills")
  fi
  # WorkBuddy（CodeBuddy 分身，skill 机制与 ZCode 兼容）
  if [ -d "$HOME/.workbuddy" ] || [ -d "/Applications/WorkBuddy.app" ]; then
    dirs+=("$HOME/.workbuddy/skills")
  fi
  # Codex（无 skill 自动加载，仅供 @ 显式引用）
  if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
    dirs+=("$HOME/.codex/skills")
  fi
  printf '%s\n' "${dirs[@]}"
}

# ------------------------------------------------------------
# 把 .ai/agents 软链到目标目录
# ------------------------------------------------------------
link_agents_to() {
  local target_dir="$1"
  [ -d "$AGENTS_SRC" ] || return 0
  mkdir -p "$target_dir"
  for a in "$AGENTS_SRC"/*.md; do
    [ -f "$a" ] || continue
    ln -sfn "$a" "$target_dir/$(basename "$a")"
  done
}

# ------------------------------------------------------------
# 克隆/更新技能仓库到目标 skills 目录
# ------------------------------------------------------------
clone_skills_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  for repo in "${SKILL_REPOS[@]}"; do
    local dest="$target_dir/$repo"
    if [ -d "$dest/.git" ]; then
      echo "  ↻ $repo 已存在，git pull 更新"
      git -C "$dest" pull --ff-only --quiet 2>/dev/null || echo "    ⚠ 更新失败，跳过（可能网络问题）"
    elif [ -e "$dest" ]; then
      echo "  ⚠ $repo 目标位置已存在但不是 git 仓库，跳过：$dest"
    else
      echo "  ↓ 克隆 $repo"
      git clone --quiet "https://github.com/$SKILL_GITHUB_USER/$repo.git" "$dest" \
        || echo "    ⚠ 克隆失败（仓库可能未公开或不存在），跳过"
    fi
  done
}

# ============================================================
# 主流程
# ============================================================
echo "== 第一步：安装 agents（随本仓库分发） =="
AGENTS_LINKED=0

if [ -d "$HOME/.zcode" ] || command -v zcode >/dev/null 2>&1; then
  link_agents_to "$HOME/.zcode/agents"
  echo "✓ ZCode        → ~/.zcode/agents"
fi
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  # Claude Code 的 agents 一般放项目内 .claude/，这里软链到全局便于跨项目复用
  link_agents_to "$HOME/.claude/agents" 2>/dev/null || true
  echo "✓ Claude Code  → ~/.claude/agents"
fi
if [ -d "$HOME/.workbuddy" ] || [ -d "/Applications/WorkBuddy.app" ]; then
  # WorkBuddy 的 agent 创建由它自己处理（Win/Mac 路径不同，手动放文件可能不生效）
  echo "⚠ WorkBuddy    → agent 需在 WorkBuddy 内创建：打开 WorkBuddy 指到本仓库根，"
  echo '                  对它说：读 .ai/agents/prd-writer.md 和 solution-designer.md，按这两份文件创建 agent'
fi
echo ""

echo "== 第二步：技能仓库安装 =="
echo "7 个核心 skill 是独立维护的 GitHub 仓库（github.com/$SKILL_GITHUB_USER/<skill-name>），"
echo "需要克隆到 AI 工具的 skills 目录才会自动触发。"
echo ""

# 检测 AI 工具
SKILL_DIRS=($(detect_skill_dirs))
if [ ${#SKILL_DIRS[@]} -eq 0 ]; then
  echo "⚠ 未检测到已安装的 AI 工具（ZCode / Claude Code / Codex）。"
  echo "  请先安装其一，再重新运行本脚本；或手动克隆技能仓库到对应目录。"
  echo "  技能清单见 README.md 的「技能生态」章节。"
  exit 0
fi

echo "检测到以下 AI 工具的 skills 目录："
for d in "${SKILL_DIRS[@]}"; do
  echo "  - $d"
done
echo ""

read -r -p "是否克隆全部技能到以上目录？[Y/n] " ans
ans="${ans:-Y}"
if [[ "$ans" =~ ^[Yy]$ ]]; then
  for d in "${SKILL_DIRS[@]}"; do
    echo "→ 安装到 $d"
    clone_skills_to "$d"
  done
  echo ""
  echo "✓ 技能安装完成。"
else
  echo "跳过克隆。如需按需安装单个技能，手动执行："
  echo "  git clone https://github.com/$SKILL_GITHUB_USER/<skill-name>.git <skills 目录>/<skill-name>"
  echo "  技能清单见 README.md 的「技能生态」章节。"
fi

echo ""
echo "== 完成 =="
echo "下一步：重启 AI 工具使 agents 和 skills 生效。"
echo "首次使用建议读 AGENTS.md 和 .ai/TOOL-MAPPING.md。"
