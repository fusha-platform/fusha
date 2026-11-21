import 'package:flutter/material.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget? badge;

  Widget get iconWidget {
    return _buildIcon(icon);
  }

  Widget get selectedIconWidget {
    return _buildIcon(selectedIcon ?? icon);
  }

  Widget _buildIcon(IconData iconData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        if (badge != null)
          PositionedDirectional(
            top: -6,
            end: -10,
            child: badge!,
          ),
      ],
    );
  }
}