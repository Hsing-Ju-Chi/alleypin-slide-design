# AlleyPin 簡報設計規範 skill
*最後更新：2026.7.1*

讓 Claude 產出**符合 AlleyPin 品牌**的簡報（封面、內容頁），適用任何主題。
這個 skill 只負責「**讓它看起來、讀起來是 AlleyPin**」——色彩、字體、封面、版面框架、logo、文案寫法；
內容結構、敘事、版面配置仍由 Claude 的簡報專業發揮，不被綁死。

## 安裝

> 🔰 **第一次安裝、或要給同事 → 請看 `安裝教學.md`**（新手逐步版，含工具建議：✅ Claude Chat / Codex / Manus AI；⚠️ Claude Code 需 Pro；❌ ChatGPT 不建議）。下面是快速版。

**Claude Code（終端）**：把整個 `alleypin-slide-design/` 資料夾放到 `~/.claude/skills/`。

**Chat / Cowork App**：依 App 的 skill / plugin 安裝方式匯入本資料夾（保留 `SKILL.md`、`templates/`、`assets/` 結構）。

裝好後，Claude 看到「簡報 / 投影片 / 提案 / slide」相關需求就會自動載入。

## 怎麼用

直接跟 Claude 說，例如：
- 「幫我做一份關於『新功能 X』的 AlleyPin 簡報」
- 「用 AlleyPin 風格把這份內容做成提案簡報」

Claude 會：
1. **先問你**：最終要 PPTX 離線檔、Google 簡報，還是 Keynote？（決定標題字體）
2. 套用品牌色盤、封面、內容頁框架、書寫規範。
3. 用 HTML（1280×720）產稿，再轉成你要的格式。

## 內容

| 檔案 | 用途 |
|---|---|
| `SKILL.md` | 規範本體：色盤、字體邏輯、封面、內容頁框架、書寫規範、logo |
| `templates/cover-a.html` | 封面 A（右側幾何 motif） |
| `templates/cover-b.html` | 封面 B（全藍幾何拼塊） |
| `templates/content-page.html` | 內容頁框架（並排卡版型） |
| `templates/content-rows.html` | 內容頁框架（滿版橫向 row，大氣版；已填真實文案當範例） |
| `templates/closing-page.html` | 封底 / Thank You 頁（logo lockup＋聯絡人＋聯絡頁尾） |
| `assets/` | 官方 logo（藍 / 白去背） |

## 注意

- 複製模板時**連同 `assets/` 一起帶走**，logo 路徑才不會斷。
- 標題字體預設 `Noto Sans TC`（Google 簡報安全）；要用 `LINE Seed TW` 須是 PPTX 離線檔且本機已安裝該字體。
- 書寫規範（全/半形、品牌名、第三方全稱、金額/概數寫法）一律遵守，詳見 `SKILL.md`。
