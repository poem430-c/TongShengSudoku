/// A single Sudoku cell: value, given flag, and pencil notes.
class SudokuCell {
  SudokuCell({
    this.value = 0,
    this.isGiven = false,
    Set<int>? notes,
  }) : notes = notes ?? <int>{};

  /// 0 means empty. Otherwise 1..size.
  int value;

  /// True if this was a preset clue (not editable).
  bool isGiven;

  /// Pencil / note candidates for empty cells.
  Set<int> notes;

  bool get isEmpty => value == 0;

  SudokuCell copy() => SudokuCell(
        value: value,
        isGiven: isGiven,
        notes: Set<int>.from(notes),
      );
}
