import 'package:design_system/src/components/loading/app_circular_progress.dart';
import 'package:material_ui/material_ui.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.size = AppProgressSize.large,
    this.color,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 12,
  });

  final String? message;
  final AppProgressSize size;
  final Color? color;
  final MainAxisSize mainAxisSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: message ?? 'Loading',
      child: Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCircularProgress(
            size: size,
            color: color,
            semanticsLabel: message ?? 'Loading',
          ),
          if (message != null) ...[
            SizedBox(height: spacing),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}