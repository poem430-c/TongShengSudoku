import 'dart:convert';

import 'game_config.dart';

/// A favorite puzzle saved locally so it can be resumed later.
class SavedPuzzle {
  SavedPuzzle({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.puzzle,
    required this.solution,
    required this.current,
    required this.savedAtMs,
    this.elapsedSeconds = 0,
    this.score = 0,
    this.errorCount = 0,
    this.hintsRemaining = 3,
  });

  final String id;
  final SudokuMode mode;
  final Difficulty difficulty;

  /// Original clue grid (0 = empty). Used to mark given cells.
  final List<List<int>> puzzle;

  /// Unique solution.
  final List<List<int>> solution;

  /// Current player progress (includes clues + filled numbers).
  final List<List<int>> current;

  final int savedAtMs;
  final int elapsedSeconds;
  final int score;
  final int errorCount;
  final int hintsRemaining;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.name,
        'difficulty': difficulty.name,
        'puzzle': puzzle,
        'solution': solution,
        'current': current,
        'savedAtMs': savedAtMs,
        'elapsedSeconds': elapsedSeconds,
        'score': score,
        'errorCount': errorCount,
        'hintsRemaining': hintsRemaining,
      };

  factory SavedPuzzle.fromJson(Map<String, dynamic> json) {
    List<List<int>> grid(dynamic raw) => (raw as List)
        .map((row) => (row as List).map((v) => v as int).toList())
        .toList();

    return SavedPuzzle(
      id: json['id'] as String,
      mode: SudokuMode.values.byName(json['mode'] as String),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      puzzle: grid(json['puzzle']),
      solution: grid(json['solution']),
      current: grid(json['current']),
      savedAtMs: json['savedAtMs'] as int? ?? 0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      errorCount: json['errorCount'] as int? ?? 0,
      hintsRemaining: json['hintsRemaining'] as int? ?? 3,
    );
  }

  String encode() => jsonEncode(toJson());

  static SavedPuzzle decode(String raw) =>
      SavedPuzzle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
