/// Game size / mode configuration for Sudoku boards.
enum SudokuMode {
  classic9,
  large12,
}

extension SudokuModeX on SudokuMode {
  int get size => switch (this) {
        SudokuMode.classic9 => 9,
        SudokuMode.large12 => 12,
      };

  /// Sub-grid height (rows per block).
  int get boxRows => switch (this) {
        SudokuMode.classic9 => 3,
        SudokuMode.large12 => 3,
      };

  /// Sub-grid width (columns per block).
  int get boxCols => switch (this) {
        SudokuMode.classic9 => 3,
        SudokuMode.large12 => 4,
      };

  String get label => switch (this) {
        SudokuMode.classic9 => '9 × 9',
        SudokuMode.large12 => '12 × 12',
      };

  String get shortLabel => switch (this) {
        SudokuMode.classic9 => '9x9',
        SudokuMode.large12 => '12x12',
      };

  String get description => switch (this) {
        SudokuMode.classic9 => 'Classic Sudoku with 3×3 blocks',
        SudokuMode.large12 => 'Large board with 3×4 blocks',
      };
}

enum Difficulty {
  easy,
  medium,
  hard,
}

extension DifficultyX on Difficulty {
  String get label => switch (this) {
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.hard => 'Hard',
      };

  /// Target filled-cell ratio (clues / total cells).
  double get clueRatioMin => switch (this) {
        Difficulty.easy => 0.50,
        Difficulty.medium => 0.40,
        Difficulty.hard => 0.30,
      };

  double get clueRatioMax => switch (this) {
        Difficulty.easy => 0.60,
        Difficulty.medium => 0.50,
        Difficulty.hard => 0.35,
      };

  String get hint => switch (this) {
        Difficulty.easy => 'Lots of clues — great for relaxing',
        Difficulty.medium => 'Balanced challenge with pencil marks',
        Difficulty.hard => 'Fewer clues — for seasoned solvers',
      };
}
