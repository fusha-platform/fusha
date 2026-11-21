abstract final class AppMotionDurations {
  AppMotionDurations._();

  /// Quick feedback: buttons and small interactions.
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions: loading and error states.
  static const Duration normal = Duration(milliseconds: 200);

  /// Page transitions and larger UI changes.
  static const Duration medium = Duration(milliseconds: 250);

  /// Delay between consecutive list items.
  static const Duration stagger = Duration(milliseconds: 40);
}