import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game_config.dart';
import '../models/saved_puzzle.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../state/game_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/game_info_bar.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/win_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    this.savedPuzzle,
  });

  final SudokuMode mode;
  final Difficulty difficulty;
  final SavedPuzzle? savedPuzzle;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _winDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameController>();
      final saved = widget.savedPuzzle;
      if (saved != null) {
        game.loadSavedGame(saved);
      } else {
        game.startNewGame(widget.mode, widget.difficulty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final t = context.watch<LocaleService>().strings;

    if (game.hasWon && !_winDialogShown && game.lastWinCount != null) {
      _winDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showWinDialog(
          context: context,
          mode: widget.mode,
          difficulty: widget.difficulty,
          winCount: game.lastWinCount!,
          onPlayAgain: () {
            _winDialogShown = false;
            game.startNewGame(widget.mode, widget.difficulty);
          },
          onHome: () => Navigator.of(context).pop(),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.mode.label} · ${t.difficultyLabel(widget.difficulty)}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: t.back,
        ),
        actions: [
          IconButton(
            icon: Icon(
              game.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 26,
              color: game.isFavorite ? AppColors.of(context).warm : null,
            ),
            tooltip: t.favorite,
            onPressed: game.isGenerating
                ? null
                : () async {
                    final wasFavorite = game.isFavorite;
                    await game.toggleFavorite();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasFavorite ? t.favoriteRemoved : t.favoriteSaved,
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 24),
            tooltip: t.sharePuzzle,
            onPressed: game.isGenerating || game.board == null
                ? null
                : () => _sharePuzzle(context, game),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 26),
            tooltip: t.theme,
            onPressed: () => _showThemeInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 26),
            tooltip: t.settings,
            onPressed: () => _showSettings(context, game),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 28),
            tooltip: t.newPuzzle,
            onPressed: game.isGenerating
                ? null
                : () {
                    _winDialogShown = false;
                    game.startNewGame(widget.mode, widget.difficulty);
                  },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: game.isGenerating || game.board == null
            ? _LoadingView(message: t.preparing)
            : _PlayView(game: game),
      ),
    );
  }

  void _sharePuzzle(BuildContext context, GameController game) {
    final t = context.read<LocaleService>().strings;
    final text = game.puzzleShareText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.puzzleCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showThemeInfo(BuildContext context) {
    final t = context.read<LocaleService>().strings;
    final theme = context.read<ThemeService>();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.themeInfo),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.light_mode_rounded),
                title: Text(t.themeLight),
                trailing: theme.mode == ThemeMode.light
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () async {
                  await theme.setMode(ThemeMode.light);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode_rounded),
                title: Text(t.themeDark),
                trailing: theme.mode == ThemeMode.dark
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () async {
                  await theme.setMode(ThemeMode.dark);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.close),
            ),
          ],
        );
      },
    );
  }

  void _showSettings(BuildContext context, GameController game) {
    final t = context.read<LocaleService>().strings;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.gameSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.highlightSameNumbers),
              value: game.highlightSameNumbers,
              onChanged: (_) {
                game.toggleHighlightSameNumbers();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.close),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayView extends StatelessWidget {
  const _PlayView({required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    final board = game.board!;
    final t = context.watch<LocaleService>().strings;
    final colors = AppColors.of(context);

    return Column(
      children: [
        GameInfoBar(
          errorCount: game.errorCount,
          score: game.score,
          difficultyLabel: t.difficultyLabel(game.difficulty!),
          elapsedSeconds: game.elapsedSeconds,
          isPaused: game.isPaused,
          onTogglePause: game.togglePause,
          errorsLabel: t.errors,
          scoreLabel: t.score,
          timeLabel: t.time,
        ),
        if (game.isPaused)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: colors.highlight,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.pause_circle_outline, color: colors.inkSoft),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.paused,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (game.showCheckFeedback && game.checkMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: game.conflicts.isEmpty
                  ? colors.accentSoft
                  : colors.errorBg,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      game.conflicts.isEmpty
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: game.conflicts.isEmpty
                          ? colors.accent
                          : colors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        game.checkMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: game.conflicts.isEmpty
                              ? colors.accent
                              : colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SudokuGrid(
              board: board,
              selectedRow: game.selectedRow,
              selectedCol: game.selectedCol,
              conflicts: game.conflicts,
              wrongCells: game.wrongCells,
              highlightedNumber: game.highlightedNumber,
              highlightSameNumbers: game.highlightSameNumbers,
              onCellTap: game.selectCell,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: NumberPad(
              maxNumber: board.size,
              notesMode: game.notesMode,
              remainingForNumber: game.remainingForNumber,
              onNumber: (n) {
                game.selectNumber(n);
                if (game.hasSelection) {
                  game.inputNumber(n);
                }
              },
              onErase: game.erase,
              onToggleNotes: game.toggleNotesMode,
              onUndo: game.undo,
              onHint: () {
                final used = game.useHint();
                if (!used && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.noHints),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              canUndo: game.canUndo,
              hintsRemaining: game.hintsRemaining,
              highlightSameNumbers: game.highlightSameNumbers,
              onToggleHighlight: game.toggleHighlightSameNumbers,
              undoLabel: t.undo,
              eraseLabel: t.erase,
              notesLabel: t.notes,
              notesOnLabel: t.notesOn,
              hintLabel: t.hint,
              highlightSameLabel: t.highlightSame,
            ),
          ),
        ),
      ],
    );
  }
}
