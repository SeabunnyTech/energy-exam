# EnergyExam 專案建置指示

請幫我在這台電腦上把「EnergyExam」這個 Godot 遊戲專案建置起來並成功執行。

這個專案由**兩個 GitHub repo** 組成，必須用符號連結（symlink / junction）串在一起才能執行。請依序完成以下步驟，**每一步做完都要驗證**再往下走。

---

## 環境需求

- **Godot 4.5**（標準版即可，不需要 .NET / Mono 版本）→ https://godotengine.org/download
- **Git**
- **Git LFS** ← 必要！地圖 repo 的 3D 模型與貼圖都存在 LFS，少了它會下載到一堆空殼檔案

先確認環境：

```
git --version
git lfs version
```

如果沒有 git-lfs，Windows 可用 `winget install GitHub.GitLFS` 安裝，安裝後務必執行一次：

```
git lfs install
```

---

## 步驟 1：把兩個 repo clone 成「同層」資料夾

選一個工作目錄（例如 `D:\Projects`），在該目錄下執行：

```
git clone https://github.com/SeabunnyTech/energy-exam.git
git clone https://github.com/SeabunnyTech/EnergyCityMaps_TRI.git
```

兩個 repo 的預設分支就是最新版本，不需要切換分支。

完成後結構應該是這樣（兩個資料夾平行放置）：

```
D:\Projects\
├── energy-exam\            ← 遊戲主程式
└── EnergyCityMaps_TRI\     ← 3D 地圖素材
```

---

## 步驟 2：確認 LFS 素材真的下載下來了

```
cd EnergyCityMaps_TRI
git lfs pull
```

**驗證**：`EnergyCityMaps_TRI\maps\Scene\map_west.tscn` 這個檔案應該約 **30 MB**，整個 `maps` 資料夾約 **113 MB**。

如果檔案只有幾 KB，代表 LFS 沒生效（下載到的是文字指標檔）→ 回頭執行 `git lfs install`，再 `git lfs pull` 一次。

---

## 步驟 3：建立 `maps` 連結（最關鍵的一步）

`energy-exam` 的程式用 `res://maps/...` 這種路徑讀取地圖，但 `maps` 資料夾**不在** energy-exam repo 裡，必須連結到另一個 repo 的 `maps` 子資料夾。

⚠️ 三個容易做錯的地方：

1. 連結要建在 `energy-exam\maps`，名稱**必須正好是 `maps`**（程式路徑寫死的）
2. 目標是 `EnergyCityMaps_TRI\maps` 這個**子資料夾**，不是 repo 根目錄
3. 用 junction（`/J`）**不需要管理員權限**；用 `/D` 才需要

**Windows**（一般命令提示字元即可）：

```
cd ..\energy-exam
mklink /J maps ..\EnergyCityMaps_TRI\maps
```

若相對路徑不通，改用絕對路徑，例如：

```
mklink /J maps D:\Projects\EnergyCityMaps_TRI\maps
```

**macOS / Linux**：

```
cd ../energy-exam
ln -s ../EnergyCityMaps_TRI/maps maps
```

> repo 裡另外附了一個互動式腳本 `setup_maps_link.bat` 也能做同樣的事，但它用的是 `mklink /D`，需要用系統管理員身分執行。上面的 `/J` 寫法比較方便。

**驗證**：

```
dir maps\Scene
```

要能看到 `map_coast.tscn`、`map_east.tscn`、`map_west.tscn` 三個檔案。看不到就是連結建錯了。

---

## 步驟 4：開啟並執行

用 **Godot 4.5** 開啟 `energy-exam\project.godot`。

第一次開啟時 Godot 會 import 約 260 MB 的 3D 素材，可能需要數分鐘，**請等進度條完全跑完**再操作。完成後按 **F5** 執行遊戲。

---

## 疑難排解

| 症狀 | 原因與解法 |
|---|---|
| 地圖一片空白 / 模型破圖 / 貼圖全黑 | LFS 素材沒下載 → 回步驟 2 |
| 報錯找不到 `res://maps/Scene/map_coast.tscn` | 連結沒建好或名稱錯 → 回步驟 3 |
| `mklink` 說權限不足 | 確認用的是 `/J` 不是 `/D` |
| 資料夾搬家後突然跑不動 | junction 記的是絕對路徑。先 `rmdir maps`（這只會刪連結，不會刪素材），再重做步驟 3 |
| 匯出 Windows 執行檔 | Godot 編輯器 → 專案 → 匯出，使用 `export_presets.cfg` 內既有的預設 |

---

## 完成確認

全部做完後，請回報以下兩項是否都成立：

1. `energy-exam\maps\Scene\map_west.tscn` 存在且約 30 MB
2. Godot 按 F5 能進入遊戲首頁，並且能點進地圖看到 3D 場景
