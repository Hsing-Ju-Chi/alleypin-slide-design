# 維護與 Review 機制（維護者專用；同事不用看這份）

這份 skill 的產出品質靠三層防線。改任何東西之前先讀這頁。

## 三層防線

| 層 | 防什麼 | 誰執行 |
|---|---|---|
| **1. 模板回歸測試** `tools/verify-templates.sh` | 模板（或誰不小心動到座標）被改壞 | 維護者，每次改動後 |
| **2. 發佈檢查清單**（下方） | GitHub 修了、同事手上還是舊 zip（發佈鏈斷裂） | 維護者，每次發佈 |
| **3. 產出端幾何驗收**（SKILL.md「封面」段，分款＋硬數字） | 同事的 Claude 做簡報時畫錯 | 同事的 Claude，每次產出 |

## 改動 SKILL.md / 模板的標準流程

1. **改之前**：想清楚這次要防的「實際失誤」是什麼（規範改動要對應真實踩過的坑，別憑想像加規則）。
2. **改模板**（`templates/*.html`）：
   - 改完跑 `bash tools/verify-templates.sh` → 會**失敗**（因為畫面變了）。
   - 開瀏覽器人工確認新畫面是對的 → 跑 `bash tools/verify-templates.sh --update` 更新基準圖。
   - **封面幾何若有動**：SKILL.md「封面」段的 **pptxgenjs 照抄 block 的座標也要同步改**，並實際產一次 pptx、用 Keynote 開起來對照 HTML 渲染（形狀、位置、顏色）。這兩處是同一組幾何的兩份實作，**改一邊必改另一邊**。
   - 幾何驗收的**硬數字**（SKILL.md）若受影響也要同步。
3. **只改文字規範**（SKILL.md / 安裝教學）：跑一次 `bash tools/verify-templates.sh` 確認沒誤觸模板即可。
4. **改完做應用測試**：開一個乾淨的 Claude session（或 subagent），只給新版 SKILL.md，請它「做一頁封面 B 並自我驗收」——它要能引用分款驗收標準、不把 A 的標準套在 B 上。規範是給模型讀的，**模型讀得懂才算改好**。
5. 更新三份文件開頭的 `*最後更新：YYYY.M.D*`（README / SKILL / 安裝教學，日期用 `date` 查）。
6. Commit（訊息寫「防什麼坑」，讓 git log 能當失誤資料庫用）。

## 🔴 檔數紅線（動素材前必讀；違反＝同事裝不起來）

skill 安裝功能（貼 GitHub 網址 / 上傳 zip）有 **200 檔硬上限**（2026-07 同事實測撞過）。因此：

1. **素材散檔（icons / illus / ip 的 PNG）永遠不進 git**——只進單一 `assets/visual-assets.zip`。三個散檔資料夾已在 `.gitignore`，是本機工作副本。
2. **新增 / 更新素材的唯一正路**：把 PNG 放進 `assets/{icons,illus,ip}/` → 跑 `bash assets/sync-visual-assets.sh`（自動重建索引＋重打包 zip）→ commit 的只有 `visual-assets.zip` 和 `ASSET-INDEX.md`。
3. **絕對禁止** `git add assets/icons` 之類把散檔加回追蹤。`tools/release.sh` 有硬檢查：追蹤檔或 full zip 超過 **150（安全線）** 直接發佈失敗並印出修復步驟。
4. 快速自查：`git ls-files | wc -l` 應在 **30 上下**；三位數＝出事了，照 release.sh 失敗訊息修。

## 發佈檢查清單（每次要給同事新版時）

- [ ] `bash tools/verify-templates.sh` 全綠
- [ ] 三份文件的「最後更新」日期一致且為今天
- [ ] `bash tools/release.sh` 打出 lite / full 兩個 zip
- [ ] 兩個 zip 發給同事，明說「請刪掉舊資料夾重新安裝」
- [ ] 請同事用驗證句自查版本（安裝教學「怎麼確認裝好了」：問 Claude 最後更新日期）
- [ ] push GitHub

> **為什麼要有這清單**：2026-07-06 修了封面規範，但同事端裝的是舊 zip——repo 修好 ≠ 同事修好。發佈鏈（zip → 同事重裝 → 版本自查）走完才算修完。

## 已知失誤資料庫（規範為什麼長這樣）

- 封面幾何 freehand 重畫 → 跑版（2026-07 同事實測，HTML 與 Google 簡報都中）→「整段複製 SVG」＋分款幾何驗收＋pptxgenjs 照抄 block。
- 幾何驗收只寫封面 A 的「一直條」→ 封面 B 無從驗、還會被誤判 → 分款驗收（2026-07-09）。
- 字級單位混淆：公版 Keynote 畫布是 1920×1080pt、skill 網格是 1280×720px、舊 pptx 版面在 Keynote 顯示 960×540 → 同一個「主標」有三種數字，跨團隊溝通必錯（2026-07-09 實際發生）→ 統一 pptx 版面 26.667×15in（Keynote 顯示 1920×1080），規範以 Keynote pt 為準、HTML px = pt×⅔。
- CSS `line-height` 直接抄進 pptxgenjs `lineSpacingMultiple` → Keynote 行距虛胖 ~1.46 倍（Noto Sans TC 實測）→ 規範行距 1.1–1.3 直接給，禁止搬 CSS 值。
- logo 寫死 w×h → 拉伸變形 → 等比安全寫法。
- 交付截圖版 → 不可編輯 → pptxgenjs 原生物件硬性要求。
- 素材 181 散檔直接進 git → repo 206 檔，同事貼網址 / 上傳 zip 安裝撞 200 檔上限（2026-07-15 實測）→ 散檔改打包單一 `visual-assets.zip`（repo 降到 ~26 檔）＋ release.sh 檔數硬檢查（>150 發佈失敗）＋ SKILL.md 首用解壓指令。**驗證教訓：發佈驗收要驗到「對方裝得起來」，不是 zip 產出來就算。**
