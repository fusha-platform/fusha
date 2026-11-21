import 'package:flutter/material.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}

class AppBreadcrumb extends StatelessWidget {
   AppBreadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.spacing = 8,
    this.maxLines = 1,
  }) : assert(items.isNotEmpty);

  final List<AppBreadcrumbItem> items;
  final Widget? separator;
  final double spacing;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final effectiveSeparator = separator ??
        Icon(
          isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          size: 18,
          color: colors.onSurfaceVariant,
        );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _BreadcrumbLabel(
            item: items[index],
            isLast: index == items.length - 1,
            maxLines: maxLines,
          ),
          if (index < items.length - 1) effectiveSeparator,
        ],
      ],
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  const _BreadcrumbLabel({
    required this.item,
    required this.isLast,
    required this.maxLines,
  });

  final AppBreadcrumbItem item;
  final bool isLast;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final text = Text(
      item.label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isLast ? colors.onSurface : colors.onSurfaceVariant,
        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
      ),
    );

    if (isLast || item.onTap == null) {
      return text;
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: text,
      ),
    );
  }
}