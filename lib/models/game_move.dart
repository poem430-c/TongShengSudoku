/// A single reversible board edit for undo support.
class GameMove {
  GameMove({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.previousNotes,
    required this.newValue,
    required this.newNotes,
    this.wasMistake = false,
  });

  final int row;
  final int col;
  final int previousValue;
  final Set<int> previousNotes;
  final int newValue;
  final Set<int> newNotes;
  final bool wasMistake;
}
