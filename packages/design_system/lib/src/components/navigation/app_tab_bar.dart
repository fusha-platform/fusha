import 'package:material_ui/material_ui.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.dividerColor,
    this.indicatorSize = TabBarIndicatorSize.label,
    this.labelPadding,
  });

  final TabController controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? dividerColor;
  final TabBarIndicatorSize indicatorSize;
  final EdgeInsetsGeometry? labelPadding;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: tabs,
      isScrollable: isScrollable,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
      dividerColor: dividerColor,
      indicatorSize: indicatorSize,
      labelPadding: labelPadding,
    );
  }
}