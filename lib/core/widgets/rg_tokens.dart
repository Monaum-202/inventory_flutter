// ============================================================
//  rg_tokens.dart
//  Shared design tokens for the Sales Report feature.
//  Import ONLY this file in widgets — never import
//  sales_report_page.dart just for colours/radii/shadows.
// ============================================================

import 'package:flutter/material.dart';

abstract class RgColors {
  static const bg         = Color(0xFFF4F6FB);
  static const surface    = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE2E8F0);
  static const text       = Color(0xFF000000);
  static const muted      = Color(0xFF64748B);
  static const primary    = Color(0xFF3B82F6);
  static const primaryDk  = Color(0xFF2563EB);
  static const success    = Color(0xFF22C55E);
  static const successBg  = Color(0xFFF0FDF4);
  static const danger     = Color(0xFFEF4444);
  static const dangerBg   = Color(0xFFFEF2F2);
  static const warning    = Color(0xFFF59E0B);
  static const warningBg  = Color(0xFFFFFBEB);
  static const info       = Color(0xFF06B6D4);
  static const infoBg     = Color(0xFFECFEFF);
  static const purple     = Color(0xFF8B5CF6);
  static const tableBg    = Color(0xFFF8FAFC);
}

abstract class RgRadius {
  static const sm   = Radius.circular(6);
  static const md   = Radius.circular(10);
  static const lg   = Radius.circular(14);
  static const full = Radius.circular(9999);

  static BorderRadius get smAll   => const BorderRadius.all(sm);
  static BorderRadius get mdAll   => const BorderRadius.all(md);
  static BorderRadius get lgAll   => const BorderRadius.all(lg);
  static BorderRadius get fullAll => const BorderRadius.all(full);
}

abstract class RgShadow {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color:       Colors.black.withOpacity(0.06),
          blurRadius:  3,
          offset:      const Offset(0, 1),
        ),
        BoxShadow(
          color:       Colors.black.withOpacity(0.04),
          blurRadius:  2,
          offset:      const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color:       Colors.black.withOpacity(0.08),
          blurRadius:  6,
          offset:      const Offset(0, 4),
        ),
        BoxShadow(
          color:       Colors.black.withOpacity(0.05),
          blurRadius:  4,
          offset:      const Offset(0, 2),
        ),
      ];
}