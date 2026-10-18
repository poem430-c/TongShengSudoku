import 'package:flutter_test/flutter_test.dart';
import 'package:mama_sudoku/models/game_config.dart';
import 'package:mama_sudoku/services/favorites_service.dart';
import 'package:mama_sudoku/services/stats_service.dart';
import 'package:mama_sudoku/state/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final stats = await StatsService.create();
      final favorites = await FavoritesService.create();
      controller = GameController(stats: stats, favorites: favorites);
    });

    tearDown(() {
      controller.dispose();
    });

    test('counts mistakes without limit', () async {
      await controller.startNewGame(SudokuMode.classic9, Difficulty.easy);
      final board = controller.board!;

      // Find an empty cell and place a wrong value.
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          final cell = board.cellAt(r, c);
          if (cell.isEmpty) {
            controller.selectCell(r, c);
            final wrong = board.solution[r][c] == 1 ? 2 : 1;
            controller.inputNumber(wrong);
            controller.inputNumber(wrong == 1 ? 2 : 1);
            controller.inputNumber(wrong);
            expect(controller.errorCount, greaterThanOrEqualTo(2));
            return;
          }
        }
      }
    });

    test('remaining count decreases for correct placements', () async {
      await controller.startNewGame(SudokuMode.classic9, Difficulty.easy);
      final board = controller.board!;
      final target = board.solution[0][0];

      final before = controller.remainingForNumber(target);
      expect(before, lessThan(9));

      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (board.cellAt(r, c).isEmpty && board.solution[r][c] == target) {
            controller.selectCell(r, c);
            controller.inputNumber(target);
            expect(controller.remainingForNumber(target), before - 1);
            return;
          }
        }
      }
    });

    test('undo keeps mistake count', () async {
      await controller.startNewGame(SudokuMode.classic9, Difficulty.easy);
      final board = controller.board!;

      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          final cell = board.cellAt(r, c);
          if (cell.isEmpty) {
            controller.selectCell(r, c);
            final wrong = board.solution[r][c] == 1 ? 2 : 1;
            controller.inputNumber(wrong);
            expect(controller.errorCount, 1);
            controller.undo();
            expect(controller.errorCount, 1);
            expect(cell.value, 0);
            return;
          }
        }
      }
    });
  });
}
