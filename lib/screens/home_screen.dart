import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/game_config.dart';
import '../models/saved_puzzle.dart';
import '../services/favorites_service.dart';
import '../services/locale_service.dart';
import '../services/stats_service.dart';
import '../state/game_controller.dart';
import '../theme/app_colors.dart';
import '../services/theme_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SudokuMode _mode = SudokuMode.classic9;
  Difficulty _difficulty = Difficulty.easy;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final locale = context.watch<LocaleService>();
    final favorites = context.watch<FavoritesService>();
    final theme = context.watch<ThemeService>();
    final colors = AppColors.of(context);
    final t = locale.strings;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.heroTop, colors.bg, colors.heroBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(locale: locale, theme: theme, strings: t),
                      const SizedBox(height: 8),
                      _AppHero(title: t.appName, subtitle: t.tagline),
                      const SizedBox(height: 28),
                      _SectionLabel(text: t.chooseBoard),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final mode in SudokuMode.values) ...[
                            if (mode != SudokuMode.values.first)
                              const SizedBox(width: 12),
                            Expanded(
                              child: _ChoiceCard(
                                title: mode.label,
                                subtitle: t.modeDescription(mode),
                                icon: mode == SudokuMode.classic9
                                    ? Icons.grid_3x3_rounded
                                    : Icons.grid_on_rounded,
                                selected: _mode == mode,
                                onTap: () => setState(() => _mode = mode),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(text: t.chooseDifficulty),
                      const SizedBox(height: 10),
                      for (final d in Difficulty.values) ...[
                        _DifficultyTile(
                          label: t.difficultyLabel(d),
                          hint: t.difficultyHint(d),
                          selected: _difficulty == d,
                          color: switch (d) {
                            Difficulty.easy => colors.accent,
                            Difficulty.medium => colors.user,
                            Difficulty.hard => colors.warm,
                          },
                          onTap: () => setState(() => _difficulty = d),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 62,
                        child: ElevatedButton(
                          onPressed: () => _startGame(context),
                          child: Text(t.startPuzzle),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FavoritesSection(
                        favorites: favorites,
                        strings: t,
                        onOpen: (saved) => _openSaved(context, saved),
                        onRemove: (id) => favorites.remove(id),
                      ),
                      const SizedBox(height: 28),
                      _WinsSection(stats: stats, strings: t),
                      const SizedBox(height: 20),
                      Text(
                        t.builtWith,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink.withValues(alpha: 0.35),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startGame(BuildContext context) async {
    final game = context.read<GameController>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          mode: _mode,
          difficulty: _difficulty,
        ),
      ),
    );
    if (mounted) setState(() {});
    game.clearCheckFeedback();
  }

  Future<void> _openSaved(BuildContext context, SavedPuzzle saved) async {
    final game = context.read<GameController>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          mode: saved.mode,
          difficulty: saved.difficulty,
          savedPuzzle: saved,
        ),
      ),
    );
    if (mounted) setState(() {});
    game.clearCheckFeedback();
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection({
    required this.favorites,
    required this.strings,
    required this.onOpen,
    required this.onRemove,
  });

  final FavoritesService favorites;
  final AppStrings strings;
  final ValueChanged<SavedPuzzle> onOpen;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final items = favorites.items;
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: colors.warm, size: 26),
            const SizedBox(width: 8),
            Text(strings.favorites, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              '${items.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.ink.withValues(alpha: 0.2)),
            ),
            child: Text(
              strings.favoritesEmpty,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.inkSoft,
              ),
            ),
          )
        else
          for (final item in items) ...[
            _FavoriteTile(
              item: item,
              strings: strings,
              onOpen: () => onOpen(item),
              onRemove: () => onRemove(item.id),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.item,
    required this.strings,
    required this.onOpen,
    required this.onRemove,
  });

  final SavedPuzzle item;
  final AppStrings strings;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = strings;
    final colors = AppColors.of(context);
    final filled =
        item.current.expand((r) => r).where((v) => v != 0).length;
    final total = item.mode.size * item.mode.size;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.warm.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: colors.warm, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.mode.label} · ${t.difficultyLabel(item.difficulty)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$filled / $total · ${t.continuePuzzle}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: t.removeFavorite,
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: colors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.locale,
    required this.theme,
    required this.strings,
  });

  final LocaleService locale;
  final ThemeService theme;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: strings.theme,
          onPressed: () => theme.toggle(),
          icon: Icon(
            theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colors.ink,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.ink.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangChip(
                label: 'EN',
                selected: locale.language == AppLanguage.english,
                onTap: () => locale.setLanguage(AppLanguage.english),
              ),
              _LangChip(
                label: '繁中',
                selected: locale.language == AppLanguage.traditionalChinese,
                onTap: () => locale.setLanguage(AppLanguage.traditionalChinese),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: selected ? colors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? colors.bg
                      : Colors.white)
                  : colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHero extends StatelessWidget {
  const _AppHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.accent, const Color(0xFF149A6E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.extension_rounded,
            size: 46,
            color: Theme.of(context).brightness == Brightness.dark
                ? colors.bg
                : Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colors.ink,
                fontSize: 36,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.inkSoft,
              ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: selected ? colors.accentSoft : colors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: selected ? 0 : 1,
      shadowColor: colors.ink.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colors.accent
                  : colors.ink.withValues(alpha: 0.2),
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? colors.accent : colors.inkSoft,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: colors.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({
    required this.label,
    required this.hint,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? (isDark ? color.withValues(alpha: 0.22) : color.withValues(alpha: 0.12))
        : colors.surface;
    final border = selected ? color : colors.ink.withValues(alpha: 0.22);
    final hintColor = selected
        ? (isDark ? colors.ink : colors.inkSoft)
        : colors.inkSoft;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: border,
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                    ),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinsSection extends StatelessWidget {
  const _WinsSection({required this.stats, required this.strings});

  final StatsService stats;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFE6A817), size: 28),
            const SizedBox(width: 8),
            Text(strings.wins, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.trophyBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.military_tech_rounded,
                      color: colors.warm, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${strings.total} ${stats.totalWins}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.warm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final mode in SudokuMode.values) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              mode.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.inkSoft,
              ),
            ),
          ),
          Row(
            children: [
              for (final d in Difficulty.values) ...[
                if (d != Difficulty.values.first) const SizedBox(width: 10),
                Expanded(
                  child: _TrophyCard(
                    wins: stats.getWins(mode, d),
                    label: strings.difficultyLabel(d),
                    accent: switch (d) {
                      Difficulty.easy => const Color(0xFF4AD6A3),
                      Difficulty.medium => const Color(0xFF8EC0FF),
                      Difficulty.hard => const Color(0xFFFFB074),
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _TrophyCard extends StatelessWidget {
  const _TrophyCard({
    required this.wins,
    required this.label,
    required this.accent,
  });

  final int wins;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasWins = wins > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: hasWins ? accent.withValues(alpha: 0.16) : colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasWins
              ? accent.withValues(alpha: 0.45)
              : colors.ink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasWins ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
            size: 34,
            color: hasWins ? const Color(0xFFE6A817) : colors.inkSoft,
          ),
          const SizedBox(height: 6),
          Text(
            '$wins',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: hasWins ? accent : colors.inkSoft,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
