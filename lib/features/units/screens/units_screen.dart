import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';

class UnitsScreen extends ConsumerStatefulWidget {
  final String? initialValue;

  const UnitsScreen({super.key, this.initialValue});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  String _selectedCategory = 'Length';
  String _fromUnit = 'meter';
  String _toUnit = 'kilometer';
  String _resultText = '';
  String _errorText = '';
  bool _isConverting = false;
  Timer? _debounce;

  // Full unit database: category → list of {name, symbol, toBase factor, offset}
  static const Map<String, List<Map<String, dynamic>>> _unitDatabase = {
    'Length': [
      {'name': 'meter', 'symbol': 'm', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilometer', 'symbol': 'km', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'centimeter', 'symbol': 'cm', 'factor': 0.01, 'offset': 0.0},
      {'name': 'millimeter', 'symbol': 'mm', 'factor': 0.001, 'offset': 0.0},
      {'name': 'micrometer', 'symbol': 'μm', 'factor': 1e-6, 'offset': 0.0},
      {'name': 'nanometer', 'symbol': 'nm', 'factor': 1e-9, 'offset': 0.0},
      {'name': 'mile', 'symbol': 'mi', 'factor': 1609.344, 'offset': 0.0},
      {'name': 'yard', 'symbol': 'yd', 'factor': 0.9144, 'offset': 0.0},
      {'name': 'foot', 'symbol': 'ft', 'factor': 0.3048, 'offset': 0.0},
      {'name': 'inch', 'symbol': 'in', 'factor': 0.0254, 'offset': 0.0},
      {'name': 'nautical mile', 'symbol': 'nmi', 'factor': 1852.0, 'offset': 0.0},
      {'name': 'light year', 'symbol': 'ly', 'factor': 9.461e15, 'offset': 0.0},
    ],
    'Mass': [
      {'name': 'kilogram', 'symbol': 'kg', 'factor': 1.0, 'offset': 0.0},
      {'name': 'gram', 'symbol': 'g', 'factor': 0.001, 'offset': 0.0},
      {'name': 'milligram', 'symbol': 'mg', 'factor': 1e-6, 'offset': 0.0},
      {'name': 'tonne', 'symbol': 't', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'pound', 'symbol': 'lb', 'factor': 0.453592, 'offset': 0.0},
      {'name': 'ounce', 'symbol': 'oz', 'factor': 0.0283495, 'offset': 0.0},
      {'name': 'stone', 'symbol': 'st', 'factor': 6.35029, 'offset': 0.0},
    ],
    'Temperature': [
      {'name': 'celsius', 'symbol': '°C', 'factor': 1.0, 'offset': 0.0},
      {'name': 'fahrenheit', 'symbol': '°F', 'factor': 5.0 / 9.0, 'offset': -32.0},
      {'name': 'kelvin', 'symbol': 'K', 'factor': 1.0, 'offset': -273.15},
      {'name': 'rankine', 'symbol': '°R', 'factor': 5.0 / 9.0, 'offset': -491.67},
    ],
    'Time': [
      {'name': 'second', 'symbol': 's', 'factor': 1.0, 'offset': 0.0},
      {'name': 'millisecond', 'symbol': 'ms', 'factor': 0.001, 'offset': 0.0},
      {'name': 'microsecond', 'symbol': 'μs', 'factor': 1e-6, 'offset': 0.0},
      {'name': 'minute', 'symbol': 'min', 'factor': 60.0, 'offset': 0.0},
      {'name': 'hour', 'symbol': 'h', 'factor': 3600.0, 'offset': 0.0},
      {'name': 'day', 'symbol': 'd', 'factor': 86400.0, 'offset': 0.0},
      {'name': 'week', 'symbol': 'wk', 'factor': 604800.0, 'offset': 0.0},
      {'name': 'year', 'symbol': 'yr', 'factor': 31557600.0, 'offset': 0.0},
    ],
    'Area': [
      {'name': 'square meter', 'symbol': 'm²', 'factor': 1.0, 'offset': 0.0},
      {'name': 'square kilometer', 'symbol': 'km²', 'factor': 1e6, 'offset': 0.0},
      {'name': 'square centimeter', 'symbol': 'cm²', 'factor': 1e-4, 'offset': 0.0},
      {'name': 'square mile', 'symbol': 'mi²', 'factor': 2589988.11, 'offset': 0.0},
      {'name': 'square foot', 'symbol': 'ft²', 'factor': 0.092903, 'offset': 0.0},
      {'name': 'hectare', 'symbol': 'ha', 'factor': 10000.0, 'offset': 0.0},
      {'name': 'acre', 'symbol': 'ac', 'factor': 4046.86, 'offset': 0.0},
    ],
    'Volume': [
      {'name': 'cubic meter', 'symbol': 'm³', 'factor': 1.0, 'offset': 0.0},
      {'name': 'liter', 'symbol': 'L', 'factor': 0.001, 'offset': 0.0},
      {'name': 'milliliter', 'symbol': 'mL', 'factor': 1e-6, 'offset': 0.0},
      {'name': 'cubic inch', 'symbol': 'in³', 'factor': 1.6387e-5, 'offset': 0.0},
      {'name': 'cubic foot', 'symbol': 'ft³', 'factor': 0.0283168, 'offset': 0.0},
      {'name': 'gallon (US)', 'symbol': 'gal', 'factor': 0.00378541, 'offset': 0.0},
      {'name': 'fluid ounce (US)', 'symbol': 'fl oz', 'factor': 2.95735e-5, 'offset': 0.0},
    ],
    'Speed': [
      {'name': 'meter per second', 'symbol': 'm/s', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilometer per hour', 'symbol': 'km/h', 'factor': 1.0 / 3.6, 'offset': 0.0},
      {'name': 'mile per hour', 'symbol': 'mph', 'factor': 0.44704, 'offset': 0.0},
      {'name': 'knot', 'symbol': 'kn', 'factor': 0.514444, 'offset': 0.0},
      {'name': 'foot per second', 'symbol': 'ft/s', 'factor': 0.3048, 'offset': 0.0},
    ],
    'Pressure': [
      {'name': 'pascal', 'symbol': 'Pa', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilopascal', 'symbol': 'kPa', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'bar', 'symbol': 'bar', 'factor': 1e5, 'offset': 0.0},
      {'name': 'atmosphere', 'symbol': 'atm', 'factor': 101325.0, 'offset': 0.0},
      {'name': 'psi', 'symbol': 'psi', 'factor': 6894.76, 'offset': 0.0},
      {'name': 'mmHg', 'symbol': 'mmHg', 'factor': 133.322, 'offset': 0.0},
    ],
    'Energy': [
      {'name': 'joule', 'symbol': 'J', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilojoule', 'symbol': 'kJ', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'calorie', 'symbol': 'cal', 'factor': 4.184, 'offset': 0.0},
      {'name': 'kilocalorie', 'symbol': 'kcal', 'factor': 4184.0, 'offset': 0.0},
      {'name': 'kilowatt-hour', 'symbol': 'kWh', 'factor': 3600000.0, 'offset': 0.0},
      {'name': 'BTU', 'symbol': 'BTU', 'factor': 1055.06, 'offset': 0.0},
    ],
    'Power': [
      {'name': 'watt', 'symbol': 'W', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilowatt', 'symbol': 'kW', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'megawatt', 'symbol': 'MW', 'factor': 1e6, 'offset': 0.0},
      {'name': 'horsepower', 'symbol': 'hp', 'factor': 745.7, 'offset': 0.0},
    ],
    'Data': [
      {'name': 'bit', 'symbol': 'bit', 'factor': 1.0, 'offset': 0.0},
      {'name': 'byte', 'symbol': 'B', 'factor': 8.0, 'offset': 0.0},
      {'name': 'kilobyte', 'symbol': 'kB', 'factor': 8000.0, 'offset': 0.0},
      {'name': 'megabyte', 'symbol': 'MB', 'factor': 8e6, 'offset': 0.0},
      {'name': 'gigabyte', 'symbol': 'GB', 'factor': 8e9, 'offset': 0.0},
      {'name': 'terabyte', 'symbol': 'TB', 'factor': 8e12, 'offset': 0.0},
    ],
    'Angle': [
      {'name': 'degree', 'symbol': '°', 'factor': 1.0, 'offset': 0.0},
      {'name': 'radian', 'symbol': 'rad', 'factor': 180.0 / 3.14159265358979, 'offset': 0.0},
      {'name': 'gradian', 'symbol': 'grad', 'factor': 0.9, 'offset': 0.0},
      {'name': 'arcminute', 'symbol': "'", 'factor': 1.0 / 60.0, 'offset': 0.0},
      {'name': 'arcsecond', 'symbol': '"', 'factor': 1.0 / 3600.0, 'offset': 0.0},
    ],
    'Frequency': [
      {'name': 'hertz', 'symbol': 'Hz', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilohertz', 'symbol': 'kHz', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'megahertz', 'symbol': 'MHz', 'factor': 1e6, 'offset': 0.0},
      {'name': 'gigahertz', 'symbol': 'GHz', 'factor': 1e9, 'offset': 0.0},
      {'name': 'rpm', 'symbol': 'rpm', 'factor': 1.0 / 60.0, 'offset': 0.0},
    ],
    'Force': [
      {'name': 'newton', 'symbol': 'N', 'factor': 1.0, 'offset': 0.0},
      {'name': 'kilonewton', 'symbol': 'kN', 'factor': 1000.0, 'offset': 0.0},
      {'name': 'pound-force', 'symbol': 'lbf', 'factor': 4.44822, 'offset': 0.0},
      {'name': 'kilogram-force', 'symbol': 'kgf', 'factor': 9.80665, 'offset': 0.0},
    ],
  };

  List<String> get _categories => _unitDatabase.keys.toList();

  List<Map<String, dynamic>> get _currentUnits =>
      _unitDatabase[_selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _inputController.text = widget.initialValue!;
    }
    _inputController.addListener(_onInputChanged);
    _ensureValidUnits();
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _searchController.dispose();
    _inputFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _ensureValidUnits() {
    final units = _currentUnits;
    if (units.isEmpty) return;
    final names = units.map((u) => u['name'] as String).toList();
    if (!names.contains(_fromUnit)) _fromUnit = names.first;
    if (!names.contains(_toUnit)) {
      _toUnit = names.length > 1 ? names[1] : names.first;
    }
    if (_fromUnit == _toUnit && names.length > 1) {
      _toUnit = names.firstWhere((n) => n != _fromUnit, orElse: () => names.first);
    }
  }

  void _onInputChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _convert);
  }

  void _convert() {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _resultText = '';
        _errorText = '';
      });
      return;
    }
    final inputValue = double.tryParse(inputText);
    if (inputValue == null) {
      setState(() {
        _errorText = 'Invalid number';
        _resultText = '';
      });
      return;
    }

    setState(() => _isConverting = true);

    try {
      final result = _performConversion(inputValue, _fromUnit, _toUnit);
      final fromSymbol = _getSymbol(_fromUnit);
      final toSymbol = _getSymbol(_toUnit);
      final resultStr = _formatResult(result);
      setState(() {
        _resultText = '$resultStr $toSymbol';
        _errorText = '';
        _isConverting = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Conversion error: $e';
        _resultText = '';
        _isConverting = false;
      });
    }
  }

  double _performConversion(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final units = _currentUnits;
    Map<String, dynamic>? fromData;
    Map<String, dynamic>? toData;

    for (final u in units) {
      if (u['name'] == fromUnit) fromData = u;
      if (u['name'] == toUnit) toData = u;
    }

    if (fromData == null || toData == null) {
      throw Exception('Unit not found');
    }

    final fromFactor = (fromData['factor'] as num).toDouble();
    final fromOffset = (fromData['offset'] as num).toDouble();
    final toFactor = (toData['factor'] as num).toDouble();
    final toOffset = (toData['offset'] as num).toDouble();

    // Convert to base unit: base = (value + offset) * factor
    // For temperature: base = (value - offset) * factor
    // Using: base = (value + fromOffset) * fromFactor
    // Then: result = base / toFactor - toOffset
    final baseValue = (value + fromOffset) * fromFactor;
    return baseValue / toFactor - toOffset;
  }

  String _getSymbol(String unitName) {
    for (final u in _currentUnits) {
      if (u['name'] == unitName) return u['symbol'] as String;
    }
    return unitName;
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value.abs() >= 1e12 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final s = value.toStringAsFixed(10);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convert();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _resultText = '';
      _errorText = '';
    });
    _ensureValidUnits();
    _convert();
  }

  void _insertResult() {
    if (_resultText.isNotEmpty) {
      // Extract just the number from the result
      final parts = _resultText.split(' ');
      if (parts.isNotEmpty) {
        Navigator.pop(context, parts.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final units = _currentUnits;
    final unitNames = units.map((u) => u['name'] as String).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        actions: [
          if (_resultText.isNotEmpty)
            TextButton.icon(
              onPressed: _insertResult,
              icon: const Icon(Icons.keyboard_return_rounded),
              label: const Text('Insert'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (sel) {
                      if (sel) _selectCategory(cat);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // From unit
                  Text('From',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: unitNames.contains(_fromUnit)
                              ? _fromUnit
                              : unitNames.first,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          items: unitNames
                              .map((n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(n,
                                        style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _fromUnit = v);
                              _convert();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _inputController,
                          focusNode: _inputFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter value',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            isDense: true,
                            suffixText: _getSymbol(_fromUnit),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Swap button
                  Center(
                    child: IconButton(
                      onPressed: _swapUnits,
                      icon: const Icon(Icons.swap_vert_rounded),
                      tooltip: 'Swap units',
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // To unit
                  Text('To',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: unitNames.contains(_toUnit)
                              ? _toUnit
                              : (unitNames.length > 1
                                  ? unitNames[1]
                                  : unitNames.first),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          items: unitNames
                              .map((n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(n,
                                        style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _toUnit = v);
                              _convert();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.3),
                            border: Border.all(
                                color: cs.primary.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isConverting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Text(
                                  _resultText.isNotEmpty
                                      ? _resultText
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _resultText.isNotEmpty
                                        ? cs.primary
                                        : cs.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (_errorText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorText,
                      style: TextStyle(color: cs.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Quick reference table
                  Text('Quick Reference',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...units.take(8).map((u) {
                    final name = u['name'] as String;
                    final symbol = u['symbol'] as String;
                    final inputVal =
                        double.tryParse(_inputController.text.trim()) ?? 1.0;
                    String converted = '—';
                    try {
                      final result =
                          _performConversion(inputVal, _fromUnit, name);
                      converted = '${_formatResult(result)} $symbol';
                    } catch (_) {}
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      cs.onSurface.withValues(alpha: 0.8)),
                            ),
                          ),
                          Text(
                            converted,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: name == _toUnit
                                  ? cs.primary
                                  : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
