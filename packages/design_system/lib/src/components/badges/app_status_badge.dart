import 'package:design_system/src/components/badges/app_badge.dart';
import 'package:design_system/src/components/badges/app_badge_type.dart';
import 'package:flutter/material.dart';

enum AppStatus {
  active,
  pending,
  rejected,
  inactive,
  completed,
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  final String label;
  final AppStatus status;
  final IconData? icon;

  AppBadgeType get _badgeType {
    return switch (status) {
      AppStatus.active => AppBadgeType.success,
      AppStatus.pending => AppBadgeType.warning,
      AppStatus.rejected => AppBadgeType.error,
      AppStatus.inactive => AppBadgeType.neutral,
      AppStatus.completed => AppBadgeType.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      type: _badgeType,
      icon: icon,
    );
  }
}