# 開發筆記

## 已知問題與假說

### [假說] 文字換行在 compiled exe 中失效

**症狀**：在 editor / headless 截圖時文字正常換行，但 compiled exe 全螢幕執行時 intro 內文與 quiz 題目 Label 不換行。

**假說根本原因**：
`ScreenContainer` 是 `CanvasLayer`，Godot 4 的 CanvasLayer 預設 `follow_viewport_enabled = false`，不跟隨 viewport 的 stretch 變換，而是直接使用實體螢幕解析度計算 Control 大小。

本專案的 ARM64 開發機螢幕解析度（推測為 2880×1920）高於 16x9 branch 的設計解析度（1920×1080），導致：

| 情境 | Label 可用寬度 | 80px 字體每行字數 |
|------|--------------|----------------|
| 設計基準 1920×1080 | ~736px | ~9 字 |
| 實體螢幕 2880×1920 (CanvasLayer) | ~1112px | ~13 字 |

短題目在設計解析度下需要換行，在實體螢幕下卻全擠在一行。

**截圖工具不受影響**的原因：`godot --screenshots all` 不開全螢幕視窗，viewport 與 CanvasLayer 都維持在 1920×1080。

**已採取的緩解措施**：手動補上缺失的 `autowrap_mode = 2`（在 `intro.tscn` 與 `quiz_screen.tscn`）。

**推薦修法（待驗證）**：
在 `super_scene.tscn` 的 `ScreenContainer` CanvasLayer 設定 `follow_viewport_enabled = true`，讓 UI 跟隨 viewport stretch 縮放，確保在任何螢幕解析度下 Control 尺寸都基於設計解析度（1920×1080）。

---

## 設定說明

### 16x9 branch 全螢幕設定（project.godot）

```ini
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=3              ; 全螢幕
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"   ; 維持比例，邊緣留黑邊
```

`canvas_items` + `keep`：所有 UI / 文字按 1920×1080 設計縮放，螢幕比例不符時留黑邊。

---

## 截圖工具

### 從 source 截圖
```bash
godot --screenshots all
```

### 從 compiled exe 截圖（可驗證 exported build 實際樣貌）
```bash
test_run.exe --screenshots all
```
`ScreenshotTool` 使用 `OS.get_cmdline_args()` 解析參數，compiled exe 同樣支援。
