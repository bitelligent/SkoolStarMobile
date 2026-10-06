import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// A pill tab item.
class AppPillTab {
  const AppPillTab({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Visual palette for [AppPillTabs].
enum AppPillTabsVariant {
  /// Soft muted container, solid-primary active pill. Default.
  light,

  /// Deep-primary container, white active pill with brand-blue icon.
  /// Used for the Session Detail section tabs.
  dark,
}

/// How tab widths are distributed inside the pill.
enum AppPillTabsLayout {
  /// The active tab expands to show icon + label; inactive tabs collapse
  /// to a round icon-only pill. Best for 3+ tabs where labels would
  /// crowd each other.
  expand,

  /// Every tab gets an equal share of the width and always shows icon +
  /// label. Best for 2-3 tabs with short labels (eg. "Month"/"Agenda",
  /// "List"/"Grid").
  equal,
}

/// Modern pill tab bar backed by a [TabController] so it still drives
/// [TabBarView]. Two visual variants and two width layouts cover every
/// case in the app.
class AppPillTabs extends StatefulWidget {
  const AppPillTabs({
    required this.controller,
    required this.items,
    this.variant = AppPillTabsVariant.light,
    this.layout = AppPillTabsLayout.expand,
    this.height = 44,
    this.activeWidthRatio = 0.34,
    this.activeMinWidth = 112,
    this.activeMaxWidth = 160,
    super.key,
  });

  final TabController controller;
  final List<AppPillTab> items;
  final AppPillTabsVariant variant;
  final AppPillTabsLayout layout;
  final double height;

  /// Only used when [layout] is [AppPillTabsLayout.expand]. The active
  /// pill tries to take this fraction of the available width, clamped to
  /// [activeMinWidth] / [activeMaxWidth]; inactive tabs share the rest.
  final double activeWidthRatio;
  final double activeMinWidth;
  final double activeMaxWidth;

  @override
  State<AppPillTabs> createState() => _AppPillTabsState();
}

class _AppPillTabsState extends State<AppPillTabs> {
  late int _current = widget.controller.index;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onIndexChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onIndexChange);
    super.dispose();
  }

  void _onIndexChange() {
    if (!mounted) return;
    final i = widget.controller.index;
    if (_current != i) setState(() => _current = i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _PillTheme.of(widget.variant);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.containerColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: theme.containerShadow,
      ),
      child: SizedBox(
        height: widget.height,
        child: widget.layout == AppPillTabsLayout.equal
            ? _buildEqual(theme)
            : _buildExpand(theme),
      ),
    );
  }

  Widget _buildEqual(_PillTheme theme) {
    const spacing = 4.0;
    final n = widget.items.length;
    return Row(
      children: List.generate(n, (i) {
        final active = i == _current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < n - 1 ? spacing : 0),
            child: _PillTab(
              item: widget.items[i],
              theme: theme,
              active: active,
              showLabel: true,
              height: widget.height,
              onTap: () => widget.controller.animateTo(i),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpand(_PillTheme theme) {
    const spacing = 4.0;
    final n = widget.items.length;
    return LayoutBuilder(
      builder: (context, c) {
        final totalSpacing = spacing * (n - 1);
        final activeWidth = (c.maxWidth * widget.activeWidthRatio)
            .clamp(widget.activeMinWidth, widget.activeMaxWidth);
        final inactiveWidth =
            (c.maxWidth - activeWidth - totalSpacing) / (n - 1);

        return Row(
          children: List.generate(n, (i) {
            final active = i == _current;
            return Padding(
              padding: EdgeInsets.only(right: i < n - 1 ? spacing : 0),
              child: _PillTab(
                item: widget.items[i],
                theme: theme,
                active: active,
                showLabel: active,
                width: active ? activeWidth : inactiveWidth,
                height: widget.height,
                onTap: () => widget.controller.animateTo(i),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Palette for one [AppPillTabs] variant.
class _PillTheme {
  const _PillTheme({
    required this.containerColor,
    required this.activeBg,
    required this.activeIconColor,
    required this.activeLabelColor,
    required this.inactiveFg,
    this.activeShadow,
    this.containerShadow,
  });

  final Color containerColor;
  final Color activeBg;
  final Color activeIconColor;
  final Color activeLabelColor;
  final Color inactiveFg;
  final List<BoxShadow>? activeShadow;
  final List<BoxShadow>? containerShadow;

  static _PillTheme of(AppPillTabsVariant v) {
    switch (v) {
      case AppPillTabsVariant.light:
        return _PillTheme(
          containerColor: AppColors.surfaceMuted,
          activeBg: AppColors.primary,
          activeIconColor: Colors.white,
          activeLabelColor: Colors.white,
          inactiveFg: AppColors.textSecondary,
          activeShadow: AppShadows.cardSoft,
        );
      case AppPillTabsVariant.dark:
        return _PillTheme(
          containerColor: AppColors.primaryDark,
          activeBg: Colors.white,
          activeIconColor: AppColors.primary,
          activeLabelColor: AppColors.textPrimary,
          inactiveFg: AppColors.primaryLight,
          activeShadow: const [
            BoxShadow(
              color: Color(0x332563EB),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          containerShadow: AppShadows.cardSoft,
        );
    }
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.item,
    required this.theme,
    required this.active,
    required this.showLabel,
    required this.height,
    required this.onTap,
    this.width,
  });

  final AppPillTab item;
  final _PillTheme theme;
  final bool active;
  final bool showLabel;
  final double height;
  final VoidCallback onTap;

  /// Fixed width (used by `expand` layout). Null means the parent
  /// (`Expanded`) provides the width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: active ? theme.activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: active ? theme.activeShadow : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Semantics(
            button: true,
            selected: active,
            label: item.label,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: active ? theme.activeIconColor : theme.inactiveFg,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: showLabel
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6, right: 2),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: active
                                  ? theme.activeLabelColor
                                  : theme.inactiveFg,
                              fontWeight: FontWeight.w700,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
