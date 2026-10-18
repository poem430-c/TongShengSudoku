import 'package:flutter_test/flutter_test.dart';
import 'package:mama_sudoku/models/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:mama_sudoku/main.dart';
import 'package:mama_sudoku/services/favorites_service.dart';
import 'package:mama_sudoku/services/locale_service.dart';
import 'package:mama_sudoku/services/stats_service.dart';
import 'package:mama_sudoku/state/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home screen shows Mama brand and start button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final stats = await StatsService.create();
    final locale = await LocaleService.create();
    final favorites = await FavoritesService.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StatsService>.value(value: stats),
          ChangeNotifierProvider<LocaleService>.value(value: locale),
          ChangeNotifierProvider<FavoritesService>.value(value: favorites),
          ChangeNotifierProvider(
            create: (_) =>
                GameController(stats: stats, favorites: favorites),
          ),
        ],
        child: const MamaSudokuApp(),
      ),
    );

    expect(find.text("Mama's Sudoku"), findsOneWidget);
    expect(find.text('Start Puzzle'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text(SudokuMode.classic9.label), findsWidgets);
    expect(find.text('Wins'), findsOneWidget);
  });
}
