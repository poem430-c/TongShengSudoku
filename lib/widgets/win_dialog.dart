import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_config.dart';
import '../services/locale_service.dart';
import '../theme/app_colors.dart';

Future<void> showWinDialog({
  required BuildContext context,
  required SudokuMode mode,
  required Difficulty difficulty,
  required int winCount,
  required VoidCallback onPlayAgain,
  required VoidCallback onHome,
}) {
  final t = context.read<LocaleService>().strings;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final colors = AppColors.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [colors.trophyBg, colors.surface]
                  : const [Color(0xFFFFF8E7), Colors.white],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: colors.trophyBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6A817).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 48,
                  color: Color(0xFFE6A817),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.wonderful,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                t.solvedMessage(mode, difficulty),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.inkSoft,
                    ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.trophyBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE6A817).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        color: Color(0xFFC45C26), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '${t.winsCount}  $winCount',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPlayAgain();
                  },
                  child: Text(t.playAgain),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHome();
                  },
                  child: Text(t.home),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
