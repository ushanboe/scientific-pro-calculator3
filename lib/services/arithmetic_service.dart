import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:scientific_pro_calculator/models/app_settings.dart';

/// Result of a calculation evaluation.
class EvaluationResult {
  final String result;
  final String resultType; // 'real', 'complex', 'error', 'infinity'
  final bool isComplex;
  final String? magnitude;
  final String? phase;
  final String? polarForm;
  final String? errorMessage;

  const EvaluationResult({
    required this.result,
    required this.resultType,
    this.isComplex = false,
    this.magnitude,
    this.phase,
    this.polarForm,
    this.errorMessage,
  });

  bool get isError => resultType == 'error';

  factory EvaluationResult.error(String message) {
    return EvaluationResult(
      result: 'Error',
      resultType: 'error',
      errorMessage: message,
    );
  }

  factory EvaluationResult.real(String value) {
    return EvaluationResult(result: value, resultType: 'real');
  }

  factory EvaluationResult.complex({
    required String result,
    required String magnitude,
    required String phase,
    required String polarForm,
  }) {
    return EvaluationResult(
      result: result,
      resultType: 'complex',
      isComplex: true,
      magnitude: magnitude,
      phase: phase,
      polarForm: polarForm,
    );
  }
}

/// Complex number with high-precision double components.
class ComplexNumber {
  final double real;
  final double imaginary;

  const ComplexNumber(this.real, this.imaginary);

  ComplexNumber operator +(ComplexNumber other) =>
      ComplexNumber(real + other.real, imaginary + other.imaginary);

  ComplexNumber operator -(ComplexNumber other) =>
      ComplexNumber(real - other.real, imaginary - other.imaginary);

  ComplexNumber operator *(ComplexNumber other) => ComplexNumber(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );

  ComplexNumber operator /(ComplexNumber other) {
    final denom = other.real * other.real + other.imaginary * other.imaginary;
    if (denom == 0) throw Exception('Division by zero');
    return ComplexNumber(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  ComplexNumber operator -() => ComplexNumber(-real, -imaginary);

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  double get phase => math.atan2(imaginary, real);

  bool get isReal => imaginary.abs() < 1e-12;

  ComplexNumber pow(ComplexNumber exponent) {
    if (real == 0 && imaginary == 0) {
      if (exponent.real == 0 && exponent.imaginary == 0)
        return ComplexNumber(1, 0);
      return ComplexNumber(0, 0);
    }
    final r = magnitude;
    final theta = phase;
    final lnR = math.log(r);
    final newLnR = lnR * exponent.real - theta * exponent.imaginary;
    final newTheta = lnR * exponent.imaginary + theta * exponent.real;
    final newR = math.exp(newLnR);
    return ComplexNumber(
        newR * math.cos(newTheta), newR * math.sin(newTheta));
  }

  ComplexNumber sqrt() {
    final r = magnitude;
    final theta = phase;
    final sqrtR = math.sqrt(r);
    return ComplexNumber(
        sqrtR * math.cos(theta / 2), sqrtR * math.sin(theta / 2));
  }

  ComplexNumber exp() {
    final expReal = math.exp(real);
    return ComplexNumber(
        expReal * math.cos(imaginary), expReal * math.sin(imaginary));
  }

  ComplexNumber log() {
    if (real == 0 && imaginary == 0)
      throw Exception('log(0) is undefined');
    return ComplexNumber(math.log(magnitude), phase);
  }

  ComplexNumber sin() => ComplexNumber(
        math.sin(real) * _cosh(imaginary),
        math.cos(real) * _sinh(imaginary),
      );

  ComplexNumber cos() => ComplexNumber(
        math.cos(real) * _cosh(imaginary),
        -math.sin(real) * _sinh(imaginary),
      );

  ComplexNumber tan() {
    final s = sin();
    final c = cos();
    return s / c;
  }

  ComplexNumber sinh() => ComplexNumber(
        _sinh(real) * math.cos(imaginary),
        _cosh(real) * math.sin(imaginary),
      );

  ComplexNumber cosh() => ComplexNumber(
        _cosh(real) * math.cos(imaginary),
        _sinh(real) * math.sin(imaginary),
      );

  ComplexNumber tanh() {
    final s = sinh();
    final c = cosh();
    return s / c;
  }

  ComplexNumber asin() {
    final iz = ComplexNumber(-imaginary, real);
    final oneMinusZ2 = ComplexNumber(1, 0) - this * this;
    final sqrtPart = oneMinusZ2.sqrt();
    final inner = iz + sqrtPart;
    final lnPart = inner.log();
    return ComplexNumber(lnPart.imaginary, -lnPart.real);
  }

  ComplexNumber acos() {
    final asinZ = asin();
    return ComplexNumber(math.pi / 2 - asinZ.real, -asinZ.imaginary);
  }

  ComplexNumber atan() {
    final iz = ComplexNumber(-imaginary, real);
    final num = ComplexNumber(1, 0) - iz;
    final den = ComplexNumber(1, 0) + iz;
    final ratio = num / den;
    final lnRatio = ratio.log();
    return ComplexNumber(-lnRatio.imaginary / 2, lnRatio.real / 2);
  }

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;

  @override
  String toString() => 'ComplexNumber($real, $imaginary)';
}

/// Token types for the expression parser.
enum _TokenType {
  number,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  power,
  leftParen,
  rightParen,
  comma,
  factorial,
  percent,
  eof,
}

class _Token {
  final _TokenType type;
  final String value;
  const _Token(this.type, this.value);
  @override
  String toString() => '_Token($type, $value)';
}

/// High-precision arithmetic engine supporting complex numbers,
/// trigonometric, hyperbolic, logarithmic, and power functions.
class ArithmeticService {
  ArithmeticService._();
  static final ArithmeticService instance = ArithmeticService._();

  // Physical constants for use in expressions
  static const Map<String, double> _constants = {
    'pi': math.pi,
    'π': math.pi,
    'e': math.e,
    'phi': 1.6180339887498948482,
    'φ': 1.6180339887498948482,
    'tau': 2 * math.pi,
    'τ': 2 * math.pi,
    'inf': double.infinity,
    '∞': double.infinity,
    'c': 299792458.0,
    'G': 6.67430e-11,
    'h': 6.62607015e-34,
    'k': 1.380649e-23,
    'Na': 6.02214076e23,
    'R': 8.314462618,
    'eps0': 8.8541878128e-12,
    'mu0': 1.25663706212e-6,
    'e_charge': 1.602176634e-19,
    'me': 9.1093837015e-31,
    'mp': 1.67262192369e-27,
    'mn': 1.67492749804e-27,
    'u': 1.66053906660e-27,
    'sigma': 5.670374419e-8,
    'alpha': 7.2973525693e-3,
    'Rinf': 10973731.568160,
    'a0': 5.29177210903e-11,
    'F': 96485.33212,
    'atm': 101325.0,
    'g_n': 9.80665,
  };

  /// Evaluate an expression string with the given settings.
  EvaluationResult evaluate(String expression, AppSettings settings) {
    if (expression.trim().isEmpty) {
      return EvaluationResult.error('Empty expression');
    }

    try {
      final processed = _preprocess(expression);
      final tokens = _tokenize(processed);
      final parser = _ExpressionParser(tokens, settings);
      final result = parser.parseExpression();
      return _formatComplexResult(result, settings);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return EvaluationResult.error(msg);
    }
  }

  /// Format a result value for display based on settings.
  String formatResult(double value, AppSettings settings) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    try {
      final decimalStr = _toHighPrecisionString(value, settings);
      return _applyDigitSeparator(decimalStr, settings.digitSeparator);
    } catch (e) {
      return value.toString();
    }
  }

  EvaluationResult _formatComplexResult(
      ComplexNumber result, AppSettings settings) {
    if (result.real.isNaN || result.imaginary.isNaN) {
      return EvaluationResult.error('Result is not a number');
    }

    if (result.real.isInfinite || result.imaginary.isInfinite) {
      if (result.imaginary == 0 || result.imaginary.isNaN) {
        return EvaluationResult.real(result.real > 0 ? '∞' : '-∞');
      }
      return EvaluationResult.error('Result is infinite');
    }

    if (result.isReal) {
      final formatted = _toHighPrecisionString(result.real, settings);
      final withSep =
          _applyDigitSeparator(formatted, settings.digitSeparator);
      return EvaluationResult.real(withSep);
    }

    final realStr = _toHighPrecisionString(result.real, settings);
    final imagAbs = result.imaginary.abs();
    final imagStr = _toHighPrecisionString(imagAbs, settings);
    final sign = result.imaginary >= 0 ? '+' : '-';

    String complexStr;
    if (imagAbs == 1.0) {
      if (result.real == 0) {
        complexStr = result.imaginary >= 0 ? 'i' : '-i';
      } else {
        complexStr = '$realStr${sign}i';
      }
    } else {
      if (result.real == 0) {
        complexStr =
            result.imaginary >= 0 ? '${imagStr}i' : '-${imagStr}i';
      } else {
        complexStr = '$realStr$sign${imagStr}i';
      }
    }

    final mag = result.magnitude;
    final phaseRad = result.phase;
    final magStr = _toHighPrecisionString(mag, settings);
    final phaseStr = _toHighPrecisionString(phaseRad, settings);
    final phaseDeg =
        _toHighPrecisionString(phaseRad * 180 / math.pi, settings);
    final polarStr = '${magStr}∠${phaseDeg}°';

    return EvaluationResult.complex(
      result: complexStr,
      magnitude: magStr,
      phase: '${phaseStr} rad (${phaseDeg}°)',
      polarForm: polarStr,
    );
  }

  String _toHighPrecisionString(double value, AppSettings settings) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    final places = settings.decimalPlaces.clamp(0, 15);

    switch (settings.displayFormat) {
      case 'scientific':
        return _toScientificNotation(value, places);
      case 'engineering':
        return _toEngineeringNotation(value, places);
      case 'fixed':
        try {
          final d = Decimal.parse(value.toStringAsFixed(places));
          return d.toString();
        } catch (_) {
          return value.toStringAsFixed(places);
        }
      default:
        if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
          return _toScientificNotation(value, places);
        }
        try {
          final d = Decimal.parse(value.toStringAsFixed(places));
          final str = d.toString();
          if (str.contains('.')) {
            return str
                .replaceAll(RegExp(r'0+$'), '')
                .replaceAll(RegExp(r'\.$'), '');
          }
          return str;
        } catch (_) {
          return value.toStringAsFixed(places);
        }
    }
  }

  String _toScientificNotation(double value, int decimalPlaces) {
    if (value == 0)
      return '0${decimalPlaces > 0 ? '.' + '0' * decimalPlaces : ''}e+0';
    final formatted = value.toStringAsExponential(decimalPlaces);
    final parts = formatted.split('e');
    if (parts.length == 2) {
      final exp = int.tryParse(parts[1]) ?? 0;
      return '${parts[0]} × 10^$exp';
    }
    return formatted;
  }

  String _toEngineeringNotation(double value, int decimalPlaces) {
    if (value == 0) return '0';
    final sign = value < 0 ? '-' : '';
    final absVal = value.abs();
    final exp = (math.log(absVal) / math.ln10).floor();
    final engExp = (exp ~/ 3) * 3;
    final mantissa = absVal / math.pow(10, engExp);
    final mantissaStr = mantissa.toStringAsFixed(decimalPlaces);
    if (engExp == 0) return '$sign$mantissaStr';
    return '${sign}${mantissaStr} × 10^$engExp';
  }

  String _applyDigitSeparator(String numStr, String separator) {
    if (separator == 'none') return numStr;

    final parts = numStr.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    final sign = intPart.startsWith('-') ? '-' : '';
    final digits = sign.isEmpty ? intPart : intPart.substring(1);

    final sepChar = separator == 'comma'
        ? ','
        : (separator == 'period' ? '.' : ' ');
    final buffer = StringBuffer(sign);
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(sepChar);
      }
      buffer.write(digits[i]);
    }
    buffer.write(decPart);
    return buffer.toString();
  }

  String _preprocess(String expr) {
    var result = expr;

    result = result.replaceAll('×', '*');
    result = result.replaceAll('÷', '/');
    result = result.replaceAll('−', '-');
    result = result.replaceAll('–', '-');
    result = result.replaceAll('√', 'sqrt');
    result = result.replaceAll('∛', 'cbrt');
    result = result.replaceAll('∑', 'sum');
    result = result.replaceAll('∏', 'prod');

    result = result.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Zπφτ∞])'),
      (m) => '${m[1]}*${m[2]}',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d)\('),
      (m) => '${m[1]}*(',
    );
    result = result.replaceAllMapped(
      RegExp(r'\)\('),
      (m) => ')*(',
    );
    result = result.replaceAllMapped(
      RegExp(r'\)([a-zA-Z])'),
      (m) => ')*${m[1]}',
    );

    return result;
  }

  List<_Token> _tokenize(String expr) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < expr.length) {
      final ch = expr[i];

      if (ch == ' ' || ch == '\t' || ch == '\n') {
        i++;
        continue;
      }

      if (ch == '0' &&
          i + 1 < expr.length &&
          (expr[i + 1] == 'x' || expr[i + 1] == 'X')) {
        int j = i + 2;
        while (j < expr.length &&
            RegExp(r'[0-9a-fA-F]').hasMatch(expr[j])) j++;
        final hexStr = expr.substring(i + 2, j);
        final value = int.tryParse(hexStr, radix: 16)?.toDouble() ?? 0.0;
        tokens.add(_Token(_TokenType.number, value.toString()));
        i = j;
        continue;
      }

      if (RegExp(r'[0-9]').hasMatch(ch) ||
          (ch == '.' &&
              i + 1 < expr.length &&
              RegExp(r'[0-9]').hasMatch(expr[i + 1]))) {
        int j = i;
        while (j < expr.length && RegExp(r'[0-9]').hasMatch(expr[j])) j++;
        if (j < expr.length && expr[j] == '.') {
          j++;
          while (j < expr.length && RegExp(r'[0-9]').hasMatch(expr[j])) j++;
        }
        if (j < expr.length && (expr[j] == 'e' || expr[j] == 'E')) {
          j++;
          if (j < expr.length && (expr[j] == '+' || expr[j] == '-')) j++;
          while (j < expr.length && RegExp(r'[0-9]').hasMatch(expr[j])) j++;
        }
        tokens.add(_Token(_TokenType.number, expr.substring(i, j)));
        i = j;
        continue;
      }

      if (RegExp(r'[a-zA-Zπφτ∞_]').hasMatch(ch)) {
        int j = i;
        while (j < expr.length &&
            RegExp(r'[a-zA-Z0-9πφτ∞_]').hasMatch(expr[j])) j++;
        tokens.add(_Token(_TokenType.identifier, expr.substring(i, j)));
        i = j;
        continue;
      }

      switch (ch) {
        case '+':
          tokens.add(const _Token(_TokenType.plus, '+'));
          break;
        case '-':
          tokens.add(const _Token(_TokenType.minus, '-'));
          break;
        case '*':
          tokens.add(const _Token(_TokenType.multiply, '*'));
          break;
        case '/':
          tokens.add(const _Token(_TokenType.divide, '/'));
          break;
        case '^':
          tokens.add(const _Token(_TokenType.power, '^'));
          break;
        case '(':
          tokens.add(const _Token(_TokenType.leftParen, '('));
          break;
        case ')':
          tokens.add(const _Token(_TokenType.rightParen, ')'));
          break;
        case ',':
          tokens.add(const _Token(_TokenType.comma, ','));
          break;
        case '!':
          tokens.add(const _Token(_TokenType.factorial, '!'));
          break;
        case '%':
          tokens.add(const _Token(_TokenType.percent, '%'));
          break;
        default:
          // Skip unknown characters
          break;
      }
      i++;
    }

    tokens.add(const _Token(_TokenType.eof, ''));
    return tokens;
  }
}

/// Recursive-descent expression parser that evaluates to ComplexNumber.
class _ExpressionParser {
  final List<_Token> _tokens;
  int _pos = 0;
  final AppSettings _settings;

  _ExpressionParser(this._tokens, this._settings);

  _Token get _current => _pos < _tokens.length
      ? _tokens[_pos]
      : const _Token(_TokenType.eof, '');

  _Token _consume() {
    final t = _current;
    _pos++;
    return t;
  }

  bool _check(_TokenType type) => _current.type == type;

  bool _match(_TokenType type) {
    if (_check(type)) {
      _consume();
      return true;
    }
    return false;
  }

  ComplexNumber parseExpression() {
    return _parseAddSub();
  }

  ComplexNumber _parseAddSub() {
    var left = _parseMulDiv();
    while (_check(_TokenType.plus) || _check(_TokenType.minus)) {
      if (_match(_TokenType.plus)) {
        left = left + _parseMulDiv();
      } else {
        _consume();
        left = left - _parseMulDiv();
      }
    }
    return left;
  }

  ComplexNumber _parseMulDiv() {
    var left = _parsePower();
    while (_check(_TokenType.multiply) || _check(_TokenType.divide)) {
      if (_match(_TokenType.multiply)) {
        left = left * _parsePower();
      } else {
        _consume();
        final right = _parsePower();
        if (right.real == 0 && right.imaginary == 0) {
          throw Exception('Division by zero');
        }
        left = left / right;
      }
    }
    return left;
  }

  ComplexNumber _parsePower() {
    var base = _parseUnary();
    if (_match(_TokenType.power)) {
      final exp = _parseUnary();
      return base.pow(exp);
    }
    return base;
  }

  ComplexNumber _parseUnary() {
    if (_match(_TokenType.minus)) {
      return -_parsePostfix();
    }
    if (_match(_TokenType.plus)) {
      return _parsePostfix();
    }
    return _parsePostfix();
  }

  ComplexNumber _parsePostfix() {
    var val = _parsePrimary();
    while (true) {
      if (_match(_TokenType.factorial)) {
        if (!val.isReal) throw Exception('Factorial requires real number');
        final n = val.real.round();
        if (n < 0) throw Exception('Factorial of negative number');
        val = ComplexNumber(_computeFactorial(n), 0);
      } else if (_match(_TokenType.percent)) {
        val = ComplexNumber(val.real / 100.0, val.imaginary / 100.0);
      } else {
        break;
      }
    }
    return val;
  }

  double _computeFactorial(int n) {
    if (n > 170) return double.infinity;
    double result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  ComplexNumber _parsePrimary() {
    // Number literal
    if (_check(_TokenType.number)) {
      final token = _consume();
      final value = double.tryParse(token.value) ?? 0.0;
      return ComplexNumber(value, 0);
    }

    // Parenthesized expression
    if (_match(_TokenType.leftParen)) {
      final val = parseExpression();
      if (!_match(_TokenType.rightParen)) {
        throw Exception('Expected closing parenthesis');
      }
      return val;
    }

    // Identifier: constant, function, or imaginary unit
    if (_check(_TokenType.identifier)) {
      final token = _consume();
      final name = token.value;

      // Imaginary unit
      if (name == 'i') {
        return const ComplexNumber(0, 1);
      }

      // Constants
      if (ArithmeticService._constants.containsKey(name)) {
        return ComplexNumber(ArithmeticService._constants[name]!, 0);
      }

      // Function call
      if (_check(_TokenType.leftParen)) {
        _consume(); // consume '('
        final args = <ComplexNumber>[];
        if (!_check(_TokenType.rightParen)) {
          args.add(parseExpression());
          while (_match(_TokenType.comma)) {
            args.add(parseExpression());
          }
        }
        if (!_match(_TokenType.rightParen)) {
          throw Exception('Expected closing parenthesis after function call');
        }
        return _callFunction(name, args);
      }

      // Unknown identifier — throw
      throw Exception('Unknown identifier: $name');
    }

    throw Exception(
        'Unexpected token: ${_current.type} (${_current.value})');
  }

  ComplexNumber _callFunction(String name, List<ComplexNumber> args) {
    ComplexNumber arg(int i) {
      if (i >= args.length) throw Exception('$name: missing argument');
      return args[i];
    }

    final angleMode = _settings.angleMode;

    double toRad(double v) {
      switch (angleMode) {
        case 'degrees':
          return v * math.pi / 180.0;
        case 'gradians':
          return v * math.pi / 200.0;
        default:
          return v;
      }
    }

    double fromRad(double v) {
      switch (angleMode) {
        case 'degrees':
          return v * 180.0 / math.pi;
        case 'gradians':
          return v * 200.0 / math.pi;
        default:
          return v;
      }
    }

    switch (name.toLowerCase()) {
      // Trig
      case 'sin':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(math.sin(toRad(a.real)), 0);
        }
        return ComplexNumber(a.real, toRad(a.imaginary)).sin();
      case 'cos':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(math.cos(toRad(a.real)), 0);
        }
        return ComplexNumber(a.real, toRad(a.imaginary)).cos();
      case 'tan':
        final a = arg(0);
        if (a.isReal) {
          final r = toRad(a.real);
          final c = math.cos(r);
          if (c.abs() < 1e-12) throw Exception('tan: undefined');
          return ComplexNumber(math.sin(r) / c, 0);
        }
        return ComplexNumber(a.real, toRad(a.imaginary)).tan();
      case 'cot':
        final a = arg(0);
        final r = toRad(a.real);
        final s = math.sin(r);
        if (s.abs() < 1e-12) throw Exception('cot: undefined');
        return ComplexNumber(math.cos(r) / s, 0);
      case 'sec':
        final a = arg(0);
        final c = math.cos(toRad(a.real));
        if (c.abs() < 1e-12) throw Exception('sec: undefined');
        return ComplexNumber(1 / c, 0);
      case 'csc':
        final a = arg(0);
        final s = math.sin(toRad(a.real));
        if (s.abs() < 1e-12) throw Exception('csc: undefined');
        return ComplexNumber(1 / s, 0);

      // Inverse trig
      case 'asin':
      case 'arcsin':
        final a = arg(0);
        if (a.isReal && a.real.abs() <= 1) {
          return ComplexNumber(fromRad(math.asin(a.real)), 0);
        }
        final r = a.asin();
        return ComplexNumber(fromRad(r.real), r.imaginary);
      case 'acos':
      case 'arccos':
        final a = arg(0);
        if (a.isReal && a.real.abs() <= 1) {
          return ComplexNumber(fromRad(math.acos(a.real)), 0);
        }
        final r = a.acos();
        return ComplexNumber(fromRad(r.real), r.imaginary);
      case 'atan':
      case 'arctan':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(fromRad(math.atan(a.real)), 0);
        }
        final r = a.atan();
        return ComplexNumber(fromRad(r.real), r.imaginary);
      case 'atan2':
        final y = arg(0);
        final x = arg(1);
        return ComplexNumber(fromRad(math.atan2(y.real, x.real)), 0);

      // Hyperbolic
      case 'sinh':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(
              (math.exp(a.real) - math.exp(-a.real)) / 2, 0);
        }
        return a.sinh();
      case 'cosh':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(
              (math.exp(a.real) + math.exp(-a.real)) / 2, 0);
        }
        return a.cosh();
      case 'tanh':
        final a = arg(0);
        if (a.isReal) {
          final e2x = math.exp(2 * a.real);
          return ComplexNumber((e2x - 1) / (e2x + 1), 0);
        }
        return a.tanh();
      case 'asinh':
      case 'arcsinh':
        final a = arg(0);
        if (a.isReal) {
          return ComplexNumber(
              math.log(a.real + math.sqrt(a.real * a.real + 1)), 0);
        }
        return (a + (a * a + ComplexNumber(1, 0)).sqrt()).log();
      case 'acosh':
      case 'arccosh':
        final a = arg(0);
        if (a.isReal && a.real >= 1) {
          return ComplexNumber(
              math.log(a.real + math.sqrt(a.real * a.real - 1)), 0);
        }
        return (a + (a * a - ComplexNumber(1, 0)).sqrt()).log();
      case 'atanh':
      case 'arctanh':
        final a = arg(0);
        if (a.isReal && a.real.abs() < 1) {
          return ComplexNumber(
              0.5 * math.log((1 + a.real) / (1 - a.real)), 0);
        }
        return ((ComplexNumber(1, 0) + a) / (ComplexNumber(1, 0) - a))
                .log() *
            ComplexNumber(0.5, 0);

      // Logarithms
      case 'ln':
      case 'log':
        final a = arg(0);
        if (a.isReal) {
          if (a.real <= 0) {
            if (a.real < 0) {
              return ComplexNumber(math.log(-a.real), math.pi);
            }
            throw Exception('ln(0) is undefined');
          }
          return ComplexNumber(math.log(a.real), 0);
        }
        return a.log();
      case 'log2':
        final a = arg(0);
        if (a.isReal && a.real > 0) {
          return ComplexNumber(math.log(a.real) / math.ln2, 0);
        }
        return a.log() / ComplexNumber(math.ln2, 0);
      case 'log10':
        final a = arg(0);
        if (a.isReal && a.real > 0) {
          return ComplexNumber(math.log(a.real) / math.ln10, 0);
        }
        return a.log() / ComplexNumber(math.ln10, 0);
      case 'logn':
        final a = arg(0);
        final base = arg(1);
        if (a.isReal && base.isReal && a.real > 0 && base.real > 0) {
          return ComplexNumber(
              math.log(a.real) / math.log(base.real), 0);
        }
        return a.log() / base.log();

      // Exponential
      case 'exp':
        final a = arg(0);
        if (a.isReal) return ComplexNumber(math.exp(a.real), 0);
        return a.exp();
      case 'exp2':
        final a = arg(0);
        return ComplexNumber(math.pow(2, a.real).toDouble(), 0);
      case 'exp10':
        final a = arg(0);
        return ComplexNumber(math.pow(10, a.real).toDouble(), 0);

      // Roots and powers
      case 'sqrt':
        final a = arg(0);
        if (a.isReal && a.real >= 0) {
          return ComplexNumber(math.sqrt(a.real), 0);
        }
        return a.sqrt();
      case 'cbrt':
        final a = arg(0);
        if (a.isReal) {
          final sign = a.real >= 0 ? 1.0 : -1.0;
          return ComplexNumber(
              sign * math.pow(a.real.abs(), 1.0 / 3.0).toDouble(), 0);
      }
        return a.pow(ComplexNumber(1.0 / 3.0, 0));
      case 'nthroot':
        final a = arg(0);
        final n = arg(1);
        return a.pow(ComplexNumber(1.0 / n.real, 0));
      case 'pow':
        return arg(0).pow(arg(1));
      case 'hypot':
        final a = arg(0);
        final b = arg(1);
        return ComplexNumber(
            math.sqrt(a.real * a.real + b.real * b.real), 0);

      // Absolute value and rounding
      case 'abs':
        final a = arg(0);
        if (a.isReal) return ComplexNumber(a.real.abs(), 0);
        return ComplexNumber(a.magnitude, 0);
      case 'floor':
        final a = arg(0);
        return ComplexNumber(a.real.floorToDouble(), 0);
      case 'ceil':
        final a = arg(0);
        return ComplexNumber(a.real.ceilToDouble(), 0);
      case 'round':
        final a = arg(0);
        return ComplexNumber(a.real.roundToDouble(), 0);
      case 'trunc':
        final a = arg(0);
        return ComplexNumber(a.real.truncateToDouble(), 0);
      case 'frac':
        final a = arg(0);
        return ComplexNumber(a.real - a.real.truncateToDouble(), 0);
      case 'sign':
        final a = arg(0);
        if (a.real == 0) return ComplexNumber(0, 0);
        return ComplexNumber(a.real > 0 ? 1.0 : -1.0, 0);

      // Min/Max
      case 'min':
        if (args.isEmpty) throw Exception('min: requires arguments');
        double minVal = args[0].real;
        for (final a in args) {
          if (a.real < minVal) minVal = a.real;
        }
        return ComplexNumber(minVal, 0);
      case 'max':
        if (args.isEmpty) throw Exception('max: requires arguments');
        double maxVal = args[0].real;
        for (final a in args) {
          if (a.real > maxVal) maxVal = a.real;
        }
        return ComplexNumber(maxVal, 0);
      case 'clamp':
        final a = arg(0);
        final lo = arg(1);
        final hi = arg(2);
        return ComplexNumber(a.real.clamp(lo.real, hi.real), 0);

      // Modulo
      case 'mod':
        final a = arg(0);
        final b = arg(1);
        if (b.real == 0) throw Exception('mod: division by zero');
        return ComplexNumber(a.real % b.real, 0);
      case 'rem':
        final a = arg(0);
        final b = arg(1);
        if (b.real == 0) throw Exception('rem: division by zero');
        return ComplexNumber(a.real.remainder(b.real), 0);

      // GCD/LCM
      case 'gcd':
        final a = arg(0).real.round().abs();
        final b = arg(1).real.round().abs();
        return ComplexNumber(_gcd(a, b).toDouble(), 0);
      case 'lcm':
        final a = arg(0).real.round().abs();
        final b = arg(1).real.round().abs();
        final g = _gcd(a, b);
        return ComplexNumber(g == 0 ? 0 : (a * b / g).toDouble(), 0);

      // Combinatorics
      case 'factorial':
        final a = arg(0);
        final n = a.real.round();
        if (n < 0) throw Exception('Factorial of negative number');
        return ComplexNumber(_computeFactorial(n), 0);
      case 'ncr':
      case 'c':
        final n = arg(0).real.round();
        final r = arg(1).real.round();
        return ComplexNumber(_nCr(n, r), 0);
      case 'npr':
      case 'p':
        final n = arg(0).real.round();
        final r = arg(1).real.round();
        return ComplexNumber(_nPr(n, r), 0);

      // Complex number operations
      case 're':
      case 'real':
        return ComplexNumber(arg(0).real, 0);
      case 'im':
      case 'imag':
        return ComplexNumber(arg(0).imaginary, 0);
      case 'conj':
      case 'conjugate':
        final a = arg(0);
        return ComplexNumber(a.real, -a.imaginary);
      case 'arg':
      case 'angle':
        return ComplexNumber(fromRad(arg(0).phase), 0);
      case 'polar':
        final r = arg(0).real;
        final theta = toRad(arg(1).real);
        return ComplexNumber(
            r * math.cos(theta), r * math.sin(theta));

      // Summation and product
      case 'sum':
        double s = 0;
        for (final a in args) s += a.real;
        return ComplexNumber(s, 0);
      case 'prod':
        double p = 1;
        for (final a in args) p *= a.real;
        return ComplexNumber(p, 0);

      // Bit operations
      case 'band':
        return ComplexNumber(
            (arg(0).real.toInt() & arg(1).real.toInt()).toDouble(), 0);
      case 'bor':
        return ComplexNumber(
            (arg(0).real.toInt() | arg(1).real.toInt()).toDouble(), 0);
      case 'bxor':
        return ComplexNumber(
            (arg(0).real.toInt() ^ arg(1).real.toInt()).toDouble(), 0);
      case 'bnot':
        return ComplexNumber((~arg(0).real.toInt()).toDouble(), 0);
      case 'shl':
        return ComplexNumber(
            (arg(0).real.toInt() << arg(1).real.toInt()).toDouble(), 0);
      case 'shr':
        return ComplexNumber(
            (arg(0).real.toInt() >> arg(1).real.toInt()).toDouble(), 0);

      // Conversion helpers
      case 'todeg':
        return ComplexNumber(arg(0).real * 180.0 / math.pi, 0);
      case 'torad':
        return ComplexNumber(arg(0).real * math.pi / 180.0, 0);
      case 'tograd':
        return ComplexNumber(arg(0).real * 200.0 / math.pi, 0);

      // Random
      case 'rand':
        return ComplexNumber(math.Random().nextDouble(), 0);
      case 'randint':
        final lo = arg(0).real.round();
        final hi = arg(1).real.round();
        return ComplexNumber(
            (lo + math.Random().nextInt(hi - lo + 1)).toDouble(), 0);

      default:
        throw Exception('Unknown function: $name');
    }
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  double _nCr(int n, int r) {
    if (r < 0 || r > n) return 0;
    if (r == 0 || r == n) return 1;
    r = r < n - r ? r : n - r;
    double result = 1;
    for (int i = 0; i < r; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }

  double _nPr(int n, int r) {
    if (r < 0 || r > n) return 0;
    double result = 1;
    for (int i = 0; i < r; i++) {
      result *= (n - i);
    }
    return result;
  }
}
