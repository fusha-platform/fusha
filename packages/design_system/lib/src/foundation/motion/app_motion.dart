import 'package:material_ui/material_ui.dart';

abstract final class AppMotion {
  AppMotion._();

  /// Checks whether the user prefers reduced animations.
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  /// Returns zero duration when animations are disabled.
  static Duration duration(
      BuildContext context,
      Duration duration,
      ) {
    return shouldReduceMotion(context) ? Duration.zero : duration;
  }

  /// Returns a simple curve when animations are disabled.
  static Curve curve(
      BuildContext context,
      Curve curve,
      ) {
    return shouldReduceMotion(context) ? Curves.linear : curve;
  }
}