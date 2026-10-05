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
      ? const Color(0xFF18191E)
      : const Color(0xFFF5F5F7);

  static Color panelColor(BuildContext context) => _isDark(context)
      ? const Color(0xFF24252B)
      : const Color(0xFFFFFFFF);

  static Color borderColor(BuildContext context) => _isDark(context)
      ? const Color(0xFF2E3038)
      : const Color(0xFFE3E3E8);

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
