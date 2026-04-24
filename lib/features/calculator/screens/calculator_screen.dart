import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/features/history/screens/history_screen.dart';
import 'package:scientific_pro_calculator/features/settings/screens/settings_screen.dart';
import 'package:scientific_pro_calculator/models/calculation_history.dart';
import 'package:scientific_pro_calculator/models/favorite_item.dart';
import 'package:scientific_pro_calculator/models/undo_redo_entry.dart';
import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';
import 'package:scientific_pro_calculator/providers/calculation_history_provider.dart';
import 'package:scientific_pro_calculator/providers/favorites_provider.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final TextEditingController expressionController = TextEditingController();
  String displayedResult = '0';
  String previewResult = '';
  bool isComplexResult = false;
  String magnitude = '0';
  String phase = '0';
  String polarForm = '0';
  bool rpnModeEnabled = false;
  List<String> rpnStack = [];
  List<UndoRedoEntry> undoStack = [];
  List<UndoRedoEntry> redoStack = [];
  List<FavoriteItem> favorites = [];
  bool isFavorited = false;
  String displayFormat = 'fixed';
  int decimalPlaces = 6;
  String angleMode = 'degrees';
  bool hapticEnabled = true;
  Timer? debounceTimer;
  int _sequenceIndex = 0;
  bool _isComputing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
      _loadFavorites();
    });
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    expressionController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final settings = ref.read(appSettingsProvider);
    setState(() {
      rpnModeEnabled = settings.rpnModeEnabled;
      displayFormat = settings.displayFormat;
      decimalPlaces = settings.decimalPlaces;
      angleMode = settings.angleMode;
      hapticEnabled = settings.hapticEnabled;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await ref.read(favoritesProvider.notifier).loadFavorites();
    if (mounted) {
      setState(() {
        favorites = favs;
      });
    }
  }

  void _checkIsFavorited() {
    final expr = expressionController.text.trim();
    if (expr.isEmpty) {
      setState(() => isFavorited = false);
      return;
    }
    final found = favorites.any((f) => f.value == expr || f.label == expr);
    setState(() => isFavorited = found);
  }

  void _saveToUndoStack() {
    final entry = UndoRedoEntry(
      expression: expressionController.text,
      cursorPosition: expressionController.selection.baseOffset,
      rpnStack: List<String>.from(rpnStack),
      sequenceIndex: _sequenceIndex++,
    );
    undoStack.add(entry);
    if (undoStack.length > 100) undoStack.removeAt(0);
    redoStack.clear();
  }

  void _triggerHaptic() {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void onExpressionChanged(String value) {
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _computePreview(value);
      if (hapticEnabled) HapticFeedback.selectionClick();
    });
    _checkIsFavorited();
  }

  Future<void> _computePreview(String expression) async {
    if (expression.trim().isEmpty) {
      if (mounted) setState(() => previewResult = '');
      return;
    }
    try {
      final result = _evaluateExpression(expression);
      if (mounted) {
        setState(() {
          previewResult = result;
        });
      }
    } catch (_) {
      if (mounted) setState(() => previewResult = '');
    }
  }

  String _evaluateExpression(String expression) {
    try {
      final sanitized = _sanitizeExpression(expression);
      if (sanitized.isEmpty) return '';
      final result = _parseAndEvaluate(sanitized);
      return _formatResult(result);
    } catch (e) {
      return '';
    }
  }

  String _sanitizeExpression(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('^', '**')
        .trim();
  }

  double _parseAndEvaluate(String expression) {
    if (expression.contains('i')) {
      throw const FormatException('complex');
    }
    return _evaluateSimple(expression);
  }

  double _evaluateSimple(String expr) {
    expr = expr.trim();
    expr = _applyFunctions(expr);
    return _parseArithmetic(expr);
  }

  String _applyFunctions(String expr) {
    expr = _replaceFunctionCalls(expr, 'sin', (x) {
      final angle = angleMode == 'degrees' ? x * math.pi / 180 : angleMode == 'gradians' ? x * math.pi / 200 : x;
      return math.sin(angle);
    });
    expr = _replaceFunctionCalls(expr, 'cos', (x) {
      final angle = angleMode == 'degrees' ? x * math.pi / 180 : angleMode == 'gradians' ? x * math.pi / 200 : x;
      return math.cos(angle);
    });
    expr = _replaceFunctionCalls(expr, 'tan', (x) {
      final angle = angleMode == 'degrees' ? x * math.pi / 180 : angleMode == 'gradians' ? x * math.pi / 200 : x;
      return math.tan(angle);
    });
    expr = _replaceFunctionCalls(expr, 'sqrt', math.sqrt);
    expr = _replaceFunctionCalls(expr, 'log', (x) => math.log(x) / math.ln10);
    expr = _replaceFunctionCalls(expr, 'ln', math.log);
    expr = _replaceFunctionCalls(expr, 'exp', math.exp);
    expr = _replaceFunctionCalls(expr, 'abs', (x) => x.abs());
    expr = expr.replaceAll('π', '${math.pi}');
    expr = expr.replaceAll('e', '${math.e}');
    return expr;
  }

  String _replaceFunctionCalls(String expr, String funcName, double Function(double) fn) {
    final pattern = RegExp('$funcName\\(([^)]+)\\)');
    return expr.replaceAllMapped(pattern, (match) {
      try {
        final inner = match.group(1)!;
        final val = _parseArithmetic(inner);
        return '${fn(val)}';
      } catch (_) {
        return match.group(0)!;
      }
    });
  }

  double _parseArithmetic(String expr) {
    expr = expr.trim();
    if (expr.isEmpty) throw const FormatException('empty');

    int depth = 0;
    int lastPlusMinusIdx = -1;
    for (int i = expr.length - 1; i >= 0; i--) {
      final ch = expr[i];
      if (ch == ')') depth++;
      else if (ch == '(') depth--;
      else if (depth == 0 && (ch == '+' || ch == '-') && i > 0) {
        lastPlusMinusIdx = i;
        break;
      }
    }
    if (lastPlusMinusIdx > 0) {
      final left = _parseArithmetic(expr.substring(0, lastPlusMinusIdx));
      final right = _parseArithmetic(expr.substring(lastPlusMinusIdx + 1));
      return expr[lastPlusMinusIdx] == '+' ? left + right : left - right;
    }

    depth = 0;
    int lastMulDivIdx = -1;
    for (int i = expr.length - 1; i >= 0; i--) {
      final ch = expr[i];
      if (ch == ')') depth++;
      else if (ch == '(') depth--;
      else if (depth == 0 && (ch == '*' || ch == '/')) {
        lastMulDivIdx = i;
        break;
      }
    }
    if (lastMulDivIdx >= 0) {
      final left = _parseArithmetic(expr.substring(0, lastMulDivIdx));
      final right = _parseArithmetic(expr.substring(lastMulDivIdx + 1));
      if (expr[lastMulDivIdx] == '/') {
        if (right == 0) throw const FormatException('division by zero');
        return left / right;
      }
      return left * right;
    }

    final powIdx = expr.lastIndexOf('**');
    if (powIdx > 0) {
      final base = _parseArithmetic(expr.substring(0, powIdx));
      final exp = _parseArithmetic(expr.substring(powIdx + 2));
      return math.pow(base, exp).toDouble();
    }

    if (expr.startsWith('(') && expr.endsWith(')')) {
      return _parseArithmetic(expr.substring(1, expr.length - 1));
    }

    if (expr.startsWith('-')) {
      return -_parseArithmetic(expr.substring(1));
    }

    final val = double.tryParse(expr);
    if (val == null) throw FormatException('Cannot parse: $expr');
    return val;
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    switch (displayFormat) {
      case 'scientific':
        return value.toStringAsExponential(decimalPlaces);
      case 'engineering':
        if (value == 0) return '0';
        final exp = (math.log(value.abs()) / math.ln10).floor();
        final engExp = (exp ~/ 3) * 3;
        final mantissa = value / math.pow(10, engExp);
        return '${mantissa.toStringAsFixed(decimalPlaces)}e$engExp';
      case 'dms':
        final degrees = value.floor();
        final minutesFrac = (value - degrees) * 60;
        final minutes = minutesFrac.floor();
        final seconds = (minutesFrac - minutes) * 60;
        return '$degrees°${minutes}\'${seconds.toStringAsFixed(2)}"';
      default:
        final formatted = value.toStringAsFixed(decimalPlaces);
        if (formatted.contains('.')) {
          return formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        return formatted;
    }
  }

  void _parseComplexResult(String expression) {
    if (!expression.contains('i')) {
      setState(() {
        isComplexResult = false;
        magnitude = '0';
        phase = '0';
        polarForm = '0';
      });
      return;
    }
    try {
      final complexResult = _evaluateComplex(expression);
      final real = complexResult.$1;
      final imag = complexResult.$2;
      final mag = math.sqrt(real * real + imag * imag);
      final phaseRad = math.atan2(imag, real);
      final phaseDisplay = angleMode == 'degrees'
          ? phaseRad * 180 / math.pi
          : angleMode == 'gradians'
              ? phaseRad * 200 / math.pi
              : phaseRad;
      final phaseUnit = angleMode == 'degrees' ? '°' : angleMode == 'gradians' ? 'grad' : ' rad';
      final resultStr = real == 0
          ? '${imag.toStringAsFixed(4)}i'
          : imag >= 0
              ? '${real.toStringAsFixed(4)} + ${imag.toStringAsFixed(4)}i'
              : '${real.toStringAsFixed(4)} - ${imag.abs().toStringAsFixed(4)}i';
      setState(() {
        isComplexResult = true;
        displayedResult = resultStr;
        magnitude = mag.toStringAsFixed(6);
        phase = '${phaseDisplay.toStringAsFixed(4)}$phaseUnit';
        polarForm = '${mag.toStringAsFixed(4)}∠${phaseDisplay.toStringAsFixed(4)}$phaseUnit';
      });
    } catch (_) {
      setState(() => isComplexResult = false);
    }
  }

  (double, double) _evaluateComplex(String expr) {
    expr = expr.trim().replaceAll(' ', '');
    if (expr == 'i') return (0, 1);
    if (expr == '-i') return (0, -1);
    final fullMatch = RegExp(r'^([+-]?\d*\.?\d+)([+-]\d*\.?\d*)i$').firstMatch(expr);
    if (fullMatch != null) {
      final real = double.parse(fullMatch.group(1)!);
      final imagStr = fullMatch.group(2)!;
      final imag = imagStr == '+' || imagStr == ''
          ? 1.0
          : imagStr == '-'
              ? -1.0
              : double.parse(imagStr);
      return (real, imag);
    }
    final purImagMatch = RegExp(r'^([+-]?\d*\.?\d+)i$').firstMatch(expr);
    if (purImagMatch != null) {
      return (0, double.parse(purImagMatch.group(1)!));
    }
    final realVal = double.tryParse(expr);
    if (realVal != null) return (realVal, 0);
    throw const FormatException('Cannot parse complex');
  }

  void insertDigit(String digit) {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final newText = text.substring(0, pos) + digit + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + digit.length),
    );
    onExpressionChanged(newText);
  }

  void insertOperator(String op) {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final newText = text.substring(0, pos) + op + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + op.length),
    );
    onExpressionChanged(newText);
  }

  void insertDecimal() {
    _triggerHaptic();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final beforeCursor = text.substring(0, pos);
    int lastOpIdx = -1;
    for (final ch in ['+', '-', '*', '/', '(']) {
      final idx = beforeCursor.lastIndexOf(ch);
      if (idx > lastOpIdx) lastOpIdx = idx;
    }
    final currentNumber = lastOpIdx < 0 ? beforeCursor : beforeCursor.substring(lastOpIdx + 1);
    if (currentNumber.contains('.')) return;
    _saveToUndoStack();
    final newText = text.substring(0, pos) + '.' + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + 1),
    );
    onExpressionChanged(newText);
  }

  void toggleSign() {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    if (text.isEmpty) {
      expressionController.text = '-';
      expressionController.selection = const TextSelection.collapsed(offset: 1);
      return;
    }
    if (text.startsWith('-')) {
      final newText = text.substring(1);
      expressionController.text = newText;
      expressionController.selection = TextSelection.collapsed(offset: newText.length);
    } else {
      final newText = '-$text';
      expressionController.text = newText;
      expressionController.selection = TextSelection.collapsed(offset: newText.length);
    }
    onExpressionChanged(expressionController.text);
  }

  void insertFunction(String funcName) {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final insertion = '$funcName(';
    final newText = text.substring(0, pos) + insertion + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + insertion.length),
    );
    onExpressionChanged(newText);
  }

  void insertComplexUnit(String unit) {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final newText = text.substring(0, pos) + unit + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + unit.length),
    );
    onExpressionChanged(newText);
  }

  void clearExpression() {
    _triggerHaptic();
    _saveToUndoStack();
    expressionController.clear();
    setState(() {
      displayedResult = '0';
      previewResult = '';
      isComplexResult = false;
      magnitude = '0';
      phase = '0';
      polarForm = '0';
      undoStack.clear();
      redoStack.clear();
      isFavorited = false;
    });
  }

  void backspace() {
    _triggerHaptic();
    final text = expressionController.text;
    if (text.isEmpty) return;
    _saveToUndoStack();
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    if (pos == 0) return;
    final newText = text.substring(0, pos - 1) + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos - 1),
    );
    onExpressionChanged(newText);
  }

  Future<void> compute() async {
    _triggerHaptic();
    final expression = expressionController.text.trim();
    if (expression.isEmpty) return;
    if (_isComputing) return;

    setState(() => _isComputing = true);

    try {
      final settings = ref.read(appSettingsProvider);
      final currentAngleMode = settings.angleMode;
      final currentDisplayFormat = settings.displayFormat;
      final currentDecimalPlaces = settings.decimalPlaces;

      if (expression.contains('i')) {
        _parseComplexResult(expression);
        if (mounted) {
          final historyEntry = CalculationHistory(
            id: 0,
            expression: expression,
            result: displayedResult,
            resultType: 'complex',
            isComplex: true,
            magnitude: magnitude,
            phase: phase,
            polarForm: polarForm,
            displayFormat: currentDisplayFormat,
            angleMode: currentAngleMode,
            inputMode: rpnModeEnabled ? 'rpn' : 'infix',
            timestamp: DateTime.now(),
          );
          await ref.read(calculationHistoryProvider.notifier).addCalculation(historyEntry);
        }
        return;
      }

      try {
        final sanitized = _sanitizeExpression(expression);
        final result = _parseAndEvaluate(sanitized);

        if (result.isNaN) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid expression', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E293B),
              ),
            );
          }
          return;
        }

        if (result.isInfinite) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Division by zero', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E293B),
              ),
            );
          }
          return;
        }

        final formatted = _formatResultWithSettings(result, currentDisplayFormat, currentDecimalPlaces);

        setState(() {
          displayedResult = formatted;
          previewResult = '';
          isComplexResult = false;
        });

        final historyEntry = CalculationHistory(
          id: 0,
          expression: expression,
          result: formatted,
          resultType: 'real',
          isComplex: false,
          displayFormat: currentDisplayFormat,
          angleMode: currentAngleMode,
          inputMode: rpnModeEnabled ? 'rpn' : 'infix',
          timestamp: DateTime.now(),
        );
        await ref.read(calculationHistoryProvider.notifier).addCalculation(historyEntry);
      } on FormatException catch (e) {
        if (e.message == 'division by zero') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Division by zero', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E293B),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid expression', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E293B),
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isComputing = false);
    }
  }

  String _formatResultWithSettings(double value, String format, int places) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    switch (format) {
      case 'scientific':
        return value.toStringAsExponential(places);
      case 'engineering':
        if (value == 0) return '0';
        final exp = (math.log(value.abs()) / math.ln10).floor();
        final engExp = (exp ~/ 3) * 3;
        final mantissa = value / math.pow(10, engExp);
        return '${mantissa.toStringAsFixed(places)}e$engExp';
      case 'dms':
        final degrees = value.floor();
        final minutesFrac = (value - degrees) * 60;
        final minutes = minutesFrac.floor();
        final seconds = (minutesFrac - minutes) * 60;
        return '$degrees°${minutes}\'${seconds.toStringAsFixed(2)}"';
      default:
        final formatted = value.toStringAsFixed(places);
        if (formatted.contains('.')) {
          return formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        return formatted;
    }
  }

  void onUndo() {
    _triggerHaptic();
    if (undoStack.isEmpty) return;
    final current = UndoRedoEntry(
      expression: expressionController.text,
      cursorPosition: expressionController.selection.baseOffset,
      rpnStack: List<String>.from(rpnStack),
      sequenceIndex: _sequenceIndex++,
    );
    redoStack.add(current);
    final previous = undoStack.removeLast();
    expressionController.value = TextEditingValue(
      text: previous.expression,
      selection: TextSelection.collapsed(
        offset: previous.cursorPosition.clamp(0, previous.expression.length),
      ),
    );
    setState(() {
      rpnStack = List<String>.from(previous.rpnStack);
    });
    _computePreview(previous.expression);
  }

  void onRedo() {
    _triggerHaptic();
    if (redoStack.isEmpty) return;
    final current = UndoRedoEntry(
      expression: expressionController.text,
      cursorPosition: expressionController.selection.baseOffset,
      rpnStack: List<String>.from(rpnStack),
      sequenceIndex: _sequenceIndex++,
    );
    undoStack.add(current);
    final next = redoStack.removeLast();
    expressionController.value = TextEditingValue(
      text: next.expression,
      selection: TextSelection.collapsed(
        offset: next.cursorPosition.clamp(0, next.expression.length),
      ),
    );
    setState(() {
      rpnStack = List<String>.from(next.rpnStack);
    });
    _computePreview(next.expression);
  }

  Future<void> toggleFavorite() async {
    _triggerHaptic();
    final expr = expressionController.text.trim();
    if (expr.isEmpty) return;

    if (isFavorited) {
      final existing = favorites.where((f) => f.value == expr || f.label == expr).toList();
      for (final fav in existing) {
        await ref.read(favoritesProvider.notifier).removeFavorite(fav.id);
      }
      setState(() {
        favorites.removeWhere((f) => f.value == expr || f.label == expr);
        isFavorited = false;
      });
    } else {
      final newFav = FavoriteItem(
        id: 0,
        type: 'expression',
        label: expr.length > 12 ? '${expr.substring(0, 12)}…' : expr,
        value: expr,
        sortOrder: favorites.length,
        createdAt: DateTime.now(),
      );
      final saved = await ref.read(favoritesProvider.notifier).addFavoriteItem(newFav);
      if (saved != null && mounted) {
        setState(() {
          favorites.add(saved);
          isFavorited = true;
        });
      }
    }
  }

  /// Shows a context menu with copy format options: decimal, scientific, fraction.
  void showCopyMenu() {
    final result = displayedResult;
    if (result == '0' || result.isEmpty) return;

    final double? numericValue = double.tryParse(result);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A2436),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Copy Result',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(color: Color(0xFF334155), height: 24),
              ListTile(
                leading: const Icon(Icons.content_copy_rounded, color: Color(0xFF94A3B8)),
                title: const Text('Copy Decimal', style: TextStyle(color: Color(0xFFE2E8F0))),
                subtitle: Text(result, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: result));
                  _showSnackBar('Copied: $result');
                },
              ),
              if (numericValue != null) ...[
                ListTile(
                  leading: const Icon(Icons.science_rounded, color: Color(0xFF94A3B8)),
                  title: const Text('Copy Scientific', style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text(
                    numericValue.toStringAsExponential(6),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    final sci = numericValue.toStringAsExponential(6);
                    Clipboard.setData(ClipboardData(text: sci));
                    _showSnackBar('Copied: $sci');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.percent_rounded, color: Color(0xFF94A3B8)),
                  title: const Text('Copy Fraction', style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text(
                    _toApproximateFraction(numericValue) ?? result,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    final frac = _toApproximateFraction(numericValue) ?? result;
                    Clipboard.setData(ClipboardData(text: frac));
                    _showSnackBar('Copied: $frac');
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String? _toApproximateFraction(double value, {int maxDenominator = 1000}) {
    if (value == 0) return '0';
    final negative = value < 0;
    final absValue = negative ? -value : value;
    int bestNumerator = 1;
    int bestDenominator = 1;
    double bestError = (absValue - 1.0).abs();
    for (int d = 1; d <= maxDenominator; d++) {
      final n = (absValue * d).round();
      final error = (absValue - n / d).abs();
      if (error < bestError) {
        bestError = error;
        bestNumerator = n;
        bestDenominator = d;
      }
      if (error < 1e-9) break;
    }
    if (bestError > 1e-4) return null;
    final sign = negative ? '-' : '';
    if (bestDenominator == 1) return '$sign$bestNumerator';
    return '$sign$bestNumerator/$bestDenominator';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void insertFavorite(FavoriteItem fav) {
    _triggerHaptic();
    _saveToUndoStack();
    final text = expressionController.text;
    final sel = expressionController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final insertion = fav.value;
    final newText = text.substring(0, pos) + insertion + text.substring(pos);
    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + insertion.length),
    );
    onExpressionChanged(newText);
  }

  void rpnEnter() {
    _triggerHaptic();
    final text = expressionController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      rpnStack.add(text);
      expressionController.clear();
    });
  }

  void rpnSwap() {
    _triggerHaptic();
    if (rpnStack.length < 2) return;
    setState(() {
      final last = rpnStack.removeLast();
      final secondLast = rpnStack.removeLast();
      // Swap: put secondLast on top, last below
      rpnStack.add(last);
      rpnStack.add(secondLast);
    });
  }

  void rpnDrop() {
    _triggerHaptic();
    if (rpnStack.isEmpty) return;
    setState(() {
      rpnStack.removeLast();
    });
  }

  void rpnClear() {
    _triggerHaptic();
    setState(() {
      rpnStack.clear();
    });
  }

  /// Navigate to HistoryScreen via Navigator.push (not named route).
  /// When user taps a history item, it returns a CalculationHistory object.
  /// We then set the expression field to item.expression and trigger preview.
  void _navigateToHistory() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    if (!mounted) return;
    if (result is CalculationHistory) {
      // Recall: set expression to the recalled item's expression
      expressionController.value = TextEditingValue(
        text: result.expression,
        selection: TextSelection.collapsed(offset: result.expression.length),
      );
      setState(() {
        displayedResult = result.result;
        previewResult = '';
      });
      _computePreview(result.expression);
    } else if (result is String && result.isNotEmpty) {
      // Fallback: insert string directly
      insertDigit(result);
    }
    // Reload settings in case they changed
    _loadSettings();
  }

  /// Navigate to SettingsScreen via Navigator.push (not named route).
  void _navigateToSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (mounted) _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // Undo button
          IconButton(
            icon: Icon(
              Icons.undo_rounded,
              color: undoStack.isNotEmpty
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            tooltip: 'Undo',
            onPressed: undoStack.isNotEmpty ? onUndo : null,
          ),
          // Redo button
          IconButton(
            icon: Icon(
              Icons.redo_rounded,
              color: redoStack.isNotEmpty
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            tooltip: 'Redo',
            onPressed: redoStack.isNotEmpty ? onRedo : null,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: _navigateToHistory,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (favorites.isNotEmpty)
                      SizedBox(
                        height: 36,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: favorites.map((fav) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ActionChip(
                                  label: Text(
                                    fav.label,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onPressed: () => insertFavorite(fav),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextField(
                      controller: expressionController,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.onSurface,
                        fontFamily: 'Roboto',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: onExpressionChanged,
                      keyboardType: TextInputType.none,
                    ),
                    const SizedBox(height: 4),
                    if (previewResult.isNotEmpty)
                      Text(
                        '= $previewResult',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    Text(
                      displayedResult,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.primary,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    if (isComplexResult) ...[
                      const SizedBox(height: 4),
                      Text(
                        '|z| = $magnitude  ∠ $phase',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        'Polar: $polarForm',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            settings.angleMode.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isFavorited ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFavorited ? const Color(0xFFF59E0B) : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          onPressed: toggleFavorite,
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.content_copy_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          onPressed: showCopyMenu,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (rpnModeEnabled && rpnStack.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  reverse: true,
                  itemCount: rpnStack.length > 3 ? 3 : rpnStack.length,
                  itemBuilder: (context, index) {
                    final stackIndex = rpnStack.length - 1 - index;
                    return Text(
                      '${stackIndex + 1}: ${rpnStack[stackIndex]}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'Roboto Mono',
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),
            const Divider(height: 1),
            Expanded(
              flex: 5,
              child: _buildKeypad(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildKey('sin', colorScheme, isFunction: true),
                _buildKey('cos', colorScheme, isFunction: true),
                _buildKey('tan', colorScheme, isFunction: true),
                _buildKey('ln', colorScheme, isFunction: true),
                _buildKey('log', colorScheme, isFunction: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('√', colorScheme, isFunction: true),
                _buildKey('x²', colorScheme, isFunction: true),
                _buildKey('π', colorScheme, isFunction: true),
                _buildKey('e', colorScheme, isFunction: true),
                _buildKey('i', colorScheme, isFunction: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('(', colorScheme, isOperator: true),
                _buildKey(')', colorScheme, isOperator: true),
                _buildKey('%', colorScheme, isOperator: true),
                _buildKey('⌫', colorScheme, isAction: true),
                _buildKey('C', colorScheme, isAction: true, isDestructive: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('7', colorScheme),
                _buildKey('8', colorScheme),
                _buildKey('9', colorScheme),
                _buildKey('÷', colorScheme, isOperator: true),
                _buildKey('^', colorScheme, isOperator: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('4', colorScheme),
                _buildKey('5', colorScheme),
                _buildKey('6', colorScheme),
                _buildKey('×', colorScheme, isOperator: true),
                _buildKey('±', colorScheme, isOperator: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('1', colorScheme),
                _buildKey('2', colorScheme),
                _buildKey('3', colorScheme),
                _buildKey('−', colorScheme, isOperator: true),
                _buildKey('=', colorScheme, isEquals: true),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildKey('0', colorScheme),
                _buildKey('.', colorScheme),
                _buildKey('00', colorScheme),
                _buildKey('+', colorScheme, isOperator: true),
                if (rpnModeEnabled) ...[
                  _buildKey('ENT', colorScheme, isAction: true),
                ] else ...[
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ),
          // RPN-specific row
          if (rpnModeEnabled)
            Expanded(
              child: Row(
                children: [
                  _buildKey('SWAP', colorScheme, isAction: true),
                  _buildKey('DROP', colorScheme, isAction: true),
                  _buildKey('CLR', colorScheme, isAction: true, isDestructive: true),
                  const Expanded(child: SizedBox()),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(
    String label,
    ColorScheme colorScheme, {
    bool isFunction = false,
    bool isOperator = false,
    bool isAction = false,
    bool isDestructive = false,
    bool isEquals = false,
  }) {
    Color bgColor;
    Color fgColor;

    if (isEquals) {
      bgColor = colorScheme.primary;
      fgColor = colorScheme.onPrimary;
    } else if (isDestructive) {
      bgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
      fgColor = const Color(0xFFEF4444);
    } else if (isAction) {
      bgColor = colorScheme.surfaceContainerHighest;
      fgColor = colorScheme.onSurface;
    } else if (isFunction) {
      bgColor = colorScheme.primary.withValues(alpha: 0.12);
      fgColor = colorScheme.primary;
    } else if (isOperator) {
      bgColor = colorScheme.secondary.withValues(alpha: 0.12);
      fgColor = colorScheme.secondary;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      fgColor = colorScheme.onSurface;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _handleKeyPress(label),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: label.length > 3 ? 12 : 16,
                  fontWeight: isEquals ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(String label) {
    switch (label) {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        insertDigit(label);
        break;
      case '00':
        insertDigit('00');
        break;
      case '.':
        insertDecimal();
        break;
      case '+':
        insertOperator('+');
        break;
      case '−':
        insertOperator('-');
        break;
      case '×':
        insertOperator('×');
        break;
      case '÷':
        insertOperator('÷');
        break;
      case '^':
        insertOperator('^');
        break;
      case '%':
        insertOperator('%');
        break;
      case '(':
        insertOperator('(');
        break;
      case ')':
        insertOperator(')');
        break;
      case '±':
        toggleSign();
        break;
      case '⌫':
        backspace();
        break;
      case 'C':
        clearExpression();
        break;
      case '=':
        compute();
        break;
      case 'sin':
      case 'cos':
      case 'tan':
      case 'ln':
      case 'log':
      case '√':
        insertFunction(label == '√' ? 'sqrt' : label);
        break;
      case 'x²':
        insertOperator('^2');
        break;
      case 'π':
        insertDigit('π');
        break;
      case 'e':
        insertDigit('e');
        break;
      case 'i':
        insertComplexUnit('i');
        break;
      case 'ENT':
        rpnEnter();
        break;
      case 'SWAP':
        rpnSwap();
        break;
      case 'DROP':
        rpnDrop();
        break;
      case 'CLR':
        rpnClear();
        break;
    }
  }
}
