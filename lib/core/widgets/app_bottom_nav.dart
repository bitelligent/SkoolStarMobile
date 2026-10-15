import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Edge-to-edge bottom navigation. All three tabs always show icon + label
/// — the only difference between active and inactive is colour + a soft
/// pill highlight behind the active icon (Material 3 NavigationBar style,
/// tuned for our palette).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    this.items = teacherItems,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  static const List<AppNavItem> teacherItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppNavItem(
      label: 'Schedule',
      icon: Icons.event_outlined,
      activeIcon: Icons.event_rounded,
    ),
    AppNavItem(
      label: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<AppNavItem> parentItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppNavItem(
      label: 'Attendance',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
    ),
    AppNavItem(
      label: 'Assignments',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    AppNavItem(
      label: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: AppShadows.cardSoft,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: AppSpacing.sm,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              // Five or more tabs: only the active tab shows its label
              // (icon + label in a pill); the others are icon-only. Labels
              // can then never collide, whatever the screen width.
              if (items.length > 4) {
                return Expanded(
                  flex: active ? 5 : 2,
                  child: _CompactNavButton(
                    item: items[i],
                    active: active,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                );
              }
              return Expanded(
                child: _NavButton(
                  item: items[i],
                  active: active,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 44,
      highlightShape: BoxShape.rectangle,
      child: Semantics(
        button: true,
        selected: active,
        label: item.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 20 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    active ? item.activeIcon : item.icon,
                    key: ValueKey(active),
                    size: 22,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: AppTextStyles.labelSmall.copyWith(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab for bars with five or more items. Inactive tabs are a bare icon; the
/// active tab grows into a pill holding the icon and its label.
class _CompactNavButton extends StatelessWidget {
  const _CompactNavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: onTap,
          radius: 40,
          highlightShape: BoxShape.rectangle,
          // A fixed row height: `Center` alone would fill the (unbounded)
          // height of the bottom bar and push the content off screen.
          child: SizedBox(
            height: 52,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: active ? 10 : 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                // Scales down instead of overflowing on very narrow screens
                // or with large text.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        size: 24,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      if (active) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          maxLines: 1,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
