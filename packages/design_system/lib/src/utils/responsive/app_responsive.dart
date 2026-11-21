import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

extension AppResponsive on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < AppBreakpoints.mobile;

  bool get isTablet =>
      screenWidth >= AppBreakpoints.mobile &&
          screenWidth < AppBreakpoints.tablet;

  bool get isDesktop =>
      screenWidth >= AppBreakpoints.tablet &&
          screenWidth < AppBreakpoints.wideDesktop;

  bool get isWideDesktop =>
      screenWidth >= AppBreakpoints.wideDesktop;
}