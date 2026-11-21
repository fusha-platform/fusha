import 'package:material_ui/material_ui.dart';

import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';

class AppBottomSheetHeader extends StatelessWidget {
  const AppBottomSheetHeader({
    super.key,
    required this.title,
    this.description,
    this.showCloseButton = true,
    this.onClose,
  });

  final String title;
  final String? description;
  final bool showCloseButton;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 6),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showCloseButton) ...[
          const SizedBox(width: 12),
          Material(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              onTap: onClose ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}