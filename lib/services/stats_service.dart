import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_config.dart';

/// Persists win counts per mode × difficulty using shared_preferences.
class StatsService extends ChangeNotifier {
  StatsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StatsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StatsService(prefs);
  }

  String _key(SudokuMode mode, Difficulty difficulty) =>
      'wins_${mode.shortLabel}_${difficulty.name}';

  int getWins(SudokuMode mode, Difficulty difficulty) =>
      _prefs.getInt(_key(mode, difficulty)) ?? 0;

  Future<int> recordWin(SudokuMode mode, Difficulty difficulty) async {
    final next = getWins(mode, difficulty) + 1;
    await _prefs.setInt(_key(mode, difficulty), next);
    notifyListeners();
    return next;
  }

  String mamaLabel(SudokuMode mode, Difficulty difficulty) =>
      "Mama's ${mode.shortLabel} ${difficulty.label} Wins";

  Map<String, int> allWins() {
    final map = <String, int>{};
    for (final mode in SudokuMode.values) {
      for (final diff in Difficulty.values) {
        map[mamaLabel(mode, diff)] = getWins(mode, diff);
      }
    }
    return map;
  }

  int get totalWins {
    var sum = 0;
    for (final mode in SudokuMode.values) {
      for (final diff in Difficulty.values) {
        sum += getWins(mode, diff);
      }
    }
    return sum;
  }
}
