import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);

  static const Color primaryLight = Color(0xFF42A5F5);

  static const Color primaryDark = Color(0xFF1565C0);

  static const Color primaryGlow = Color(0xFF0D47A1);

  static const Color primaryTransparent = Color(0xCC1E88E5);
  static const Color primaryLightTransparent = Color(0xCC42A5F5);
  static const Color primaryDarkTransparent = Color(0xCC1565C0);

  static const Color background = Color.fromARGB(255, 1, 12, 65);

  static const Color backgroundGlow = Color(0xFF0D1B2E);

  static const Color sidebarBg = Color(0xCC0A0F22);

  static const Color cardBg = Color(0xCC111632);

  static const Color cardBgGlass = Color(0x99111632);

  static const Color cardElement = Color(0xCC161C3E);

  static const Color textPrimary = Colors.white;
  static const Color textPrimaryGlow = Color(0xFFE0F0FF);

  static const Color textSecondary = Color(0xFFB8D0E8);
  static const Color textSecondaryDim = Color(0xFFAAB8CC);

  static const Color textHelper = Color(0xFF8A9CB0);

  static const Color success = Color(0xFF22C55E);
  static const Color successGlow = Color(0x4422C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0x44EF4444);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningGlow = Color(0x44F59E0B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoGlow = Color(0x443B82F6);

  static const Color cardBlue = Color(0xFF1E88E5);
  static const Color cardBlueGlow = Color(0x441E88E5);

  static const Color cardGreen = Color(0xFF8B5CF6);
  static const Color cardGreenGlow = Color(0x441E88E5);

  static const Color cardOrange = Color(0xFFF59E0B);
  static const Color cardOrangeGlow = Color(0x441E88E5);

  static const Color cardPurple = Color(0xFF8B5CF6);
  static const Color cardPurpleGlow = Color(0x448B5CF6);

  static const Color cardTeal = Color(0xFF14B8A6);
  static const Color cardTealGlow = Color(0x4414B8A6);

  static const Color cardPink = Color(0xFFEC4899);
  static const Color cardPinkGlow = Color(0x44EC4899);

  static const Color cardBorder = Color(0x442A2F6A);
  static const Color cardBorderGlow = Color(0x661E88E5);

  static const Color topBarBorder = Color(0x442A2F6A);

  static const Color pageBg = Color(0xFF080B1A);
  static const Color sidebarTextSel = Colors.white;
  static const Color sidebarText = Color(0xFFB8D0E8);
  static const Color sidebarSelected = Color(0xCC1E88E5);
  static const Color topBarBg = Color(0xCC0A0F22);
}

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF080B1A),
      Color(0xFF0D1B2E),
      Color(0xFF1E88E5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xCC111632),
      Color(0x990D1B2E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF42A5F5),
      Color(0xFF64B5F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [
      Color(0xCC0A0F22),
      Color(0x990A1530),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [
      Color(0x331E88E5),
      Color(0x1142A5F5),
      Colors.transparent,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x331E88E5),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      spreadRadius: -5,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 25,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> sidebarShadow = [
    const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 15,
      spreadRadius: 0,
      offset: Offset(4, 0),
    ),
  ];
}
