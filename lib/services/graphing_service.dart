import 'dart:math' as math;
import 'package:scientific_pro_calculator/services/arithmetic_service.dart';
import 'package:scientific_pro_calculator/models/app_settings.dart';
import 'package:scientific_pro_calculator/models/graph_function_2d.dart';
import 'package:scientific_pro_calculator/models/graph_function_3d.dart';

/// A 2D plot point — may be null to indicate a discontinuity/gap in the curve.
class PlotPoint {
  final double x;
  final double y;
  const PlotPoint(this.x, this.y);
}

/// A 3D surface vertex.
class Vertex3D {
  final double x;
  final double y;
  final double z;
  const Vertex3D(this.x, this.y, this.z);
}

/// Result from a 3D surface mesh generation.
class SurfaceMesh {
  final List<List<Vertex3D?>> vertices;
  final int uSteps;
  final int vSteps;
  final double zMin;
  final double zMax;

  const SurfaceMesh({
    required this.vertices,
    required this.uSteps,
    required this.vSteps,
    required this.zMin,
    required this.zMax,
  });
}

/// Result of a trace query at a specific x value.
class TraceResult {
  final double x;
  final double y;
  final String xFormatted;
  final String yFormatted;
  const TraceResult({
    required this.x,
    required this.y,
    required this.xFormatted,
    required this.yFormatted,
  });
}

/// An extremum found on a curve.
class Extremum {
  final double x;
  final double y;
  final bool isMaximum;
  const Extremum({required this.x, required this.y, required this.isMaximum});
}

/// Service that generates plot data for 2D curves and 3D surface meshes
/// from function expressions. Uses ArithmeticService for evaluation.
class GraphingService {
  GraphingService._();
  static final GraphingService instance = GraphingService._();

  final ArithmeticService _arithmetic = ArithmeticService.instance;

  static final AppSettings _defaultSettings = AppSettings.defaults();

  static const double _discontinuityThreshold = 50.0;
  static const int _minPointsForDiscontinuity = 3;

  /// Evaluate a 2D function expression at a single x value.
  double? evaluateAt(String expression, double x, {AppSettings? settings}) {
    final s = settings ?? _defaultSettings;
    final substituted = _substituteX(expression, x);
    final result = _arithmetic.evaluate(substituted, s);
    if (result.isError || result.isComplex) return null;
    final val = double.tryParse(result.result.replaceAll(' ', '').replaceAll('×10^', 'e'));
    if (val == null || val.isNaN || val.isInfinite) return null;
    return val;
  }

  /// Evaluate a 3D function expression z = f(x, y) at a single (x, y) point.
  double? evaluateAt3D(String expression, double x, double y, {AppSettings? settings}) {
    final s = settings ?? _defaultSettings;
    final substituted = _substituteXY(expression, x, y);
    final result = _arithmetic.evaluate(substituted, s);
    if (result.isError || result.isComplex) return null;
    final val = double.tryParse(result.result.replaceAll(' ', '').replaceAll('×10^', 'e'));
    if (val == null || val.isNaN || val.isInfinite) return null;
    return val;
  }

  /// Generate plot data for a 2D function curve.
  List<PlotPoint?> generatePlotData(
    String expression, {
    required double xMin,
    required double xMax,
    int resolution = 500,
    AppSettings? settings,
  }) {
    if (xMin >= xMax) return [];
    if (resolution < 2) resolution = 2;

    final s = settings ?? _defaultSettings;
    final step = (xMax - xMin) / resolution;
    final points = <PlotPoint?>[];
    double? prevY;
    double? prevPrevY;

    for (int i = 0; i <= resolution; i++) {
      final x = xMin + i * step;
      final y = evaluateAt(expression, x, settings: s);

      if (y == null) {
        if (points.isNotEmpty && points.last != null) {
          points.add(null);
        }
        prevY = null;
        prevPrevY = null;
        continue;
      }

      if (prevY != null && prevPrevY != null && points.length >= _minPointsForDiscontinuity) {
        final prevDelta = (prevY - prevPrevY).abs();
        final currDelta = (y - prevY).abs();
        if (prevDelta > 0 && currDelta / prevDelta > _discontinuityThreshold && currDelta > 1.0) {
          points.add(null);
          prevPrevY = null;
          prevY = null;
        }
      }

      const yLimit = 1e10;
      final clampedY = y.clamp(-yLimit, yLimit);

      points.add(PlotPoint(x, clampedY));
      prevPrevY = prevY;
      prevY = y;
    }

    return points;
  }

  /// Generate plot data for multiple 2D functions simultaneously.
  Map<int, List<PlotPoint?>> generateMultiplePlotData(
    List<GraphFunction2D> functions, {
    required double xMin,
    required double xMax,
    int resolution = 500,
    AppSettings? settings,
  }) {
    final result = <int, List<PlotPoint?>>{};
    for (int i = 0; i < functions.length; i++) {
      result[i] = generatePlotData(
        functions[i].expression,
        xMin: xMin,
        xMax: xMax,
        resolution: resolution,
        settings: settings,
      );
    }
    return result;
  }

  /// Generate shaded region data for integral visualization.
  List<PlotPoint> generateIntegralShadeData(
    String expression, {
    required double lowerBound,
    required double upperBound,
    int resolution = 200,
    AppSettings? settings,
  }) {
    if (lowerBound >= upperBound) return [];

    final s = settings ?? _defaultSettings;
    final step = (upperBound - lowerBound) / resolution;
    final curvePoints = <PlotPoint>[];

    for (int i = 0; i <= resolution; i++) {
      final x = lowerBound + i * step;
      final y = evaluateAt(expression, x, settings: s) ?? 0.0;
      curvePoints.add(PlotPoint(x, y.clamp(-1e10, 1e10)));
    }

    final polygon = <PlotPoint>[...curvePoints];
    polygon.add(PlotPoint(upperBound, 0.0));
    polygon.add(PlotPoint(lowerBound, 0.0));

    return polygon;
  }

  /// Numerically compute the definite integral using Simpson's rule.
  double computeDefiniteIntegral(
    String expression, {
    required double lower,
    required double upper,
    int intervals = 1000,
    AppSettings? settings,
  }) {
    if (lower >= upper) return 0.0;
    if (intervals % 2 != 0) intervals++;
    final s = settings ?? _defaultSettings;
    final h = (upper - lower) / intervals;
    double sum = 0.0;

    final y0 = evaluateAt(expression, lower, settings: s) ?? 0.0;
    final yn = evaluateAt(expression, upper, settings: s) ?? 0.0;
    sum = y0 + yn;

    for (int i = 1; i < intervals; i++) {
      final x = lower + i * h;
      final y = evaluateAt(expression, x, settings: s) ?? 0.0;
      sum += (i % 2 == 0) ? 2 * y : 4 * y;
    }

    return sum * h / 3.0;
  }

  /// Find approximate roots (zero crossings) of a function in [xMin, xMax].
  List<double> findRoots(
    String expression, {
    required double xMin,
    required double xMax,
    int resolution = 1000,
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    final roots = <double>[];
    final step = (xMax - xMin) / resolution;

    double? prevY;
    double prevX = xMin;

    for (int i = 0; i <= resolution; i++) {
      final x = xMin + i * step;
      final y = evaluateAt(expression, x, settings: s);
      if (y == null) {
        prevY = null;
        prevX = x;
        continue;
      }

      if (prevY != null) {
        if (prevY * y < 0) {
          final root = _bisect(expression, prevX, x, s);
          if (root != null) {
            if (roots.isEmpty || (root - roots.last).abs() > step * 0.5) {
              roots.add(root);
            }
          }
        } else if (y.abs() < 1e-10) {
          if (roots.isEmpty || (x - roots.last).abs() > step * 0.5) {
            roots.add(x);
          }
        }
      }

      prevY = y;
      prevX = x;
    }

    return roots;
  }

  /// Find approximate intersections of two functions in [xMin, xMax].
  List<PlotPoint> findIntersections(
    String expression1,
    String expression2, {
    required double xMin,
    required double xMax,
    int resolution = 1000,
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    final intersections = <PlotPoint>[];
    final step = (xMax - xMin) / resolution;

    double? prevDiff;
    double prevX = xMin;

    for (int i = 0; i <= resolution; i++) {
      final x = xMin + i * step;
      final y1 = evaluateAt(expression1, x, settings: s);
      final y2 = evaluateAt(expression2, x, settings: s);
      if (y1 == null || y2 == null) {
        prevDiff = null;
        prevX = x;
        continue;
      }

      final diff = y1 - y2;

      if (prevDiff != null) {
        if (prevDiff * diff < 0) {
          final ix = _bisectDifference(expression1, expression2, prevX, x, s);
          if (ix != null) {
            final iy = evaluateAt(expression1, ix, settings: s);
            if (iy != null) {
              if (intersections.isEmpty || (ix - intersections.last.x).abs() > step * 0.5) {
                intersections.add(PlotPoint(ix, iy));
              }
            }
          }
        } else if (diff.abs() < 1e-10) {
          final iy = evaluateAt(expression1, x, settings: s);
          if (iy != null) {
            if (intersections.isEmpty || (x - intersections.last.x).abs() > step * 0.5) {
              intersections.add(PlotPoint(x, iy));
            }
          }
        }
      }

      prevDiff = diff;
      prevX = x;
    }

    return intersections;
  }

  /// Find local extrema (minima and maxima) of a function in [xMin, xMax].
  List<Extremum> findExtrema(
    String expression, {
    required double xMin,
    required double xMax,
    int resolution = 500,
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    final extrema = <Extremum>[];
    final step = (xMax - xMin) / resolution;

    double? prevDeriv;
    double prevX = xMin;

    for (int i = 1; i < resolution; i++) {
      final x = xMin + i * step;
      final h = step * 0.01;
      final yPlus = evaluateAt(expression, x + h, settings: s);
      final yMinus = evaluateAt(expression, x - h, settings: s);
      if (yPlus == null || yMinus == null) {
        prevDeriv = null;
        prevX = x;
        continue;
      }

      final deriv = (yPlus - yMinus) / (2 * h);

      if (prevDeriv != null) {
        if (prevDeriv * deriv < 0) {
          final ex = (prevX + x) / 2;
          final ey = evaluateAt(expression, ex, settings: s);
          if (ey != null) {
            final isMax = prevDeriv > 0;
            if (extrema.isEmpty || (ex - extrema.last.x).abs() > step) {
              extrema.add(Extremum(x: ex, y: ey, isMaximum: isMax));
            }
          }
        }
      }

      prevDeriv = deriv;
      prevX = x;
    }

    return extrema;
  }

  /// Get the exact (x, y) value of a function at a specific x for the trace tool.
  TraceResult? getTracePoint(
    String expression,
    double x, {
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    final y = evaluateAt(expression, x, settings: s);
    if (y == null) return null;

    final xFormatted = _formatDouble(x, s);
    final yFormatted = _formatDouble(y, s);

    return TraceResult(
      x: x,
      y: y,
      xFormatted: xFormatted,
      yFormatted: yFormatted,
    );
  }

  /// Compute the numerical derivative of a function at point x.
  double? numericalDerivative(
    String expression,
    double x, {
    AppSettings? settings,
    double h = 1e-6,
  }) {
    final s = settings ?? _defaultSettings;
    final yPlus = evaluateAt(expression, x + h, settings: s);
    final yMinus = evaluateAt(expression, x - h, settings: s);
    if (yPlus == null || yMinus == null) return null;
    return (yPlus - yMinus) / (2 * h);
  }

  /// Compute the numerical limit of a function as x approaches targetX.
  double? numericalLimit(
    String expression,
    double targetX, {
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    const epsilon = 1e-8;
    final leftY = evaluateAt(expression, targetX - epsilon, settings: s);
    final rightY = evaluateAt(expression, targetX + epsilon, settings: s);

    if (leftY == null && rightY == null) return null;
    if (leftY == null) return rightY;
    if (rightY == null) return leftY;

    if ((leftY - rightY).abs() > 1e-4 * (leftY.abs() + rightY.abs() + 1)) {
      return null; // Limit does not exist
    }

    return (leftY + rightY) / 2;
  }

  /// Generate a 3D surface mesh for a function z = f(x, y).
  SurfaceMesh generate3DSurfaceData(
    GraphFunction3D function3D, {
    AppSettings? settings,
  }) {
    final s = settings ?? _defaultSettings;
    final uSteps = function3D.meshDensity;
    final vSteps = function3D.meshDensity;
    final uMin = function3D.uMin;
    final uMax = function3D.uMax;
    final vMin = function3D.vMin;
    final vMax = function3D.vMax;

    final uStep = (uMax - uMin) / uSteps;
    final vStep = (vMax - vMin) / vSteps;

    double zMin = double.infinity;
    double zMax = double.negativeInfinity;

    final vertices = List.generate(uSteps + 1, (ui) {
      return List.generate(vSteps + 1, (vi) {
        final u = uMin + ui * uStep;
        final v = vMin + vi * vStep;
        final z = evaluateAt3D(function3D.expression, u, v, settings: s);
        if (z != null) {
          if (z < zMin) zMin = z;
          if (z > zMax) zMax = z;
          return Vertex3D(u, v, z);
        }
        return null;
      });
    });

    if (zMin == double.infinity) zMin = -1;
    if (zMax == double.negativeInfinity) zMax = 1;

    return SurfaceMesh(
      vertices: vertices,
      uSteps: uSteps,
      vSteps: vSteps,
      zMin: zMin,
      zMax: zMax,
    );
  }

  // ─── Private Helpers ────────────────────────────────────────────────────────

  String _substituteX(String expression, double x) {
    final xStr = x.toString();
    // Replace standalone 'x' with the value
    return expression.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z])x(?![a-zA-Z0-9_])'),
      (_) => '($xStr)',
    );
  }

  String _substituteXY(String expression, double x, double y) {
    String result = expression;
    result = result.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z])x(?![a-zA-Z0-9_])'),
      (_) => '(${x.toString()})',
    );
    result = result.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z])y(?![a-zA-Z0-9_])'),
      (_) => '(${y.toString()})',
    );
    return result;
  }

  /// Bisect to find a root of [expression] between [a] and [b].
  double? _bisect(String expression, double a, double b, AppSettings settings) {
    for (int i = 0; i < 100; i++) {
      final m = (a + b) / 2;
      final fm = evaluateAt(expression, m, settings: settings);
      if (fm == null) return null;
      if (fm.abs() < 1e-12 || (b - a) / 2 < 1e-12) return m;
      final fa = evaluateAt(expression, a, settings: settings);
      if (fa == null) return null;
      if (fa * fm < 0) {
        b = m;
      } else {
        a = m;
      }
    }
    return (a + b) / 2;
  }

  /// Bisect to find intersection of two functions between [a] and [b].
  double? _bisectDifference(
    String expr1,
    String expr2,
    double a,
    double b,
    AppSettings settings,
  ) {
    for (int i = 0; i < 100; i++) {
      final m = (a + b) / 2;
      final y1m = evaluateAt(expr1, m, settings: settings);
      final y2m = evaluateAt(expr2, m, settings: settings);
      if (y1m == null || y2m == null) return null;
      final fm = y1m - y2m;
      if (fm.abs() < 1e-12 || (b - a) / 2 < 1e-12) return m;
      final y1a = evaluateAt(expr1, a, settings: settings);
      final y2a = evaluateAt(expr2, a, settings: settings);
      if (y1a == null || y2a == null) return null;
      final fa = y1a - y2a;
      if (fa * fm < 0) {
        b = m;
      } else {
        a = m;
      }
    }
    return (a + b) / 2;
  }

  /// Format a double value for display.
  String _formatDouble(double value, AppSettings settings) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == 0) return '0';

    final abs = value.abs();
    if (abs >= 1e6 || (abs < 1e-4 && abs > 0)) {
      return value.toStringAsExponential(4);
    }

    // Remove trailing zeros
    final s = value.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
