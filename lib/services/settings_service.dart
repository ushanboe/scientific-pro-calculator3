// Step 1: Inventory
// This file DEFINES: SettingsService class (singleton) with:
//   - static instance getter
//   - _prefs (SharedPreferences, nullable)
//   - init() — loads SharedPreferences instance
//   - loadSettings() — reads all keys from SharedPreferences, returns AppSettings
//   - saveSettings(AppSettings) — writes all fields to SharedPreferences
//   - individual setters: setDisplayFormat, setDecimalPlaces, setDigitSeparator,
//     setAngleMode, setRpnModeEnabled, setHapticEnabled, setTheme,
//     setFullScreenMode, setSignificandDigits
//   - resetToDefaults() — saves AppSettings.defaults() to SharedPreferences
//
// Uses from other files:
//   - AppSettings (lib/models/app_settings.dart) — fields: displayFormat, decimalPlaces,
//     digitSeparator, angleMode, rpnModeEnabled, hapticEnabled, theme, fullScreenMode,
//     significandDigits. Methods: defaults(), fromJson(), toJson(), copyWith()
//
// Step 2: Connections
// - main.dart calls SettingsService.instance.init() before runApp()
// - app_settings_provider.dart calls SettingsService.instance.loadSettings() on init
//   and SettingsService.instance.saveSettings() on every state change
// - settings_screen.dart calls provider methods which delegate to this service
//
// Step 3: User Journey Trace
// App starts → main.dart calls SettingsService.instance.init() → SharedPreferences loaded
// AppSettingsProvider builds → calls loadSettings() → reads stored JSON → AppSettings.fromJson()
// User changes setting in SettingsScreen → provider calls setXxx() → persists to SharedPreferences
// App restarts → loadSettings() reads persisted values → correct settings restored
//
// Step 4: Layout Sanity
// Pure service class — no widgets, no layout concerns
// SharedPreferences stores each setting as individual typed keys for reliability
// Also stores full JSON blob as backup for easy migration
// Null-safe: _prefs checked before use, falls back to defaults if not initialized

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scientific_pro_calculator/models/app_settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  static const String _keyDisplayFormat = 'display_format';
  static const String _keyDecimalPlaces = 'decimal_places';
  static const String _keyDigitSeparator = 'digit_separator';
  static const String _keyAngleMode = 'angle_mode';
  static const String _keyRpnModeEnabled = 'rpn_mode_enabled';
  static const String _keyHapticEnabled = 'haptic_enabled';
  static const String _keyTheme = 'theme';
  static const String _keyFullScreenMode = 'full_screen_mode';
  static const String _keySignificandDigits = 'significand_digits';
  static const String _keySettingsJson = 'app_settings_json';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  AppSettings loadSettings() {
    final prefs = _prefs;
    if (prefs == null) {
      return AppSettings.defaults();
    }

    // Try loading from the JSON blob first (for forward compatibility)
    final jsonStr = prefs.getString(_keySettingsJson);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return AppSettings.fromJson(json);
      } catch (_) {
        // Fall through to individual key loading
      }
    }

    // Load from individual keys (legacy / fallback path)
    return AppSettings(
      displayFormat: prefs.getString(_keyDisplayFormat) ?? 'fixed',
      decimalPlaces: prefs.getInt(_keyDecimalPlaces) ?? 6,
      digitSeparator: prefs.getString(_keyDigitSeparator) ?? 'none',
      angleMode: prefs.getString(_keyAngleMode) ?? 'degrees',
      rpnModeEnabled: prefs.getBool(_keyRpnModeEnabled) ?? false,
      hapticEnabled: prefs.getBool(_keyHapticEnabled) ?? true,
      theme: prefs.getString(_keyTheme) ?? 'system',
      fullScreenMode: prefs.getBool(_keyFullScreenMode) ?? false,
      significandDigits: prefs.getInt(_keySignificandDigits) ?? 15,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Write individual keys for fast reads
    await prefs.setString(_keyDisplayFormat, settings.displayFormat);
    await prefs.setInt(_keyDecimalPlaces, settings.decimalPlaces);
    await prefs.setString(_keyDigitSeparator, settings.digitSeparator);
    await prefs.setString(_keyAngleMode, settings.angleMode);
    await prefs.setBool(_keyRpnModeEnabled, settings.rpnModeEnabled);
    await prefs.setBool(_keyHapticEnabled, settings.hapticEnabled);
    await prefs.setString(_keyTheme, settings.theme);
    await prefs.setBool(_keyFullScreenMode, settings.fullScreenMode);
    await prefs.setInt(_keySignificandDigits, settings.significandDigits);

    // Also write full JSON blob for migration support
    try {
      await prefs.setString(_keySettingsJson, jsonEncode(settings.toJson()));
    } catch (_) {
      // JSON write failure is non-critical — individual keys are the source of truth
    }
  }

  Future<void> setDisplayFormat(String format) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyDisplayFormat, format);
    await _updateJsonBlob();
  }

  Future<void> setDecimalPlaces(int places) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final clamped = places.clamp(0, 15);
    await prefs.setInt(_keyDecimalPlaces, clamped);
    await _updateJsonBlob();
  }

  Future<void> setDigitSeparator(String separator) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyDigitSeparator, separator);
    await _updateJsonBlob();
  }

  Future<void> setAngleMode(String mode) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyAngleMode, mode);
    await _updateJsonBlob();
  }

  Future<void> setRpnModeEnabled(bool enabled) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_keyRpnModeEnabled, enabled);
    await _updateJsonBlob();
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_keyHapticEnabled, enabled);
    await _updateJsonBlob();
  }

  Future<void> setTheme(String theme) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyTheme, theme);
    await _updateJsonBlob();
  }

  Future<void> setFullScreenMode(bool enabled) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_keyFullScreenMode, enabled);
    await _updateJsonBlob();
  }

  Future<void> setSignificandDigits(int digits) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final clamped = digits.clamp(1, 100);
    await prefs.setInt(_keySignificandDigits, clamped);
    await _updateJsonBlob();
  }

  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings.defaults());
  }

  /// Rewrites the JSON blob from current individual key values.
  Future<void> _updateJsonBlob() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final current = loadSettings();
    try {
      await prefs.setString(_keySettingsJson, jsonEncode(current.toJson()));
    } catch (_) {
      // Non-critical
    }
  }

  /// Returns true if SharedPreferences has been initialized.
  bool get isInitialized => _prefs != null;
}