import 'package:design_system/src/components/navigation/app_navigation_item.dart';
import 'package:flutter/material.dart';

class AppNavigationRail extends StatelessWidget {
   AppNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor,
    this.indicatorColor,
    this.extended = false,
    this.labelType,
    this.leading,
    this.trailing,
    this.groupAlignment = -1,
    this.minWidth = 72,
    this.minExtendedWidth = 200,
  }) : assert(items.isNotEmpty),
        assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<AppNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool extended;
  final NavigationRailLabelType? labelType;
  final Widget? leading;
  final Widget? trailing;
  final double groupAlignment;
  final double minWidth;
  final double minExtendedWidth;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      extended: extended,
      labelType: extended
          ? null
          : labelType ?? NavigationRailLabelType.all,
      leading: leading,
      trailing: trailing,
      groupAlignment: groupAlignment,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: item.iconWidget,
          selectedIcon: item.selectedIconWidget,
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}