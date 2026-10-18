import '../models/game_config.dart';

enum AppLanguage {
  english,
  traditionalChinese,
}

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.traditionalChinese => 'zh-Hant',
      };

  String get shortLabel => switch (this) {
        AppLanguage.english => 'EN',
        AppLanguage.traditionalChinese => '繁',
      };
}

/// Simple EN / Traditional Chinese strings for the app.
class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  bool get isZh => language == AppLanguage.traditionalChinese;

  String get appName => isZh ? '媽米專用數獨' : "Mama's Sudoku";
  String get tagline => isZh
      ? '今日都係輕輕鬆鬆，陪自己玩一局。'
      : 'A quiet little puzzle for today — just for you.';

  String get languageLabel => isZh ? '語言' : 'Language';
  String get chooseBoard => isZh ? '選擇棋盤' : 'Choose board';
  String get chooseDifficulty => isZh ? '選擇難度' : 'Choose difficulty';
  String get startPuzzle => isZh ? '開始遊戲' : 'Start Puzzle';
  String get wins => isZh ? '勝利' : 'Wins';
  String get total => isZh ? '總計' : 'Total';
  String get builtWith => isZh ? 'Built with C' : 'Built with C';

  String modeDescription(SudokuMode mode) => switch (mode) {
        SudokuMode.classic9 =>
          isZh ? '經典 3×3 小格' : 'Classic 3×3 blocks',
        SudokuMode.large12 =>
          isZh ? '大棋盤 3×4 小格' : 'Large 3×4 blocks',
      };

  String difficultyLabel(Difficulty d) => switch (d) {
        Difficulty.easy => isZh ? '簡單' : 'Easy',
        Difficulty.medium => isZh ? '中等' : 'Medium',
        Difficulty.hard => isZh ? '困難' : 'Hard',
      };

  String difficultyHint(Difficulty d) => switch (d) {
        Difficulty.easy =>
          isZh ? '提示多，輕鬆玩' : 'Lots of clues — relaxing',
        Difficulty.medium =>
          isZh ? '適中挑戰' : 'Balanced challenge',
        Difficulty.hard =>
          isZh ? '提示少，挑戰高' : 'Fewer clues — advanced',
      };

  String get wonderful => isZh ? '太棒了！' : 'Wonderful!';
  String solvedMessage(SudokuMode mode, Difficulty d) => isZh
      ? '你完成了 ${mode.label}「${difficultyLabel(d)}」題目！'
      : 'You solved the ${mode.label} ${difficultyLabel(d)} puzzle.';
  String get playAgain => isZh ? '再玩一局' : 'Play Again';
  String get home => isZh ? '回主頁' : 'Home';
  String get winsCount => isZh ? '勝場' : 'Wins';

  String get preparing => isZh ? '正在準備題目…' : 'Preparing your puzzle…';
  String get back => isZh ? '返回' : 'Back';
  String get newPuzzle => isZh ? '新題目' : 'New puzzle';
  String get favorite => isZh ? '收藏' : 'Favorite';
  String get favorites => isZh ? '已收藏' : 'Favorites';
  String get favoritesEmpty =>
      isZh ? '未有收藏。遊戲中撳星星即可儲存。' : 'No favorites yet. Tap the star during a game to save.';
  String get continuePuzzle => isZh ? '繼續玩' : 'Continue';
  String get removeFavorite => isZh ? '移除' : 'Remove';
  String get favoriteSaved => isZh ? '已加入收藏' : 'Saved to Favorites';
  String get favoriteRemoved => isZh ? '已取消收藏' : 'Removed from Favorites';
  String get sharePuzzle => isZh ? '分享題目' : 'Share puzzle';
  String get theme => isZh ? '主題' : 'Theme';
  String get themeLight => isZh ? '淺色' : 'Light';
  String get themeDark => isZh ? '深色' : 'Dark';
  String get settings => isZh ? '設定' : 'Settings';
  String get gameSettings => isZh ? '遊戲設定' : 'Game settings';
  String get highlightSameNumbers =>
      isZh ? '醒目相同數字' : 'Highlight same numbers';
  String get close => isZh ? '關閉' : 'Close';
  String get ok => isZh ? '好' : 'OK';
  String get themeInfo => isZh
      ? '可以揀淺色或深色主題。'
      : 'Choose a light or dark theme.';
  String get puzzleCopied =>
      isZh ? '題目已複製到剪貼簿' : 'Puzzle copied to clipboard';
  String get paused =>
      isZh ? '已暫停 — 撳播放繼續' : 'Game paused — tap play to continue';
  String get noHints =>
      isZh ? '沒有提示或沒有空格' : 'No hints left or no empty cells';

  String get errors => isZh ? '錯誤' : 'Errors';
  String get score => isZh ? '分數' : 'Score';
  String get time => isZh ? '時間' : 'Time';

  String get undo => isZh ? '復原' : 'Undo';
  String get erase => isZh ? '清除' : 'Erase';
  String get notes => isZh ? '筆記' : 'Notes';
  String get notesOn => isZh ? '筆記開' : 'Notes ON';
  String get hint => isZh ? '提示' : 'Hint';
  String get highlightSame => isZh ? '醒目相同' : 'Highlight same';
}
