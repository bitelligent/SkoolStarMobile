import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Horizontal strip of day cards (14 days around the anchor). The selected
/// day gets the primary gradient background; the rest are muted. Used at
/// the top of the Schedule screen.
class DateStrip extends StatefulWidget {
  const DateStrip({
    required this.anchor,
    required this.selected,
    required this.onSelect,
    this.span = 21,
    super.key,
  });

  final DateTime anchor;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final int span;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    if (!_controller.hasClients) return;
    final list = _days();
    final target = widget.selected ?? widget.anchor;
    final i = list.indexWhere((d) => _same(d, target));
    if (i < 0) return;
    final offset = (i * 64.0 - 120).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.jumpTo(offset);
  }

  @override
  void didUpdateWidget(covariant DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<DateTime> _days() {
    final start = DateTime(widget.anchor.year, widget.anchor.month, widget.anchor.day)
        .subtract(const Duration(days: 7));
    return List.generate(widget.span, (i) => start.add(Duration(days: i)));
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _days();
    final today = DateTime.now();
    return SizedBox(
      height: 76,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = days[i];
          final isSelected = widget.selected != null && _same(d, widget.selected!);
          final isToday = _same(d, today);
          return _DayPill(
            date: d,
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => widget.onSelect(d),
          );
        },
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primary : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isToday ? AppColors.primary : AppColors.border),
          ),
          boxShadow: isSelected ? AppShadows.glow(AppColors.primary) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date).toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.88)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: AppTextStyles.titleLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
