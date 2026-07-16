#!/bin/bash
# 發佈打包（維護者用）：先跑回歸測試，通過才打 lite / full 兩個 zip
# 用法：bash tools/release.sh  → 產出到 ~/Desktop/
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$HOME/Desktop}"
mkdir -p "$OUT"
STAMP="$(date +%Y%m%d)"

echo "① 回歸測試…"
bash "$DIR/tools/verify-templates.sh"

echo "② 打包…"
cd "$(dirname "$DIR")"
BASE="$(basename "$DIR")"
LITE="$OUT/alleypin-slide-design_lite_$STAMP.zip"
FULL="$OUT/alleypin-slide-design_full_$STAMP.zip"
rm -f "$LITE" "$FULL"

# 兩版都排除的：git、維護工具、素材「散檔」資料夾（散檔已打包進 visual-assets.zip，不再直接發佈）
COMMON_X=("$BASE/.git/*" "$BASE/tools/*" "$BASE/assets/icons/*" "$BASE/assets/illus/*" "$BASE/assets/ip/*" "$BASE/.DS_Store" "$BASE/*/.DS_Store")

# lite：不含素材（給 Claude Chat / Manus；logo 保留，封面封底要用）
zip -rq "$LITE" "$BASE" \
  -x "${COMMON_X[@]}" \
     "$BASE/assets/visual-assets.zip" \
     "$BASE/assets/ASSET-INDEX.md" "$BASE/assets/sync-visual-assets.sh"

# full：素材以單一 visual-assets.zip 隨包（給 Claude Code / Codex，用前解壓，見 SKILL.md）
zip -rq "$FULL" "$BASE" \
  -x "${COMMON_X[@]}"

echo "③ 完成："
ls -lh "$LITE" "$FULL"

echo "④ 檔數檢查（上傳型安裝有 200 檔硬上限，2026-07 同事實測撞過）…"
FULL_N=$(unzip -l "$FULL" | tail -1 | awk '{print $2}')
REPO_N=$(git -C "$DIR" ls-files | wc -l | tr -d ' ')
echo "  full zip 條目數：$FULL_N；GitHub 整包（貼網址安裝會抓的）檔數：$REPO_N"
if [ "$FULL_N" -gt 150 ] || [ "$REPO_N" -gt 150 ]; then
  rm -f "$LITE" "$FULL"   # 刪掉剛打的 zip，確保壞包不會被誤發
  printf '\033[1;31m❌ 檔數超過 150 安全線（上限 200）——發佈中止、zip 已刪！\033[0m\n'
  echo "   多半是素材散檔被 git add 進來了。素材一律只進 assets/visual-assets.zip："
  echo "   1) 把散檔放回 assets/{icons,illus,ip}/（已在 .gitignore）"
  echo "   2) bash assets/sync-visual-assets.sh   ← 會重建索引＋重打包 visual-assets.zip"
  echo "   3) git rm -r --cached assets/icons assets/illus assets/ip 2>/dev/null; 再重跑本腳本"
  exit 1
fi
echo ""
echo "接下來（照 tools/MAINTAINING.md 的發佈清單）："
echo "  - 把兩個 zip 發給同事、請他們「重新安裝」"
echo "  - 提醒同事用驗證句確認版本（見 安裝教學.md「怎麼確認裝好了」）"
