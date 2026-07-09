#!/bin/bash
# 發佈打包（維護者用）：先跑回歸測試，通過才打 lite / full 兩個 zip
# 用法：bash tools/release.sh  → 產出到 ~/Desktop/
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$HOME/Desktop}"
STAMP="$(date +%Y%m%d)"

echo "① 回歸測試…"
bash "$DIR/tools/verify-templates.sh"

echo "② 打包…"
cd "$(dirname "$DIR")"
BASE="$(basename "$DIR")"
LITE="$OUT/alleypin-slide-design_lite_$STAMP.zip"
FULL="$OUT/alleypin-slide-design_full_$STAMP.zip"
rm -f "$LITE" "$FULL"

# lite：不含素材庫與維護工具（給 Claude Chat / Manus；logo 保留，封面封底要用）
zip -rq "$LITE" "$BASE" \
  -x "$BASE/.git/*" "$BASE/tools/*" \
     "$BASE/assets/icons/*" "$BASE/assets/illus/*" "$BASE/assets/ip/*" \
     "$BASE/assets/ASSET-INDEX.md" "$BASE/assets/sync-visual-assets.sh" \
     "$BASE/.DS_Store" "$BASE/*/.DS_Store"

# full：含素材庫，不含維護工具（給 Claude Code / Codex）
zip -rq "$FULL" "$BASE" \
  -x "$BASE/.git/*" "$BASE/tools/*" "$BASE/.DS_Store" "$BASE/*/.DS_Store"

echo "③ 完成："
ls -lh "$LITE" "$FULL"
echo ""
echo "接下來（照 tools/MAINTAINING.md 的發佈清單）："
echo "  - 把兩個 zip 發給同事、請他們「重新安裝」"
echo "  - 提醒同事用驗證句確認版本（見 安裝教學.md「怎麼確認裝好了」）"
