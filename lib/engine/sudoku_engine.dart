import 'dart:math';

import '../models/game_config.dart';
import '../models/sudoku_cell.dart';

/// Core Sudoku board logic: placement, conflicts, and win checks.
class SudokuBoard {
  SudokuBoard({
    required this.mode,
    required List<List<int>> puzzle,
    List<List<int>>? solution,
    List<List<int>>? current,
  })  : size = mode.size,
        boxRows = mode.boxRows,
        boxCols = mode.boxCols,
        cells = List.generate(
          mode.size,
          (r) => List.generate(
            mode.size,
            (c) {
              final given = puzzle[r][c] != 0;
              final value = current != null ? current[r][c] : puzzle[r][c];
              return SudokuCell(
                value: value,
                isGiven: given,
              );
            },
          ),
        ),
        solution = solution ??
            List.generate(mode.size, (_) => List.filled(mode.size, 0));

  final SudokuMode mode;
  final int size;
  final int boxRows;
  final int boxCols;
  final List<List<SudokuCell>> cells;
  final List<List<int>> solution;

  /// Original clue grid inferred from given cells.
  List<List<int>> toPuzzleGrid() {
    return List.generate(
      size,
      (r) => List.generate(size, (c) => cells[r][c].isGiven ? cells[r][c].value : 0),
    );
  }

  int get cellCount => size * size;

  SudokuCell cellAt(int row, int col) => cells[row][col];

  bool isValidPlacement(int row, int col, int value) {
    if (value < 1 || value > size) return false;

    for (var c = 0; c < size; c++) {
      if (c != col && cells[row][c].value == value) return false;
    }
    for (var r = 0; r < size; r++) {
      if (r != row && cells[r][col].value == value) return false;
    }

    final startRow = (row ~/ boxRows) * boxRows;
    final startCol = (col ~/ boxCols) * boxCols;
    for (var r = startRow; r < startRow + boxRows; r++) {
      for (var c = startCol; c < startCol + boxCols; c++) {
        if ((r != row || c != col) && cells[r][c].value == value) {
          return false;
        }
      }
    }
    return true;
  }

  /// Returns all (row, col) pairs that conflict with another same value
  /// in the same row, column, or block.
  Set<(int, int)> findConflicts() {
    final conflicts = <(int, int)>{};

    void markDuplicates(List<(int, int)> positions) {
      final byValue = <int, List<(int, int)>>{};
      for (final pos in positions) {
        final v = cells[pos.$1][pos.$2].value;
        if (v == 0) continue;
        byValue.putIfAbsent(v, () => []).add(pos);
      }
      for (final list in byValue.values) {
        if (list.length > 1) {
          conflicts.addAll(list);
        }
      }
    }

    for (var r = 0; r < size; r++) {
      markDuplicates([for (var c = 0; c < size; c++) (r, c)]);
    }
    for (var c = 0; c < size; c++) {
      markDuplicates([for (var r = 0; r < size; r++) (r, c)]);
    }

    for (var br = 0; br < size; br += boxRows) {
      for (var bc = 0; bc < size; bc += boxCols) {
        final positions = <(int, int)>[];
        for (var r = br; r < br + boxRows; r++) {
          for (var c = bc; c < bc + boxCols; c++) {
            positions.add((r, c));
          }
        }
        markDuplicates(positions);
      }
    }

    return conflicts;
  }

  bool get isComplete {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (cells[r][c].value == 0) return false;
      }
    }
    return findConflicts().isEmpty;
  }

  bool matchesSolution() {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (cells[r][c].value != solution[r][c]) return false;
      }
    }
    return true;
  }

  /// Cells that differ from the known unique solution (filled wrong).
  Set<(int, int)> findWrongValues() {
    final wrong = <(int, int)>{};
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final v = cells[r][c].value;
        if (v != 0 && v != solution[r][c]) {
          wrong.add((r, c));
        }
      }
    }
    return wrong;
  }

  List<List<int>> toValueGrid() {
    return List.generate(
      size,
      (r) => List.generate(size, (c) => cells[r][c].value),
    );
  }

  static List<List<int>> emptyGrid(int size) =>
      List.generate(size, (_) => List.filled(size, 0));

  static List<List<int>> cloneGrid(List<List<int>> grid) =>
      List.generate(grid.length, (r) => List<int>.from(grid[r]));
}

/// Backtracking solver used for generation and uniqueness checks.
class SudokuSolver {
  SudokuSolver(this.mode)
      : size = mode.size,
        boxRows = mode.boxRows,
        boxCols = mode.boxCols;

  final SudokuMode mode;
  final int size;
  final int boxRows;
  final int boxCols;
  final _rng = Random();

  bool canPlace(List<List<int>> grid, int row, int col, int value) {
    for (var c = 0; c < size; c++) {
      if (grid[row][c] == value) return false;
    }
    for (var r = 0; r < size; r++) {
      if (grid[r][col] == value) return false;
    }
    final startRow = (row ~/ boxRows) * boxRows;
    final startCol = (col ~/ boxCols) * boxCols;
    for (var r = startRow; r < startRow + boxRows; r++) {
      for (var c = startCol; c < startCol + boxCols; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  (int, int)? _findEmpty(List<List<int>> grid) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] == 0) return (r, c);
      }
    }
    return null;
  }

  /// Fills [grid] in place. Returns true if a solution was found.
  bool solve(List<List<int>> grid, {bool shuffleCandidates = false}) {
    final empty = _findEmpty(grid);
    if (empty == null) return true;

    final (row, col) = empty;
    final candidates = List<int>.generate(size, (i) => i + 1);
    if (shuffleCandidates) {
      candidates.shuffle(_rng);
    }

    for (final value in candidates) {
      if (canPlace(grid, row, col, value)) {
        grid[row][col] = value;
        if (solve(grid, shuffleCandidates: shuffleCandidates)) {
          return true;
        }
        grid[row][col] = 0;
      }
    }
    return false;
  }

  /// Counts solutions up to [limit] (typically 2 for uniqueness).
  int countSolutions(List<List<int>> grid, {int limit = 2}) {
    final work = SudokuBoard.cloneGrid(grid);
    var count = 0;

    bool search() {
      if (count >= limit) return true;
      final empty = _findEmpty(work);
      if (empty == null) {
        count++;
        return count >= limit;
      }
      final (row, col) = empty;
      for (var value = 1; value <= size; value++) {
        if (canPlace(work, row, col, value)) {
          work[row][col] = value;
          if (search()) return true;
          work[row][col] = 0;
        }
      }
      return false;
    }

    search();
    return count;
  }

  /// Generates a complete valid filled board.
  List<List<int>> generateFilled() {
    final grid = SudokuBoard.emptyGrid(size);
    final ok = solve(grid, shuffleCandidates: true);
    if (!ok) {
      throw StateError('Failed to generate a filled Sudoku board');
    }
    return grid;
  }
}

/// Creates puzzles with a unique solution and difficulty-based clue counts.
class SudokuGenerator {
  SudokuGenerator(this.mode) : _solver = SudokuSolver(mode);

  final SudokuMode mode;
  final SudokuSolver _solver;
  final _rng = Random();

  int get size => mode.size;

  /// Returns (puzzle, solution) where puzzle has 0 for empty cells.
  (List<List<int>>, List<List<int>>) generate(Difficulty difficulty) {
    final solution = _solver.generateFilled();
    final puzzle = SudokuBoard.cloneGrid(solution);

    final total = size * size;
    final targetClues = _targetClueCount(difficulty, total);
    final minClues = (total * difficulty.clueRatioMin).round();

    final positions = <(int, int)>[
      for (var r = 0; r < size; r++)
        for (var c = 0; c < size; c++) (r, c),
    ]..shuffle(_rng);

    // Cap uniqueness attempts so 12x12 stays responsive on slower PCs.
    final maxAttempts = size <= 9 ? positions.length : 90;
    var attempts = 0;

    for (final (r, c) in positions) {
      if (_countClues(puzzle) <= targetClues) break;
      if (attempts >= maxAttempts) break;
      attempts++;

      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      // Keep uniqueness: only allow removal if exactly one solution remains.
      if (_solver.countSolutions(puzzle, limit: 2) != 1) {
        puzzle[r][c] = backup;
      }
    }

    // Optional second pass toward the difficulty floor (still uniqueness-safe).
    if (_countClues(puzzle) > (total * difficulty.clueRatioMax).round()) {
      positions.shuffle(_rng);
      var extra = 0;
      final extraLimit = size <= 9 ? 40 : 25;
      for (final (r, c) in positions) {
        if (_countClues(puzzle) <= minClues) break;
        if (extra >= extraLimit) break;
        if (puzzle[r][c] == 0) continue;
        extra++;
        final backup = puzzle[r][c];
        puzzle[r][c] = 0;
        if (_solver.countSolutions(puzzle, limit: 2) != 1) {
          puzzle[r][c] = backup;
        }
      }
    }

    return (puzzle, solution);
  }

  int _targetClueCount(Difficulty difficulty, int total) {
    final min = (total * difficulty.clueRatioMin).round();
    final max = (total * difficulty.clueRatioMax).round();
    if (max <= min) return min;
    return min + _rng.nextInt(max - min + 1);
  }

  int _countClues(List<List<int>> puzzle) {
    var n = 0;
    for (final row in puzzle) {
      for (final v in row) {
        if (v != 0) n++;
      }
    }
    return n;
  }
}
