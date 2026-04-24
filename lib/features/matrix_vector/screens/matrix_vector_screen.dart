import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';

class MatrixVectorScreen extends ConsumerStatefulWidget {
  const MatrixVectorScreen({super.key});

  @override
  ConsumerState<MatrixVectorScreen> createState() => _MatrixVectorScreenState();
}

class _MatrixVectorScreenState extends ConsumerState<MatrixVectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Matrix A state
  int _matARows = 3;
  int _matACols = 3;
  late List<List<TextEditingController>> _matAControllers;

  // Matrix B state
  int _matBRows = 3;
  int _matBCols = 3;
  late List<List<TextEditingController>> _matBControllers;

  // Vector state
  int _vecSize = 3;
  int _vecBSize = 3;
  late List<TextEditingController> _vecAControllers;
  late List<TextEditingController> _vecBControllers;

  // Results
  String _resultText = '';
  String _resultLabel = '';

  // Operation selection
  String _selectedMatrixOp = 'add';
  String _selectedDecomp = 'LU';
  String _selectedVectorOp = 'dot';

  static const List<String> _matrixOps = [
    'add', 'subtract', 'multiply', 'transpose_A', 'invert_A',
    'determinant_A', 'trace_A', 'rank_A', 'eigenvalues_A',
  ];

  static const List<String> _matrixOpLabels = [
    'A + B', 'A − B', 'A × B', 'Transpose A', 'Inverse A',
    'Det(A)', 'Trace(A)', 'Rank(A)', 'Eigen(A)',
  ];

  static const List<String> _decomps = ['LU', 'QR', 'SVD'];

  static const List<String> _vectorOps = [
    'dot', 'cross', 'norm_A', 'normalize_A', 'add_vec', 'subtract_vec',
  ];

  static const List<String> _vectorOpLabels = [
    'A · B', 'A × B', '‖A‖', 'Normalize A', 'A + B', 'A − B',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initMatAControllers();
    _initMatBControllers();
    _initVecControllers();
  }

  void _initMatAControllers() {
    _matAControllers = List.generate(
      _matARows,
      (r) => List.generate(_matACols, (c) => TextEditingController(text: '0')),
    );
  }

  void _initMatBControllers() {
    _matBControllers = List.generate(
      _matBRows,
      (r) => List.generate(_matBCols, (c) => TextEditingController(text: '0')),
    );
  }

  void _initVecControllers() {
    _vecAControllers =
        List.generate(_vecSize, (i) => TextEditingController(text: '0'));
    _vecBControllers =
        List.generate(_vecBSize, (i) => TextEditingController(text: '0'));
  }

  void _disposeMatAControllers() {
    for (final row in _matAControllers) {
      for (final c in row) c.dispose();
    }
  }

  void _disposeMatBControllers() {
    for (final row in _matBControllers) {
      for (final c in row) c.dispose();
    }
  }

  void _disposeVecControllers() {
    for (final c in _vecAControllers) c.dispose();
    for (final c in _vecBControllers) c.dispose();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeMatAControllers();
    _disposeMatBControllers();
    _disposeVecControllers();
    super.dispose();
  }

  // ─── Matrix helpers ───────────────────────────────────────────────────────

  List<List<double>> _readMatA() {
    return List.generate(
      _matARows,
      (r) => List.generate(
        _matACols,
        (c) => double.tryParse(_matAControllers[r][c].text) ?? 0.0,
      ),
    );
  }

  List<List<double>> _readMatB() {
    return List.generate(
      _matBRows,
      (r) => List.generate(
        _matBCols,
        (c) => double.tryParse(_matBControllers[r][c].text) ?? 0.0,
      ),
    );
  }

  List<double> _readVecA() =>
      _vecAControllers.map((c) => double.tryParse(c.text) ?? 0.0).toList();

  List<double> _readVecB() =>
      _vecBControllers.map((c) => double.tryParse(c.text) ?? 0.0).toList();

  void _resizeMatA(int rows, int cols) {
    final old = _readMatA();
    _disposeMatAControllers();
    setState(() {
      _matARows = rows;
      _matACols = cols;
      _matAControllers = List.generate(
        rows,
        (r) => List.generate(cols, (c) {
          final val =
              (r < old.length && c < old[r].length) ? old[r][c] : 0.0;
          return TextEditingController(text: _formatNum(val));
        }),
      );
    });
  }

  void _resizeMatB(int rows, int cols) {
    final old = _readMatB();
    _disposeMatBControllers();
    setState(() {
      _matBRows = rows;
      _matBCols = cols;
      _matBControllers = List.generate(
        rows,
        (r) => List.generate(cols, (c) {
          final val =
              (r < old.length && c < old[r].length) ? old[r][c] : 0.0;
          return TextEditingController(text: _formatNum(val));
        }),
      );
    });
  }

  void _resizeVecA(int size) {
    final old = _readVecA();
    for (final c in _vecAControllers) c.dispose();
    setState(() {
      _vecSize = size;
      _vecAControllers = List.generate(size, (i) {
        final val = i < old.length ? old[i] : 0.0;
        return TextEditingController(text: _formatNum(val));
      });
    });
  }

  void _resizeVecB(int size) {
    final old = _readVecB();
    for (final c in _vecBControllers) c.dispose();
    setState(() {
      _vecBSize = size;
      _vecBControllers = List.generate(size, (i) {
        final val = i < old.length ? old[i] : 0.0;
        return TextEditingController(text: _formatNum(val));
      });
    });
  }

  // ─── Pure math implementations ────────────────────────────────────────────

  String _formatNum(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsFixed(8);
    final trimmed = s
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  String _formatNumResult(double v) {
    if (v.isNaN) return 'NaN';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    if (v.abs() < 1e-12 && v != 0) return v.toStringAsExponential(6);
    if (v.abs() >= 1e10) return v.toStringAsExponential(6);
    if (v == v.truncateToDouble()) return v.toInt().toString();
    final s = v
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return s.isEmpty ? '0' : s;
  }

  String _matrixToString(List<List<double>> m, {String? label}) {
    final sb = StringBuffer();
    if (label != null) sb.writeln(label);
    for (int r = 0; r < m.length; r++) {
      sb.write(r == 0 ? '⎡' : (r == m.length - 1 ? '⎣' : '⎢'));
      sb.write(m[r].map(_formatNumResult).join('  '));
      sb.writeln(r == 0 ? '⎤' : (r == m.length - 1 ? '⎦' : '⎥'));
    }
    return sb.toString();
  }

  List<List<double>> _matAdd(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception(
          'Dimension mismatch: A is ${a.length}×${a[0].length}, B is ${b.length}×${b[0].length}');
    }
    return List.generate(
        a.length, (r) => List.generate(a[0].length, (c) => a[r][c] + b[r][c]));
  }

  List<List<double>> _matSubtract(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception(
          'Dimension mismatch: A is ${a.length}×${a[0].length}, B is ${b.length}×${b[0].length}');
    }
    return List.generate(
        a.length, (r) => List.generate(a[0].length, (c) => a[r][c] - b[r][c]));
  }

  List<List<double>> _matMultiply(List<List<double>> a, List<List<double>> b) {
    if (a[0].length != b.length) {
      throw Exception(
          'Dimension mismatch: A cols (${a[0].length}) ≠ B rows (${b.length})');
    }
    final int m = a.length, n = b[0].length, k = b.length;
    return List.generate(
        m,
        (r) => List.generate(n, (c) {
              double sum = 0;
              for (int i = 0; i < k; i++) sum += a[r][i] * b[i][c];
              return sum;
            }));
  }

  List<List<double>> _transpose(List<List<double>> m) {
    final rows = m.length, cols = m[0].length;
    return List.generate(cols, (r) => List.generate(rows, (c) => m[c][r]));
  }

  double _determinant(List<List<double>> m) {
    final n = m.length;
    if (n != m[0].length)
      throw Exception('Matrix must be square for determinant');
    if (n == 1) return m[0][0];
    if (n == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    final lu = _luDecompRaw(m);
    double det = lu.sign.toDouble();
    for (int i = 0; i < n; i++) det *= lu.u[i][i];
    return det;
  }

  double _trace(List<List<double>> m) {
    if (m.length != m[0].length)
      throw Exception('Matrix must be square for trace');
    double t = 0;
    for (int i = 0; i < m.length; i++) t += m[i][i];
    return t;
  }

  int _rank(List<List<double>> m) {
    final rows = m.length, cols = m[0].length;
    final a = List.generate(rows, (r) => List<double>.from(m[r]));
    int rank = 0;
    final List<bool> rowUsed = List.filled(rows, false);
    for (int col = 0; col < cols; col++) {
      int pivotRow = -1;
      for (int row = 0; row < rows; row++) {
        if (!rowUsed[row] && a[row][col].abs() > 1e-9) {
          if (pivotRow == -1 || a[row][col].abs() > a[pivotRow][col].abs()) {
            pivotRow = row;
          }
        }
      }
      if (pivotRow == -1) continue;
      rowUsed[pivotRow] = true;
      rank++;
      final pivot = a[pivotRow][col];
      for (int row = 0; row < rows; row++) {
        if (row != pivotRow) {
          final factor = a[row][col] / pivot;
          for (int c = col; c < cols; c++) {
            a[row][c] -= factor * a[pivotRow][c];
          }
        }
      }
    }
    return rank;
  }

  List<List<double>> _invert(List<List<double>> m) {
    final n = m.length;
    if (n != m[0].length) throw Exception('Matrix must be square to invert');
    final aug = List.generate(n, (r) {
      final row = List<double>.from(m[r]);
      for (int c = 0; c < n; c++) row.add(c == r ? 1.0 : 0.0);
      return row;
    });
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > aug[pivotRow][col].abs()) pivotRow = row;
      }
      final tmp = aug[col];
      aug[col] = aug[pivotRow];
      aug[pivotRow] = tmp;
      if (aug[col][col].abs() < 1e-12)
        throw Exception('Matrix is singular (not invertible)');
      final pivot = aug[col][col];
      for (int c = 0; c < 2 * n; c++) aug[col][c] /= pivot;
      for (int row = 0; row < n; row++) {
        if (row != col) {
          final factor = aug[row][col];
          for (int c = 0; c < 2 * n; c++) aug[row][c] -= factor * aug[col][c];
        }
      }
    }
    return List.generate(n, (r) => aug[r].sublist(n));
  }

  ({List<List<double>> l, List<List<double>> u, List<int> p, int sign})
      _luDecompRaw(List<List<double>> m) {
    final n = m.length;
    if (n != m[0].length) throw Exception('LU requires square matrix');
    final a = List.generate(n, (r) => List<double>.from(m[r]));
    final perm = List.generate(n, (i) => i);
    int sign = 1;
    for (int k = 0; k < n; k++) {
      int maxRow = k;
      for (int i = k + 1; i < n; i++) {
        if (a[i][k].abs() > a[maxRow][k].abs()) maxRow = i;
      }
      if (maxRow != k) {
        final tmpRow = a[k];
        a[k] = a[maxRow];
        a[maxRow] = tmpRow;
        final tmpP = perm[k];
        perm[k] = perm[maxRow];
        perm[maxRow] = tmpP;
        sign = -sign;
      }
      if (a[k][k].abs() < 1e-12) continue;
      for (int i = k + 1; i < n; i++) {
        a[i][k] /= a[k][k];
        for (int j = k + 1; j < n; j++) {
          a[i][j] -= a[i][k] * a[k][j];
        }
      }
    }
    final l = List.generate(
        n,
        (r) => List.generate(n, (c) {
              if (r == c) return 1.0;
              if (r > c) return a[r][c];
              return 0.0;
            }));
    final u = List.generate(
        n,
        (r) => List.generate(n, (c) {
              if (r <= c) return a[r][c];
              return 0.0;
            }));
    return (l: l, u: u, p: perm, sign: sign);
  }

  ({List<List<double>> q, List<List<double>> r}) _qrDecomp(
      List<List<double>> m) {
    final rows = m.length, cols = m[0].length;
    final q = List.generate(rows, (r) => List.filled(cols, 0.0));
    final r = List.generate(cols, (r) => List.filled(cols, 0.0));
    final colVecs =
        List.generate(cols, (c) => List.generate(rows, (r) => m[r][c]));
    final qCols = <List<double>>[];
    for (int j = 0; j < cols; j++) {
      var v = List<double>.from(colVecs[j]);
      for (int i = 0; i < qCols.length; i++) {
        final proj = _dot(qCols[i], colVecs[j]);
        r[i][j] = proj;
        for (int k = 0; k < rows; k++) v[k] -= proj * qCols[i][k];
      }
      final norm = math.sqrt(_dot(v, v));
      r[j][j] = norm;
      if (norm > 1e-12) {
        final qCol = v.map((x) => x / norm).toList();
        qCols.add(qCol);
        for (int k = 0; k < rows; k++) q[k][j] = qCol[k];
      } else {
        qCols.add(List.filled(rows, 0.0));
      }
    }
    return (q: q, r: r);
  }

  double _dot(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length && i < b.length; i++) sum += a[i] * b[i];
    return sum;
  }

  ({List<double> values, List<List<double>> vectors}) _jacobiEigen(
      List<List<double>> m) {
    final n = m.length;
    final a = List.generate(n, (r) => List<double>.from(m[r]));
    var v = List.generate(n, (r) => List.generate(n, (c) => r == c ? 1.0 : 0.0));
    for (int iter = 0; iter < 100; iter++) {
      int p = 0, q = 1;
      double maxVal = a[0][1].abs();
      for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
          if (a[i][j].abs() > maxVal) {
            maxVal = a[i][j].abs();
            p = i;
            q = j;
          }
        }
      }
      if (maxVal < 1e-10) break;
      final theta = (a[q][q] - a[p][p]) / (2 * a[p][q]);
      final t = theta >= 0
          ? 1.0 / (theta + math.sqrt(1 + theta * theta))
          : 1.0 / (theta - math.sqrt(1 + theta * theta));
      final c = 1.0 / math.sqrt(1 + t * t);
      final s = t * c;
      final app = a[p][p], aqq = a[q][q], apq = a[p][q];
      a[p][p] = app - t * apq;
      a[q][q] = aqq + t * apq;
      a[p][q] = 0;
      a[q][p] = 0;
      for (int r = 0; r < n; r++) {
        if (r != p && r != q) {
          final arp = a[r][p], arq = a[r][q];
          a[r][p] = c * arp - s * arq;
          a[p][r] = a[r][p];
          a[r][q] = s * arp + c * arq;
          a[q][r] = a[r][q];
        }
      }
      for (int r = 0; r < n; r++) {
        final vrp = v[r][p], vrq = v[r][q];
        v[r][p] = c * vrp - s * vrq;
        v[r][q] = s * vrp + c * vrq;
      }
    }
    final values = List.generate(n, (i) => a[i][i]);
    return (values: values, vectors: v);
  }

  List<double> _cross(List<double> a, List<double> b) {
    if (a.length != 3 || b.length != 3) {
      throw Exception('Cross product requires 3D vectors');
    }
    return [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0],
    ];
  }

  List<double> _normalize(List<double> v) {
    final norm = math.sqrt(_dot(v, v));
    if (norm < 1e-12) throw Exception('Cannot normalize zero vector');
    return v.map((x) => x / norm).toList();
  }

  void _executeMatrixOp() {
    try {
      final a = _readMatA();
      final b = _readMatB();
      String result = '';
      switch (_selectedMatrixOp) {
        case 'add':
          result = _matrixToString(_matAdd(a, b), label: 'A + B =');
          break;
        case 'subtract':
          result = _matrixToString(_matSubtract(a, b), label: 'A − B =');
          break;
        case 'multiply':
          result = _matrixToString(_matMultiply(a, b), label: 'A × B =');
          break;
        case 'transpose_A':
          result = _matrixToString(_transpose(a), label: 'Aᵀ =');
          break;
        case 'invert_A':
          result = _matrixToString(_invert(a), label: 'A⁻¹ =');
          break;
        case 'determinant_A':
          result = 'det(A) = ${_formatNumResult(_determinant(a))}';
          break;
        case 'trace_A':
          result = 'tr(A) = ${_formatNumResult(_trace(a))}';
          break;
        case 'rank_A':
          result = 'rank(A) = ${_rank(a)}';
          break;
        case 'eigenvalues_A':
          final eigen = _jacobiEigen(a);
          result = 'Eigenvalues:\n${eigen.values.map(_formatNumResult).join(', ')}';
          break;
        default:
          result = 'Unknown operation';
      }
      setState(() {
        _resultText = result;
        _resultLabel = '';
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
        _resultLabel = '';
      });
    }
  }

  void _executeDecomp() {
    try {
      final a = _readMatA();
      String result = '';
      switch (_selectedDecomp) {
        case 'LU':
          final lu = _luDecompRaw(a);
          result = '${_matrixToString(lu.l, label: 'L =')}\n${_matrixToString(lu.u, label: 'U =')}';
          break;
        case 'QR':
          final qr = _qrDecomp(a);
          result = '${_matrixToString(qr.q, label: 'Q =')}\n${_matrixToString(qr.r, label: 'R =')}';
          break;
        case 'SVD':
          final eigen = _jacobiEigen(a);
          result = 'Singular values:\n${eigen.values.map((v) => _formatNumResult(math.sqrt(v.abs()))).join(', ')}';
          break;
        default:
          result = 'Unknown decomposition';
      }
      setState(() {
        _resultText = result;
        _resultLabel = '';
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
        _resultLabel = '';
      });
    }
  }

  void _executeVectorOp() {
    try {
      final a = _readVecA();
      final b = _readVecB();
      String result = '';
      switch (_selectedVectorOp) {
        case 'dot':
          result = 'A · B = ${_formatNumResult(_dot(a, b))}';
          break;
        case 'cross':
          final c = _cross(a, b);
          result = 'A × B = [${c.map(_formatNumResult).join(', ')}]';
          break;
        case 'norm_A':
          result = '‖A‖ = ${_formatNumResult(math.sqrt(_dot(a, a)))}';
          break;
        case 'normalize_A':
          final n = _normalize(a);
          result = 'Normalize A = [${n.map(_formatNumResult).join(', ')}]';
          break;
        case 'add_vec':
          if (a.length != b.length)
            throw Exception('Vectors must have same length');
          final sum = List.generate(a.length, (i) => a[i] + b[i]);
          result = 'A + B = [${sum.map(_formatNumResult).join(', ')}]';
          break;
        case 'subtract_vec':
          if (a.length != b.length)
            throw Exception('Vectors must have same length');
          final diff = List.generate(a.length, (i) => a[i] - b[i]);
          result = 'A − B = [${diff.map(_formatNumResult).join(', ')}]';
          break;
        default:
          result = 'Unknown operation';
      }
      setState(() {
        _resultText = result;
        _resultLabel = '';
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
        _resultLabel = '';
      });
    }
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  Widget _buildMatrixGrid(
    List<List<TextEditingController>> controllers,
    int rows,
    int cols,
    ColorScheme cs,
  ) {
    return Column(
      children: List.generate(rows, (r) {
        return Row(
          children: List.generate(cols, (c) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                child: TextField(
                  controller: controllers[r][c],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDimensionSelector(
    String label,
    int rows,
    int cols,
    void Function(int, int) onChanged,
    ColorScheme cs,
  ) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7))),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: rows,
          items: [1, 2, 3, 4, 5, 6]
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v, cols);
          },
          isDense: true,
        ),
        const Text(' × '),
        DropdownButton<int>(
          value: cols,
          items: [1, 2, 3, 4, 5, 6]
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(rows, v);
          },
          isDense: true,
        ),
      ],
    );
  }

  Widget _buildMatrixTab(ColorScheme cs, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matrix A
          Text('Matrix A',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDimensionSelector(
              'Size:', _matARows, _matACols, _resizeMatA, cs),
          const SizedBox(height: 8),
          _buildMatrixGrid(_matAControllers, _matARows, _matACols, cs),
          const SizedBox(height: 16),
          // Matrix B
          Text('Matrix B',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDimensionSelector(
              'Size:', _matBRows, _matBCols, _resizeMatB, cs),
          const SizedBox(height: 8),
          _buildMatrixGrid(_matBControllers, _matBRows, _matBCols, cs),
          const SizedBox(height: 16),
          // Operation selector
          Text('Operation',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_matrixOps.length, (i) {
              return ChoiceChip(
                label: Text(_matrixOpLabels[i],
                    style: const TextStyle(fontSize: 12)),
                selected: _selectedMatrixOp == _matrixOps[i],
                onSelected: (sel) {
                  if (sel) setState(() => _selectedMatrixOp = _matrixOps[i]);
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _executeMatrixOp,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Compute'),
            ),
          ),
          const SizedBox(height: 16),
          // Decomposition
          Text('Decomposition',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _decomps.map((d) {
              return ChoiceChip(
                label: Text(d),
                selected: _selectedDecomp == d,
                onSelected: (sel) {
                  if (sel) setState(() => _selectedDecomp = d);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _executeDecomp,
              icon: const Icon(Icons.account_tree_rounded),
              label: Text('Decompose ($_selectedDecomp)'),
            ),
          ),
          const SizedBox(height: 16),
          // Result
          if (_resultText.isNotEmpty) ...[
            Text('Result',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                _resultText,
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVectorTab(ColorScheme cs, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vector A
          Text('Vector A',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Size:',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _vecSize,
                items: [2, 3, 4, 5, 6]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _resizeVecA(v);
                },
                isDense: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _vecAControllers.map((ctrl) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  child: TextField(
                    controller: ctrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Vector B
          Text('Vector B',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Size:',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _vecBSize,
                items: [2, 3, 4, 5, 6]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _resizeVecB(v);
                },
                isDense: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _vecBControllers.map((ctrl) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  child: TextField(
                    controller: ctrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Operation selector
          Text('Operation',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_vectorOps.length, (i) {
              return ChoiceChip(
                label: Text(_vectorOpLabels[i],
                    style: const TextStyle(fontSize: 12)),
                selected: _selectedVectorOp == _vectorOps[i],
                onSelected: (sel) {
                  if (sel) setState(() => _selectedVectorOp = _vectorOps[i]);
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _executeVectorOp,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Compute'),
            ),
          ),
          const SizedBox(height: 16),
          // Result
          if (_resultText.isNotEmpty) ...[
            Text('Result',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                _resultText,
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix & Vector'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Matrices'),
            Tab(text: 'Vectors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatrixTab(cs, theme),
          _buildVectorTab(cs, theme),
        ],
      ),
    );
  }
}
