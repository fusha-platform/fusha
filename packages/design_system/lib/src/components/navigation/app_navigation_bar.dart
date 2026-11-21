import 'package:design_system/src/components/navigation/app_navigation_item.dart';
import 'package:flutter/material.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor,
    this.indicatorColor,
    this.labelBehavior = NavigationDestinationLabelBehavior.alwaysShow,
    this.height,
    this.elevation = 0,
  }) : assert(items.length >= 2),
        assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<AppNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final NavigationDestinationLabelBehavior labelBehavior;
  final double? height;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      labelBehavior: labelBehavior,
      height: height,
      elevation: elevation,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: item.iconWidget,
          selectedIcon: item.selectedIconWidget,
          label: item.label,
        );
      }).toList(),
    );
  }
}