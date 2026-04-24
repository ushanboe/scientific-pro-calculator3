import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/app_settings.dart';
import 'package:scientific_pro_calculator/services/settings_service.dart';

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return SettingsService.instance.loadSettings();
  }

  Future<void> setDisplayFormat(String format) async {
    state = state.copyWith(displayFormat: format);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setDecimalPlaces(int places) async {
    final clamped = places.clamp(0, 15);
    state = state.copyWith(decimalPlaces: clamped);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setAngleMode(String mode) async {
    state = state.copyWith(angleMode: mode);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> toggleRpnMode(bool enabled) async {
    state = state.copyWith(rpnModeEnabled: enabled);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> toggleHaptic(bool enabled) async {
    state = state.copyWith(hapticEnabled: enabled);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setDigitSeparator(String separator) async {
    state = state.copyWith(digitSeparator: separator);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setFullScreenMode(bool enabled) async {
    state = state.copyWith(fullScreenMode: enabled);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> setSignificandDigits(int digits) async {
    final clamped = digits.clamp(1, 100);
    state = state.copyWith(significandDigits: clamped);
    await SettingsService.instance.saveSettings(state);
  }

  Future<void> resetToDefaults() async {
    state = AppSettings.defaults();
    await SettingsService.instance.saveSettings(state);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
