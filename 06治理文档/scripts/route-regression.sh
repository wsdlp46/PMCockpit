#!/usr/bin/env bash
# ============================================================
# AI能力路由规范静态回归（只读）
# 作用：校验核心固定路由；可用 --with-test、--with-vitepress 追加校验可选路由。
# 用法：bash 06治理文档/scripts/route-regression.sh
# ============================================================
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROUTING_FILE="$ROOT/01通用规则/AI能力路由规范.md"
WITH_TEST=0
WITH_VITEPRESS=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-test) WITH_TEST=1 ;;
    --with-vitepress) WITH_VITEPRESS=1 ;;
    *) echo "用法：bash 06治理文档/scripts/route-regression.sh [--with-test] [--with-vitepress]"; exit 2 ;;
  esac
  shift
done

if [ ! -f "$ROUTING_FILE" ]; then
  echo "✗ 找不到 $ROUTING_FILE"
  exit 1
fi

ROUTES=(
  'R01|project-iteration|在既有“数据治理平台”项目中启动 V1.0.0。'
  'R02|project-intake-pm|将本周会议纪要入库到数据治理平台 V1.0.0。'
  'R03|research-pm|对数据治理平台的目标客户、市场、行业政策或竞品开展调研，形成决策依据。'
  'R04|prd-writer|为已确定主题撰写 V1.0.0 PRD。'
  'R05|solution-designer|依据已确认 PRD 写数据治理平台的业务建设方案。'
  'R06|proto-spec-generator|按已确认 PRD，为管理后台逐页编写原型设计规格。'
  'R07|prototype-html-pin|依据已确认页面规格，生成带 Pin 标注的单文件 HTML 原型。'
  'R09|tapd-requirement-upload|基于已确认 PRD 生成 TAPD 需求规划，先不要上传。'
  'R10|project-retrospective-pm|版本完成后复盘本次交付并沉淀改进项。'
)
if [ "$WITH_TEST" -eq 1 ]; then
  ROUTES+=( 'O01|test-flow-pm|V1.0.0 已提测，请输出用例并执行冒烟测试。' )
fi
if [ "$WITH_VITEPRESS" -eq 1 ]; then
  ROUTES+=( 'O02|vitepress-deploy|已确认原型，请 dry-run 同步到现有 VitePress 文档站。' )
fi

passed=0
failed=0
echo "== 能力路由回归（核心 ${#ROUTES[@]} 条，静态） =="
for route in "${ROUTES[@]}"; do
  IFS='|' read -r id target sentence <<EOF
$route
EOF
  row="$(grep -F "| $id |" "$ROUTING_FILE" || true)"
  if [ -n "$row" ] && printf '%s\n' "$row" | grep -Fq "$target" && printf '%s\n' "$row" | grep -Fq "$sentence"; then
    echo "  OK   $id → $target"
    passed=$((passed + 1))
  else
    echo "  FAIL ${id}：未找到路由语句或目标能力不一致（期望 ${target}）"
    failed=$((failed + 1))
  fi
done

echo "== 结果：通过 $passed/${#ROUTES[@]}，失败 $failed =="
[ "$failed" -eq 0 ]
