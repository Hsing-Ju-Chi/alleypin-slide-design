#!/bin/bash
# 同步視覺素材到本 skill 並重建 ASSET-INDEX.md（維護者用，需本機有 social-post-generator）
# 用法：bash assets/sync-visual-assets.sh [來源視覺素材資料夾]
set -e
AST="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-$HOME/Desktop/AlleyPin/social-post-generator/assets/視覺素材}"

if [ -d "$SRC" ]; then
  mkdir -p "$AST/icons" "$AST/illus" "$AST/ip"
  cp "$SRC/icons/"*.png              "$AST/icons/" 2>/dev/null || true
  cp "$SRC/illus 橘黑線條插圖/"*.png  "$AST/illus/" 2>/dev/null || true
  cp "$SRC/IP場景/"*.png             "$AST/ip/"    2>/dev/null || true
  echo "已同步素材自：$SRC"
else
  echo "找不到來源（$SRC），僅重建索引。"
fi

# 重建索引
IDX="$AST/ASSET-INDEX.md"
{
  echo "# 素材索引 ( ASSET-INDEX.md )"
  echo
  echo "> 自動由 \`sync-visual-assets.sh\` 生成，**勿手改**。挑圖時用檔名語意判斷適配（見 SKILL.md「插圖 / icon / IP 素材庫」）。"
  echo
  echo "## icons ( 深灰線稿＋橘點綴，放白卡 / 卡片右上角 )　共 $(ls "$AST/icons"/*.png 2>/dev/null | wc -l | tr -d ' ') 個"
  echo
  ( cd "$AST/icons" && ls *.png 2>/dev/null | sed 's/^/- /' )
  echo
  echo "## illus ( 黑線＋品牌橘人物情境，放空白半邊當支撐視覺 )　共 $(ls "$AST/illus"/*.png 2>/dev/null | wc -l | tr -d ' ') 個"
  echo
  ( cd "$AST/illus" && ls *.png 2>/dev/null | sed 's/^/- /' )
  echo
  echo "## ip ( 品牌 IP 角色：山豆醫師 / 吐司 / 伊吉，封面・分隔頁・收尾・內部活潑向 )　共 $(ls "$AST/ip"/*.png 2>/dev/null | wc -l | tr -d ' ') 個"
  echo
  ( cd "$AST/ip" && ls *.png 2>/dev/null | sed 's/^/- /' )
} > "$IDX"
echo "已重建索引：$IDX（icons $(ls "$AST/icons"/*.png 2>/dev/null|wc -l|tr -d ' ') / illus $(ls "$AST/illus"/*.png 2>/dev/null|wc -l|tr -d ' ') / ip $(ls "$AST/ip"/*.png 2>/dev/null|wc -l|tr -d ' '))"
