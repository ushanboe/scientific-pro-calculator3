// Step 1: Inventory
// This file DEFINES: AppSettings class with fields:
//   - displayFormat (String, non-nullable) — 'fixed', 'scientific', 'engineering', or 'dms'
//   - decimalPlaces (int, non-nullable) — 0-15
//   - digitSeparator (String, non-nullable) — 'none', 'comma', 'period', or 'space'
//   - angleMode (String, non-nullable) — 'degrees', 'radians', or 'gradians'
//   - rpnModeEnabled (bool, non-nullable)
//   - hapticEnabled (bool, non-nullable)
//   - theme (String, non-nullable) — 'light', 'dark', or 'system'
//   - fullScreenMode (bool, non-nullable)
//   - significandDigits (int, non-nullable) — 1-100
// Methods: copyWith, toJson, fromJson
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: settings_service.dart, app_settings_provider.dart, settings_screen.dart,
//          calculator_screen.dart, main.dart (via provider)
// toJson/fromJson → SharedPreferences persistence via SettingsService
// copyWith → provider state updates in AppSettingsProvider
// The provider watches this model to drive theme, display format, angle mode, etc.
//
// Step 3: User Journey Trace
// SettingsService.init() loads JSON from SharedPreferences → AppSettings.fromJson()
// AppSettingsProvider exposes AppSettings to all screens via ref.watch()
// SettingsScreen updates settings → provider calls copyWith() → saves via toJson()
// CalculatorScreen reads angleMode/displayFormat/decimalPlaces for computation/display
// main.dart reads theme field to set ThemeMode on MaterialApp
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// bool fields stored as bool in JSON (not 0/1 — this is SharedPreferences JSON, not SQLite)
// Follows exact same pattern as other models in this project for consistency
// Default values must be sensible: fixed format, 6 decimal places, no separator,
//   degrees, RPN off, haptic on, system theme, no full screen, 15 significand digits

class AppSettings {
  final String displayFormat;
  final int decimalPlaces;
  final String digitSeparator;
  final String angleMode;
  final bool rpnModeEnabled;
  final bool hapticEnabled;
  final String theme;
  final bool fullScreenMode;
  final int significandDigits;

  const AppSettings({
    required this.displayFormat,
    required this.decimalPlaces,
    required this.digitSeparator,
    required this.angleMode,
    required this.rpnModeEnabled,
    required this.hapticEnabled,
    required this.theme,
    required this.fullScreenMode,
    required this.significandDigits,
  });

  /// Default settings used on first launch.
  factory AppSettings.defaults() {
    return const AppSettings(
      displayFormat: 'fixed',
      decimalPlaces: 6,
      digitSeparator: 'none',
      angleMode: 'degrees',
      rpnModeEnabled: false,
      hapticEnabled: true,
      theme: 'system',
      fullScreenMode: false,
      significandDigits: 15,
    );
  }

  AppSettings copyWith({
    String? displayFormat,
    int? decimalPlaces,
    String? digitSeparator,
    String? angleMode,
    bool? rpnModeEnabled,
    bool? hapticEnabled,
    String? theme,
    bool? fullScreenMode,
    int? significandDigits,
  }) {
    return AppSettings(
      displayFormat: displayFormat ?? this.displayFormat,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      digitSeparator: digitSeparator ?? this.digitSeparator,
      angleMode: angleMode ?? this.angleMode,
      rpnModeEnabled: rpnModeEnabled ?? this.rpnModeEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      theme: theme ?? this.theme,
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      significandDigits: significandDigits ?? this.significandDigits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayFormat': displayFormat,
      'decimalPlaces': decimalPlaces,
      'digitSeparator': digitSeparator,
      'angleMode': angleMode,
      'rpnModeEnabled': rpnModeEnabled,
      'hapticEnabled': hapticEnabled,
      'theme': theme,
      'fullScreenMode': fullScreenMode,
      'significandDigits': significandDigits,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      displayFormat: json['displayFormat'] as String? ?? 'fixed',
      decimalPlaces: json['decimalPlaces'] as int? ?? 6,
      digitSeparator: json['digitSeparator'] as String? ?? 'none',
      angleMode: json['angleMode'] as String? ?? 'degrees',
      rpnModeEnabled: json['rpnModeEnabled'] as bool? ?? false,
      hapticEnabled: json['hapticEnabled'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      fullScreenMode: json['fullScreenMode'] as bool? ?? false,
      significandDigits: json['significandDigits'] as int? ?? 15,
    );
  }

  @override
  String toString() {
    return 'AppSettings(displayFormat: $displayFormat, decimalPlaces: $decimalPlaces, '
        'digitSeparator: $digitSeparator, angleMode: $angleMode, '
        'rpnModeEnabled: $rpnModeEnabled, hapticEnabled: $hapticEnabled, '
        'theme: $theme, fullScreenMode: $fullScreenMode, '
        'significandDigits: $significandDigits)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.displayFormat == displayFormat &&
        other.decimalPlaces == decimalPlaces &&
        other.digitSeparator == digitSeparator &&
        other.angleMode == angleMode &&
        other.rpnModeEnabled == rpnModeEnabled &&
        other.hapticEnabled == hapticEnabled &&
        other.theme == theme &&
        other.fullScreenMode == fullScreenMode &&
        other.significandDigits == significandDigits;
  }

  @override
  int get hashCode => Object.hash(
        displayFormat,
        decimalPlaces,
        digitSeparator,
        angleMode,
        rpnModeEnabled,
        hapticEnabled,
        theme,
        fullScreenMode,
        significandDigits,
      );
}