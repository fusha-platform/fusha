import 'package:material_ui/material_ui.dart';

import '../../theme/extensions/app_theme_extensions.dart';
import 'app_card.dart';
import 'app_card_header.dart';
import 'app_card_type.dart';

class AppInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final Widget? trailing;
  final AppCardType type;
  final VoidCallback? onTap;

  const AppInfoCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.trailing,
    this.type = AppCardType.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      type: type,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: title,
            icon: icon,
            iconColor: iconColor,
            trailing: trailing,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: textTheme.headlineLarge?.copyWith(
              color: valueColor ?? colors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}