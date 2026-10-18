import 'dart:async';

import 'package:flutter/foundation.dart';

import '../engine/sudoku_engine.dart';
import '../models/game_config.dart';
import '../models/game_move.dart';
import '../models/saved_puzzle.dart';
import '../services/favorites_service.dart';
import '../services/stats_service.dart';

/// Mutable gameplay state for the active puzzle.
class GameController extends ChangeNotifier {
  GameController({
    required StatsService stats,
    required FavoritesService favorites,
  })  : _stats = stats,
        _favorites = favorites;

  final StatsService _stats;
  final FavoritesService _favorites;
  Timer? _timer;

  /// Stable id for the current puzzle (used by favorites).
  String? puzzleId;

  SudokuBoard? board;
  SudokuMode? mode;
  Difficulty? difficulty;

  int? selectedRow;
  int? selectedCol;
  int? highlightedNumber;
  bool notesMode = false;
  bool isGenerating = false;
  bool hasWon = false;
  bool showCheckFeedback = false;
  String? checkMessage;
  Set<(int, int)> conflicts = {};
  Set<(int, int)> wrongCells = {};
  int? lastWinCount;

  int errorCount = 0;
  int score = 0;
  int elapsedSeconds = 0;
  bool isPaused = false;
  int hintsRemaining = 3;
  bool highlightSameNumbers = true;
  bool isFavorite = false;

  final List<GameMove> _undoStack = [];

  bool get hasSelection => selectedRow != null && selectedCol != null;
  bool get canUndo => _undoStack.isNotEmpty && !hasWon;
  bool get canHint => hintsRemaining > 0 && !hasWon && board != null;

  Future<void> startNewGame(SudokuMode newMode, Difficulty newDifficulty) async {
    _stopTimer();
    isGenerating = true;
    hasWon = false;
    showCheckFeedback = false;
    checkMessage = null;
    selectedRow = null;
    selectedCol = null;
    highlightedNumber = null;
    notesMode = false;
    conflicts = {};
    wrongCells = {};
    lastWinCount = null;
    errorCount = 0;
    elapsedSeconds = 0;
    isPaused = false;
    hintsRemaining = _initialHints(newDifficulty);
    highlightSameNumbers = true;
    isFavorite = false;
    puzzleId = null;
    _undoStack.clear();
    mode = newMode;
    difficulty = newDifficulty;
    score = _initialScore(newDifficulty);
    board = null;
    notifyListeners();

    final result = await compute(_generateIsolate, (newMode, newDifficulty));
    final puzzle = result.$1;
    final solution = result.$2;

    puzzleId = _makePuzzleId(puzzle);
    isFavorite = _favorites.containsId(puzzleId!);
    board = SudokuBoard(mode: newMode, puzzle: puzzle, solution: solution);
    _refreshConflicts();
    isGenerating = false;
    _startTimer();
    notifyListeners();
  }

  Future<void> loadSavedGame(SavedPuzzle saved) async {
    _stopTimer();
    isGenerating = true;
    hasWon = false;
    showCheckFeedback = false;
    checkMessage = null;
    selectedRow = null;
    selectedCol = null;
    highlightedNumber = null;
    notesMode = false;
    conflicts = {};
    wrongCells = {};
    lastWinCount = null;
    _undoStack.clear();
    board = null;
    notifyListeners();

    mode = saved.mode;
    difficulty = saved.difficulty;
    puzzleId = saved.id;
    isFavorite = true;
    elapsedSeconds = saved.elapsedSeconds;
    score = saved.score;
    errorCount = saved.errorCount;
    hintsRemaining = saved.hintsRemaining;
    isPaused = false;

    board = SudokuBoard(
      mode: saved.mode,
      puzzle: saved.puzzle,
      solution: saved.solution,
      current: saved.current,
    );
    _refreshConflicts();
    isGenerating = false;
    if (!hasWon) _startTimer();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    if (board == null || hasWon) return;
    selectedRow = row;
    selectedCol = col;
    final value = board!.cellAt(row, col).value;
    highlightedNumber = value != 0 ? value : highlightedNumber;
    showCheckFeedback = false;
    notifyListeners();
  }

  void selectNumber(int value) {
    if (board == null || hasWon) return;
    highlightedNumber = value;
    notifyListeners();
  }

  void toggleNotesMode() {
    notesMode = !notesMode;
    notifyListeners();
  }

  void toggleHighlightSameNumbers() {
    highlightSameNumbers = !highlightSameNumbers;
    notifyListeners();
  }

  void togglePause() {
    if (hasWon || board == null) return;
    isPaused = !isPaused;
    if (isPaused) {
      _stopTimer();
    } else {
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    final b = board;
    final m = mode;
    final d = difficulty;
    final id = puzzleId;
    if (b == null || m == null || d == null || id == null) return;

    if (isFavorite) {
      await _favorites.remove(id);
      isFavorite = false;
    } else {
      await _favorites.upsert(_snapshotFavorite());
      isFavorite = true;
    }
    notifyListeners();
  }

  /// Keep favorite progress up to date while starred.
  Future<void> syncFavoriteProgress() async {
    if (!isFavorite || puzzleId == null || board == null) return;
    await _favorites.upsert(_snapshotFavorite());
  }

  SavedPuzzle _snapshotFavorite() {
    final b = board!;
    return SavedPuzzle(
      id: puzzleId!,
      mode: mode!,
      difficulty: difficulty!,
      puzzle: b.toPuzzleGrid(),
      solution: SudokuBoard.cloneGrid(b.solution),
      current: b.toValueGrid(),
      savedAtMs: DateTime.now().millisecondsSinceEpoch,
      elapsedSeconds: elapsedSeconds,
      score: score,
      errorCount: errorCount,
      hintsRemaining: hintsRemaining,
    );
  }

  String _makePuzzleId(List<List<int>> puzzle) {
    final flat = puzzle.expand((r) => r).join(',');
    return '${mode!.name}_${difficulty!.name}_${flat.hashCode}';
  }

  void inputNumber(int value) {
    final b = board;
    if (b == null || !hasSelection || hasWon || isPaused) return;
    final row = selectedRow!;
    final col = selectedCol!;
    final cell = b.cellAt(row, col);
    if (cell.isGiven) return;

    highlightedNumber = value;

    if (notesMode) {
      if (cell.value != 0) return;
      final prevNotes = Set<int>.from(cell.notes);
      if (cell.notes.contains(value)) {
        cell.notes.remove(value);
      } else {
        cell.notes.add(value);
      }
      _pushMove(
        row: row,
        col: col,
        previousValue: 0,
        previousNotes: prevNotes,
        newValue: 0,
        newNotes: Set<int>.from(cell.notes),
      );
    } else {
      final prevValue = cell.value;
      final prevNotes = Set<int>.from(cell.notes);
      final newValue = prevValue == value ? 0 : value;

      cell.notes.clear();
      cell.value = newValue;

      var wasMistake = false;
      if (newValue != 0 && newValue != b.solution[row][col]) {
        wasMistake = true;
        errorCount++;
        score = (score - 100).clamp(0, 999999);
      } else if (newValue != 0 && prevValue == 0) {
        score += 10;
      }

      _pushMove(
        row: row,
        col: col,
        previousValue: prevValue,
        previousNotes: prevNotes,
        newValue: newValue,
        newNotes: const {},
        wasMistake: wasMistake,
      );
      _refreshConflicts();
      _checkWin();
    }
    showCheckFeedback = false;
    notifyListeners();
    syncFavoriteProgress();
  }

  void erase() {
    final b = board;
    if (b == null || !hasSelection || hasWon || isPaused) return;
    final row = selectedRow!;
    final col = selectedCol!;
    final cell = b.cellAt(row, col);
    if (cell.isGiven) return;
    if (cell.value == 0 && cell.notes.isEmpty) return;

    final prevValue = cell.value;
    final prevNotes = Set<int>.from(cell.notes);
    cell.value = 0;
    cell.notes.clear();

    _pushMove(
      row: row,
      col: col,
      previousValue: prevValue,
      previousNotes: prevNotes,
      newValue: 0,
      newNotes: const {},
    );
    _refreshConflicts();
    showCheckFeedback = false;
    notifyListeners();
    syncFavoriteProgress();
  }

  void undo() {
    final b = board;
    if (b == null || _undoStack.isEmpty || hasWon || isPaused) return;

    final move = _undoStack.removeLast();
    final cell = b.cellAt(move.row, move.col);
    cell.value = move.previousValue;
    cell.notes
      ..clear()
      ..addAll(move.previousNotes);

    // Errors stay counted even after undo — mistakes are permanent.
    // (Score penalty from mistakes also stays.)

    selectedRow = move.row;
    selectedCol = move.col;
    highlightedNumber = move.previousValue != 0 ? move.previousValue : null;
    _refreshConflicts();
    showCheckFeedback = false;
    notifyListeners();
    syncFavoriteProgress();
  }

  bool useHint() {
    final b = board;
    if (b == null || hintsRemaining <= 0 || hasWon || isPaused) return false;

    final target = _hintTarget(b);
    if (target == null) return false;

    final (row, col) = target;
    final cell = b.cellAt(row, col);
    if (!cell.isEmpty || cell.isGiven) return false;

    final correct = b.solution[row][col];
    selectedRow = row;
    selectedCol = col;
    highlightedNumber = correct;

    final prevNotes = Set<int>.from(cell.notes);
    cell.notes.clear();
    cell.value = correct;

    _pushMove(
      row: row,
      col: col,
      previousValue: 0,
      previousNotes: prevNotes,
      newValue: correct,
      newNotes: const {},
    );

    hintsRemaining--;
    score = (score - 150).clamp(0, 999999);
    _refreshConflicts();
    _checkWin();
    notifyListeners();
    syncFavoriteProgress();
    return true;
  }

  void checkBoard() {
    final b = board;
    if (b == null || hasWon) return;

    _refreshConflicts();
    final wrong = b.findWrongValues();

    if (conflicts.isEmpty && wrong.isEmpty && b.isComplete) {
      checkMessage = 'Looking great — keep going!';
    } else if (conflicts.isNotEmpty) {
      checkMessage =
          'Found ${conflicts.length} conflicting cell${conflicts.length == 1 ? '' : 's'}.';
    } else if (wrong.isNotEmpty) {
      checkMessage =
          'No conflicts, but ${wrong.length} number${wrong.length == 1 ? ' is' : 's are'} incorrect.';
    } else {
      final empty = b.cellCount -
          b.toValueGrid().expand((r) => r).where((v) => v != 0).length;
      checkMessage =
          'No errors yet. $empty empty cell${empty == 1 ? '' : 's'} left.';
    }
    showCheckFeedback = true;
    notifyListeners();
  }

  /// How many more of [number] still need to be placed correctly.
  int remainingForNumber(int number) {
    final b = board;
    if (b == null) return 0;

    var placed = 0;
    for (var r = 0; r < b.size; r++) {
      for (var c = 0; c < b.size; c++) {
        final v = b.cells[r][c].value;
        if (v == number && v == b.solution[r][c]) placed++;
      }
    }
    return b.size - placed;
  }

  bool isNumberComplete(int number) => remainingForNumber(number) == 0;

  String puzzleShareText() {
    final b = board;
    if (b == null) return '';
    final lines = b.toValueGrid().map((row) {
      return row.map((v) => v == 0 ? '.' : '$v').join(' ');
    }).join('\n');
    return "Mama's Sudoku ${mode?.label ?? ''} · ${difficulty?.label ?? ''}\n\n$lines";
  }

  void _pushMove({
    required int row,
    required int col,
    required int previousValue,
    required Set<int> previousNotes,
    required int newValue,
    required Set<int> newNotes,
    bool wasMistake = false,
  }) {
    _undoStack.add(
      GameMove(
        row: row,
        col: col,
        previousValue: previousValue,
        previousNotes: previousNotes,
        newValue: newValue,
        newNotes: newNotes,
        wasMistake: wasMistake,
      ),
    );
  }

  (int, int)? _hintTarget(SudokuBoard b) {
    if (hasSelection) {
      final cell = b.cellAt(selectedRow!, selectedCol!);
      if (cell.isEmpty && !cell.isGiven) return (selectedRow!, selectedCol!);
    }
    for (var r = 0; r < b.size; r++) {
      for (var c = 0; c < b.size; c++) {
        final cell = b.cellAt(r, c);
        if (cell.isEmpty && !cell.isGiven) return (r, c);
      }
    }
    return null;
  }

  void _refreshConflicts() {
    final b = board;
    if (b == null) {
      conflicts = {};
      wrongCells = {};
      return;
    }
    conflicts = b.findConflicts();
    wrongCells = b.findWrongValues();
  }

  Future<void> _checkWin() async {
    final b = board;
    final m = mode;
    final d = difficulty;
    if (b == null || m == null || d == null || hasWon) return;

    if (b.isComplete && b.matchesSolution()) {
      hasWon = true;
      _stopTimer();
      score += _timeBonus();
      lastWinCount = await _stats.recordWin(m, d);
      // Completed puzzles leave the favorites list.
      if (puzzleId != null) {
        await _favorites.remove(puzzleId!);
        isFavorite = false;
      }
      notifyListeners();
    }
  }

  int _timeBonus() {
    final d = difficulty;
    if (d == null) return 0;
    final base = switch (d) {
      Difficulty.easy => 200,
      Difficulty.medium => 400,
      Difficulty.hard => 600,
    };
    final penalty = elapsedSeconds ~/ 10;
    return (base - penalty).clamp(50, base);
  }

  int _initialScore(Difficulty d) => switch (d) {
        Difficulty.easy => 2000,
        Difficulty.medium => 3000,
        Difficulty.hard => 5000,
      };

  int _initialHints(Difficulty d) => switch (d) {
        Difficulty.easy => 5,
        Difficulty.medium => 3,
        Difficulty.hard => 1,
      };

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused && !hasWon) {
        elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void clearCheckFeedback() {
    showCheckFeedback = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

(List<List<int>>, List<List<int>>) _generateIsolate(
  (SudokuMode, Difficulty) args,
) {
  final generator = SudokuGenerator(args.$1);
  return generator.generate(args.$2);
}
