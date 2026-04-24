// Step 1: Inventory
// This file DEFINES: CalculationHistory class with fields:
//   - id (int, non-nullable)
//   - expression (String, non-nullable)
//   - result (String, non-nullable)
//   - resultType (String, non-nullable)
//   - isComplex (bool, non-nullable)
//   - magnitude (String?, nullable)
//   - phase (String?, nullable)
//   - polarForm (String?, nullable)
//   - displayFormat (String, non-nullable)
//   - angleMode (String, non-nullable)
//   - inputMode (String, non-nullable)
//   - timestamp (DateTime, non-nullable)
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: history_service.dart, calculation_history_provider.dart, history_screen.dart, calculator_screen.dart
// toMap/fromMap → SQLite persistence via HistoryService
// toJson/fromJson → export via ExportService
// copyWith → provider state updates
//
// Step 3: User Journey Trace
// CalculatorScreen evaluates expression → creates CalculationHistory via constructor
// HistoryService.addCalculation() calls toMap() to insert into SQLite
// HistoryService.getAllHistory() calls fromMap() to reconstruct from SQLite rows
// ExportService calls toJson() to serialize for JSON export
// HistoryScreen displays history items using expression, result, timestamp fields
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// timestamp stored as ISO8601 string in SQLite, parsed back via DateTime.parse()

class CalculationHistory {
  final int id;
  final String expression;
  final String result;
  final String resultType;
  final bool isComplex;
  final String? magnitude;
  final String? phase;
  final String? polarForm;
  final String displayFormat;
  final String angleMode;
  final String inputMode;
  final DateTime timestamp;

  const CalculationHistory({
    required this.id,
    required this.expression,
    required this.result,
    required this.resultType,
    required this.isComplex,
    this.magnitude,
    this.phase,
    this.polarForm,
    required this.displayFormat,
    required this.angleMode,
    required this.inputMode,
    required this.timestamp,
  });

  CalculationHistory copyWith({
    int? id,
    String? expression,
    String? result,
    String? resultType,
    bool? isComplex,
    String? magnitude,
    String? phase,
    String? polarForm,
    String? displayFormat,
    String? angleMode,
    String? inputMode,
    DateTime? timestamp,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      resultType: resultType ?? this.resultType,
      isComplex: isComplex ?? this.isComplex,
      magnitude: magnitude ?? this.magnitude,
      phase: phase ?? this.phase,
      polarForm: polarForm ?? this.polarForm,
      displayFormat: displayFormat ?? this.displayFormat,
      angleMode: angleMode ?? this.angleMode,
      inputMode: inputMode ?? this.inputMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'resultType': resultType,
      'isComplex': isComplex,
      'magnitude': magnitude,
      'phase': phase,
      'polarForm': polarForm,
      'displayFormat': displayFormat,
      'angleMode': angleMode,
      'inputMode': inputMode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      id: json['id'] as int,
      expression: json['expression'] as String,
      result: json['result'] as String,
      resultType: json['resultType'] as String,
      isComplex: json['isComplex'] as bool,
      magnitude: json['magnitude'] as String?,
      phase: json['phase'] as String?,
      polarForm: json['polarForm'] as String?,
      displayFormat: json['displayFormat'] as String,
      angleMode: json['angleMode'] as String,
      inputMode: json['inputMode'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'expression': expression,
      'result': result,
      'result_type': resultType,
      'is_complex': isComplex ? 1 : 0,
      'magnitude': magnitude,
      'phase': phase,
      'polar_form': polarForm,
      'display_format': displayFormat,
      'angle_mode': angleMode,
      'input_mode': inputMode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'] as int,
      expression: map['expression'] as String,
      result: map['result'] as String,
      resultType: map['result_type'] as String,
      isComplex: (map['is_complex'] as int) == 1,
      magnitude: map['magnitude'] as String?,
      phase: map['phase'] as String?,
      polarForm: map['polar_form'] as String?,
      displayFormat: map['display_format'] as String,
      angleMode: map['angle_mode'] as String,
      inputMode: map['input_mode'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'CalculationHistory(id: $id, expression: $expression, result: $result, '
        'resultType: $resultType, isComplex: $isComplex, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}