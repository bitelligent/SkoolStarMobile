import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

/// Compact month calendar used by the Dashboard's Month view. Each day cell
/// shows a coloured dot when it has sessions and highlights today.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.focus,
    required this.sessions,
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onDayTap,
    super.key,
  });

  final DateTime focus;
  final DateTime? selectedDate;
  final List<Session> sessions;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onDayTap;

  List<DateTime> _daysForGrid() {
    final first = DateTime(focus.year, focus.month, 1);
    final weekdayMon0 = (first.weekday + 6) % 7;
    final start = first.subtract(Duration(days: weekdayMon0));
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  int _countOn(DateTime d) => sessions
      .where(
        (s) =>
            s.date.year == d.year &&
            s.date.month == d.month &&
            s.date.day == d.day,
      )
      .length;

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _daysForGrid();
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          children: [
            _NavCircle(icon: Icons.chevron_left_rounded, onTap: onPrev),
            Expanded(
              child: GestureDetector(
                onTap: onToday,
                child: Text(
                  DateFormat('MMMM y').format(focus),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _NavCircle(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: weekdays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: days.length,
          itemBuilder: (context, i) {
            final d = days[i];
            final inMonth = d.month == focus.month;
            final isToday = _same(d, DateTime.now());
            final isSelected = selectedDate != null && _same(d, selectedDate!);
            final count = _countOn(d);

            return _DayCell(
              day: d.day,
              inMonth: inMonth,
              isToday: isToday,
              isSelected: isSelected,
              count: count,
              onTap: () => onDayTap(d),
            );
          },
        ),
      ],
    );
  }
}

class _NavCircle extends StatelessWidget {
  const _NavCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  final int day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSchedule = count > 0 && inMonth;

    // Precedence: selected > today > hasSchedule > off-month > default.
    // The coloured background is now the only "has sessions" indicator —
    // no dot — so each state uses a distinct fill/border combo:
    //
    //   • Selected       → solid primary, white text
    //   • Today + busy   → primaryLight (slightly stronger tint) + ring
    //   • Today          → ring only, no fill
    //   • Busy day       → primarySoft fill
    //   • Off-month      → faded text
    //   • Default        → transparent

    final Color bg;
    final Color textColor;
    final Color? borderColor;
    final FontWeight weight;

    if (isSelected) {
      bg = AppColors.primary;
      textColor = Colors.white;
      borderColor = null;
      weight = FontWeight.w800;
    } else if (isToday) {
      bg = hasSchedule ? AppColors.primaryLight : Colors.transparent;
      textColor = AppColors.primary;
      borderColor = AppColors.primary;
      weight = FontWeight.w800;
    } else if (hasSchedule) {
      bg = AppColors.primarySoft;
      textColor = AppColors.primary;
      borderColor = null;
      weight = FontWeight.w700;
    } else {
      bg = Colors.transparent;
      textColor =
          inMonth ? AppColors.textPrimary : AppColors.textTertiary;
      borderColor = null;
      weight = FontWeight.w500;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Text(
          '$day',
          style: AppTextStyles.labelMedium.copyWith(
            color: textColor,
            fontWeight: weight,
          ),
        ),
      ),
    );
  }
}
