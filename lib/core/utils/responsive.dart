import 'package:flutter/material.dart';

/// Standard responsive breakpoints for Invox across Mobile, Tablet, Desktop, and Web.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double tabletMax = 1099.0;
  static const double desktopMin = 1100.0;

  static const double maxContentWidth = 1360.0;
  static const double maxFormWidth = 640.0;
  static const double maxDialogWidth = 520.0;
}

/// Convenience extensions on [BuildContext] for responsive queries.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < AppBreakpoints.tabletMin;
  bool get isTablet =>
      screenWidth >= AppBreakpoints.tabletMin &&
      screenWidth < AppBreakpoints.desktopMin;
  bool get isDesktop => screenWidth >= AppBreakpoints.desktopMin;
  bool get isDesktopOrTablet => screenWidth >= AppBreakpoints.tabletMin;

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet ?? desktop;
    return mobile;
  }
}

/// A widget that switches between mobile, tablet, and desktop presentations.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktopMin) {
          return desktop;
        } else if (constraints.maxWidth >= AppBreakpoints.tabletMin) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Wraps content in a horizontally centered container with an optional [maxWidth].
/// Ensures desktop/web pages don't stretch excessively across ultra-wide monitors.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

