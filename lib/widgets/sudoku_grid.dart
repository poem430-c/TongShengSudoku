import 'package:flutter/material.dart';

import '../engine/sudoku_engine.dart';
import '../theme/app_colors.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({
    super.key,
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.conflicts,
    required this.wrongCells,
    required this.onCellTap,
    this.highlightedNumber,
    this.highlightSameNumbers = true,
  });

  final SudokuBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final Set<(int, int)> conflicts;
  final Set<(int, int)> wrongCells;
  final void Function(int row, int col) onCellTap;
  final int? highlightedNumber;
  final bool highlightSameNumbers;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final size = board.size;
    final selectedValue = (selectedRow != null && selectedCol != null)
        ? board.cellAt(selectedRow!, selectedCol!).value
        : 0;
    final highlightValue = selectedValue != 0
        ? selectedValue
        : (highlightSameNumbers ? highlightedNumber : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.gridBold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: CustomPaint(
                painter: _GridLinesPainter(
                  size: size,
                  boxRows: board.boxRows,
                  boxCols: board.boxCols,
                  gridLine: colors.gridLine,
                  gridBold: colors.gridBold,
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size,
                  ),
                  itemCount: size * size,
                  itemBuilder: (context, index) {
                    final row = index ~/ size;
                    final col = index % size;
                    final cell = board.cellAt(row, col);
                    final isSelected =
                        selectedRow == row && selectedCol == col;
                    final inLine = selectedRow == row || selectedCol == col;
                    final sameNumber = highlightValue != null &&
                        highlightValue != 0 &&
                        cell.value == highlightValue &&
                        !isSelected;
                    final hasConflict = conflicts.contains((row, col));
                    final isWrong = wrongCells.contains((row, col));
                    final hasError = hasConflict || isWrong;

                    Color bg = Colors.transparent;
                    if (hasError) {
                      bg = colors.errorBg;
                    } else if (isSelected) {
                      bg = colors.selected;
                    } else if (sameNumber) {
                      bg = colors.sameNumber;
                    } else if (inLine) {
                      bg = colors.highlight;
                    }

                    return Material(
                      color: bg,
                      child: InkWell(
                        onTap: () => onCellTap(row, col),
                        child: Center(
                          child: cell.value != 0
                              ? Text(
                                  '${cell.value}',
                                  style: TextStyle(
                                    fontSize: size <= 9 ? 26 : 18,
                                    fontWeight: FontWeight.w800,
                                    color: hasError
                                        ? colors.error
                                        : (cell.isGiven
                                            ? colors.given
                                            : colors.user),
                                    height: 1,
                                  ),
                                )
                              : _NotesView(
                                  notes: cell.notes,
                                  maxNumber: size,
                                  compact: size > 9,
                                  noteColor: colors.inkSoft,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView({
    required this.notes,
    required this.maxNumber,
    required this.compact,
    required this.noteColor,
  });

  final Set<int> notes;
  final int maxNumber;
  final bool compact;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final cols = maxNumber <= 9 ? 3 : 4;
    final rows = (maxNumber / cols).ceil();

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: List.generate(rows, (r) {
          return Expanded(
            child: Row(
              children: List.generate(cols, (c) {
                final n = r * cols + c + 1;
                if (n > maxNumber) {
                  return const Expanded(child: SizedBox.shrink());
                }
                return Expanded(
                  child: Center(
                    child: Text(
                      notes.contains(n) ? '$n' : '',
                      style: TextStyle(
                        fontSize: compact ? 7 : 9,
                        fontWeight: FontWeight.w700,
                        color: noteColor,
                        height: 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  _GridLinesPainter({
    required this.size,
    required this.boxRows,
    required this.boxCols,
    required this.gridLine,
    required this.gridBold,
  });

  final int size;
  final int boxRows;
  final int boxCols;
  final Color gridLine;
  final Color gridBold;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final thin = Paint()
      ..color = gridLine
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = gridBold
      ..strokeWidth = 2.5;

    final cellW = canvasSize.width / size;
    final cellH = canvasSize.height / size;

    for (var i = 1; i < size; i++) {
      final paint = (i % boxCols == 0) ? thick : thin;
      final x = cellW * i;
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), paint);
    }
    for (var i = 1; i < size; i++) {
      final paint = (i % boxRows == 0) ? thick : thin;
      final y = cellH * i;
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.boxRows != boxRows ||
      oldDelegate.boxCols != boxCols ||
      oldDelegate.gridLine != gridLine ||
      oldDelegate.gridBold != gridBold;
}
