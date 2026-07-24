#!/usr/bin/env bash
# ============================================================
# AI 资产安装脚本
# 作用：
#   1. 把 .ai/agents 链接到各 AI 工具的全局目录
#   2. 引导用户克隆 8 个独立技能仓库到对应工具的 skills 目录
# 兼容：ZCode、Claude Code、WorkBuddy、Codex (OpenAI CLI)
# 用法：
#   bash .ai/install.sh                 # 自动检测 AI 工具
#   bash .ai/install.sh /path/to/skills # 手动指定 skills 目录
# ============================================================

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_SRC="$ROOT/.ai/agents"

# ------------------------------------------------------------
# timeout 兼容层：macOS 默认无 timeout 命令，用 perl 或 gtimeout 兜底
# ------------------------------------------------------------
if ! command -v timeout >/dev/null 2>&1; then
  if command -v gtimeout >/dev/null 2>&1; then
    timeout() { gtimeout "$@"; }
  else
    # perl 兜底：timeout <secs> <cmd...>
    timeout() {
      local secs="$1"; shift
      perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
    }
  fi
fi

# 8 个独立维护的技能仓库（按需克隆，互不影响）
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
# 单仓库克隆/更新，带超时和重试
# 返回 0 成功，1 失败
sync_one_skill() {
  local repo="$1"
  local dest="$2"
  local max_retry=2
  local try=0

  if [ -d "$dest/.git" ]; then
    # 已存在，尝试 pull 更新
    for try in 1; do
      if timeout 60 git -C "$dest" pull --ff-only --quiet 2>/dev/null; then
        echo "  ↻ $repo 已更新"
        return 0
      fi
    done
    echo "  ⚠ $repo 更新失败（网络超时或无法连接），保留本地旧版"
    return 1
  elif [ -e "$dest" ]; then
    echo "  ⚠ $repo 目标位置已存在但不是 git 仓库，跳过：$dest"
    return 1
  fi

  # 新克隆，带重试
  while [ $try -lt $max_retry ]; do
    try=$((try + 1))
    echo "  ↓ 克隆 $repo（第 $try/$max_retry 次）"
    if timeout 90 git clone --quiet "https://github.com/$SKILL_GITHUB_USER/$repo.git" "$dest" 2>/dev/null; then
      return 0
    fi
    rm -rf "$dest" 2>/dev/null
  done
  echo "  ✗ $repo 克隆失败（连续 $max_retry 次超时或被拒）"
  echo "    可能原因：网络不畅（国内访问 GitHub 常见）/ 仓库未公开 / 仓库不存在"
  echo "    排查：浏览器打开 https://github.com/$SKILL_GITHUB_USER/$repo 确认仓库存在"
  echo "    重试：网络恢复后重跑 bash .ai/install.sh 即可续装"
  return 1
}

clone_skills_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  local failed=()
  local succeeded=0
  for repo in "${SKILL_REPOS[@]}"; do
    if sync_one_skill "$repo" "$target_dir/$repo"; then
      succeeded=$((succeeded + 1))
    else
      failed+=("$repo")
    fi
  done
  echo ""
  echo "  汇总：成功 $succeeded/${#SKILL_REPOS[@]}"
  if [ ${#failed[@]} -gt 0 ]; then
    echo "  ⚠ 失败的技能（对应功能不可用，需重跑或手动安装）："
    for f in "${failed[@]}"; do
      echo "     - $f"
    done
  fi
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
echo "8 个 skill 是独立维护的 GitHub 仓库（github.com/$SKILL_GITHUB_USER/<skill-name>），"
echo "需要克隆到 AI 工具的 skills 目录才会自动触发。"
echo ""

# 检测 AI 工具（支持命令行参数手动指定 skills 目录）
AUTO_CONFIRM="n"
if [ -n "$1" ]; then
  # 用户手动指定了 skills 目录（意图明确，直接克隆，不再询问）
  mkdir -p "$1" 2>/dev/null
  SKILL_DIRS=("$1")
  echo "将克隆到用户指定的目录：$1"
  echo ""
  AUTO_CONFIRM="y"
else
  SKILL_DIRS=($(detect_skill_dirs))
  if [ ${#SKILL_DIRS[@]} -eq 0 ]; then
    echo "⚠ 未检测到已安装的 AI 工具（ZCode / Claude Code / WorkBuddy / Codex）。"
    echo ""
    echo "  可能原因："
    echo "    1. 还没安装任何 AI 工具 → 先装一个再重跑本脚本"
    echo "    2. 工具装在非默认路径 → 手动指定 skills 目录"
    echo ""
    echo "  手动指定路径克隆（示例）："
    echo "    bash .ai/install.sh /path/to/your/skills-dir"
    echo ""
    echo "  或直接手动克隆（8 个 skill）："
    echo "    for s in project-iteration project-intake-pm proto-spec-generator \\"
    echo "             prototype-html-pin tapd-requirement-upload vitepress-deploy \\"
    echo "             project-retrospective-pm prd-writer; do"
    echo "      git clone https://github.com/$SKILL_GITHUB_USER/\$s.git <你的skills目录>/\$s"
    echo "    done"
    echo ""
    echo "  技能清单详见 README.md 的「技能生态」章节。"
    exit 0
  fi

  echo "检测到以下 AI 工具的 skills 目录："
  for d in "${SKILL_DIRS[@]}"; do
    echo "  - $d"
  done
  echo ""

  read -r -p "是否克隆全部技能到以上目录？[Y/n] " ans
  ans="${ans:-Y}"
  AUTO_CONFIRM=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
fi

if [ "$AUTO_CONFIRM" = "y" ]; then
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
