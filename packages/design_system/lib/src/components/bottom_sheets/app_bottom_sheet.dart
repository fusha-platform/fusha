import 'package:material_ui/material_ui.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';
import 'app_bottom_sheet_header.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 24),
    this.header,
  });

  final Widget child;
  final String? title;
  final String? description;
  final bool showDragHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry padding;
  final Widget? header;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) {
    final duration = AppMotion.duration(
      context,
      AppMotionDurations.medium,
    );

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      sheetAnimationStyle: AnimationStyle(
        duration: duration,
        reverseDuration: duration,
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      key: const ValueKey('app_bottom_sheet_drag_handle'),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.disabled,
                        borderRadius: BorderRadius.circular(
                          AppRadius.full,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (header != null)
                  header!
                else if (title != null)
                  AppBottomSheetHeader(
                    title: title!,
                    description: description,
                    showCloseButton: showCloseButton,
                  ),
                if (header != null || title != null)
                  const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}