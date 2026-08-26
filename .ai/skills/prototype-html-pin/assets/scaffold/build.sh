#!/usr/bin/env bash
# ==========================================================================
# build.sh（管理端） — 把引用公共样板的源页面合并为单文件 HTML 交付物
#
# 源页面（编辑区，AI 主要操作这里）：
#   - 位于 04-原型/ 根目录，文件名 *.src.html
#   - 用占位符标记公共样板插入点：
#       <!-- SCAFFOLD:CSS -->      → 内联 _scaffold/proto-base.css
#       <!-- SCAFFOLD:SIDEBAR -->  → 内联 _scaffold/proto-sidebar-admin.html
#       <!-- SCAFFOLD:JS -->       → 内联 _scaffold/proto-connect.js
#
# 交付物（构建产物，对外交付/演示用）：
#   - 输出到 04-原型/ 根目录，文件名 A*.html（去掉 .src）
#   - 单文件，所有 CSS/HTML/JS 内联，可直接双击打开或分发
#
# 用法：
#   ./build.sh              # 构建所有 *.src.html
#   ./build.sh AD2          # 只构建匹配 AD2*.src.html 的页面
# ==========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"   # 04-原型/
SCAFFOLD_DIR="$SCRIPT_DIR"

CSS_FILE="$SCAFFOLD_DIR/proto-base.css"
SIDEBAR_FILE="$SCAFFOLD_DIR/proto-sidebar-admin.html"
JS_FILE="$SCAFFOLD_DIR/proto-connect.js"

# 检查样板文件存在
for f in "$CSS_FILE" "$SIDEBAR_FILE" "$JS_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ 缺少样板文件: $f" >&2
    exit 1
  fi
done

# 选择要构建的源文件。使用 NUL 分隔，避免中文、空格或括号路径被 shell 拆开。
# 兼容 macOS bash 3.x，不使用 mapfile 或 sort -z。
FILTER="${1:-}"
SRC_FILES=()
while IFS= read -r -d '' src_file; do
  SRC_FILES+=("$src_file")
done < <(find "$PROJECT_DIR" -maxdepth 1 -type f -name "${FILTER}*.src.html" -print0)

if [[ ${#SRC_FILES[@]} -eq 0 ]]; then
  echo "⚠️  未找到 .src.html 源文件。"
  echo "   源页面应命名为 *.src.html，放在 $PROJECT_DIR"
  exit 0
fi

# 用 python3 做占位符替换（处理大块文本更稳妥）
build_one() {
  local src="$1"
  local out="${src%.src.html}.html"
  python3 - "$src" "$out" "$CSS_FILE" "$SIDEBAR_FILE" "$JS_FILE" << 'PYEOF'
import sys, re
src, out, css, sidebar, js = sys.argv[1:6]
src_name = src.split('/')[-1]
out_name = out.split('/')[-1]

with open(src, encoding='utf-8') as f: html = f.read()
with open(css, encoding='utf-8') as f: css_content = f.read()
with open(sidebar, encoding='utf-8') as f: sidebar_content = f.read()
with open(js, encoding='utf-8') as f: js_content = f.read()

# 统计源文件里的占位符，校验三个都在
expected = {'SCAFFOLD:CSS', 'SCAFFOLD:SIDEBAR', 'SCAFFOLD:JS'}
found = set(re.findall(r'<!--\s*(SCAFFOLD:\w+)\s*-->', html))
missing = expected - found
if missing:
    print(f"  ❌ {src_name}: 缺少占位符 {sorted(missing)}，跳过构建", file=sys.stderr)
    sys.exit(2)

# 替换占位符（允许占位符前后有空白）
html = re.sub(r'<!--\s*SCAFFOLD:CSS\s*-->', '<style>\n' + css_content + '\n</style>', html)
html = re.sub(r'<!--\s*SCAFFOLD:SIDEBAR\s*-->', sidebar_content.strip(), html)
html = re.sub(r'<!--\s*SCAFFOLD:JS\s*-->', '<script>\n' + js_content + '\n</script>', html)

# 构建后自检：不应再残留任何 SCAFFOLD: 字样（防占位符拼写错误导致替换失败）
leftover = re.findall(r'SCAFFOLD:\w+', html)
if leftover:
    print(f"  ❌ {out_name}: 替换后仍残留 {set(leftover)}，占位符可能拼错", file=sys.stderr)
    sys.exit(3)

# 产物头部注入警告标记（提示改 src 而非产物）
warning = (
    "<!-- ⚠️ 构建产物，请勿手改，改动会在下次 build 时丢失。 -->\n"
    f"<!-- 编辑源文件 {src_name}，然后运行 _scaffold/build.sh 重新生成。 -->\n"
)
if html.startswith('<!DOCTYPE'):
    html = html.replace('<!DOCTYPE', warning + '<!DOCTYPE', 1)
else:
    html = warning + html

with open(out, 'w', encoding='utf-8') as f: f.write(html)
print(f"  ✓ {src_name} → {out_name}")
PYEOF
}

echo "🔨 开始构建（管理端样板目录: _scaffold/）"
echo "   源文件数: ${#SRC_FILES[@]}"
for src in "${SRC_FILES[@]}"; do
  build_one "$src"
done
echo "✅ 构建完成"
