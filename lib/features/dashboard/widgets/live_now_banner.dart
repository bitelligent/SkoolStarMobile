import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_gradient_hero.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

/// Hero banner for an in-progress session with an animated LIVE NOW
/// indicator (sonar-style expanding ripples around a glowing dot, plus a
/// subtle breathing scale on the pill), the session summary, and the
/// "Open live class" CTA.
class LiveNowBanner extends StatelessWidget {
  const LiveNowBanner({
    required this.session,
    required this.subjects,
    required this.classes,
    required this.onOpen,
    super.key,
  });

  final Session session;
  final List<Subject> subjects;
  final List<ClassGroup> classes;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final subjectNames = subjects
        .where((s) => session.subjectIds.contains(s.id))
        .map((s) => s.name)
        .join(', ');
    final classNames = classes
        .where((c) => session.classIds.contains(c.id))
        .map((c) => c.name)
        .join(' · ');

    return AppGradientHero(
      gradient: AppGradients.live,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _LivePill(),
              const Spacer(),
              Text(
                '${session.startTime} – ${session.endTime}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            subjectNames,
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            classNames,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _OpenLiveButton(onTap: onOpen)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated "LIVE NOW" chip:
///   • two staggered expanding rings around the dot (radar/sonar effect)
///   • a solid green core with a soft glow
///   • subtle breathing scale on the whole pill
class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with TickerProviderStateMixin {
  static const Color _liveGreen = Color(0xFF34D399);

  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ripple.dispose();
    _breathe.dispose();
    super.dispose();
  }

  /// Builds a single ripple ring at [phase] 0..1 (0 = small/opaque,
  /// 1 = big/transparent). Centered inside the dot's SizedBox.
  Widget _ring(double phase) {
    final scale = 0.4 + phase * 1.3; // 0.4x → 1.7x
    final opacity = ((1 - phase) * 0.6).clamp(0.0, 1.0);
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _liveGreen.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ripple, _breathe]),
      builder: (_, __) {
        final t = _ripple.value;
        final scale = 1.0 + 0.04 * _breathe.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _ring(t),
                      _ring((t + 0.5) % 1),
                      // Core dot with glow
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _liveGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _liveGreen.withOpacity(0.7),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE NOW',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OpenLiveButton extends StatelessWidget {
  const _OpenLiveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md - 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.accentPurple,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Open live class',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.accentPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
