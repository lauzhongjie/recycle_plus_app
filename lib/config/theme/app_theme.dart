import 'package:flutter/material.dart';
import 'package:recycle_plus_app/config/theme/color_schemes.g.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: colorPrimary,
      foregroundColor: white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: colorSecondary,
      foregroundColor: white,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorSecondary,
        foregroundColor: white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: colorSecondary,
        ),
        backgroundColor: white,
        foregroundColor: colorSecondary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: colorPrimary,
      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 30),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: colorSecondary),
    dialogTheme: DialogTheme(
      backgroundColor: white,
      surfaceTintColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorPrimary,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkerGrey,
      actionTextColor: colorSecondary,
    ),
    fontFamily: 'Hind Vadodara',
    textTheme: GoogleFonts.hindVadodaraTextTheme(),
    cardTheme: const CardTheme(
      color: Colors.white,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    // scaffoldBackgroundColor: Colors.white,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Color(0xFF24B682),
    //   foregroundColor: Colors.white,
    // ),
    // floatingActionButtonTheme: const FloatingActionButtonThemeData(
    //   backgroundColor: Color(0xFF34D99E),
    //   foregroundColor: Colors.white,
    //   shape: CircleBorder(),
    // ),
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: const Color(0xFF34D99E),
    //     foregroundColor: Colors.white,
    //   ),
    // ),
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: OutlinedButton.styleFrom(
    //     side: const BorderSide(
    //       color: Color(0xFF34D99E),
    //     ),
    //     backgroundColor: Colors.white,
    //     foregroundColor: const Color(0xFF34D99E),
    //   ),
    // ),
    // textTheme: GoogleFonts.hindVadodaraTextTheme(),
  );
}
