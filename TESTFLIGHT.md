# Mama's Sudoku → TestFlight

新手請先睇呢份（最似 Expo EAS）：

👉 **`GUIDE_CODEMAGIC.md`**

下面係舊版 GitHub Actions 說明（進階先用）。

---

# （進階）GitHub Actions 做法

你用 **Windows + GitHub**。  
GitHub Actions 會用 **雲端 Mac** 幫你 build，再上傳 **TestFlight**。

---

## 整體流程

```
你的電腦 (Windows)
    ↓ push code
GitHub repo
    ↓ Actions (macos runner)
打出 .ipa
    ↓ App Store Connect API
TestFlight
    ↓
你的 iPhone 安裝
```

---

## 第一步：準備 Apple 資料

### 1) Bundle ID（已設定）
專案已用：`com.poemc.mamasudoku`

### 2) Apple Developer 開 App ID
https://developer.apple.com/account  
→ Certificates, Identifiers & Profiles → Identifiers → + → App

### 3) 建立 Distribution Certificate + App Store Provisioning Profile
同一頁：
- **Certificates** → Apple Distribution（下載 .cer，喺 Keychain 做成 .p12）  
  > 如果未試過，可用朋友部 Mac / 暫時借 Mac 做一次；或者之後我教你逐步截圖流程  
- **Profiles** → App Store Connect → 揀你的 App ID + Distribution cert → 下載 `.mobileprovision`

### 4) App Store Connect 開 App
https://appstoreconnect.apple.com  
→ 新增 App → 揀同一 Bundle ID

### 5) 建立 App Store Connect API Key
App Store Connect → 用戶和訪問 → 集成 → App Store Connect API  
- 產生 Key（App Manager）  
- 下載 `.p8`（只得一次）  
- 記低 **Key ID**、**Issuer ID**

---

## 第二步：專案上 GitHub

```powershell
cd "C:\Users\cc_wi\Documents\C\App Project\SudokuApps"
git init
git add .
git commit -m "Add GitHub Actions TestFlight workflow"
git branch -M main
git remote add origin https://github.com/你的帳號/MamaSudoku.git
git push -u origin main
```

（如果已經有 repo，淨係 `git push` 就得。）

---

## 第三步：喺 GitHub 加 Secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

要加呢啲：

| Secret 名稱 | 內容 |
|-------------|------|
| `BUNDLE_ID` | 例如 `com.xxx.mamasudoku` |
| `APPLE_TEAM_ID` | Apple Team ID（10 位） |
| `BUILD_CERTIFICATE_BASE64` | Distribution .p12 轉 base64 |
| `P12_PASSWORD` | 匯出 .p12 時設嘅密碼 |
| `BUILD_PROVISION_PROFILE_BASE64` | `.mobileprovision` 轉 base64 |
| `KEYCHAIN_PASSWORD` | 任意一串密碼（例如亂數） |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | `.p8` 檔轉 base64 |

### Windows 轉 base64 方法（PowerShell）

```powershell
# .p12
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\dist.p12")) | Set-Clipboard

# .mobileprovision
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\app.mobileprovision")) | Set-Clipboard

# .p8
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\AuthKey_XXXX.p8")) | Set-Clipboard
```

貼上 GitHub Secret 後，剪貼簿記得清。

---

## 第四步：改 ExportOptions.plist

開 `ios/ExportOptions.plist`，改：

- `YOUR_APPLE_TEAM_ID` → 你的 Team ID  
- Bundle ID 已設為 `com.poemc.mamasudoku`  
- `YOUR_APPLE_TEAM_ID` → 你的 Team ID  
- `YOUR_PROFILE_NAME` / profile 名 → 之後開好 App Store Profile 嘅**名稱**

---

## 第五步：跑 GitHub Actions

1. GitHub repo → **Actions**  
2. 揀 **iOS TestFlight**  
3. **Run workflow**  

成功後會上傳去 TestFlight。

---

## 第六步：iPhone 安裝

1. 等 App Store Connect 處理 build（約 5–30 分鐘）  
2. TestFlight 加自己做測試員  
3. iPhone 裝 **TestFlight** → 安裝 Mama's Sudoku  

---

## 費用注意

GitHub Actions **macOS 分鐘較貴**（會按倍率扣免費額度）。  
免費帳號通常夠試幾次；如果成日 build，可能要用完免費分鐘。

---

## 你而家回覆我呢 3 樣

1. 想用嘅 **Bundle ID**  
2. GitHub repo 連結（有就俾；未有我教你開）  
3. 你有冇已經有 **Distribution .p12** 同 **.mobileprovision**？  

有 Bundle ID 我可以即刻幫你改專案入面嘅 ID 同 `ExportOptions.plist`。
