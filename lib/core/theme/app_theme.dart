import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E7D32);
  static const double _radius = 16;

  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF1E7A4E),
        secondary: const Color(0xFF2B9B6B),
        surface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFFE7EFEA),
        outlineVariant: const Color(0xFFD4E0D8),
      );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF51C28D),
        secondary: const Color(0xFF72D9AA),
        surface: const Color(0xFF141A17),
        surfaceContainerHighest: const Color(0xFF27312C),
        outlineVariant: const Color(0xFF3A4740),
      );

  static TextTheme _textTheme(Color textColor) {
    return GoogleFonts.manropeTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme scheme) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
      ),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 1.4),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 1.6),
      ),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        side: BorderSide(color: scheme.outlineVariant),
        foregroundColor: scheme.onSurface,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffold,
  }) {
    final textTheme = _textTheme(colorScheme.onSurface);
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      inputDecorationTheme: _inputTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: colorScheme.onSurface),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary.withValues(alpha: 0.18),
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        iconColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static final ThemeData lightTheme = _baseTheme(
    brightness: Brightness.light,
    colorScheme: _lightScheme,
    scaffold: const Color(0xFFF3F6F4),
  );

  static final ThemeData darkTheme = _baseTheme(
    brightness: Brightness.dark,
    colorScheme: _darkScheme,
    scaffold: const Color(0xFF0D1210),
  );
}
