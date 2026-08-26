#!/usr/bin/env bash
# ============================================================
# 跨 Harness 治理巡检脚本（只读）
# 作用：扫描核心 8 个 Skill 文档清单、可选能力、四端软链健康、ZCode Agent、实体副本、悬空链接
#       与各端 MCP 配置键名。只报告，不改动任何文件。
# 用法：bash 06治理文档/scripts/harness-audit.sh
# 依据：06治理文档/治理巡检清单.md、01通用规则/AI能力治理规范.md
# ============================================================
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$ROOT/.ai/skills"
OPTIONAL_TEST_SRC="$ROOT/.ai/optional-skills/test-flow-pm"
OPTIONAL_VITEPRESS_SRC="$ROOT/.ai/optional-skills/vitepress-deploy"
AGENTS_SRC="$ROOT/.ai/agents"
SOLUTION_AGENT="$AGENTS_SRC/solution-designer.md"
HARNESS_HOME="${PM_HARNESS_HOME:-$HOME}"
HARNESS_DIRS=(
  "$HARNESS_HOME/.zcode/skills"
  "$HARNESS_HOME/.workbuddy/skills"
  "$HARNESS_HOME/.codex/skills"
  "$HARNESS_HOME/.claude/skills"
)
ZCODE_AGENTS_DIR="$HARNESS_HOME/.zcode/agents"

echo "== 跨 Harness 治理巡检（只读） =="
echo "工作区：$ROOT"
echo "时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo

# --- 1. 权威源完整性 ---
echo "-- 1. 权威源完整性 --"
SRC_TOTAL=0
SOURCE_SKILLS=()
if [ -d "$SKILLS_SRC" ]; then
  for d in "$SKILLS_SRC"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    SRC_TOTAL=$((SRC_TOTAL + 1))
    n="$(basename "$d")"
    SOURCE_SKILLS+=("$n")
    if [ -f "$d/SKILL.md" ]; then
      echo "  OK   $n"
    else
      echo "  MISS ${n}（缺 SKILL.md）"
    fi
  done
  echo "  核心技能数：${SRC_TOTAL}（期望 8）"
  if [ "$SRC_TOTAL" -ne 8 ]; then
    echo "  WARN 核心 Skill 数量不为 8；更新发行清单前先确认新增或退役决策"
  fi
else
  echo "  ✗ 找不到 ${SKILLS_SRC}，请在工作区根执行"
fi
if [ -f "$OPTIONAL_TEST_SRC/SKILL.md" ]; then
  echo "  可选能力：test-flow-pm（默认不安装，使用 --with-test 启用）"
else
  echo "  ✗ 可选 test-flow-pm 缺失：$OPTIONAL_TEST_SRC/SKILL.md"
fi
if [ -f "$OPTIONAL_VITEPRESS_SRC/SKILL.md" ]; then
  echo "  可选能力：vitepress-deploy（默认不安装，使用 --with-vitepress 启用）"
else
  echo "  ✗ 可选 vitepress-deploy 缺失：$OPTIONAL_VITEPRESS_SRC/SKILL.md"
fi
for f in "$ROOT/.ai/install.sh" "$ROOT/.ai/TOOL-MAPPING.md" "$ROOT/AGENTS.md" \
         "$ROOT/01通用规则/AI能力治理规范.md" "$ROOT/01通用规则/AI能力路由规范.md" \
         "$ROOT/01通用规则/项目工作流/01-项目结构与版本治理.md" \
         "$ROOT/01通用规则/项目工作流/02-材料与知识资产治理.md" \
         "$ROOT/01通用规则/项目工作流/03-文档与页面资产规范.md" \
         "$ROOT/00环境配置/MCP能力清单.md"; do
  [ -f "$f" ] || echo "  ✗ 权威文件缺失：$f"
done
echo

# --- 1.1 实际 Skill 与三份文档清单一致性 ---
echo "-- 1.1 Skill 文档清单一致性 --"
check_skill_inventory() {
  local label="$1"
  local file="$2"
  local listed=""
  local actual_count=0
  local missing=""
  local extra=""
  local n

  if [ ! -f "$file" ]; then
    echo "  [$label] MISS 文档不存在：$file"
    return 0
  fi

  listed="$(sed -n '/<!-- skill-inventory:start -->/,/<!-- skill-inventory:end -->/p' "$file" \
    | awk -F '`' '{ for (i = 2; i <= NF; i += 2) if ($i ~ /^[a-z][a-z0-9-]*$/) print $i }' | sort -u)"
  if [ -z "$listed" ]; then
    echo "  [$label] MISS 未找到可审计的 Skill 清单标记"
    return 0
  fi

  for n in "${SOURCE_SKILLS[@]}"; do
    if printf '%s\n' "$listed" | grep -Fxq "$n"; then
      actual_count=$((actual_count + 1))
    else
      missing="$missing $n"
    fi
  done
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    [ "$n" = "solution-designer" ] && continue
    if ! printf '%s\n' "${SOURCE_SKILLS[@]}" | grep -Fxq "$n"; then
      extra="$extra $n"
    fi
  done <<EOF
$listed
EOF

  if [ "$actual_count" -eq "$SRC_TOTAL" ] && [ -z "$extra" ]; then
    echo "  [$label] OK   $actual_count/$SRC_TOTAL"
  else
    echo "  [$label] WARN 命中 $actual_count/$SRC_TOTAL${missing:+；缺失:$missing}${extra:+；多余:$extra}"
  fi
}

check_skill_inventory "TOOL-MAPPING" "$ROOT/.ai/TOOL-MAPPING.md"
check_skill_inventory "AI能力路由规范" "$ROOT/01通用规则/AI能力路由规范.md"
echo

# --- 2. 四端软链同源 / 实体副本 / 悬空链接 ---
echo "-- 2. 四端软链同源 / 实体副本 / 悬空链接 --"
for dir in "${HARNESS_DIRS[@]}"; do
  name="$(basename "$(dirname "$dir")")"
  if [ ! -d "$dir" ]; then
    echo "  [$name] 目录不存在（未安装该工具则忽略）"
    continue
  fi
  ok=0
  copies=""
  missing=""
  for d in "$SKILLS_SRC"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    n="$(basename "$d")"
    t="$dir/$n"
    if [ -L "$t" ] && [ -e "$t" ]; then
      if [ "$(readlink "$t")" = "${d%/}" ]; then
        ok=$((ok + 1))
      else
        copies="$copies $n(指向其他来源)"
      fi
    elif [ -d "$t" ]; then
      copies="$copies $n"
    else
      missing="$missing $n"
    fi
  done
  echo "  [$name] 软链 $ok/$SRC_TOTAL${copies:+；实体副本:$copies}${missing:+；缺失:$missing}"
  while IFS= read -r l; do
    echo "  [$name] 悬空链接：$(basename "$l") -> $(readlink "$l")"
  done < <(find "$dir" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null)
done
echo

# --- 3. ZCode Agent 软链（只读） ---
echo "-- 3. ZCode Agent 软链（只读） --"
if [ ! -f "$SOLUTION_AGENT" ]; then
  echo "  MISS 权威 Agent 不存在：$SOLUTION_AGENT"
elif [ ! -d "$ZCODE_AGENTS_DIR" ]; then
  echo "  [ZCode] 目录不存在（未安装该工具则忽略）"
else
  zcode_agent_target="$ZCODE_AGENTS_DIR/solution-designer.md"
  if [ -L "$zcode_agent_target" ] && [ -e "$zcode_agent_target" ]; then
    if [ "$(readlink "$zcode_agent_target")" = "$SOLUTION_AGENT" ]; then
      echo "  [ZCode] OK   solution-designer.md 指向权威 Agent"
    else
      echo "  [ZCode] WARN solution-designer.md 指向其他来源：$(readlink "$zcode_agent_target")"
    fi
  elif [ -e "$zcode_agent_target" ]; then
    echo "  [ZCode] WARN solution-designer.md 为非软链实体文件"
  elif [ -L "$zcode_agent_target" ]; then
    echo "  [ZCode] WARN solution-designer.md 为悬空软链：$(readlink "$zcode_agent_target")"
  else
    echo "  [ZCode] MISS solution-designer.md 未链接"
  fi
fi
echo

# --- 4. MCP 配置键名（只列名称，不输出地址与凭证） ---
echo "-- 4. MCP 配置键名（对照 00环境配置/MCP能力清单.md） --"
echo "[ZCode] ~/.zcode/cli/config.json"
python3 - <<'PY'
import json, os
try:
    d = json.load(open(os.path.expanduser('~/.zcode/cli/config.json')))
    keys = sorted(d.get('mcp', {}).get('servers', {}).keys())
    print('  ' + (', '.join(keys) if keys else '(无)'))
except Exception:
    print('  (无或读取失败)')
PY
echo "[WorkBuddy] ~/.workbuddy/mcp.json"
python3 - <<'PY'
import json, os
try:
    d = json.load(open(os.path.expanduser('~/.workbuddy/mcp.json')))
    s = d.get('mcpServers', d)
    keys = sorted(s.keys()) if isinstance(s, dict) else []
    print('  ' + (', '.join(keys) if keys else '(无)'))
except Exception:
    print('  (无或读取失败)')
PY
echo "[Codex] ~/.codex/config.toml"
if grep -qE '^\[mcp_servers\.[^].]+\]$' "$HOME/.codex/config.toml" 2>/dev/null; then
  grep -E '^\[mcp_servers\.[^].]+\]$' "$HOME/.codex/config.toml" \
    | sed 's/^\[mcp_servers\./  /; s/\]$//' | sort -u
else
  echo "  (无 mcp_servers 或文件不存在)"
fi
echo
echo "== 巡检结束：处置纪律见 治理巡检清单.md（删除/迁移类必须经用户确认） =="
exit 0
