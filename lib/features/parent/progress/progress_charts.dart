import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

/// Colour for a percentage band (shared by every progress visual).
Color bandColor(int? percent) => switch (StatBand.of(percent)) {
  StatBand.good => AppColors.success,
  StatBand.fair => AppColors.warning,
  StatBand.poor => AppColors.danger,
  StatBand.none => AppColors.textTertiary,
};

/// Last weeks as bars (0-100 %). Weeks with nothing to measure are shown as
/// an empty slot, not as a zero.
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({required this.values, required this.starts, super.key});

  /// Percent per week, `null` = no data. Oldest first.
  final List<int?> values;
  final List<DateTime> starts;

  @override
  Widget build(BuildContext context) {
    final label = [
      for (var i = 0; i < values.length; i++)
        '${DateFormat('MMM d').format(starts[i])}: '
            '${values[i] == null ? 'no data' : '${values[i]} percent'}',
    ].join(', ');
    return Semantics(
      label: 'Weekly trend. $label',
      excludeSemantics: true,
      child: SizedBox(
        height: 150,
        child: CustomPaint(
          size: Size.infinite,
          painter: _BarsPainter(
            values: values,
            starts: starts,
            emptyColor: AppColors.border,
            textColor: AppColors.textSecondary,
            mutedColor: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.starts,
    required this.emptyColor,
    required this.textColor,
    required this.mutedColor,
  });

  final List<int?> values;
  final List<DateTime> starts;
  final Color emptyColor;
  final Color textColor;
  final Color mutedColor;

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 18.0;
    const valueH = 16.0;
    final chartH = size.height - labelH - valueH;
    final n = values.length;
    if (n == 0) return;
    final slot = size.width / n;
    final barW = (slot * 0.52).clamp(8.0, 28.0);

    // 100 % guide.
    final guide = Paint()
      ..color = emptyColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(0, valueH),
      Offset(size.width, valueH),
      guide,
    );

    for (var i = 0; i < n; i++) {
      final cx = slot * i + slot / 2;
      final v = values[i];
      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, valueH, barW, chartH),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        track,
        Paint()..color = emptyColor.withValues(alpha: 0.35),
      );
      if (v != null) {
        final h = chartH * v.clamp(0, 100) / 100;
        final bar = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - barW / 2, valueH + chartH - h, barW, h),
          const Radius.circular(6),
        );
        canvas.drawRRect(bar, Paint()..color = bandColor(v));
        _text(
          canvas,
          '$v',
          Offset(cx, valueH + chartH - h - 12),
          textColor,
          10,
        );
      } else {
        _text(canvas, '–', Offset(cx, valueH + chartH / 2), mutedColor, 12);
      }
      _text(
        canvas,
        DateFormat('d MMM').format(starts[i]),
        Offset(cx, size.height - 8),
        mutedColor,
        9.5,
      );
    }
  }

  void _text(Canvas canvas, String s, Offset center, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.values != values || old.starts != starts;
}

/// Horizontal bar per subject (average score).
class SubjectBars extends StatelessWidget {
  const SubjectBars({required this.subjects, super.key});

  final List<SubjectScore> subjects;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final s in subjects)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Semantics(
              label:
                  '${s.subject}, ${s.score.percent} percent, '
                  '${s.score.part} of ${s.score.whole} marks',
              excludeSemantics: true,
              child: Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      s.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: (s.score.percent ?? 0) / 100,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceMuted,
                        color: bandColor(s.score.percent),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${s.score.percent}%',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "▲ 5 pts" / "▼ 8 pts" / "no change" against the previous period.
class TrendChip extends StatelessWidget {
  const TrendChip({required this.delta, super.key});

  final int? delta;

  @override
  Widget build(BuildContext context) {
    final d = delta;
    if (d == null) return const SizedBox.shrink();
    final (icon, color, text) = d > 0
        ? (Icons.arrow_upward_rounded, AppColors.success, '$d pts')
        : d < 0
        ? (Icons.arrow_downward_rounded, AppColors.danger, '${-d} pts')
        : (Icons.remove_rounded, AppColors.textSecondary, 'No change');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// A coloured dot used by the legend of the weekly chart.
class LegendDot extends StatelessWidget {
  const LegendDot({required this.color, required this.label, super.key});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}
