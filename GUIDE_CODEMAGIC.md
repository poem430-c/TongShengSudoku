# Codemagic 超簡單指南（畀新手）

目標：好似你上次用 **Expo EAS** 咁，  
喺雲端幫你 **compile + 簽名**，之後去 **TestFlight**。

你 **唔需要 Mac**。  
跟住一步步做就得。唔明就停低，抄錯誤訊息問我。

---

## 你而家已經有咩

- Flutter App（Mama's Sudoku）
- Bundle ID：`com.poemc.mamasudoku`
- App Store Connect 已經開咗 App
- Apple Developer 帳號

---

## 大圖（記住呢 4 步就夠）

```
1. 把專案放到 GitHub
2. 用 GitHub 登入 Codemagic
3. 連接 Apple（簽名）
4. 撳 Build → 等 TestFlight
```

---

# 第 1 步：把專案放到 GitHub

## 1.1 開一個新 repo
1. 打開 https://github.com
2. 撳 **New repository**
3. Repository name 寫：`MamaSudoku`
4. 揀 **Private**（建議）
5. **唔好**勾 Add README
6. 撳 **Create repository**

## 1.2 喺電腦上傳 code
打開 PowerShell，複製貼上（如果未做過 git）：

```powershell
cd "C:\Users\cc_wi\Documents\C\App Project\SudokuApps"
git init
git add .
git commit -m "First upload for Codemagic"
git branch -M main
```

然後把 GitHub 顯示嘅地址換入去（例子）：

```powershell
git remote add origin https://github.com/你的帳號/MamaSudoku.git
git push -u origin main
```

成功後，GitHub 網頁會見到你嘅檔案。

> 如果 `git push` 叫你登入：用 GitHub 登入／Personal Access Token 就得。

---

# 第 2 步：開 Codemagic 帳號

1. 打開 https://codemagic.io/signup  
2. 揀 **Sign up with GitHub**（用你嘅 GitHub 登入最簡單）  
3. 允許 Codemagic 讀你嘅 repo  

---

# 第 3 步：加入 MamaSudoku 專案

1. 登入後撳 **Add application** / **From repository**  
2. 揀 GitHub  
3. 搵 `MamaSudoku` → **Select**  
4. Project type 揀 **Flutter App**  
5. 撳完成／Continue  

---

# 第 4 步：連接 Apple（最重要，好似 EAS 連 Apple）

## 4A. 開 App Store Connect API Key（如果未開）

1. 打開 https://appstoreconnect.apple.com  
2. 去 **用戶和訪問**（Users and Access）  
3. 上面揀 **集成**（Integrations）  
4. 左邊／分頁揀 **App Store Connect API**  
5. 撳 **產生 API 密鑰**（Generate）  
6. 名稱寫：`Codemagic`  
7. 權限揀：**App Manager**  
8. 撳產生  
9. **立刻下載 .p8 檔**（只可以下載一次！）  
10. 抄低／截圖保存：
    - **Issuer ID**（頁頂）
    - **Key ID**

## 4B. 喺 Codemagic 加入呢個 Key

1. Codemagic → 右上角團隊設定 / **Teams** → 你的 team  
2. 搵 **codemagic.yaml** 唔使先理；去 **Team integrations** 或 **Apple Developer Portal** / **App Store Connect**  
3. 加入 App Store Connect API：
   - Issuer ID
   - Key ID
   - 上傳 `.p8`

（不同版面可能叫 **Integrations** → **App Store Connect**）

---

# 第 5 步：設定 iOS Build（用畫面設定，唔使自己寫碼）

1. 入你的 `MamaSudoku` application  
2. 撳 **Configuration** / 齒輪設定  
3. 揀 **iOS code signing**
   - 用 **Automatic**（自動簽名）最似 EAS  
   - Bundle ID 填：`com.poemc.mamasudoku`  
   - 連接你嘅 Apple team  
4. 去 **Distribution / Publishing**
   - 打開 **App Store Connect**
   - 勾 **Submit to TestFlight**
5. Build 設定：
   - Mode：`Release`
   - Flutter 用 `stable`
6. **Save**

> 如果佢叫你用 Workflow Editor：揀 iOS，跟提示開 code signing + publishing 就得。

---

# 第 6 步：開始 Build（好似 EAS Build）

1. 撳 **Start new build**  
2. 揀 branch：`main`  
3. 揀 iOS workflow  
4. 撳 **Start build**  
5. 等 15–30 分鐘（第一次可能耐啲）

成功會見到綠色。  
失敗會紅色——把紅色最後 20 行錯誤複製俾我。

---

# 第 7 步：去 TestFlight 睇

1. 打開 App Store Connect → 你的 Mama's Sudoku  
2. 上面揀 **TestFlight**  
3. 等 build 出現（有時要多等 5–20 分鐘處理）  
4. 加自己做 **Internal Tester**  
5. iPhone 安裝 **TestFlight** App  
6. 接受邀請 → 安裝 Mama's Sudoku  

恭喜，呢步就好似你上次見到 `1.1.0 (7)` 咁。

---

## 常見問題（好短）

### Codemagic 要錢嗎？
第一次試通常有免費分鐘。用完先可能要俾。試一次一般夠。

### 我要自己整 .p12 嗎？
跟呢份指南用 **Automatic signing** 嘅話，多數 **唔使**自己整（呢點就係似 EAS）。

### Build 失敗最常見原因
- API Key 未加好  
- Bundle ID 唔係 `com.poemc.mamasudoku`  
- App Store Connect 未開好 App  
- Apple 協議未同意（Developer / Connect 有時會有新協議要撳 Agree）

---

## 而家你先做邊步？

由 **第 1 步 GitHub** 開始。

做完一步就回覆我：

`第1步完成` / `第2步完成` ...

或者貼錯誤訊息，我一步步陪你。
