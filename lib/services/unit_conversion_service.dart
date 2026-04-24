import 'dart:math' as math;

enum UnitCategory {
  length,
  mass,
  time,
  temperature,
  area,
  volume,
  speed,
  force,
  energy,
  power,
  pressure,
  electricCurrent,
  voltage,
  resistance,
  frequency,
  digitalStorage,
  angle,
  luminance,
  fuelEconomy,
  density,
  torque,
  viscosity,
  magneticFlux,
  radioactivity,
  concentration,
  flowRate,
}

extension UnitCategoryLabel on UnitCategory {
  String get label {
    switch (this) {
      case UnitCategory.length: return 'Length';
      case UnitCategory.mass: return 'Mass';
      case UnitCategory.time: return 'Time';
      case UnitCategory.temperature: return 'Temperature';
      case UnitCategory.area: return 'Area';
      case UnitCategory.volume: return 'Volume';
      case UnitCategory.speed: return 'Speed';
      case UnitCategory.force: return 'Force';
      case UnitCategory.energy: return 'Energy';
      case UnitCategory.power: return 'Power';
      case UnitCategory.pressure: return 'Pressure';
      case UnitCategory.electricCurrent: return 'Electric Current';
      case UnitCategory.voltage: return 'Voltage';
      case UnitCategory.resistance: return 'Resistance';
      case UnitCategory.frequency: return 'Frequency';
      case UnitCategory.digitalStorage: return 'Digital Storage';
      case UnitCategory.angle: return 'Angle';
      case UnitCategory.luminance: return 'Luminance';
      case UnitCategory.fuelEconomy: return 'Fuel Economy';
      case UnitCategory.density: return 'Density';
      case UnitCategory.torque: return 'Torque';
      case UnitCategory.viscosity: return 'Viscosity';
      case UnitCategory.magneticFlux: return 'Magnetic Flux';
      case UnitCategory.radioactivity: return 'Radioactivity';
      case UnitCategory.concentration: return 'Concentration';
      case UnitCategory.flowRate: return 'Flow Rate';
    }
  }
}

class UnitDefinition {
  final String name;
  final String symbol;
  final UnitCategory category;
  final double toBaseFactor;
  final double toBaseOffset;
  final bool isTemperature;

  const UnitDefinition({
    required this.name,
    required this.symbol,
    required this.category,
    required this.toBaseFactor,
    this.toBaseOffset = 0.0,
    this.isTemperature = false,
  });

  double toBase(double value) => value * toBaseFactor + toBaseOffset;
  double fromBase(double baseValue) => (baseValue - toBaseOffset) / toBaseFactor;

  @override
  String toString() => '$name ($symbol)';
}

class ConversionResult {
  final double inputValue;
  final double outputValue;
  final UnitDefinition fromUnit;
  final UnitDefinition toUnit;
  final double conversionFactor;
  final UnitCategory category;

  const ConversionResult({
    required this.inputValue,
    required this.outputValue,
    required this.fromUnit,
    required this.toUnit,
    required this.conversionFactor,
    required this.category,
  });

  String get formattedOutput {
    if (outputValue.abs() >= 1e15 || (outputValue.abs() < 1e-6 && outputValue != 0)) {
      return outputValue.toStringAsExponential(10);
    }
    final s = outputValue.toStringAsFixed(12);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return trimmed;
  }

  @override
  String toString() => '$inputValue ${fromUnit.symbol} = $outputValue ${toUnit.symbol}';
}

class UnitConversionService {
  static final UnitConversionService instance = UnitConversionService._internal();
  UnitConversionService._internal();

  late final List<UnitDefinition> _allUnits;
  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    _allUnits = _buildAllUnits();
    _initialized = true;
  }

  List<UnitDefinition> _buildAllUnits() {
    return [
      // ─── LENGTH (base: meter) ───────────────────────────────────────────────
      const UnitDefinition(name: 'Yottameter', symbol: 'Ym', category: UnitCategory.length, toBaseFactor: 1e24),
      const UnitDefinition(name: 'Zettameter', symbol: 'Zm', category: UnitCategory.length, toBaseFactor: 1e21),
      const UnitDefinition(name: 'Exameter', symbol: 'Em', category: UnitCategory.length, toBaseFactor: 1e18),
      const UnitDefinition(name: 'Petameter', symbol: 'Pm', category: UnitCategory.length, toBaseFactor: 1e15),
      const UnitDefinition(name: 'Terameter', symbol: 'Tm', category: UnitCategory.length, toBaseFactor: 1e12),
      const UnitDefinition(name: 'Gigameter', symbol: 'Gm', category: UnitCategory.length, toBaseFactor: 1e9),
      const UnitDefinition(name: 'Megameter', symbol: 'Mm', category: UnitCategory.length, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Kilometer', symbol: 'km', category: UnitCategory.length, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Hectometer', symbol: 'hm', category: UnitCategory.length, toBaseFactor: 1e2),
      const UnitDefinition(name: 'Decameter', symbol: 'dam', category: UnitCategory.length, toBaseFactor: 1e1),
      const UnitDefinition(name: 'Meter', symbol: 'm', category: UnitCategory.length, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Decimeter', symbol: 'dm', category: UnitCategory.length, toBaseFactor: 1e-1),
      const UnitDefinition(name: 'Centimeter', symbol: 'cm', category: UnitCategory.length, toBaseFactor: 1e-2),
      const UnitDefinition(name: 'Millimeter', symbol: 'mm', category: UnitCategory.length, toBaseFactor: 1e-3),
      const UnitDefinition(name: 'Micrometer', symbol: 'μm', category: UnitCategory.length, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Nanometer', symbol: 'nm', category: UnitCategory.length, toBaseFactor: 1e-9),
      const UnitDefinition(name: 'Picometer', symbol: 'pm', category: UnitCategory.length, toBaseFactor: 1e-12),
      const UnitDefinition(name: 'Femtometer', symbol: 'fm', category: UnitCategory.length, toBaseFactor: 1e-15),
      const UnitDefinition(name: 'Angstrom', symbol: 'Å', category: UnitCategory.length, toBaseFactor: 1e-10),
      const UnitDefinition(name: 'Inch', symbol: 'in', category: UnitCategory.length, toBaseFactor: 0.0254),
      const UnitDefinition(name: 'Foot', symbol: 'ft', category: UnitCategory.length, toBaseFactor: 0.3048),
      const UnitDefinition(name: 'Yard', symbol: 'yd', category: UnitCategory.length, toBaseFactor: 0.9144),
      const UnitDefinition(name: 'Mile', symbol: 'mi', category: UnitCategory.length, toBaseFactor: 1609.344),
      const UnitDefinition(name: 'Nautical Mile', symbol: 'nmi', category: UnitCategory.length, toBaseFactor: 1852.0),
      const UnitDefinition(name: 'Fathom', symbol: 'fath', category: UnitCategory.length, toBaseFactor: 1.8288),
      const UnitDefinition(name: 'Furlong', symbol: 'fur', category: UnitCategory.length, toBaseFactor: 201.168),
      const UnitDefinition(name: 'Light Year', symbol: 'ly', category: UnitCategory.length, toBaseFactor: 9.4607304725808e15),
      const UnitDefinition(name: 'Astronomical Unit', symbol: 'AU', category: UnitCategory.length, toBaseFactor: 1.495978707e11),
      const UnitDefinition(name: 'Parsec', symbol: 'pc', category: UnitCategory.length, toBaseFactor: 3.085677581e16),

      // ─── MASS (base: kilogram) ──────────────────────────────────────────────
      const UnitDefinition(name: 'Kilogram', symbol: 'kg', category: UnitCategory.mass, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Gram', symbol: 'g', category: UnitCategory.mass, toBaseFactor: 1e-3),
      const UnitDefinition(name: 'Milligram', symbol: 'mg', category: UnitCategory.mass, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Microgram', symbol: 'μg', category: UnitCategory.mass, toBaseFactor: 1e-9),
      const UnitDefinition(name: 'Metric Ton', symbol: 't', category: UnitCategory.mass, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Pound', symbol: 'lb', category: UnitCategory.mass, toBaseFactor: 0.45359237),
      const UnitDefinition(name: 'Ounce', symbol: 'oz', category: UnitCategory.mass, toBaseFactor: 0.028349523125),
      const UnitDefinition(name: 'Stone', symbol: 'st', category: UnitCategory.mass, toBaseFactor: 6.35029318),
      const UnitDefinition(name: 'Short Ton', symbol: 'ton', category: UnitCategory.mass, toBaseFactor: 907.18474),
      const UnitDefinition(name: 'Long Ton', symbol: 'LT', category: UnitCategory.mass, toBaseFactor: 1016.0469088),
      const UnitDefinition(name: 'Carat', symbol: 'ct', category: UnitCategory.mass, toBaseFactor: 2e-4),
      const UnitDefinition(name: 'Grain', symbol: 'gr', category: UnitCategory.mass, toBaseFactor: 6.479891e-5),
      const UnitDefinition(name: 'Dalton', symbol: 'Da', category: UnitCategory.mass, toBaseFactor: 1.66053906660e-27),

      // ─── TIME (base: second) ────────────────────────────────────────────────
      const UnitDefinition(name: 'Second', symbol: 's', category: UnitCategory.time, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Millisecond', symbol: 'ms', category: UnitCategory.time, toBaseFactor: 1e-3),
      const UnitDefinition(name: 'Microsecond', symbol: 'μs', category: UnitCategory.time, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Nanosecond', symbol: 'ns', category: UnitCategory.time, toBaseFactor: 1e-9),
      const UnitDefinition(name: 'Picosecond', symbol: 'ps', category: UnitCategory.time, toBaseFactor: 1e-12),
      const UnitDefinition(name: 'Femtosecond', symbol: 'fs', category: UnitCategory.time, toBaseFactor: 1e-15),
      const UnitDefinition(name: 'Minute', symbol: 'min', category: UnitCategory.time, toBaseFactor: 60.0),
      const UnitDefinition(name: 'Hour', symbol: 'h', category: UnitCategory.time, toBaseFactor: 3600.0),
      const UnitDefinition(name: 'Day', symbol: 'd', category: UnitCategory.time, toBaseFactor: 86400.0),
      const UnitDefinition(name: 'Week', symbol: 'wk', category: UnitCategory.time, toBaseFactor: 604800.0),
      const UnitDefinition(name: 'Month', symbol: 'mo', category: UnitCategory.time, toBaseFactor: 2629746.0),
      const UnitDefinition(name: 'Year', symbol: 'yr', category: UnitCategory.time, toBaseFactor: 31556952.0),
      const UnitDefinition(name: 'Decade', symbol: 'dec', category: UnitCategory.time, toBaseFactor: 315569520.0),
      const UnitDefinition(name: 'Century', symbol: 'cent', category: UnitCategory.time, toBaseFactor: 3155695200.0),
      const UnitDefinition(name: 'Millennium', symbol: 'mill', category: UnitCategory.time, toBaseFactor: 31556952000.0),

      // ─── TEMPERATURE (base: Kelvin) ─────────────────────────────────────────
      const UnitDefinition(name: 'Kelvin', symbol: 'K', category: UnitCategory.temperature, toBaseFactor: 1.0, toBaseOffset: 0.0, isTemperature: true),
      const UnitDefinition(name: 'Celsius', symbol: '°C', category: UnitCategory.temperature, toBaseFactor: 1.0, toBaseOffset: 273.15, isTemperature: true),
      UnitDefinition(name: 'Fahrenheit', symbol: '°F', category: UnitCategory.temperature, toBaseFactor: 5.0 / 9.0, toBaseOffset: 459.67 * 5.0 / 9.0, isTemperature: true),
      UnitDefinition(name: 'Rankine', symbol: '°R', category: UnitCategory.temperature, toBaseFactor: 5.0 / 9.0, toBaseOffset: 0.0, isTemperature: true),
      UnitDefinition(name: 'Réaumur', symbol: '°Ré', category: UnitCategory.temperature, toBaseFactor: 5.0 / 4.0, toBaseOffset: 273.15, isTemperature: true),

      // ─── AREA (base: square meter) ──────────────────────────────────────────
      const UnitDefinition(name: 'Square Kilometer', symbol: 'km²', category: UnitCategory.area, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Square Meter', symbol: 'm²', category: UnitCategory.area, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Square Centimeter', symbol: 'cm²', category: UnitCategory.area, toBaseFactor: 1e-4),
      const UnitDefinition(name: 'Square Millimeter', symbol: 'mm²', category: UnitCategory.area, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Hectare', symbol: 'ha', category: UnitCategory.area, toBaseFactor: 1e4),
      const UnitDefinition(name: 'Are', symbol: 'a', category: UnitCategory.area, toBaseFactor: 100.0),
      const UnitDefinition(name: 'Square Inch', symbol: 'in²', category: UnitCategory.area, toBaseFactor: 6.4516e-4),
      const UnitDefinition(name: 'Square Foot', symbol: 'ft²', category: UnitCategory.area, toBaseFactor: 0.09290304),
      const UnitDefinition(name: 'Square Yard', symbol: 'yd²', category: UnitCategory.area, toBaseFactor: 0.83612736),
      const UnitDefinition(name: 'Square Mile', symbol: 'mi²', category: UnitCategory.area, toBaseFactor: 2589988.110336),
      const UnitDefinition(name: 'Acre', symbol: 'ac', category: UnitCategory.area, toBaseFactor: 4046.8564224),

      // ─── VOLUME (base: cubic meter) ─────────────────────────────────────────
      const UnitDefinition(name: 'Cubic Meter', symbol: 'm³', category: UnitCategory.volume, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Liter', symbol: 'L', category: UnitCategory.volume, toBaseFactor: 1e-3),
      const UnitDefinition(name: 'Milliliter', symbol: 'mL', category: UnitCategory.volume, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Centiliter', symbol: 'cL', category: UnitCategory.volume, toBaseFactor: 1e-5),
      const UnitDefinition(name: 'Deciliter', symbol: 'dL', category: UnitCategory.volume, toBaseFactor: 1e-4),
      const UnitDefinition(name: 'Cubic Centimeter', symbol: 'cm³', category: UnitCategory.volume, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Cubic Inch', symbol: 'in³', category: UnitCategory.volume, toBaseFactor: 1.6387064e-5),
      const UnitDefinition(name: 'Cubic Foot', symbol: 'ft³', category: UnitCategory.volume, toBaseFactor: 0.028316846592),
      const UnitDefinition(name: 'Cubic Yard', symbol: 'yd³', category: UnitCategory.volume, toBaseFactor: 0.764554857984),
      const UnitDefinition(name: 'US Gallon', symbol: 'gal', category: UnitCategory.volume, toBaseFactor: 0.003785411784),
      const UnitDefinition(name: 'US Quart', symbol: 'qt', category: UnitCategory.volume, toBaseFactor: 9.46352946e-4),
      const UnitDefinition(name: 'US Pint', symbol: 'pt', category: UnitCategory.volume, toBaseFactor: 4.73176473e-4),
      const UnitDefinition(name: 'US Cup', symbol: 'cup', category: UnitCategory.volume, toBaseFactor: 2.365882365e-4),
      const UnitDefinition(name: 'US Fluid Ounce', symbol: 'fl oz', category: UnitCategory.volume, toBaseFactor: 2.95735295625e-5),
      const UnitDefinition(name: 'US Tablespoon', symbol: 'tbsp', category: UnitCategory.volume, toBaseFactor: 1.47867647813e-5),
      const UnitDefinition(name: 'US Teaspoon', symbol: 'tsp', category: UnitCategory.volume, toBaseFactor: 4.92892159375e-6),
      const UnitDefinition(name: 'Imperial Gallon', symbol: 'imp gal', category: UnitCategory.volume, toBaseFactor: 0.00454609),
      const UnitDefinition(name: 'Imperial Pint', symbol: 'imp pt', category: UnitCategory.volume, toBaseFactor: 5.6826125e-4),
      const UnitDefinition(name: 'Barrel (oil)', symbol: 'bbl', category: UnitCategory.volume, toBaseFactor: 0.158987294928),

      // ─── SPEED (base: meter per second) ─────────────────────────────────────
      const UnitDefinition(name: 'Meter per Second', symbol: 'm/s', category: UnitCategory.speed, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilometer per Hour', symbol: 'km/h', category: UnitCategory.speed, toBaseFactor: 1.0 / 3.6),
      const UnitDefinition(name: 'Mile per Hour', symbol: 'mph', category: UnitCategory.speed, toBaseFactor: 0.44704),
      const UnitDefinition(name: 'Foot per Second', symbol: 'ft/s', category: UnitCategory.speed, toBaseFactor: 0.3048),
      const UnitDefinition(name: 'Knot', symbol: 'kn', category: UnitCategory.speed, toBaseFactor: 0.514444),
      const UnitDefinition(name: 'Mach', symbol: 'Ma', category: UnitCategory.speed, toBaseFactor: 340.29),
      const UnitDefinition(name: 'Speed of Light', symbol: 'c', category: UnitCategory.speed, toBaseFactor: 299792458.0),

      // ─── FORCE (base: Newton) ───────────────────────────────────────────────
      const UnitDefinition(name: 'Newton', symbol: 'N', category: UnitCategory.force, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilonewton', symbol: 'kN', category: UnitCategory.force, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Meganewton', symbol: 'MN', category: UnitCategory.force, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Dyne', symbol: 'dyn', category: UnitCategory.force, toBaseFactor: 1e-5),
      const UnitDefinition(name: 'Pound-force', symbol: 'lbf', category: UnitCategory.force, toBaseFactor: 4.44822),
      const UnitDefinition(name: 'Kilogram-force', symbol: 'kgf', category: UnitCategory.force, toBaseFactor: 9.80665),

      // ─── ENERGY (base: Joule) ───────────────────────────────────────────────
      const UnitDefinition(name: 'Joule', symbol: 'J', category: UnitCategory.energy, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilojoule', symbol: 'kJ', category: UnitCategory.energy, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megajoule', symbol: 'MJ', category: UnitCategory.energy, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Calorie', symbol: 'cal', category: UnitCategory.energy, toBaseFactor: 4.184),
      const UnitDefinition(name: 'Kilocalorie', symbol: 'kcal', category: UnitCategory.energy, toBaseFactor: 4184.0),
      const UnitDefinition(name: 'Watt-hour', symbol: 'Wh', category: UnitCategory.energy, toBaseFactor: 3600.0),
      const UnitDefinition(name: 'Kilowatt-hour', symbol: 'kWh', category: UnitCategory.energy, toBaseFactor: 3600000.0),
      const UnitDefinition(name: 'Electronvolt', symbol: 'eV', category: UnitCategory.energy, toBaseFactor: 1.60218e-19),
      const UnitDefinition(name: 'BTU', symbol: 'BTU', category: UnitCategory.energy, toBaseFactor: 1055.06),
      const UnitDefinition(name: 'Foot-pound', symbol: 'ft·lbf', category: UnitCategory.energy, toBaseFactor: 1.35582),
      const UnitDefinition(name: 'Erg', symbol: 'erg', category: UnitCategory.energy, toBaseFactor: 1e-7),

      // ─── POWER (base: Watt) ─────────────────────────────────────────────────
      const UnitDefinition(name: 'Watt', symbol: 'W', category: UnitCategory.power, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilowatt', symbol: 'kW', category: UnitCategory.power, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megawatt', symbol: 'MW', category: UnitCategory.power, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Gigawatt', symbol: 'GW', category: UnitCategory.power, toBaseFactor: 1e9),
      const UnitDefinition(name: 'Horsepower', symbol: 'hp', category: UnitCategory.power, toBaseFactor: 745.7),
      const UnitDefinition(name: 'Milliwatt', symbol: 'mW', category: UnitCategory.power, toBaseFactor: 0.001),

      // ─── PRESSURE (base: Pascal) ────────────────────────────────────────────
      const UnitDefinition(name: 'Pascal', symbol: 'Pa', category: UnitCategory.pressure, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilopascal', symbol: 'kPa', category: UnitCategory.pressure, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megapascal', symbol: 'MPa', category: UnitCategory.pressure, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Bar', symbol: 'bar', category: UnitCategory.pressure, toBaseFactor: 1e5),
      const UnitDefinition(name: 'Millibar', symbol: 'mbar', category: UnitCategory.pressure, toBaseFactor: 100.0),
      const UnitDefinition(name: 'Atmosphere', symbol: 'atm', category: UnitCategory.pressure, toBaseFactor: 101325.0),
      const UnitDefinition(name: 'Torr', symbol: 'Torr', category: UnitCategory.pressure, toBaseFactor: 133.322),
      const UnitDefinition(name: 'mmHg', symbol: 'mmHg', category: UnitCategory.pressure, toBaseFactor: 133.322),
      const UnitDefinition(name: 'PSI', symbol: 'psi', category: UnitCategory.pressure, toBaseFactor: 6894.76),

      // ─── ELECTRIC CURRENT (base: Ampere) ────────────────────────────────────
      const UnitDefinition(name: 'Ampere', symbol: 'A', category: UnitCategory.electricCurrent, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Milliampere', symbol: 'mA', category: UnitCategory.electricCurrent, toBaseFactor: 0.001),
      const UnitDefinition(name: 'Microampere', symbol: 'μA', category: UnitCategory.electricCurrent, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Kiloampere', symbol: 'kA', category: UnitCategory.electricCurrent, toBaseFactor: 1e3),

      // ─── VOLTAGE (base: Volt) ───────────────────────────────────────────────
      const UnitDefinition(name: 'Volt', symbol: 'V', category: UnitCategory.voltage, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Millivolt', symbol: 'mV', category: UnitCategory.voltage, toBaseFactor: 0.001),
      const UnitDefinition(name: 'Microvolt', symbol: 'μV', category: UnitCategory.voltage, toBaseFactor: 1e-6),
      const UnitDefinition(name: 'Kilovolt', symbol: 'kV', category: UnitCategory.voltage, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megavolt', symbol: 'MV', category: UnitCategory.voltage, toBaseFactor: 1e6),

      // ─── RESISTANCE (base: Ohm) ─────────────────────────────────────────────
      const UnitDefinition(name: 'Ohm', symbol: 'Ω', category: UnitCategory.resistance, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Milliohm', symbol: 'mΩ', category: UnitCategory.resistance, toBaseFactor: 0.001),
      const UnitDefinition(name: 'Kilohm', symbol: 'kΩ', category: UnitCategory.resistance, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megohm', symbol: 'MΩ', category: UnitCategory.resistance, toBaseFactor: 1e6),

      // ─── FREQUENCY (base: Hertz) ────────────────────────────────────────────
      const UnitDefinition(name: 'Hertz', symbol: 'Hz', category: UnitCategory.frequency, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Kilohertz', symbol: 'kHz', category: UnitCategory.frequency, toBaseFactor: 1e3),
      const UnitDefinition(name: 'Megahertz', symbol: 'MHz', category: UnitCategory.frequency, toBaseFactor: 1e6),
      const UnitDefinition(name: 'Gigahertz', symbol: 'GHz', category: UnitCategory.frequency, toBaseFactor: 1e9),
      const UnitDefinition(name: 'Terahertz', symbol: 'THz', category: UnitCategory.frequency, toBaseFactor: 1e12),
      const UnitDefinition(name: 'RPM', symbol: 'rpm', category: UnitCategory.frequency, toBaseFactor: 1.0 / 60.0),

      // ─── DIGITAL STORAGE (base: bit) ────────────────────────────────────────
      const UnitDefinition(name: 'Bit', symbol: 'bit', category: UnitCategory.digitalStorage, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Byte', symbol: 'B', category: UnitCategory.digitalStorage, toBaseFactor: 8.0),
      const UnitDefinition(name: 'Kilobyte', symbol: 'kB', category: UnitCategory.digitalStorage, toBaseFactor: 8000.0),
      const UnitDefinition(name: 'Kibibyte', symbol: 'KiB', category: UnitCategory.digitalStorage, toBaseFactor: 8192.0),
      const UnitDefinition(name: 'Megabyte', symbol: 'MB', category: UnitCategory.digitalStorage, toBaseFactor: 8e6),
      const UnitDefinition(name: 'Mebibyte', symbol: 'MiB', category: UnitCategory.digitalStorage, toBaseFactor: 8388608.0),
      const UnitDefinition(name: 'Gigabyte', symbol: 'GB', category: UnitCategory.digitalStorage, toBaseFactor: 8e9),
      const UnitDefinition(name: 'Gibibyte', symbol: 'GiB', category: UnitCategory.digitalStorage, toBaseFactor: 8589934592.0),
      const UnitDefinition(name: 'Terabyte', symbol: 'TB', category: UnitCategory.digitalStorage, toBaseFactor: 8e12),
      const UnitDefinition(name: 'Petabyte', symbol: 'PB', category: UnitCategory.digitalStorage, toBaseFactor: 8e15),

      // ─── ANGLE (base: degree) ───────────────────────────────────────────────
      const UnitDefinition(name: 'Degree', symbol: '°', category: UnitCategory.angle, toBaseFactor: 1.0),
      UnitDefinition(name: 'Radian', symbol: 'rad', category: UnitCategory.angle, toBaseFactor: 180.0 / math.pi),
      const UnitDefinition(name: 'Gradian', symbol: 'grad', category: UnitCategory.angle, toBaseFactor: 0.9),
      const UnitDefinition(name: 'Arcminute', symbol: "'", category: UnitCategory.angle, toBaseFactor: 1.0 / 60.0),
      const UnitDefinition(name: 'Arcsecond', symbol: '"', category: UnitCategory.angle, toBaseFactor: 1.0 / 3600.0),
      const UnitDefinition(name: 'Turn', symbol: 'tr', category: UnitCategory.angle, toBaseFactor: 360.0),

      // ─── LUMINANCE (base: candela per square meter) ──────────────────────────
      const UnitDefinition(name: 'Candela/m²', symbol: 'cd/m²', category: UnitCategory.luminance, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Nit', symbol: 'nt', category: UnitCategory.luminance, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Foot-Lambert', symbol: 'fL', category: UnitCategory.luminance, toBaseFactor: 3.42626),
      const UnitDefinition(name: 'Lambert', symbol: 'L', category: UnitCategory.luminance, toBaseFactor: 3183.099),

      // ─── FUEL ECONOMY (base: km/L) ──────────────────────────────────────────
      const UnitDefinition(name: 'km/L', symbol: 'km/L', category: UnitCategory.fuelEconomy, toBaseFactor: 1.0),
      const UnitDefinition(name: 'mpg (US)', symbol: 'mpg', category: UnitCategory.fuelEconomy, toBaseFactor: 0.425144),
      const UnitDefinition(name: 'mpg (UK)', symbol: 'mpg UK', category: UnitCategory.fuelEconomy, toBaseFactor: 0.354006),

      // ─── DENSITY (base: kg/m³) ──────────────────────────────────────────────
      const UnitDefinition(name: 'kg/m³', symbol: 'kg/m³', category: UnitCategory.density, toBaseFactor: 1.0),
      const UnitDefinition(name: 'g/cm³', symbol: 'g/cm³', category: UnitCategory.density, toBaseFactor: 1000.0),
      const UnitDefinition(name: 'g/L', symbol: 'g/L', category: UnitCategory.density, toBaseFactor: 1.0),
      const UnitDefinition(name: 'lb/ft³', symbol: 'lb/ft³', category: UnitCategory.density, toBaseFactor: 16.0185),

      // ─── TORQUE (base: Newton-meter) ────────────────────────────────────────
      const UnitDefinition(name: 'Newton-meter', symbol: 'N·m', category: UnitCategory.torque, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Foot-pound', symbol: 'ft·lbf', category: UnitCategory.torque, toBaseFactor: 1.35582),
      const UnitDefinition(name: 'Inch-pound', symbol: 'in·lbf', category: UnitCategory.torque, toBaseFactor: 0.112985),
      const UnitDefinition(name: 'Kilogram-meter', symbol: 'kgf·m', category: UnitCategory.torque, toBaseFactor: 9.80665),

      // ─── VISCOSITY (base: Pascal-second) ────────────────────────────────────
      const UnitDefinition(name: 'Pascal-second', symbol: 'Pa·s', category: UnitCategory.viscosity, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Poise', symbol: 'P', category: UnitCategory.viscosity, toBaseFactor: 0.1),
      const UnitDefinition(name: 'Centipoise', symbol: 'cP', category: UnitCategory.viscosity, toBaseFactor: 0.001),

      // ─── MAGNETIC FLUX (base: Weber) ────────────────────────────────────────
      const UnitDefinition(name: 'Weber', symbol: 'Wb', category: UnitCategory.magneticFlux, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Maxwell', symbol: 'Mx', category: UnitCategory.magneticFlux, toBaseFactor: 1e-8),
      const UnitDefinition(name: 'Tesla·m²', symbol: 'T·m²', category: UnitCategory.magneticFlux, toBaseFactor: 1.0),

      // ─── RADIOACTIVITY (base: Becquerel) ────────────────────────────────────
      const UnitDefinition(name: 'Becquerel', symbol: 'Bq', category: UnitCategory.radioactivity, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Curie', symbol: 'Ci', category: UnitCategory.radioactivity, toBaseFactor: 3.7e10),
      const UnitDefinition(name: 'Rutherford', symbol: 'Rd', category: UnitCategory.radioactivity, toBaseFactor: 1e6),

      // ─── CONCENTRATION (base: mol/L) ────────────────────────────────────────
      const UnitDefinition(name: 'Molar', symbol: 'M', category: UnitCategory.concentration, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Millimolar', symbol: 'mM', category: UnitCategory.concentration, toBaseFactor: 0.001),
      const UnitDefinition(name: 'Micromolar', symbol: 'μM', category: UnitCategory.concentration, toBaseFactor: 1e-6),

      // ─── FLOW RATE (base: m³/s) ─────────────────────────────────────────────
      const UnitDefinition(name: 'Cubic Meter/Second', symbol: 'm³/s', category: UnitCategory.flowRate, toBaseFactor: 1.0),
      const UnitDefinition(name: 'Liter/Second', symbol: 'L/s', category: UnitCategory.flowRate, toBaseFactor: 0.001),
      const UnitDefinition(name: 'Liter/Minute', symbol: 'L/min', category: UnitCategory.flowRate, toBaseFactor: 1.0 / 60000.0),
      const UnitDefinition(name: 'Gallon/Minute', symbol: 'gal/min', category: UnitCategory.flowRate, toBaseFactor: 6.30902e-5),
    ];
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  List<UnitDefinition> getAllUnits() {
    _ensureInitialized();
    return List.unmodifiable(_allUnits);
  }

  List<UnitDefinition> getUnitsByCategory(UnitCategory category) {
    _ensureInitialized();
    return _allUnits.where((u) => u.category == category).toList();
  }

  List<UnitCategory> getAllCategories() {
    return UnitCategory.values;
  }

  List<UnitDefinition> search(String query) {
    _ensureInitialized();
    if (query.trim().isEmpty) return List.unmodifiable(_allUnits);
    final lower = query.toLowerCase().trim();
    return _allUnits.where((u) {
      return u.name.toLowerCase().contains(lower) ||
          u.symbol.toLowerCase().contains(lower) ||
          u.category.label.toLowerCase().contains(lower);
    }).toList();
  }

  UnitDefinition? findUnit(String nameOrSymbol) {
    _ensureInitialized();
    final lower = nameOrSymbol.toLowerCase().trim();
    try {
      return _allUnits.firstWhere(
        (u) => u.name.toLowerCase() == lower || u.symbol.toLowerCase() == lower,
      );
    } catch (_) {
      return null;
    }
  }

  ConversionResult? convert(double value, String fromNameOrSymbol, String toNameOrSymbol) {
    _ensureInitialized();
    final fromUnit = findUnit(fromNameOrSymbol);
    final toUnit = findUnit(toNameOrSymbol);
    if (fromUnit == null || toUnit == null) return null;
    if (fromUnit.category != toUnit.category) return null;

    final baseValue = fromUnit.toBase(value);
    final outputValue = toUnit.fromBase(baseValue);
    final factor = toUnit.toBaseFactor > 0 ? fromUnit.toBaseFactor / toUnit.toBaseFactor : 1.0;

    return ConversionResult(
      inputValue: value,
      outputValue: outputValue,
      fromUnit: fromUnit,
      toUnit: toUnit,
      conversionFactor: factor,
      category: fromUnit.category,
    );
  }

  double getConversionFactor(String fromNameOrSymbol, String toNameOrSymbol) {
    _ensureInitialized();
    final fromUnit = findUnit(fromNameOrSymbol);
    final toUnit = findUnit(toNameOrSymbol);
    if (fromUnit == null || toUnit == null) return 1.0;
    if (fromUnit.category != toUnit.category) return 1.0;
    return toUnit.toBaseFactor > 0 ? fromUnit.toBaseFactor / toUnit.toBaseFactor : 1.0;
  }
}
