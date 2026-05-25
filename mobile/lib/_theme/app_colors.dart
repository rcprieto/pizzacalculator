import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const pageBg = Color(0xFFf5f0eb);
  static const cardBg = Colors.white;
  static const inputBg = Color(0xFFFAF6F1);
  static const modalFooterBg = Color(0xFFFAF6F1);

  // AppBar / TopBar gradient
  static const barTop = Color(0xFF1c0f0a);
  static const barBottom = Color(0xFF3d200e);
  static const barFg = Colors.white;

  // Borders
  static const border = Color(0xFFe0d4c8);
  static const borderLight = Color(0xFFede6dd);

  // Accent (amber)
  static const accent = Color(0xFFc07a0a);
  static const accentBg = Color(0xFFfff8e7);

  // Text
  static const textPrimary = Color(0xFF1a1a1a);
  static const textSecondary = Color(0xFF999999);
  static const textMuted = Color(0xFFaaaaaa);

  // Icon sets
  static const iconPizzaBg = Color(0xFFfff0ef);
  static const iconPizzaFg = Color(0xFFc0392b);

  static const iconReceitaBg = Color(0xFFfff8e7);
  static const iconReceitaFg = Color(0xFFc07a0a);

  static const iconAdminBg = Color(0xFFeef1f8);
  static const iconAdminFg = Color(0xFF3d5a8a);

  static const iconGrupoBg = Color(0xFFf0f4ff);
  static const iconGrupoFg = Color(0xFF3d5a8a);

  // Action buttons
  static const editBg = Color(0xFFEEF3FF);
  static const editFg = Color(0xFF3d5a8a);
  static const deleteBg = Color(0xFFfff0ef);
  static const deleteFg = Color(0xFFc0392b);

  // Gradients
  static const LinearGradient barGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [barTop, barBottom],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.55, 1],
    colors: [Color(0xFF1c0f0a), Color(0xFF3d200e), Color(0xFF6b3a1f)],
  );
}
