import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/favorites_service.dart';
import 'services/locale_service.dart';
import 'services/stats_service.dart';
import 'services/theme_service.dart';
import 'state/game_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final stats = await StatsService.create();
  final locale = await LocaleService.create();
  final favorites = await FavoritesService.create();
  final theme = await ThemeService.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatsService>.value(value: stats),
        ChangeNotifierProvider<LocaleService>.value(value: locale),
        ChangeNotifierProvider<FavoritesService>.value(value: favorites),
        ChangeNotifierProvider<ThemeService>.value(value: theme),
        ChangeNotifierProvider(
          create: (_) => GameController(stats: stats, favorites: favorites),
        ),
      ],
      child: const MamaSudokuApp(),
    ),
  );
}

class MamaSudokuApp extends StatelessWidget {
  const MamaSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleService>();
    final theme = context.watch<ThemeService>();

    return MaterialApp(
      title: locale.strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.mode,
      home: const HomeScreen(),
    );
  }
}
