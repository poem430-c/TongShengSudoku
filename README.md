# Mama's Sudoku

An elderly-friendly, **ad-free** Flutter Sudoku app with **9×9** and **12×12** modes, three difficulty levels, pencil notes, error highlighting, and local win tracking.

## Features

- **9×9** classic Sudoku (3×3 blocks, numbers 1–9)
- **12×12** large Sudoku (3×4 blocks, numbers 1–12)
- **Easy / Medium / Hard** clue densities with a unique-solution generator
- Large tap targets, high-contrast colors, big fonts
- Row / column / matching-number highlights
- Auto conflict highlighting + Check button
- Pencil / notes mode
- Win celebration dialog
- Local stats via `shared_preferences` (e.g. `Mama's 9x9 Easy Wins: 5`)

## Project structure

```
SudokuApps/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── game_config.dart
│   │   └── sudoku_cell.dart
│   ├── engine/
│   │   └── sudoku_engine.dart
│   ├── services/
│   │   └── stats_service.dart
│   ├── state/
│   │   └── game_controller.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── game_screen.dart
│   └── widgets/
│       ├── sudoku_grid.dart
│       ├── number_pad.dart
│       └── win_dialog.dart
├── test/
│   └── sudoku_engine_test.dart
├── pubspec.yaml
└── README.md
```

## Setup on Windows

Flutter was installed for this machine at `C:\src\flutter`. Add it to PATH permanently:

1. Settings → System → About → Advanced system settings → Environment Variables
2. Edit **Path** → New → `C:\src\flutter\bin`
3. Open a **new** PowerShell window

Also enable **Developer Mode** (needed for Flutter plugins):

```powershell
start ms-settings:developers
```

Turn on Developer Mode, then continue.

### 1. Install Visual Studio (for native Windows desktop)

Download [Visual Studio Community](https://visualstudio.microsoft.com/downloads/) and install the **Desktop development with C++** workload.

Until that is installed, you can still test in Chrome (see below).

### 2. Get packages and run

```powershell
cd "C:\Users\cc_wi\Documents\C\App Project\SudokuApps"
flutter pub get

# Test in Chrome (works now):
flutter run -d chrome

# Native Windows (needs Visual Studio C++ workload):
flutter run -d windows
```

Or run the helper script:

```powershell
.\setup_windows.ps1
```

### 3. Deploy to iOS later

Build and archive on a **Mac** with Xcode:

```bash
flutter pub get
flutter build ios
```

Then open `ios/Runner.xcworkspace` in Xcode to sign and install on a device.

## How to play

1. Pick **9×9** or **12×12**
2. Pick **Easy**, **Medium**, or **Hard**
3. Tap **Start Puzzle**
4. Tap a cell, then a number
5. Use **Notes** for pencil marks, **Check** to validate, **Erase** to clear
6. Errors (duplicates) highlight automatically in red
7. When you win, a celebration popup appears and your Mama wins counter updates on the home screen

## Notes

- Puzzle generation (especially 12×12 Hard) can take a few seconds — a loading spinner is shown.
- All data stays on-device. There are no ads and no accounts.
