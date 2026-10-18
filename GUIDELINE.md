# Mama's Sudoku 測試指南

呢份指南教你點樣喺電腦同 iPhone 測試呢個數獨 App。

---

## 開始之前

1. 打開 **PowerShell**
2. 去到專案資料夾：

```powershell
cd "C:\Users\cc_wi\Documents\C\App Project\SudokuApps"
```

3. 設定 Flutter（如果未加 PATH）：

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
```

4. 安裝套件（第一次先做）：

```powershell
flutter pub get
```

---

## 方法一：喺電腦 Chrome 測試（最簡單）

適合：快速睇畫面、試玩

```powershell
flutter run -d chrome
```

等一陣，Chrome 會自動打開遊戲。

**停止測試：** 喺 PowerShell 按 `q`

---

## 方法二：喺 iPhone Safari 測試（用 port 8000）

適合：用手機試大按鈕、觸控操作

> 注意：呢個係網頁版測試，唔係真正 App Store App，但玩法同畫面差唔多。

### 第一步：開伺服器（port 8000）

喺 PowerShell 輸入：

```powershell
cd "C:\Users\cc_wi\Documents\C\App Project\SudokuApps"
$env:PATH = "C:\src\flutter\bin;$env:PATH"
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000
```

等一陣，見到類似呢句就代表成功：

```
lib\main.dart is being served at http://0.0.0.0:8000
```

**唔好關呢個視窗。** 關咗手機就連唔到。

### 第二步：搵電腦 IP

開 **另一個** PowerShell，輸入：

```powershell
ipconfig
```

搵 **Wi-Fi** 下面嘅 **IPv4 Address**。

你部電腦而家嘅 IP 大概係：`192.168.68.54`（每次可能唔同，以 ipconfig 顯示為準）

### 第三步：iPhone 打開 Safari

1. iPhone 同電腦要連 **同一個 Wi-Fi**（唔好用訪客網絡）
2. 打開 Safari
3. 輸入網址（用你自己嘅 IP + **8000**）：

```
http://192.168.68.54:8000
```

> 記住：最後要有 `:8000`，唔係淨係打 IP！

### 第四步：電腦自己先試（確認伺服器正常）

喺電腦 Chrome 打開：

```
http://localhost:8000
```

- 電腦打得開、手機打唔開 → 多數係 Wi-Fi 或防火牆問題
- 電腦都打唔開 → 伺服器未成功啟動，睇返第一步

### 打唔開？逐樣試：

1. **防火牆** — Windows 彈出提示時撳 **允許**
2. **IP 啱唔啱** — 再跑一次 `ipconfig` 確認
3. **同一個 Wi-Fi** — 手機唔好用 4G/5G，要用 Wi-Fi
4. **伺服器有冇行緊** — PowerShell 視窗要開住，唔好按 `q`
5. **換 port 試** — 如果 8000 被佔用，可以改用 8080：

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

然後 Safari 打：`http://192.168.68.54:8080`

### 想好似 App 咁放喺主畫面？

Safari → 分享 → **加入主畫面**

### 懶人方法：一鍵啟動（推薦）

專案入面有個腳本 `test_on_iphone.ps1`，會自動顯示 IP 同開 port 8000：

1. 喺檔案總管打開專案資料夾
2. 右鍵 `test_on_iphone.ps1` → **使用 PowerShell 執行**
3. 跟住畫面顯示嘅網址，喺 iPhone Safari 打開

---

## 方法三：Windows 桌面 App

適合：喺 Windows 當真正程式用

需要 Visual Studio 安裝咗 **「使用 C++ 的桌面開發」**。

```powershell
flutter run -d windows
```

---

## 點樣玩

1. 揀 **9×9** 或 **12×12**
2. 揀 **Easy / Medium / Hard**
3. 撳 **Start Puzzle**
4. 撳格仔 → 再撳數字
5. **Notes** = 鉛筆記號
6. **Check** = 檢查有冇錯
7. **Erase** = 清除
8. 贏咗會彈慶祝視窗，主畫面會記低贏咗幾次

---

## 常見問題

### 可唔可以用 Expo Go 測試？
唔可以。呢個係 **Flutter** 專案，唔係 Expo。

### 可唔可以用 TestFlight 而唔使俾錢？
唔可以。TestFlight 需要 Apple Developer 帳號（約 US$99/年）。

### Safari 測試同真正 iPhone App 有咩分別？
- Safari = 網頁版，方便測試
- 真正 App = 要 Mac + Xcode，或者付費 Developer 帳號

### 贏咗幾次會唔會保存？
會。資料儲存喺你部機（電腦或手機瀏覽器）入面。

---

## 有問題可以試

```powershell
flutter doctor
```

睇下有咩未裝好。

---

---

## TestFlight（真正 iPhone App）

完整步驟睇：`TESTFLIGHT.md`

簡短版（用 **GitHub Actions**，唔使 Codemagic）：
1. Apple Developer 開 Bundle ID + 證書 + Profile  
2. App Store Connect 開 App + API Key  
3. 專案上 GitHub，加 Secrets  
4. Actions → Run **iOS TestFlight**  
5. iPhone 裝 TestFlight → 安裝 Mama's Sudoku  

**祝測試順利！**
