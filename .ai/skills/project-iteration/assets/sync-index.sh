#!/usr/bin/env bash
# ==========================================================================
# sync-index.sh — 自动校正版本 _index.md 的目录导航状态
#
# 解决问题：_index.md 的状态列经常失真（标"待启动"但文件实际已存在），
# 导致 AI 进入版本"第一眼"就是错的。
#
# 判定逻辑（按文件存在情况）：
#   02-需求文档/ 有 *.md       → 需求完成
#   03-规格文档/ 有 *.md       → 规格完成
#   04-原型/     有 *.html     → 原型完成
#   05-TAPD上传规划/ 有 *.md   → TAPD完成
#   全部完成                   → 版本状态升级为"待收尾"
#
# 用法：
#   ./sync-index.sh /path/to/02-迭代/02-V1.0.1     # 校正单个版本
#   ./sync-index.sh /path/to/02-迭代               # 校正该迭代下所有版本
# ==========================================================================

set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "用法: $0 <版本目录或迭代目录>"
  echo "示例: $0 02-迭代/02-V1.0.1"
  echo "      $0 02-迭代"
  exit 1
fi

# 确定要处理的版本目录列表
if [[ -f "$TARGET/_index.md" ]] && [[ -d "$TARGET/02-需求文档" ]]; then
  # 目标本身是版本目录
  VERSIONS=( "$TARGET" )
elif [[ -d "$TARGET" ]]; then
  # 目标是迭代目录，找其下所有版本
  VERSIONS=( $(find "$TARGET" -maxdepth 1 -mindepth 1 -type d -name "*-V*" | sort) )
else
  echo "❌ 目标不存在或不是目录: $TARGET" >&2
  exit 1
fi

if [[ ${#VERSIONS[@]} -eq 0 ]]; then
  echo "⚠️  未找到版本目录（需匹配 *-V* 命名）"
  exit 0
fi

sync_one() {
  local ver="$1"
  local ver_name=$(basename "$ver")
  local idx="$ver/_index.md"

  if [[ ! -f "$idx" ]]; then
    echo "⚠️  $ver_name: 无 _index.md，跳过"
    return
  fi

  # 判定各阶段状态
  local req_files=$(find "$ver/02-需求文档" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  local spec_files=$(find "$ver/03-规格文档" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  local proto_files=$(find "$ver/04-原型" -name "*.html" 2>/dev/null | wc -l | tr -d ' ')
  local tapd_files=$(find "$ver/05-TAPD上传规划" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

  local req_status=$([[ $req_files -gt 0 ]] && echo "需求完成($req_files)" || echo "待启动")
  local spec_status=$([[ $spec_files -gt 0 ]] && echo "规格完成($spec_files)" || echo "待启动")
  local proto_status=$([[ $proto_files -gt 0 ]] && echo "原型完成($proto_files)" || echo "待启动")
  local tapd_status=$([[ $tapd_files -gt 0 ]] && echo "TAPD完成($tapd_files)" || echo "待启动")

  # 用 python 更新 _index.md 的目录导航表（保留表结构，只改状态列）
  python3 - "$idx" "$req_status" "$spec_status" "$proto_status" "$tapd_status" << 'PYEOF'
import sys, re
idx, req, spec, proto, tapd = sys.argv[1:6]

with open(idx, encoding='utf-8') as f:
    content = f.read()

# 状态映射：目录名 → 新状态
status_map = {
    '01-原始需求': '外部输入',
    '02-需求文档': req,
    '03-规格文档': spec,
    '04-原型': proto,
    '05-TAPD上传规划': tapd,
    '06-变更记录': '变更追踪',
}

# 定位"目录导航"表格，更新状态列
# 表格行格式：| `目录名/` | 说明 | 状态 |
def update_table(text):
    lines = text.split('\n')
    # 先找到"目录导航"标题所在行
    nav_title_idx = None
    for i, line in enumerate(lines):
        if '目录导航' in line and line.strip().startswith('#'):
            nav_title_idx = i
            break
    if nav_title_idx is None:
        return '\n'.join(lines), 0

    # 从标题往下找表格区（跳过空行，到第一个 | 开头的行开始）
    i = nav_title_idx + 1
    updated = 0
    while i < len(lines):
        line = lines[i]
        if line.strip().startswith('|'):
            cells = [c.strip() for c in line.split('|')]
            # cells[0] 和 cells[-1] 是首尾空（由首尾 | 产生）
            if len(cells) < 4:
                i += 1
                continue
            # 匹配目录名（在第二个单元格）
            cell_dirname = cells[1]
            for dirname, new_status in status_map.items():
                if dirname in cell_dirname:
                    # 状态列是倒数第二个（最后一个 | 之前）
                    cells[-2] = new_status
                    # 重组行（去掉首尾空 cell，用 | 连接）
                    lines[i] = '| ' + ' | '.join(cells[1:-1]) + ' |'
                    updated += 1
                    break
            i += 1
        elif line.strip() == '':
            # 表格区内可能有空行，但如果已经进入表格又遇到空行+非表格，说明表格结束
            # 简单处理：连续两个非表格行才退出
            i += 1
        else:
            # 非表格非空行，表格已结束
            if updated > 0:
                break
            i += 1
    return '\n'.join(lines), updated

new_content, updated = update_table(content)

# 更新版本状态行（顶部 "> 版本：... | 状态：..."）
all_done = all('完成' in s for s in [req, spec, proto, tapd])
if all_done:
    new_content = re.sub(
        r'(状态：)[^|]*(?=\s*\|)',
        r'\g<1>待收尾 ',
        new_content, count=1
    )

if new_content != content:
    with open(idx, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"  ✓ {idx.split('/')[-2]}: 更新 {updated} 个状态")
else:
    print(f"  · {idx.split('/')[-2]}: 无需更新（状态已正确）")
PYEOF
}

echo "🔄 同步 _index.md 状态"
for ver in "${VERSIONS[@]}"; do
  sync_one "$ver"
done
echo "✅ 完成"
