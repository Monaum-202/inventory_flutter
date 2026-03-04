import 'package:flutter/material.dart';

/// Professional navigation color palette
class NavColors {
  static const Color background = Colors.black;
  static const Color activeBackground = Color(0xFFff5252); // Slightly different from #ff6b6b to be more red
  static const Color activeHover = Color(0xFFff6b6b); // The specified coral red
  static const Color text = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFF333333);
}

/// Navigation styling constants
class NavSizing {
  static const double sidebarExpandedWidth = 250; // 15.6rem
  static const double sidebarCollapsedWidth = 80; // 5rem
  static const double iconMinWidth = 20; // 1.25rem
  static const double borderRadius = 10;
  static const double moduleIconSize = 24;
  static const double menuIconSize = 20;
  static const double animationDuration = 300; // milliseconds
}
