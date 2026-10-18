import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GameInfoBar extends StatelessWidget {
  const GameInfoBar({
    super.key,
    required this.errorCount,
    required this.score,
    required this.difficultyLabel,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.onTogglePause,
    required this.errorsLabel,
    required this.scoreLabel,
    required this.timeLabel,
  });

  final int errorCount;
  final int score;
  final String difficultyLabel;
  final int elapsedSeconds;
  final bool isPaused;
  final VoidCallback onTogglePause;
  final String errorsLabel;
  final String scoreLabel;
  final String timeLabel;

  String get _formattedTime {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedScore {
    final s = score.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              label: errorsLabel,
              value: '$errorCount',
              align: CrossAxisAlignment.start,
            ),
          ),
          Expanded(
            child: _InfoTile(
              label: scoreLabel,
              value: _formattedScore,
              subtitle: difficultyLabel,
              align: CrossAxisAlignment.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _InfoTile(
                  label: timeLabel,
                  value: _formattedTime,
                  align: CrossAxisAlignment.end,
                ),
                const SizedBox(width: 8),
                Material(
                  color: isPaused ? colors.accentSoft : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onTogglePause,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.ink.withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: colors.ink,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.align,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.inkSoft,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.inkSoft,
            ),
          ),
        ],
      ],
    );
  }
}
