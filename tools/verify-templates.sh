#!/bin/bash
# 模板回歸測試（維護者用，Mac + Chrome）
# 用法：
#   bash tools/verify-templates.sh           # 驗證：渲染所有模板，跟 tools/golden/ 基準圖比對
#   bash tools/verify-templates.sh --update  # 改版後刻意更新基準圖（先確認新畫面是對的再跑）
# 原理：任何人改了 templates/*.html（或不小心動到幾何座標），渲染結果會偏離基準圖 → 測試失敗。
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
GOLDEN="$DIR/tools/golden"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "❌ 找不到 Google Chrome"; exit 1; }

MODE="${1:-verify}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -r "$DIR/templates" "$TMP/t"
cp -r "$DIR/assets" "$TMP/t/assets"   # 模板內 logo 路徑是 assets/...

mkdir -p "$GOLDEN"
FAIL=0
for f in "$TMP"/t/*.html; do
  name="$(basename "$f" .html)"
  shot="$TMP/$name.png"
  "$CHROME" --headless --disable-gpu --hide-scrollbars --window-size=1280,720 \
    --screenshot="$shot" "file://$f" 2>/dev/null
  if [ "$MODE" = "--update" ]; then
    cp "$shot" "$GOLDEN/$name.png"
    echo "🔄 updated golden: $name"
    continue
  fi
  if [ ! -f "$GOLDEN/$name.png" ]; then
    echo "⚠️  $name：沒有基準圖（新模板？先人工確認畫面，再跑 --update 建立基準）"
    FAIL=1
    continue
  fi
  python3 - "$GOLDEN/$name.png" "$shot" "$name" <<'PY' || FAIL=1
import sys
from PIL import Image, ImageChops
golden, shot, name = sys.argv[1], sys.argv[2], sys.argv[3]
a = Image.open(golden).convert("RGB"); b = Image.open(shot).convert("RGB")
if a.size != b.size:
    print(f"❌ {name}：尺寸不同 {a.size} vs {b.size}"); sys.exit(1)
h = ImageChops.difference(a, b).convert("L").histogram()
total = a.size[0] * a.size[1]
big = sum(h[9:])          # 通道差 >8 的像素（>8 可排除 Chrome 版本間的次像素抗鋸齒漂移）
pct = big / total * 100
LIMIT = 1.0               # 超過 1% 實質差異＝有東西真的動了
if pct > LIMIT:
    print(f"❌ {name}：{pct:.2f}% 像素偏離基準（>{LIMIT}%）——版面被改動或改壞了")
    sys.exit(1)
print(f"✅ {name}（偏離 {pct:.3f}%）")
PY
done

if [ "$MODE" = "--update" ]; then
  echo "基準圖已更新到 tools/golden/ ——記得連同基準圖一起 commit。"
elif [ "$FAIL" = 1 ]; then
  echo ""
  echo "有模板沒過。若是刻意改版：人工確認新畫面正確後跑 bash tools/verify-templates.sh --update"
  exit 1
else
  echo ""
  echo "全部模板通過回歸測試 ✅"
fi
