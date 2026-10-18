import 'package:flutter_test/flutter_test.dart';
import 'package:mama_sudoku/engine/sudoku_engine.dart';
import 'package:mama_sudoku/models/game_config.dart';

void main() {
  group('SudokuGenerator', () {
    test('9x9 easy puzzle has unique solution', () {
      final generator = SudokuGenerator(SudokuMode.classic9);
      final (puzzle, solution) = generator.generate(Difficulty.easy);
      final solver = SudokuSolver(SudokuMode.classic9);

      expect(solver.countSolutions(puzzle, limit: 2), 1);

      final work = SudokuBoard.cloneGrid(puzzle);
      expect(solver.solve(work), isTrue);
      expect(work, solution);

      final clues = puzzle.expand((r) => r).where((v) => v != 0).length;
      expect(clues, greaterThanOrEqualTo(24));
      expect(clues, lessThanOrEqualTo(55));
    });

    test('12x12 medium puzzle has unique solution', () {
      final generator = SudokuGenerator(SudokuMode.large12);
      final (puzzle, solution) = generator.generate(Difficulty.medium);
      final solver = SudokuSolver(SudokuMode.large12);

      expect(solver.countSolutions(puzzle, limit: 2), 1);
      expect(solution.length, 12);
      expect(solution.first.length, 12);

      final clues = puzzle.expand((r) => r).where((v) => v != 0).length;
      expect(clues, greaterThan(0));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('SudokuBoard conflicts', () {
    test('detects row duplicates', () {
      final puzzle = List.generate(9, (_) => List.filled(9, 0));
      puzzle[0][0] = 5;
      puzzle[0][3] = 5;
      final board = SudokuBoard(
        mode: SudokuMode.classic9,
        puzzle: puzzle,
        solution: List.generate(9, (_) => List.filled(9, 0)),
      );
      final conflicts = board.findConflicts();
      expect(conflicts.contains((0, 0)), isTrue);
      expect(conflicts.contains((0, 3)), isTrue);
    });
  });
}
