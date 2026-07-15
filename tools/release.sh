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

echo "④ 檔數檢查（上傳型安裝有 200 檔硬上限，2026-07 同事實測撞過）…"
FULL_N=$(unzip -l "$FULL" | tail -1 | awk '{print $2}')
REPO_N=$(git -C "$DIR" ls-files | wc -l | tr -d ' ')
echo "  full zip 條目數：$FULL_N；GitHub 整包（貼網址安裝會抓的）檔數：$REPO_N"
if [ "$FULL_N" -gt 195 ] || [ "$REPO_N" -gt 195 ]; then
  printf '\033[1;31m⚠️  超過/逼近 200 檔上限——「貼 GitHub 網址」與「上傳 full zip」都會失敗！\033[0m\n'
  echo "   full 版只能走資料夾安裝：終端機 git clone 到 ~/.claude/skills/（見 安裝教學.md）"
  echo "   lite zip 不受影響，上傳型環境（Claude Chat 等）照用"
fi
echo ""
echo "接下來（照 tools/MAINTAINING.md 的發佈清單）："
echo "  - 把兩個 zip 發給同事、請他們「重新安裝」"
echo "  - 提醒同事用驗證句確認版本（見 安裝教學.md「怎麼確認裝好了」）"
