import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── TRADITIONAL – Warm Terracotta & Cream ────────────────────────────────
  static const Color tradBg          = Color(0xFFFDF6F0);
  static const Color tradSurface     = Color(0xFFF8EDE0);
  static const Color tradPrimary     = Color(0xFFC9956C); // warm terracotta
  static const Color tradPrimaryDark = Color(0xFFA87048);
  static const Color tradGold        = Color(0xFFC9A227); // antique gold
  static const Color tradMauve       = Color(0xFFB19DA0);
  static const Color tradText        = Color(0xFF3D2010); // deep warm brown
  static const Color tradTextSub     = Color(0xFFA07860); // muted terracotta
  static const Color tradTextLight   = Color(0xFFB8967A);
  static const Color tradBorder      = Color(0xFFE8D5C0);
  static const Color tradEarth       = Color(0xFF8B5A3A);
  static const Color tradCard        = Color(0xFFFFF3E8);

  // ── DIGITAL – Bucktrout Brown & Velvet Plum ──────────────────────────────
  static const Color digBg       = Color(0xFF342A2B); // Bucktrout Brown
  static const Color digBgDark   = Color(0xFF281E20);
  static const Color digSurface  = Color(0xFF3D3032);
  static const Color digCard     = Color(0xFF4A3840); // Velvet Plum
  static const Color digPrimary  = Color(0xFF705B59); // muted rosewood
  static const Color digAccent   = Color(0xFFA68C8C); // soft rose
  static const Color digCinnamon = Color(0xFF8C7A7B);
  static const Color digMulberry = Color(0xFFA68C8C);
  static const Color digPorcelain= Color(0xFFCFC3C3);
  static const Color digMauve    = Color(0xFFB19DA0);
  static const Color digGold     = Color(0xFFC9A227);
  static const Color digText     = Color(0xFFCFC3C3); // porcelain
  static const Color digTextSub  = Color(0xFF8C7A7B);
  static const Color digTextLight= Color(0xFF705B59);
  static const Color digBorder   = Color(0xFF4A3840);

  // ── SHARED ───────────────────────────────────────────────────────────────
  static const Color gold    = Color(0xFFC9A227);
  static const Color mauve   = Color(0xFFB19DA0);
  static const Color error   = Color(0xFFD63031);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color star    = Color(0xFFF9CA24);
  static const Color white   = Color(0xFFFFFFFF);
  static const Color black   = Color(0xFF111111);
  static const Color silver  = Color(0xFF9E9E9E);
  static const Color bronze  = Color(0xFFCD7F32);

  // Token colors
  static const Color shreeColor   = Color(0xFF3F51B5);
  static const Color daColor      = Color(0xFF00B894);
  static const Color shreedaColor = Color(0xFF6C63FF);

  // ── BACKWARD-COMPAT ALIASES ───────────────────────────────────────────────
  // Keep these so existing screens compile without modification.
  static const Color primary           = tradPrimary;
  static const Color primaryDark       = tradPrimaryDark;
  static const Color tradBackground    = tradBg;
  static const Color digBackground     = digBg;
  static const Color tradTextSecondary = tradTextSub;
  static const Color digTextSecondary  = digTextSub;
  static const Color textSecondary     = tradTextSub;
  static const Color tradAccent        = tradGold;
  static const Color digBright         = digAccent;

  // ── DYNAMIC HELPERS (pass isDigital from ThemeProvider) ──────────────────

  static Color bg(bool isDigital) =>
      isDigital ? digBg : tradBg;

  static Color surfaceColor(bool isDigital) =>
      isDigital ? digSurface : tradSurface;

  static Color adaptivePrimary(bool isDigital) =>
      isDigital ? digAccent : tradPrimary;

  static Color textFor(bool isDigital) =>
      isDigital ? digText : tradText;

  static Color textSubFor(bool isDigital) =>
      isDigital ? digTextSub : tradTextSub;

  static Color cardBg(bool isDigital) =>
      isDigital
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.68);

  static Color cardBorder(bool isDigital) =>
      isDigital
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.85);

  static Color navBg(bool isDigital) =>
      isDigital ? digBgDark : tradBg;

  static Color chipBg(bool isDigital) =>
      isDigital
          ? const Color(0xFF705B59).withValues(alpha: 0.22)
          : const Color(0xFFC9956C).withValues(alpha: 0.10);

  static Color chipText(bool isDigital) =>
      isDigital ? digAccent : tradPrimary;

  static Color chipBorder(bool isDigital) =>
      isDigital
          ? const Color(0xFF705B59).withValues(alpha: 0.30)
          : const Color(0xFFC9956C).withValues(alpha: 0.20);
}
