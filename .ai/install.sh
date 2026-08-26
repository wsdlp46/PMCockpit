#!/usr/bin/env bash
# ============================================================
# AI 资产安装脚本
# 作用：默认链接 8 个核心 Skill；按需链接测试或 VitePress 能力；仅向 ZCode 链接 solution-designer Agent
# 兼容：ZCode、WorkBuddy、Claude Code、Codex
# 用法：在项目根执行 bash .ai/install.sh
#       需要测试闭环时：bash .ai/install.sh --with-test
#       已有独立 VitePress 文档站时：bash .ai/install.sh --with-vitepress
# ============================================================
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$ROOT/.ai/skills"
OPTIONAL_TEST_SRC="$ROOT/.ai/optional-skills/test-flow-pm"
OPTIONAL_VITEPRESS_SRC="$ROOT/.ai/optional-skills/vitepress-deploy"
AGENTS_SRC="$ROOT/.ai/agents"
# PM_HARNESS_HOME 仅用于隔离回归验证；常规安装始终使用当前用户目录。
HARNESS_HOME="${PM_HARNESS_HOME:-$HOME}"

WITH_VITEPRESS=0
WITH_TEST=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-test) WITH_TEST=1 ;;
    --with-vitepress) WITH_VITEPRESS=1 ;;
    -h|--help)
      echo "用法：bash .ai/install.sh [--with-test] [--with-vitepress]"
      echo "默认仅安装 8 个核心 Skill；测试和 VitePress 均须显式启用。"
      exit 0
      ;;
    *)
      echo "✗ 未知参数：$1。用 --help 查看用法。"
      exit 2
      ;;
  esac
  shift
done

if [ ! -d "$SKILLS_SRC" ]; then
  echo "✗ 找不到 ${SKILLS_SRC}，请在项目根目录执行本脚本"
  exit 1
fi

SKILL_LINKED=0
SKILL_SKIPPED=0
SKILL_CONFLICT_SKIPPED=0
SKILL_UNAVAILABLE_SKIPPED=0
AGENT_LINKED=0
AGENT_SKIPPED=0
AGENT_CONFLICT_SKIPPED=0
AGENT_UNAVAILABLE_SKIPPED=0
HARNESS_DETECTED=0

SKILL_TOTAL=0
for s in "$SKILLS_SRC"/*/; do
  [ -f "$s/SKILL.md" ] || continue
  SKILL_TOTAL=$((SKILL_TOTAL + 1))
done
if [ "$WITH_TEST" -eq 1 ]; then
  if [ ! -f "$OPTIONAL_TEST_SRC/SKILL.md" ]; then
    echo "✗ 找不到可选 test-flow-pm：${OPTIONAL_TEST_SRC}"
    exit 1
  fi
  SKILL_TOTAL=$((SKILL_TOTAL + 1))
fi
if [ "$WITH_VITEPRESS" -eq 1 ]; then
  if [ ! -f "$OPTIONAL_VITEPRESS_SRC/SKILL.md" ]; then
    echo "✗ 找不到可选 vitepress-deploy：${OPTIONAL_VITEPRESS_SRC}"
    exit 1
  fi
  SKILL_TOTAL=$((SKILL_TOTAL + 1))
fi

SOLUTION_AGENT="$AGENTS_SRC/solution-designer.md"
AGENT_TOTAL=0
if [ -f "$SOLUTION_AGENT" ]; then
  AGENT_TOTAL=1
else
  echo "⚠ 找不到 ${SOLUTION_AGENT}，ZCode Agent 将无法安装"
fi

link_optional_skill() {
  local harness="$1"
  local target_dir="$2"
  local skill_src="$3"
  local name="$4"
  local target="$target_dir/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "⚠ [$harness] 跳过 ${target}：发现非软链文件或目录，请先核对并迁移后再同步"
    SKILL_SKIPPED=$((SKILL_SKIPPED + 1))
    SKILL_CONFLICT_SKIPPED=$((SKILL_CONFLICT_SKIPPED + 1))
  else
    ln -sfn "$skill_src" "$target"
    SKILL_LINKED=$((SKILL_LINKED + 1))
  fi
}

link_skills_to() {
  local harness="$1"
  local target_dir="$2"
  mkdir -p "$target_dir"
  for s in "$SKILLS_SRC"/*/; do
    [ -f "$s/SKILL.md" ] || continue
    local name; name="$(basename "$s")"
    local target="$target_dir/$name"
    # 真实目录可能是其他版本的手工副本。安装脚本不覆盖，保留现场并提示人工迁移。
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "⚠ [$harness] 跳过 ${target}：发现非软链文件或目录，请先核对并迁移后再同步"
      SKILL_SKIPPED=$((SKILL_SKIPPED + 1))
      SKILL_CONFLICT_SKIPPED=$((SKILL_CONFLICT_SKIPPED + 1))
      continue
    fi
    # 软链，源文件改了全局同步更新；去掉源尾斜杠避免 ln 把链接建进目录内部
    ln -sfn "${s%/}" "$target"
    SKILL_LINKED=$((SKILL_LINKED + 1))
  done
  if [ "$WITH_TEST" -eq 1 ]; then
    link_optional_skill "$harness" "$target_dir" "$OPTIONAL_TEST_SRC" "test-flow-pm"
  fi
  if [ "$WITH_VITEPRESS" -eq 1 ]; then
    link_optional_skill "$harness" "$target_dir" "$OPTIONAL_VITEPRESS_SRC" "vitepress-deploy"
  fi
}

link_solution_designer_to_zcode() {
  local target_dir="$1"
  [ "$AGENT_TOTAL" -eq 1 ] || return 0
  mkdir -p "$target_dir"
  local target="$target_dir/solution-designer.md"
  # 与 Skill 一样，绝不覆盖工具目录中的实体文件或目录。
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "⚠ [ZCode] 跳过 ${target}：发现非软链文件或目录，请先核对后再同步"
    AGENT_SKIPPED=$((AGENT_SKIPPED + 1))
    AGENT_CONFLICT_SKIPPED=$((AGENT_CONFLICT_SKIPPED + 1))
    return 0
  fi
  ln -sfn "$SOLUTION_AGENT" "$target"
  AGENT_LINKED=$((AGENT_LINKED + 1))
}

echo "== 安装 PM 工作流 Skills =="
if [ "$WITH_TEST" -eq 1 ]; then
  echo "已启用可选 test-flow-pm：仅在版本已提测或用户明确要求测试时使用。"
else
  echo "默认未集成 test-flow-pm。需要测试规划、执行、报告或回归时，请重跑：bash .ai/install.sh --with-test"
fi
if [ "$WITH_VITEPRESS" -eq 1 ]; then
  echo "已启用可选 vitepress-deploy：仅用于已有独立 VitePress 文档站的维护。"
else
  echo "默认未集成 vitepress-deploy。若已有独立文档站且需要维护，请重跑：bash .ai/install.sh --with-vitepress"
fi

# --- ZCode：Skill + 唯一允许安装的工作区 Agent ---
if [ -d "$HARNESS_HOME/.zcode" ] || command -v zcode >/dev/null 2>&1; then
  HARNESS_DETECTED=$((HARNESS_DETECTED + 1))
  link_skills_to "ZCode" "$HARNESS_HOME/.zcode/skills"
  link_solution_designer_to_zcode "$HARNESS_HOME/.zcode/agents"
  echo "✓ ZCode      → ~/.zcode/skills；~/.zcode/agents/solution-designer.md"
else
  echo "— ZCode      未检测到，跳过 $SKILL_TOTAL 个 Skill 和 $AGENT_TOTAL 个 Agent 链接"
  SKILL_SKIPPED=$((SKILL_SKIPPED + SKILL_TOTAL))
  SKILL_UNAVAILABLE_SKIPPED=$((SKILL_UNAVAILABLE_SKIPPED + SKILL_TOTAL))
  AGENT_SKIPPED=$((AGENT_SKIPPED + AGENT_TOTAL))
  AGENT_UNAVAILABLE_SKIPPED=$((AGENT_UNAVAILABLE_SKIPPED + AGENT_TOTAL))
fi

# --- WorkBuddy：只安装 Skills ---
if [ -d "$HARNESS_HOME/.workbuddy" ] || command -v workbuddy >/dev/null 2>&1; then
  HARNESS_DETECTED=$((HARNESS_DETECTED + 1))
  link_skills_to "WorkBuddy" "$HARNESS_HOME/.workbuddy/skills"
  echo "✓ WorkBuddy  → ~/.workbuddy/skills"
else
  echo "— WorkBuddy  未检测到，跳过 $SKILL_TOTAL 个 Skill 链接"
  SKILL_SKIPPED=$((SKILL_SKIPPED + SKILL_TOTAL))
  SKILL_UNAVAILABLE_SKIPPED=$((SKILL_UNAVAILABLE_SKIPPED + SKILL_TOTAL))
fi

# --- Claude Code：只安装 Skills ---
if [ -d "$HARNESS_HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  HARNESS_DETECTED=$((HARNESS_DETECTED + 1))
  link_skills_to "Claude Code" "$HARNESS_HOME/.claude/skills"
  echo "✓ Claude Code → ~/.claude/skills"
else
  echo "— Claude Code 未检测到，跳过 $SKILL_TOTAL 个 Skill 链接"
  SKILL_SKIPPED=$((SKILL_SKIPPED + SKILL_TOTAL))
  SKILL_UNAVAILABLE_SKIPPED=$((SKILL_UNAVAILABLE_SKIPPED + SKILL_TOTAL))
fi

# --- Codex：只安装 Skills ---
if [ -d "$HARNESS_HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  HARNESS_DETECTED=$((HARNESS_DETECTED + 1))
  link_skills_to "Codex" "$HARNESS_HOME/.codex/skills"
  echo "✓ Codex    → ~/.codex/skills（按客户端能力发现或显式调用 Skill，详见 TOOL-MAPPING.md）"
else
  echo "— Codex    未检测到，跳过 $SKILL_TOTAL 个 Skill 链接"
  SKILL_SKIPPED=$((SKILL_SKIPPED + SKILL_TOTAL))
  SKILL_UNAVAILABLE_SKIPPED=$((SKILL_UNAVAILABLE_SKIPPED + SKILL_TOTAL))
fi

echo ""
echo "== 安装统计 =="
echo "Skill：已链接 ${SKILL_LINKED}，已跳过 ${SKILL_SKIPPED}（端未检测 ${SKILL_UNAVAILABLE_SKIPPED}，非软链冲突 ${SKILL_CONFLICT_SKIPPED}）"
echo "Agent（仅 ZCode solution-designer）：已链接 ${AGENT_LINKED}，已跳过 ${AGENT_SKIPPED}（端未检测 ${AGENT_UNAVAILABLE_SKIPPED}，非软链冲突 ${AGENT_CONFLICT_SKIPPED}）"
if [ "$HARNESS_DETECTED" -eq 0 ]; then
  echo "✗ 未检测到受支持的 AI 工具，未安装任何 Skill。请按 .ai/TOOL-MAPPING.md 核对安装路径后重试。"
  exit 1
fi
if [ "$SKILL_CONFLICT_SKIPPED" -gt 0 ] || [ "$AGENT_CONFLICT_SKIPPED" -gt 0 ]; then
  echo "⚠ 存在非软链冲突，未覆盖任何现场文件；请按 TOOL-MAPPING.md 核对后迁移。"
fi
echo "下一步：重启 AI 工具使链接生效。首次使用建议读 AGENTS.md、01通用规则/AI能力治理规范.md 和 .ai/TOOL-MAPPING.md。"
