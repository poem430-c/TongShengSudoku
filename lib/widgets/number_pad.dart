import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.maxNumber,
    required this.notesMode,
    required this.remainingForNumber,
    required this.onNumber,
    required this.onErase,
    required this.onToggleNotes,
    required this.onUndo,
    required this.onHint,
    required this.canUndo,
    required this.hintsRemaining,
    required this.highlightSameNumbers,
    required this.onToggleHighlight,
    required this.undoLabel,
    required this.eraseLabel,
    required this.notesLabel,
    required this.notesOnLabel,
    required this.hintLabel,
    required this.highlightSameLabel,
  });

  final int maxNumber;
  final bool notesMode;
  final int Function(int number) remainingForNumber;
  final ValueChanged<int> onNumber;
  final VoidCallback onErase;
  final VoidCallback onToggleNotes;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final bool canUndo;
  final int hintsRemaining;
  final bool highlightSameNumbers;
  final VoidCallback onToggleHighlight;
  final String undoLabel;
  final String eraseLabel;
  final String notesLabel;
  final String notesOnLabel;
  final String hintLabel;
  final String highlightSameLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cols = maxNumber <= 9 ? 5 : 6;
    final visibleNumbers = [
      for (var n = 1; n <= maxNumber; n++)
        if (remainingForNumber(n) > 0) n,
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              highlightSameLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.inkSoft,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: highlightSameNumbers,
              onChanged: (_) => onToggleHighlight(),
              activeThumbColor: colors.accent,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _ToolButton(
                label: undoLabel,
                icon: Icons.undo_rounded,
                onTap: canUndo ? onUndo : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToolButton(
                label: eraseLabel,
                icon: Icons.backspace_outlined,
                onTap: onErase,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToolButton(
                label: notesMode ? notesOnLabel : notesLabel,
                icon: Icons.edit_note_rounded,
                active: notesMode,
                onTap: onToggleNotes,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToolButton(
                label: hintLabel,
                icon: Icons.lightbulb_outline_rounded,
                badge: hintsRemaining > 0 ? '$hintsRemaining' : null,
                onTap: hintsRemaining > 0 ? onHint : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
          ),
          itemCount: visibleNumbers.length,
          itemBuilder: (context, index) {
            final n = visibleNumbers[index];
            final remaining = remainingForNumber(n);
            return Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onNumber(n),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.ink.withValues(alpha: 0.15),
                      width: 2,
                    ),
                    color: notesMode ? colors.accentSoft : colors.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$n',
                        style: TextStyle(
                          fontSize: maxNumber <= 9 ? 28 : 22,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.inkSoft,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.badge,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enabled = onTap != null;
    final bg = active ? colors.accentSoft : colors.surface;
    final fg = enabled ? colors.ink : colors.inkSoft;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.ink.withValues(alpha: enabled ? 0.15 : 0.08),
              width: 2,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 4,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? colors.bg
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
