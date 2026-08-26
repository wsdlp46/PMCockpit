#!/usr/bin/env bash
# 将演练源页面中的三个 SCAFFOLD 占位符合并为可直接打开的单文件 HTML。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_FILES=()
while IFS= read -r -d '' src_file; do
  SRC_FILES+=("$src_file")
done < <(find "$PROJECT_DIR" -maxdepth 1 -type f -name "*.src.html" -print0)

if [[ ${#SRC_FILES[@]} -eq 0 ]]; then
  echo "未找到 .src.html 源文件。"
  exit 1
fi

for src in "${SRC_FILES[@]}"; do
  out="${src%.src.html}.html"
  python3 - "$src" "$out" "$SCRIPT_DIR" <<'PYEOF'
import re, sys
src, out, scaffold = sys.argv[1:4]
with open(src, encoding='utf-8') as f: html = f.read()
for token, filename, wrapper in (
    ('CSS', 'proto-base.css', ('<style>\n', '\n</style>')),
    ('SIDEBAR', 'proto-sidebar-admin.html', ('\n', '\n')),
    ('JS', 'proto-connect.js', ('<script>\n', '\n</script>')),
):
    marker = f'<!-- SCAFFOLD:{token} -->'
    if marker not in html:
        raise SystemExit(f'{src}: 缺少 {marker}')
    with open(f'{scaffold}/{filename}', encoding='utf-8') as f: content = f.read()
    html = html.replace(marker, wrapper[0] + content + wrapper[1])
with open(out, 'w', encoding='utf-8') as f: f.write(html)
print(f'✓ {src.split("/")[-1]} → {out.split("/")[-1]}')
PYEOF
done
