import 'package:flutter/material.dart';

import '../../theme/extensions/app_theme_extensions.dart';
import 'app_card.dart';
import 'app_card_type.dart';

class AppActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final AppCardType type;

  const AppActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.description,
    this.trailing,
    this.iconColor,
    this.type = AppCardType.filled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      type: type,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colors.secondaryText,
              ),
        ],
      ),
    );
  }
}