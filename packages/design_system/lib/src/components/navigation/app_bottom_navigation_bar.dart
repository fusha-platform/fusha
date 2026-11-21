import 'package:design_system/src/components/navigation/app_navigation_item.dart';
import 'package:design_system/src/foundation/motion/app_motion.dart';
import 'package:design_system/src/foundation/motion/app_motion_durations.dart';
import 'package:design_system/src/foundation/radius/app_radius.dart';
import 'package:design_system/src/theme/extensions/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showLabels = true,
    this.elevation = 0,
  }) : assert(items.length >= 2),
        assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<AppNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showLabels;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final selected = selectedColor ?? theme.colorScheme.primary;
    final unselected = unselectedColor ?? colors.secondaryText;

    return Material(
      color: backgroundColor ?? colors.surface,
      elevation: elevation,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;
              final color = isSelected ? selected : unselected;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    child: AnimatedContainer(
                      duration: AppMotion.duration(
                        context,
                        AppMotionDurations.normal,
                      ),
                      curve: AppMotion.curve(
                        context,
                        Curves.easeInOut,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppRadius.md,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected
                                    ? item.selectedIcon ?? item.icon
                                    : item.icon,
                                color: color,
                                size: 22,
                              ),
                              if (item.badge != null)
                                PositionedDirectional(
                                  top: -6,
                                  end: -10,
                                  child: item.badge!,
                                ),
                            ],
                          ),
                          if (showLabels) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}