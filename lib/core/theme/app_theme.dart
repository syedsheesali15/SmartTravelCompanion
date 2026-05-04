import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

ThemeData lightTheme(ColorScheme seeds) => ThemeData(
  useMaterial3: true,
  colorScheme: seeds,
  scaffoldBackgroundColor: AppColors.lightBackground,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.lightBackground,
    foregroundColor: seeds.onSurface,
    titleTextStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: seeds.primary,
    unselectedItemColor: const Color(0xFF94A3B8),
    selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    type: BottomNavigationBarType.fixed,
  ),
  chipTheme: ChipThemeData(
    selectedColor: seeds.primary.withOpacity(0.22),
    side: BorderSide(color: seeds.outline),
    shape: StadiumBorder(side: BorderSide(color: seeds.outline)),
    labelStyle: GoogleFonts.poppins(fontSize: 12),
  ),
);

ThemeData darkTheme(ColorScheme seeds) => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: seeds,
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.darkBackground,
    foregroundColor: seeds.onSurface,
    titleTextStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkSurface),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: seeds.primary,
    unselectedItemColor: Colors.white70,
  ),
  chipTheme: ChipThemeData(
    selectedColor: seeds.primary.withOpacity(0.3),
    side: const BorderSide(color: Colors.white24),
    shape: const StadiumBorder(side: BorderSide(color: Colors.white24)),
  ),
);

ColorScheme lightScheme() => ColorScheme.light(
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.accentHeart,
  onSecondary: Colors.white,
  surface: Colors.white,
  onSurface: const Color(0xFF0F172A),
  outline: const Color(0xFFE2E8F0),
  outlineVariant: const Color(0xFFCBD5F5),
);

ColorScheme darkScheme() => const ColorScheme.dark(
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.accentHeart,
  onSecondary: Colors.white,
  surface: AppColors.darkSurface,
  onSurface: Color(0xFFE2E8F0),
  outline: Color(0xFF334155),
  outlineVariant: Color(0xFF475569),
);
