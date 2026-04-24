import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class SymbolicMathService {
  static final SymbolicMathService instance = SymbolicMathService._();
  SymbolicMathService._();

  final Parser _parser = Parser();

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Compute symbolic derivative of [expression] with respect to [variable]
  /// up to the given [order]. Returns a simplified symbolic string.
  String derivative(String expression, String variable, [int order = 1]) {
    try {
      final cleaned = _normalizeExpression(expression);
      Expression expr = _parser.parse(cleaned);
      Expression result = expr;
      for (int i = 0; i < order; i++) {
        result = result.derive(variable);
        result = _simplifyExpression(result);
      }
      return _expressionToString(result);
    } catch (e) {
      try {
        return _numericDerivativeString(expression, variable, order: order);
      } catch (_) {
        return 'Error: Cannot differentiate "$expression"';
      }
    }
  }

  /// Compute indefinite integral of [expression] with respect to [variable].
  String integralIndefinite(String expression, String variable) {
    try {
      final cleaned = _normalizeExpression(expression);
      final result = _symbolicIntegrate(cleaned, variable);
      return '$result + C';
    } catch (e) {
      return 'Error: Cannot integrate "$expression"';
    }
  }

  /// Compute definite integral of [expression] from [lower] to [upper]
  /// with respect to [variable] using adaptive Simpson's rule.
  /// Returns a String representation of the result.
  Future<String> integralDefinite(
    String expression,
    String variable,
    double lower,
    double upper,
  ) async {
    try {
      final cleaned = _normalizeExpression(expression);
      final result = _adaptiveSimpson(cleaned, variable, lower, upper, 1e-8, 20);
      if (result.isNaN) return 'Does not converge';
      if (result.isInfinite) return result > 0 ? '+∞' : '-∞';
      return _formatNumber(result);
    } catch (e) {
      return 'Error: Cannot compute definite integral';
    }
  }

  /// Compute definite integral numerically, returning double.
  double integralDefiniteNumeric(
    String expression,
    String variable,
    double lower,
    double upper,
  ) {
    try {
      final cleaned = _normalizeExpression(expression);
      return _adaptiveSimpson(cleaned, variable, lower, upper, 1e-8, 20);
    } catch (e) {
      return double.nan;
    }
  }

  /// Compute limit of [expression] as [variable] approaches [targetValue].
  /// [targetValue] can be a number string or 'inf'/'-inf'.
  Future<String> limit(
    String expression,
    String variable,
    String targetValue,
  ) async {
    try {
      final cleaned = _normalizeExpression(expression);
      double target;
      if (targetValue.trim() == 'inf' || targetValue.trim() == '∞') {
        target = double.infinity;
      } else if (targetValue.trim() == '-inf' || targetValue.trim() == '-∞') {
        target = double.negativeInfinity;
      } else {
        target = double.tryParse(targetValue.trim()) ?? 0.0;
      }
      final result = _computeLimit(cleaned, variable, target);
      if (result.isNaN) return 'Does not exist';
      if (result.isInfinite) return result > 0 ? '+∞' : '-∞';
      return _formatNumber(result);
    } catch (e) {
      return 'Error: Cannot compute limit';
    }
  }

  /// Generate Taylor series expansion of [expression] around [expansionPoint]
  /// up to the given [order] in [variable].
  /// [expansionPoint] is a string representation of the point.
  Future<String> taylorSeries(
    String expression,
    String variable,
    String expansionPoint,
    int order,
  ) async {
    try {
      final cleaned = _normalizeExpression(expression);
      final point = double.tryParse(expansionPoint.trim()) ?? 0.0;
      return _buildTaylorSeries(cleaned, variable, point, order);
    } catch (e) {
      return 'Error: Cannot compute Taylor series';
    }
  }

  /// Simplify [expression] algebraically.
  Future<String> simplify(String expression) async {
    try {
      final cleaned = _normalizeExpression(expression);
      Expression expr = _parser.parse(cleaned);
      Expression simplified = _simplifyExpression(expr);
      return _expressionToString(simplified);
    } catch (e) {
      return _normalizeExpression(expression);
    }
  }

  /// Solve equation [equation] (in the form "expr = 0" or "lhs = rhs") for [variable].
  Future<List<String>> solveEquation(String equation, String variable) async {
    try {
      final normalized = _normalizeEquation(equation);
      final symbolic = _solveSymbolic(normalized, variable);
      if (symbolic.isNotEmpty) return symbolic;
      return _solveNumeric(normalized, variable);
    } catch (e) {
      return ['Error: Cannot solve equation'];
    }
  }

  /// Solve a system of equations for the given variables.
  Future<Map<String, String>> solveSystem(
    List<String> equations,
    List<String> variables,
  ) async {
    try {
      if (equations.length != variables.length) {
        return {for (final v in variables) v: 'Error: equation count mismatch'};
      }
      if (variables.length == 1) {
        final solutions = await solveEquation(equations[0], variables[0]);
        return {variables[0]: solutions.join(', ')};
      }
      if (variables.length == 2) {
        return _solveSystem2x2(equations, variables);
      }
      return _solveLinearSystem(equations, variables);
    } catch (e) {
      return {for (final v in variables) v: 'Error: Cannot solve system'};
    }
  }

  // ─── Expression Normalization ───────────────────────────────────────────────

  String _normalizeExpression(String expr) {
    String s = expr.trim();
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    s = s.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z(])'),
      (m) => '${m[1]}*${m[2]}',
    );
    s = s.replaceAll('e^', 'exp(');
    return s;
  }

  String _normalizeEquation(String equation) {
    if (equation.contains('=')) {
      final parts = equation.split('=');
      if (parts.length == 2) {
        final lhs = parts[0].trim();
        final rhs = parts[1].trim();
        if (rhs == '0') return lhs;
        return '($lhs) - ($rhs)';
      }
    }
    return equation.trim();
  }

  // ─── Symbolic Differentiation Helpers ──────────────────────────────────────

  Expression _simplifyExpression(Expression expr) {
    try {
      return _algebraicSimplify(expr);
    } catch (_) {
      return expr;
    }
  }

  Expression _algebraicSimplify(Expression expr) {
    if (expr is Number) return expr;
    if (expr is Variable) return expr;

    if (expr is UnaryMinus) {
      final inner = _algebraicSimplify(expr.exp);
      if (inner is Number) return Number(-inner.value);
      return UnaryMinus(inner);
    }

    if (expr is Plus) {
      final left = _algebraicSimplify(expr.first);
      final right = _algebraicSimplify(expr.second);
      if (right is Number && right.value == 0) return left;
      if (left is Number && left.value == 0) return right;
      if (left is Number && right is Number) return Number(left.value + right.value);
      return Plus(left, right);
    }

    if (expr is Minus) {
      final left = _algebraicSimplify(expr.first);
      final right = _algebraicSimplify(expr.second);
      if (right is Number && right.value == 0) return left;
      if (left is Number && left.value == 0) return UnaryMinus(right);
      if (left is Number && right is Number) return Number(left.value - right.value);
      return Minus(left, right);
    }

    if (expr is Times) {
      final left = _algebraicSimplify(expr.first);
      final right = _algebraicSimplify(expr.second);
      if ((left is Number && left.value == 0) || (right is Number && right.value == 0)) return Number(0);
      if (right is Number && right.value == 1) return left;
      if (left is Number && left.value == 1) return right;
      if (left is Number && left.value == -1) return UnaryMinus(right);
      if (left is Number && right is Number) return Number(left.value * right.value);
      return Times(left, right);
    }

    if (expr is Divide) {
      final left = _algebraicSimplify(expr.first);
      final right = _algebraicSimplify(expr.second);
      if (left is Number && left.value == 0) return Number(0);
      if (right is Number && right.value == 1) return left;
      if (left is Number && right is Number && right.value != 0) return Number(left.value / right.value);
      return Divide(left, right);
    }

    if (expr is Power) {
      final base = _algebraicSimplify(expr.first);
      final exp = _algebraicSimplify(expr.second);
      if (exp is Number && exp.value == 0) return Number(1);
      if (exp is Number && exp.value == 1) return base;
      if (base is Number && base.value == 0) return Number(0);
      if (base is Number && base.value == 1) return Number(1);
      if (base is Number && exp is Number) return Number(math.pow(base.value, exp.value).toDouble());
      return Power(base, exp);
    }

    return expr;
  }

  String _expressionToString(Expression expr) {
    final raw = expr.toString();
    return _prettyPrintExpression(raw);
  }

  String _prettyPrintExpression(String raw) {
    String s = raw;
    s = s.replaceAll('1.0 * ', '');
    s = s.replaceAll(' * 1.0', '');
    s = s.replaceAll('+ 0.0', '');
    s = s.replaceAll('0.0 +', '');
    s = s.replaceAll('- 0.0', '');
    s = s.replaceAll('* 0.0', '0');
    s = s.replaceAll('0.0 *', '0');
    s = s.replaceAll('0.0 / ', '0');
    s = s.replaceAllMapped(RegExp(r'(\d+)\.0(?!\d)'), (m) => m[1]!);
    return s.trim();
  }

  String _numericDerivativeString(String expression, String variable, {int order = 1}) {
    return 'd${order > 1 ? '^$order' : ''}($expression)/d$variable${order > 1 ? '^$order' : ''}';
  }

  // ─── Symbolic Integration ───────────────────────────────────────────────────

  String _symbolicIntegrate(String expression, String variable) {
    final expr = expression.trim();

    final constantMatch = RegExp(r'^-?\d+(\.\d+)?$').firstMatch(expr);
    if (constantMatch != null) return '${expr}*$variable';

    final powerMatch = RegExp(r'^(\w+)\^(-?\d+(\.\d+)?)$').firstMatch(expr);
    if (powerMatch != null && powerMatch[1] == variable) {
      final n = double.parse(powerMatch[2]!);
      if (n == -1) return 'ln(|$variable|)';
      final np1 = n + 1;
      final np1Str = np1 == np1.roundToDouble() ? np1.toInt().toString() : np1.toString();
      return '$variable^$np1Str/$np1Str';
    }

    if (expr == variable) return '$variable^2/2';

    final cPowerMatch = RegExp(r'^(-?\d+(\.\d+)?)\*(\w+)\^(-?\d+(\.\d+)?)$').firstMatch(expr);
    if (cPowerMatch != null && cPowerMatch[3] == variable) {
      final c = double.parse(cPowerMatch[1]!);
      final n = double.parse(cPowerMatch[4]!);
      if (n == -1) return '${_formatCoeff(c)}*ln(|$variable|)';
      final np1 = n + 1;
      final coeff = c / np1;
      final np1Str = np1 == np1.roundToDouble() ? np1.toInt().toString() : np1.toString();
      return '${_formatCoeff(coeff)}*$variable^$np1Str';
    }

    final cxMatch = RegExp(r'^(-?\d+(\.\d+)?)\*(\w+)$').firstMatch(expr);
    if (cxMatch != null && cxMatch[3] == variable) {
      final c = double.parse(cxMatch[1]!);
      return '${_formatCoeff(c / 2)}*$variable^2';
    }

    if (expr == 'sin($variable)') return '-cos($variable)';
    if (expr == 'cos($variable)') return 'sin($variable)';
    if (expr == 'tan($variable)') return '-ln(|cos($variable)|)';
    if (expr == 'exp($variable)' || expr == 'e^$variable') return 'exp($variable)';

    final expMatch = RegExp(r'^exp\((-?\d+(\.\d+)?)\*(\w+)\)$').firstMatch(expr);
    if (expMatch != null && expMatch[3] == variable) {
      final a = double.parse(expMatch[1]!);
      return 'exp(${expMatch[1]}*$variable)/${_formatCoeff(a)}';
    }

    if (expr == '1/$variable' || expr == '$variable^(-1)') return 'ln(|$variable|)';
    if (expr == 'ln($variable)' || expr == 'log($variable)') return '$variable*ln($variable) - $variable';
    if (expr == '1/sqrt(1-$variable^2)') return 'arcsin($variable)';
    if (expr == '1/(1+$variable^2)') return 'arctan($variable)';

    final parts = _splitTopLevel(expr);
    if (parts != null) {
      final op = parts['op']!;
      final leftIntegral = _symbolicIntegrate(parts['left']!, variable);
      final rightIntegral = _symbolicIntegrate(parts['right']!, variable);
      return '$leftIntegral $op $rightIntegral';
    }

    final constMultipleMatch = RegExp(r'^(-?\d+(\.\d+)?)\*(.+)$').firstMatch(expr);
    if (constMultipleMatch != null) {
      final c = constMultipleMatch[1]!;
      final inner = constMultipleMatch[3]!;
      final innerIntegral = _symbolicIntegrate(inner, variable);
      return '$c*($innerIntegral)';
    }

    return '∫($expr)d$variable';
  }

  String _formatCoeff(double c) {
    if (c == c.roundToDouble()) return c.toInt().toString();
    return c.toString();
  }

  Map<String, String>? _splitTopLevel(String expr) {
    int depth = 0;
    for (int i = expr.length - 1; i > 0; i--) {
      final ch = expr[i];
      if (ch == ')') depth++;
      if (ch == '(') depth--;
      if (depth == 0 && (ch == '+' || ch == '-')) {
        if (i == 0) continue;
        final prev = expr[i - 1];
        if (prev == '*' || prev == '/' || prev == '^' || prev == '(') continue;
        return {
          'left': expr.substring(0, i).trim(),
          'right': expr.substring(i + 1).trim(),
          'op': ch,
        };
      }
    }
    return null;
  }

  // ─── Numeric Integration (Adaptive Simpson's Rule) ─────────────────────────

  double _adaptiveSimpson(
    String expression,
    String variable,
    double a,
    double b,
    double tol,
    int maxDepth,
  ) {
    if (a >= b) return 0.0;
    final fa = _evaluateAt(expression, variable, a);
    final fb = _evaluateAt(expression, variable, b);
    final fm = _evaluateAt(expression, variable, (a + b) / 2);
    final whole = (b - a) / 6 * (fa + 4 * fm + fb);
    return _adaptiveSimpsonHelper(expression, variable, a, b, tol, whole, maxDepth, fa, fb, fm);
  }

  double _adaptiveSimpsonHelper(
    String expression,
    String variable,
    double a,
    double b,
    double tol,
    double whole,
    int depth,
    double fa,
    double fb,
    double fm,
  ) {
    final m = (a + b) / 2;
    final lm = (a + m) / 2;
    final rm = (m + b) / 2;
    final flm = _evaluateAt(expression, variable, lm);
    final frm = _evaluateAt(expression, variable, rm);
    final left = (m - a) / 6 * (fa + 4 * flm + fm);
    final right = (b - m) / 6 * (fm + 4 * frm + fb);
    final delta = left + right - whole;
    if (depth <= 0 || delta.abs() <= 15 * tol) {
      return left + right + delta / 15;
    }
    return _adaptiveSimpsonHelper(expression, variable, a, m, tol / 2, left, depth - 1, fa, fm, flm) +
        _adaptiveSimpsonHelper(expression, variable, m, b, tol / 2, right, depth - 1, fm, fb, frm);
  }

  double _evaluateAt(String expression, String variable, double value) {
    try {
      final substituted = expression.replaceAllMapped(
        RegExp(r'\b' + variable + r'\b'),
        (_) => value.toString(),
      );
      final expr = _parser.parse(substituted);
      final cm = ContextModel();
      final result = expr.evaluate(EvaluationType.REAL, cm);
      if (result is double) return result;
      return double.nan;
    } catch (_) {
      return double.nan;
    }
  }

  // ─── Limit Computation ─────────────────────────────────────────────────────

  double _computeLimit(String expression, String variable, double targetValue) {
    if (targetValue.isInfinite) {
      // Approach from large values
      final sign = targetValue > 0 ? 1 : -1;
      final vals = [1e6, 1e8, 1e10, 1e12].map((v) => _evaluateAt(expression, variable, sign * v)).toList();
      if (vals.every((v) => v.isNaN)) return double.nan;
      final last = vals.lastWhere((v) => !v.isNaN, orElse: () => double.nan);
      return last;
    }

    // Try direct evaluation first
    final direct = _evaluateAt(expression, variable, targetValue);
    if (!direct.isNaN && !direct.isInfinite) return direct;

    // Approach from both sides
    const epsilon = 1e-8;
    final leftVal = _evaluateAt(expression, variable, targetValue - epsilon);
    final rightVal = _evaluateAt(expression, variable, targetValue + epsilon);

    if (leftVal.isNaN && rightVal.isNaN) return double.nan;
    if (leftVal.isNaN) return rightVal;
    if (rightVal.isNaN) return leftVal;

    if ((leftVal - rightVal).abs() > 1e-4 * (leftVal.abs() + rightVal.abs() + 1)) {
      return double.nan; // Limit does not exist (left ≠ right)
    }

    return (leftVal + rightVal) / 2;
  }

  // ─── Taylor Series ─────────────────────────────────────────────────────────

  String _buildTaylorSeries(
    String expression,
    String variable,
    double expansionPoint,
    int order,
  ) {
    final terms = <String>[];
    double factorial = 1.0;

    for (int n = 0; n <= order; n++) {
      if (n > 0) factorial *= n;

      // Compute nth derivative numerically at expansion point
      final deriv = _numericalDerivative(expression, variable, expansionPoint, n);
      if (deriv.isNaN || deriv.isInfinite) continue;

      final coeff = deriv / factorial;
      if (coeff.abs() < 1e-12) continue;

      String term;
      if (n == 0) {
        term = _formatNumber(coeff);
      } else if (n == 1) {
        final pointStr = expansionPoint == 0 ? variable : '($variable - ${_formatNumber(expansionPoint)})';
        term = '${_formatNumber(coeff)}·$pointStr';
      } else {
        final pointStr = expansionPoint == 0 ? variable : '($variable - ${_formatNumber(expansionPoint)})';
        term = '${_formatNumber(coeff)}·$pointStr^$n';
      }
      terms.add(term);
    }

    if (terms.isEmpty) return '0';
    return terms.join(' + ').replaceAll('+ -', '- ');
  }

  double _numericalDerivative(String expression, String variable, double point, int order) {
    if (order == 0) return _evaluateAt(expression, variable, point);
    const h = 1e-4;
    if (order == 1) {
      final fPlus = _evaluateAt(expression, variable, point + h);
      final fMinus = _evaluateAt(expression, variable, point - h);
      return (fPlus - fMinus) / (2 * h);
    }
    // Higher order: recursive finite differences
    final fPlus = _numericalDerivative(expression, variable, point + h, order - 1);
    final fMinus = _numericalDerivative(expression, variable, point - h, order - 1);
    return (fPlus - fMinus) / (2 * h);
  }

  // ─── Equation Solving ──────────────────────────────────────────────────────

  List<String> _solveSymbolic(String expression, String variable) {
    final expr = expression.trim();

    // Linear: ax + b = 0 → x = -b/a
    final linearMatch = RegExp(r'^(-?\d*\.?\d*)\*?' + variable + r'\s*([+-]\s*\d+\.?\d*)?$').firstMatch(expr);
    if (linearMatch != null) {
      final aStr = linearMatch[1]!.isEmpty ? '1' : linearMatch[1]!;
      final a = double.tryParse(aStr) ?? 1.0;
      final bStr = linearMatch[2]?.replaceAll(' ', '') ?? '0';
      final b = double.tryParse(bStr) ?? 0.0;
      if (a != 0) return ['$variable = ${_formatNumber(-b / a)}'];
    }

    // Quadratic: ax^2 + bx + c = 0
    return _solveQuadratic(expr, variable);
  }

  List<String> _solveQuadratic(String expression, String variable) {
    // Try to extract coefficients of ax^2 + bx + c
    try {
      // Numerical approach: find roots in [-1000, 1000]
      return _solveNumeric(expression, variable);
    } catch (_) {
      return [];
    }
  }

  List<String> _solveNumeric(String expression, String variable) {
    final roots = <String>[];
    const xMin = -100.0;
    const xMax = 100.0;
    const steps = 1000;
    const step = (xMax - xMin) / steps;

    double? prevY;
    double prevX = xMin;

    for (int i = 0; i <= steps; i++) {
      final x = xMin + i * step;
      final y = _evaluateAt(expression, variable, x);
      if (y.isNaN || y.isInfinite) {
        prevY = null;
        prevX = x;
        continue;
      }

      if (prevY != null && prevY * y < 0) {
        // Sign change — bisect
        final root = _bisect(expression, variable, prevX, x);
        if (root != null) {
          final rootStr = _formatNumber(root);
          if (!roots.contains('$variable = $rootStr')) {
            roots.add('$variable = $rootStr');
          }
        }
      } else if (y.abs() < 1e-10) {
        final rootStr = _formatNumber(x);
        if (!roots.contains('$variable = $rootStr')) {
          roots.add('$variable = $rootStr');
        }
      }

      prevY = y;
      prevX = x;
    }

    return roots;
  }

  double? _bisect(String expression, String variable, double a, double b) {
    for (int i = 0; i < 100; i++) {
      final m = (a + b) / 2;
      final fm = _evaluateAt(expression, variable, m);
      if (fm.abs() < 1e-12 || (b - a) / 2 < 1e-12) return m;
      final fa = _evaluateAt(expression, variable, a);
      if (fa * fm < 0) {
        b = m;
      } else {
        a = m;
      }
    }
    return (a + b) / 2;
  }

  Map<String, String> _solveSystem2x2(List<String> equations, List<String> variables) {
    // Numerical approach: grid search + Newton's method
    final x0 = variables[0];
    final x1 = variables[1];

    // Try to find solution numerically
    for (double a = -10.0; a <= 10.0; a += 1.0) {
      for (double b = -10.0; b <= 10.0; b += 1.0) {
        final f0 = _evaluateSystem(equations[0], variables, [a, b]);
        final f1 = _evaluateSystem(equations[1], variables, [a, b]);
        if (f0.abs() < 1e-6 && f1.abs() < 1e-6) {
          return {
            x0: _formatNumber(a),
            x1: _formatNumber(b),
          };
        }
      }
    }

    // Newton's method from origin
    double a = 0.0, b = 0.0;
    for (int iter = 0; iter < 100; iter++) {
      final f0 = _evaluateSystem(equations[0], variables, [a, b]);
      final f1 = _evaluateSystem(equations[1], variables, [a, b]);
      if (f0.abs() < 1e-10 && f1.abs() < 1e-10) break;

      const h = 1e-6;
      final df0da = (_evaluateSystem(equations[0], variables, [a + h, b]) - f0) / h;
      final df0db = (_evaluateSystem(equations[0], variables, [a, b + h]) - f0) / h;
      final df1da = (_evaluateSystem(equations[1], variables, [a + h, b]) - f1) / h;
      final df1db = (_evaluateSystem(equations[1], variables, [a, b + h]) - f1) / h;

      final det = df0da * df1db - df0db * df1da;
      if (det.abs() < 1e-12) break;

      a -= (f0 * df1db - f1 * df0db) / det;
      b -= (f1 * df0da - f0 * df1da) / det;
    }

    final f0 = _evaluateSystem(equations[0], variables, [a, b]);
    final f1 = _evaluateSystem(equations[1], variables, [a, b]);
    if (f0.abs() < 1e-6 && f1.abs() < 1e-6) {
      return {x0: _formatNumber(a), x1: _formatNumber(b)};
    }

    return {x0: 'No solution found', x1: 'No solution found'};
  }

  double _evaluateSystem(String expression, List<String> variables, List<double> values) {
    String expr = _normalizeEquation(expression);
    for (int i = 0; i < variables.length; i++) {
      expr = expr.replaceAllMapped(
        RegExp(r'\b' + variables[i] + r'\b'),
        (_) => values[i].toString(),
      );
    }
    try {
      final parsed = _parser.parse(expr);
      final cm = ContextModel();
      final result = parsed.evaluate(EvaluationType.REAL, cm);
      if (result is double) return result;
      return double.nan;
    } catch (_) {
      return double.nan;
    }
  }

  Map<String, String> _solveLinearSystem(List<String> equations, List<String> variables) {
    // Gaussian elimination on linearized system
    final n = variables.length;
    final aug = List.generate(n, (i) => List.filled(n + 1, 0.0));

    for (int i = 0; i < n; i++) {
      final normalized = _normalizeEquation(equations[i]);
      for (int j = 0; j < n; j++) {
        // Numerical coefficient extraction
        const h = 1e-6;
        final base = _evaluateSystem(normalized, variables, List.filled(n, 0.0));
        final vals = List.filled(n, 0.0);
        vals[j] = h;
        final perturbed = _evaluateSystem(normalized, variables, vals);
        aug[i][j] = (perturbed - base) / h;
      }
      aug[i][n] = -_evaluateSystem(normalized, variables, List.filled(n, 0.0));
    }

    // Gaussian elimination
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      double maxVal = aug[col][col].abs();
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > maxVal) {
          maxVal = aug[row][col].abs();
          pivotRow = row;
        }
      }
      final tmp = aug[col];
      aug[col] = aug[pivotRow];
      aug[pivotRow] = tmp;

      if (aug[col][col].abs() < 1e-12) continue;
      final pivotVal = aug[col][col];
      for (int j = col; j <= n; j++) aug[col][j] /= pivotVal;
      for (int row = 0; row < n; row++) {
        if (row != col) {
          final factor = aug[row][col];
          for (int j = col; j <= n; j++) aug[row][j] -= factor * aug[col][j];
        }
      }
    }

    return {
      for (int i = 0; i < n; i++) variables[i]: _formatNumber(aug[i][n]),
    };
  }

  // ─── Formatting ────────────────────────────────────────────────────────────

  String _formatNumber(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    // Remove trailing zeros
    final s = value.toStringAsFixed(8);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
