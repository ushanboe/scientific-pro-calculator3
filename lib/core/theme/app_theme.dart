import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF4C6EF5);
  static const Color _secondaryColor = Color(0xFFF59E0B);
  static const Color _accentColor = Color(0xFF14B8A6);
  static const Color _errorColor = Color(0xFFEF4444);

  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkText = Color(0xFFE2E8F0);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextTertiary = Color(0xFF64748B);

  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightText = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightTextTertiary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF3451C7),
      onPrimaryContainer: const Color(0xFFDDE3FF),
      secondary: _secondaryColor,
      onSecondary: const Color(0xFF1A1200),
      secondaryContainer: const Color(0xFFB87800),
      onSecondaryContainer: const Color(0xFFFFE08A),
      tertiary: _accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF0D8A7A),
      onTertiaryContainer: const Color(0xFFB2EFEA),
      error: _errorColor,
      onError: Colors.white,
      errorContainer: const Color(0xFF9B1C1C),
      onErrorContainer: const Color(0xFFFECACA),
      surface: _darkSurface,
      onSurface: _darkText,
      surfaceContainerHighest: const Color(0xFF293548),
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkTextTertiary,
      outlineVariant: const Color(0xFF334155),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _darkText,
      onInverseSurface: _darkBackground,
      inversePrimary: const Color(0xFF3451C7),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: _darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(color: _darkText),
        actionsIconTheme: const IconThemeData(color: _darkTextSecondary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _darkTextSecondary,
          highlightColor: _primaryColor.withValues(alpha: 0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF293548),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary, fontFamily: 'Roboto'),
        hintStyle: const TextStyle(color: _darkTextTertiary, fontFamily: 'Roboto'),
        prefixIconColor: _darkTextSecondary,
        suffixIconColor: _darkTextSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A2436),
        selectedItemColor: _primaryColor,
        unselectedItemColor: _darkTextTertiary,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A2436),
        indicatorColor: _primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryColor, size: 24);
          }
          return const IconThemeData(color: _darkTextTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            );
          }
          return const TextStyle(
            color: _darkTextTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          );
        }),
        elevation: 8,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF293548),
        selectedColor: _primaryColor.withValues(alpha: 0.25),
        disabledColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(
          color: _darkText,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return _darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.4);
          }
          return const Color(0xFF334155);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: const Color(0xFF334155),
        thumbColor: _primaryColor,
        overlayColor: _primaryColor.withValues(alpha: 0.15),
        valueIndicatorColor: _primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: _darkTextTertiary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return _darkTextTertiary;
        }),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: _darkText, fontFamily: 'Roboto'),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF293548),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
          elevation: WidgetStateProperty.all(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF293548),
        contentTextStyle: const TextStyle(color: _darkText, fontFamily: 'Roboto'),
        actionTextColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: _darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        contentTextStyle: const TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A2436),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0xFF334155),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _primaryColor,
        unselectedLabelColor: _darkTextSecondary,
        indicatorColor: _primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _darkText,
        iconColor: _darkTextSecondary,
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF293548),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        textStyle: const TextStyle(
          color: _darkText,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: Color(0xFF334155),
        circularTrackColor: Color(0xFF334155),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displaySmall: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16),
        titleSmall: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium: TextStyle(color: _darkTextSecondary, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: TextStyle(color: _darkTextTertiary, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: TextStyle(color: _darkText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
        labelMedium: TextStyle(color: _darkTextSecondary, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall: TextStyle(color: _darkTextTertiary, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDDE3FF),
      onPrimaryContainer: const Color(0xFF1A2E8A),
      secondary: _secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFE08A),
      onSecondaryContainer: const Color(0xFF4A3000),
      tertiary: _accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFB2EFEA),
      onTertiaryContainer: const Color(0xFF003E38),
      error: _errorColor,
      onError: Colors.white,
      errorContainer: const Color(0xFFFECACA),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: _lightSurface,
      onSurface: _lightText,
      surfaceContainerHighest: const Color(0xFFEEF2FF),
      onSurfaceVariant: _lightTextSecondary,
      outline: _lightTextTertiary,
      outlineVariant: const Color(0xFFE2E8F0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _lightText,
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFFDDE3FF),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: _lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(color: _lightText),
        actionsIconTheme: IconThemeData(color: _lightTextSecondary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _lightTextSecondary,
          highlightColor: _primaryColor.withValues(alpha: 0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: _lightTextSecondary, fontFamily: 'Roboto'),
        hintStyle: TextStyle(color: _lightTextTertiary, fontFamily: 'Roboto'),
        prefixIconColor: _lightTextSecondary,
        suffixIconColor: _lightTextSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _lightTextTertiary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightSurface,
        indicatorColor: _primaryColor.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryColor, size: 24);
          }
          return IconThemeData(color: _lightTextTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            );
          }
          return TextStyle(
            color: _lightTextTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          );
        }),
        elevation: 8,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: _primaryColor.withValues(alpha: 0.15),
        disabledColor: const Color(0xFFE2E8F0),
        labelStyle: TextStyle(
          color: _lightText,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return _lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.4);
          }
          return const Color(0xFFE2E8F0);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: const Color(0xFFE2E8F0),
        thumbColor: _primaryColor,
        overlayColor: _primaryColor.withValues(alpha: 0.15),
        valueIndicatorColor: _primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: _lightTextTertiary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return _lightTextTertiary;
        }),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: _lightText, fontFamily: 'Roboto'),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(_lightSurface),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          elevation: WidgetStateProperty.all(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        actionTextColor: _accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: _lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        contentTextStyle: TextStyle(
          color: _lightTextSecondary,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0xFFE2E8F0),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _primaryColor,
        unselectedLabelColor: _lightTextSecondary,
        indicatorColor: _primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: _lightText,
        iconColor: _lightTextSecondary,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: Color(0xFFE2E8F0),
        circularTrackColor: Color(0xFFE2E8F0),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displaySmall: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16),
        titleSmall: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium: TextStyle(color: _lightTextSecondary, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: TextStyle(color: _lightTextTertiary, fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: TextStyle(color: _lightText, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
        labelMedium: TextStyle(color: _lightTextSecondary, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall: TextStyle(color: _lightTextTertiary, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }
}