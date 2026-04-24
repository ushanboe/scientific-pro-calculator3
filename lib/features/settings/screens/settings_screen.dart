import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/app_settings.dart';
import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to Defaults',
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Display', icon: Icons.display_settings_rounded),
            _SettingsCard(
              children: [
                _DropdownTile<String>(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Number Format',
                  subtitle: 'How results are displayed',
                  value: settings.displayFormat,
                  items: const [
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed Decimal')),
                    DropdownMenuItem(value: 'scientific', child: Text('Scientific Notation')),
                    DropdownMenuItem(value: 'engineering', child: Text('Engineering Notation')),
                    DropdownMenuItem(value: 'dms', child: Text('Degrees° Minutes\' Seconds"')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).setDisplayFormat(value);
                    }
                  },
                ),
                const Divider(height: 1),
                _SliderTile(
                  icon: Icons.numbers_rounded,
                  title: 'Decimal Places',
                  subtitle: 'Digits after decimal point: ${settings.decimalPlaces}',
                  value: settings.decimalPlaces.toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setDecimalPlaces(value.round());
                  },
                ),
                const Divider(height: 1),
                _SliderTile(
                  icon: Icons.precision_manufacturing_rounded,
                  title: 'Significand Digits',
                  subtitle: 'Precision for scientific mode: ${settings.significandDigits}',
                  value: settings.significandDigits.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setSignificandDigits(value.round());
                  },
                ),
                const Divider(height: 1),
                _DropdownTile<String>(
                  icon: Icons.space_bar_rounded,
                  title: 'Digit Separator',
                  subtitle: 'Thousands grouping character',
                  value: settings.digitSeparator,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None  (1234567)')),
                    DropdownMenuItem(value: 'comma', child: Text('Comma  (1,234,567)')),
                    DropdownMenuItem(value: 'period', child: Text('Period  (1.234.567)')),
                    DropdownMenuItem(value: 'space', child: Text('Space  (1 234 567)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).setDigitSeparator(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Calculation', icon: Icons.calculate_rounded),
            _SettingsCard(
              children: [
                _DropdownTile<String>(
                  icon: Icons.rotate_right_rounded,
                  title: 'Angle Mode',
                  subtitle: 'Unit for trigonometric functions',
                  value: settings.angleMode,
                  items: const [
                    DropdownMenuItem(value: 'degrees', child: Text('Degrees (°)')),
                    DropdownMenuItem(value: 'radians', child: Text('Radians (rad)')),
                    DropdownMenuItem(value: 'gradians', child: Text('Gradians (grad)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).setAngleMode(value);
                    }
                  },
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.stacked_line_chart_rounded,
                  title: 'RPN Mode',
                  subtitle: 'Reverse Polish Notation input',
                  value: settings.rpnModeEnabled,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).toggleRpnMode(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Appearance', icon: Icons.palette_rounded),
            _SettingsCard(
              children: [
                _DropdownTile<String>(
                  icon: Icons.dark_mode_rounded,
                  title: 'Theme',
                  subtitle: 'App color scheme',
                  value: settings.theme,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System Default')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).setTheme(value);
                    }
                  },
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.fullscreen_rounded,
                  title: 'Full Screen Mode',
                  subtitle: 'Hide status bar for more display space',
                  value: settings.fullScreenMode,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setFullScreenMode(value);
                    if (value) {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                    } else {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Feedback', icon: Icons.vibration_rounded),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on button press',
                  value: settings.hapticEnabled,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).toggleHaptic(value);
                    if (value) {
                      HapticFeedback.selectionClick();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Current Settings Preview', icon: Icons.preview_rounded),
            _PreviewCard(settings: settings),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset All Settings to Defaults'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _showResetDialog(context, ref),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will restore all settings to their default values. '
          'Your calculation history and favorites will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx, true);
              ref.read(appSettingsProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            dropdownColor: colorScheme.surface,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            borderRadius: BorderRadius.circular(12),
            isDense: true,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(min.round().toString(), style: textTheme.labelSmall),
                Text(max.round().toString(), style: textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final AppSettings settings;

  const _PreviewCard({required this.settings});

  String _formatSampleNumber(AppSettings s) {
    const sampleValue = 1234567.891234567890;
    switch (s.displayFormat) {
      case 'scientific':
        return sampleValue.toStringAsExponential(s.decimalPlaces.clamp(0, 15));
      case 'engineering':
        return '1.234567 × 10^6';
      case 'dms':
        return '343° 21\' 54"';
      default:
        return sampleValue.toStringAsFixed(s.decimalPlaces.clamp(0, 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sample Output', style: textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatSampleNumber(settings),
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'RobotoMono',
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _PreviewChip(label: 'Format: ${settings.displayFormat}', cs: colorScheme),
                _PreviewChip(label: 'Angle: ${settings.angleMode}', cs: colorScheme),
                _PreviewChip(label: 'Theme: ${settings.theme}', cs: colorScheme),
                _PreviewChip(label: 'RPN: ${settings.rpnModeEnabled ? "on" : "off"}', cs: colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;
  final ColorScheme cs;

  const _PreviewChip({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: cs.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
