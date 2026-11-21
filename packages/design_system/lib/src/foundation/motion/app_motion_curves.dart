import 'package:flutter/animation.dart';

abstract final class AppMotionCurves {
  AppMotionCurves._();

  /// Smooth entrance and interaction.
  static const Curve enter = Curves.easeOutCubic;

  /// Smooth exit.
  static const Curve exit = Curves.easeInCubic;

  /// Balanced transitions between UI states.
  static const Curve standard = Curves.easeInOutCubic;

  /// Gentle movement for page transitions.
  static const Curve page = Curves.easeInOut;
}