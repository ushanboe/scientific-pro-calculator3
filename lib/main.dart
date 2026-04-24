import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/core/theme/app_theme.dart';
import 'package:scientific_pro_calculator/core/navigation/app_navigator.dart';
import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';
import 'package:scientific_pro_calculator/services/settings_service.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';
import 'package:scientific_pro_calculator/services/constants_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    const ProviderScope(
      child: ScientificProCalculatorApp(),
    ),
  );
}

class ScientificProCalculatorApp extends StatefulWidget {
  const ScientificProCalculatorApp({super.key});

  @override
  State<ScientificProCalculatorApp> createState() => _ScientificProCalculatorAppState();
}

class _ScientificProCalculatorAppState extends State<ScientificProCalculatorApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await SettingsService.instance.init();
      await HistoryService.instance.init();
      try {
        await ConstantsService.instance.seedDatabaseIfNeeded();
      } catch (e) {
        print('SCIENTIFIC_PRO_CALC constants seed error: $e');
      }
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC init error: $e');
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _LoadingScreen(),
      );
    }

    return const _AppWithProviders();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4C6EF5).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4C6EF5).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                size: 44,
                color: Color(0xFF4C6EF5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scientific Pro',
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Calculator',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Initializing...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppWithProviders extends ConsumerWidget {
  const _AppWithProviders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    ThemeMode themeMode;
    switch (settings.theme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Scientific Pro Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppNavigator(),
    );
  }
}