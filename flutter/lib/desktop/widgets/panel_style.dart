import 'package:flutter/material.dart';

/// Colors, type sizes, shapes, and icon sizes shared by the desktop home
/// window and Settings pages.
class DesktopPanelStyle {
  DesktopPanelStyle._();

  static const double fontDisplay = 24;
  static const double fontHeading = 22;
  static const double fontTitle = 15;
  static const double fontBody = 14;
  static const double fontSmall = 13;

  static const double panelRadius = 12;
  static const double controlRadius = 8;

  static const double iconInline = 16;
  static const double iconButton = 20;
  static const double iconChevron = 18;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color windowColor(BuildContext context) => _isDark(context)
      ? const Color(0xFF15181F)
      : const Color(0xFFF2F4F8);

  static Color panelColor(BuildContext context) => _isDark(context)
      ? const Color(0xFF20242D)
      : const Color(0xFFFFFFFF);

  static Color borderColor(BuildContext context) => _isDark(context)
      ? const Color(0xFF2A303B)
      : const Color(0xFFDDE2EB);

  static const double headerWashHeightLight = 215;
  static const double headerWashHeightDark = 230;
  static const List<Color> headerWashColorsLight = [
    Color.fromRGBO(0, 113, 255, 0.075),
    Color.fromRGBO(0, 113, 255, 0.03),
    Color.fromRGBO(0, 113, 255, 0),
  ];
  static const List<Color> headerWashColorsDark = [
    Color.fromRGBO(20, 80, 210, 0.30),
    Color.fromRGBO(20, 80, 210, 0.10),
    Color.fromRGBO(20, 80, 210, 0),
  ];

  static double headerWashHeight(BuildContext context) =>
      _isDark(context) ? headerWashHeightDark : headerWashHeightLight;

  /// Light: a vertical fade. Dark: a glow from the top center whose radius
  /// spans the wash height vertically and 120% of the width horizontally.
  static Gradient headerWash(BuildContext context) => _isDark(context)
      ? const RadialGradient(
          center: Alignment.topCenter,
          radius: 1,
          colors: headerWashColorsDark,
          stops: [0, 0.6, 1],
          transform: _StretchToWidth(1.2),
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: headerWashColorsLight,
          stops: [0, 130 / headerWashHeightLight, 1],
        );

  static Color secondaryTextColor(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.6) ??
      Colors.grey;

  static BoxDecoration panel(BuildContext context,
          {double radius = panelRadius, Color? borderColor}) =>
      BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? DesktopPanelStyle.borderColor(context)),
      );
}

/// A RadialGradient's radius is a fraction of the box's shorter side, so it
/// draws a circle. This scales x about the center so the horizontal radius
/// becomes [widthFactor] times the box width, giving an ellipse.
class _StretchToWidth extends GradientTransform {
  const _StretchToWidth(this.widthFactor);

  final double widthFactor;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    if (bounds.shortestSide <= 0) return null;
    final scaleX = widthFactor * bounds.width / bounds.shortestSide;
    final cx = bounds.center.dx;
    return Matrix4.translationValues(cx, 0, 0) *
        Matrix4.diagonal3Values(scaleX, 1, 1) *
        Matrix4.translationValues(-cx, 0, 0);
  }
}
