import 'dart:math' as math;

/// Represents a matrix of doubles.
class Matrix {
  final List<List<double>> data;
  final int rows;
  final int cols;

  Matrix(this.data)
      : rows = data.length,
        cols = data.isEmpty ? 0 : data[0].length;

  factory Matrix.zero(int rows, int cols) {
    return Matrix(List.generate(rows, (_) => List.filled(cols, 0.0)));
  }

  factory Matrix.identity(int n) {
    return Matrix(List.generate(n, (i) => List.generate(n, (j) => i == j ? 1.0 : 0.0)));
  }

  double get(int row, int col) => data[row][col];
  void set(int row, int col, double value) => data[row][col] = value;

  bool get isSquare => rows == cols;

  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError('Matrix dimensions must match for addition');
    }
    return Matrix(List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] + other.data[i][j])));
  }

  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError('Matrix dimensions must match for subtraction');
    }
    return Matrix(List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] - other.data[i][j])));
  }

  Matrix operator *(Matrix other) {
    if (cols != other.rows) {
      throw ArgumentError('Matrix dimensions incompatible for multiplication: ${rows}x$cols * ${other.rows}x${other.cols}');
    }
    final result = Matrix.zero(rows, other.cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < other.cols; j++) {
        double sum = 0;
        for (int k = 0; k < cols; k++) {
          sum += data[i][k] * other.data[k][j];
        }
        result.set(i, j, sum);
      }
    }
    return result;
  }

  Matrix scale(double scalar) {
    return Matrix(List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] * scalar)));
  }

  Matrix transpose() {
    return Matrix(List.generate(cols, (i) => List.generate(rows, (j) => data[j][i])));
  }

  Matrix copyWith() {
    return Matrix(List.generate(rows, (i) => List.from(data[i])));
  }

  @override
  String toString() {
    return data.map((row) => row.map((v) => _fmt(v)).join('\t')).join('\n');
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

/// Represents a mathematical vector.
class Vector {
  final List<double> components;
  int get dimension => components.length;

  Vector(this.components);

  factory Vector.zero(int n) => Vector(List.filled(n, 0.0));

  double operator [](int i) => components[i];

  Vector operator +(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Vector dimensions must match');
    return Vector(List.generate(dimension, (i) => components[i] + other.components[i]));
  }

  Vector operator -(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Vector dimensions must match');
    return Vector(List.generate(dimension, (i) => components[i] - other.components[i]));
  }

  Vector scale(double scalar) {
    return Vector(components.map((c) => c * scalar).toList());
  }

  double dot(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Vector dimensions must match');
    return List.generate(dimension, (i) => components[i] * other.components[i]).fold(0.0, (a, b) => a + b);
  }

  Vector cross(Vector other) {
    if (dimension != 3 || other.dimension != 3) {
      throw ArgumentError('Cross product requires 3D vectors');
    }
    return Vector([
      components[1] * other.components[2] - components[2] * other.components[1],
      components[2] * other.components[0] - components[0] * other.components[2],
      components[0] * other.components[1] - components[1] * other.components[0],
    ]);
  }

  double get magnitude => math.sqrt(components.fold(0.0, (acc, c) => acc + c * c));

  Vector normalize() {
    final mag = magnitude;
    if (mag == 0) throw StateError('Cannot normalize zero vector');
    return scale(1 / mag);
  }

  double angleTo(Vector other) {
    final dotProd = dot(other);
    final mags = magnitude * other.magnitude;
    if (mags == 0) return 0;
    return math.acos((dotProd / mags).clamp(-1.0, 1.0));
  }

  Matrix toColumnMatrix() {
    return Matrix(List.generate(dimension, (i) => [components[i]]));
  }

  Matrix toRowMatrix() {
    return Matrix([List.from(components)]);
  }

  @override
  String toString() => '[${components.map((c) => Matrix._fmt(c)).join(', ')}]';
}

/// Result of LU decomposition.
class LUDecomposition {
  final Matrix l;
  final Matrix u;
  final List<int> pivots;
  final int swapCount;

  const LUDecomposition({
    required this.l,
    required this.u,
    required this.pivots,
    required this.swapCount,
  });
}

/// Result of QR decomposition.
class QRDecomposition {
  final Matrix q;
  final Matrix r;

  const QRDecomposition({required this.q, required this.r});
}

/// Result of eigenvalue decomposition.
class EigenDecomposition {
  final List<double> eigenvalues;
  final List<Vector> eigenvectors;

  const EigenDecomposition({
    required this.eigenvalues,
    required this.eigenvectors,
  });
}

/// Service providing matrix and vector operations.
class MatrixVectorService {
  MatrixVectorService._();
  static final MatrixVectorService instance = MatrixVectorService._();

  // ─── Matrix Operations ──────────────────────────────────────────────────────

  Matrix add(Matrix a, Matrix b) => a + b;
  Matrix subtract(Matrix a, Matrix b) => a - b;
  Matrix multiply(Matrix a, Matrix b) => a * b;
  Matrix scale(Matrix a, double scalar) => a.scale(scalar);
  Matrix transpose(Matrix a) => a.transpose();

  /// Compute the determinant using LU decomposition.
  double determinant(Matrix m) {
    if (!m.isSquare) throw ArgumentError('Determinant requires a square matrix');
    final n = m.rows;
    if (n == 1) return m.get(0, 0);
    if (n == 2) return m.get(0, 0) * m.get(1, 1) - m.get(0, 1) * m.get(1, 0);

    final lu = _luDecompose(m);
    double det = lu.swapCount % 2 == 0 ? 1.0 : -1.0;
    for (int i = 0; i < n; i++) {
      det *= lu.u.get(i, i);
    }
    return det;
  }

  /// Compute the inverse using Gauss-Jordan elimination.
  Matrix inverse(Matrix m) {
    if (!m.isSquare) throw ArgumentError('Inverse requires a square matrix');
    final n = m.rows;

    // Augment with identity
    final aug = Matrix(List.generate(n, (i) {
      return [...m.data[i], ...List.generate(n, (j) => i == j ? 1.0 : 0.0)];
    }));

    // Forward elimination with partial pivoting
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      double maxVal = aug.get(col, col).abs();
      for (int row = col + 1; row < n; row++) {
        if (aug.get(row, col).abs() > maxVal) {
          maxVal = aug.get(row, col).abs();
          pivotRow = row;
        }
      }

      if (maxVal < 1e-12) throw StateError('Matrix is singular');

      if (pivotRow != col) {
        final tmp = aug.data[col];
        aug.data[col] = aug.data[pivotRow];
        aug.data[pivotRow] = tmp;
      }

      final pivotVal = aug.get(col, col);
      for (int j = 0; j < 2 * n; j++) {
        aug.data[col][j] /= pivotVal;
      }

      for (int row = 0; row < n; row++) {
        if (row != col) {
          final factor = aug.get(row, col);
          for (int j = 0; j < 2 * n; j++) {
            aug.data[row][j] -= factor * aug.data[col][j];
          }
        }
      }
    }

    // Extract right half
    return Matrix(List.generate(n, (i) => aug.data[i].sublist(n)));
  }

  /// Compute the rank of a matrix using row reduction.
  int rank(Matrix m) {
    final reduced = _rowEchelon(m.copyWith());
    int r = 0;
    for (int i = 0; i < reduced.rows; i++) {
      if (reduced.data[i].any((v) => v.abs() > 1e-10)) r++;
    }
    return r;
  }

  /// Compute the trace (sum of diagonal elements).
  double trace(Matrix m) {
    if (!m.isSquare) throw ArgumentError('Trace requires a square matrix');
    double sum = 0;
    for (int i = 0; i < m.rows; i++) sum += m.get(i, i);
    return sum;
  }

  /// Compute the Frobenius norm.
  double frobeniusNorm(Matrix m) {
    double sum = 0;
    for (int i = 0; i < m.rows; i++) {
      for (int j = 0; j < m.cols; j++) {
        sum += m.get(i, j) * m.get(i, j);
      }
    }
    return math.sqrt(sum);
  }

  /// Compute matrix power (integer exponent).
  Matrix matrixPower(Matrix m, int n) {
    if (!m.isSquare) throw ArgumentError('Matrix power requires a square matrix');
    if (n < 0) return matrixPower(inverse(m), -n);
    if (n == 0) return Matrix.identity(m.rows);
    if (n == 1) return m;
    if (n % 2 == 0) {
      final half = matrixPower(m, n ~/ 2);
      return half * half;
    }
    return m * matrixPower(m, n - 1);
  }

  /// Solve the linear system Ax = b using LU decomposition.
  Vector solveLinearSystem(Matrix a, Vector b) {
    if (!a.isSquare) throw ArgumentError('Coefficient matrix must be square');
    if (a.rows != b.dimension) throw ArgumentError('Dimension mismatch');

    final lu = _luDecompose(a);
    final n = a.rows;

    // Apply permutation to b
    final pb = List<double>.from(b.components);
    for (int i = 0; i < n; i++) {
      final tmp = pb[i];
      pb[i] = pb[lu.pivots[i]];
      pb[lu.pivots[i]] = tmp;
    }

    // Forward substitution: Ly = Pb
    final y = List<double>.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      y[i] = pb[i];
      for (int j = 0; j < i; j++) {
        y[i] -= lu.l.get(i, j) * y[j];
      }
    }

    // Back substitution: Ux = y
    final x = List<double>.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = y[i];
      for (int j = i + 1; j < n; j++) {
        x[i] -= lu.u.get(i, j) * x[j];
      }
      if (lu.u.get(i, i).abs() < 1e-12) throw StateError('Matrix is singular');
      x[i] /= lu.u.get(i, i);
    }

    return Vector(x);
  }

  /// LU decomposition with partial pivoting.
  LUDecomposition luDecompose(Matrix m) => _luDecompose(m);

  LUDecomposition _luDecompose(Matrix m) {
    if (!m.isSquare) throw ArgumentError('LU decomposition requires a square matrix');
    final n = m.rows;
    final l = Matrix.identity(n);
    final u = m.copyWith();
    final pivots = List<int>.generate(n, (i) => i);
    int swapCount = 0;

    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      double maxVal = u.get(col, col).abs();
      for (int row = col + 1; row < n; row++) {
        if (u.get(row, col).abs() > maxVal) {
          maxVal = u.get(row, col).abs();
          pivotRow = row;
        }
      }

      if (pivotRow != col) {
        final tmpU = u.data[col];
        u.data[col] = u.data[pivotRow];
        u.data[pivotRow] = tmpU;

        for (int j = 0; j < col; j++) {
          final tmpL = l.data[col][j];
          l.data[col][j] = l.data[pivotRow][j];
          l.data[pivotRow][j] = tmpL;
        }

        final tmpP = pivots[col];
        pivots[col] = pivots[pivotRow];
        pivots[pivotRow] = tmpP;
        swapCount++;
      }

      if (u.get(col, col).abs() < 1e-12) continue;

      for (int row = col + 1; row < n; row++) {
        final factor = u.get(row, col) / u.get(col, col);
        l.set(row, col, factor);
        for (int j = col; j < n; j++) {
          u.data[row][j] -= factor * u.data[col][j];
        }
      }
    }

    return LUDecomposition(l: l, u: u, pivots: pivots, swapCount: swapCount);
  }

  /// QR decomposition using Gram-Schmidt orthogonalization.
  QRDecomposition qrDecompose(Matrix m) {
    final n = m.rows;
    final k = m.cols;
    final q = Matrix.zero(n, k);
    final r = Matrix.zero(k, k);

    for (int j = 0; j < k; j++) {
      // Get j-th column of m
      var v = Vector(List.generate(n, (i) => m.get(i, j)));

      for (int i = 0; i < j; i++) {
        final qi = Vector(List.generate(n, (row) => q.get(row, i)));
        final rij = v.dot(qi);
        r.set(i, j, rij);
        v = v - qi.scale(rij);
      }

      final norm = v.magnitude;
      r.set(j, j, norm);

      if (norm > 1e-12) {
        final qj = v.scale(1 / norm);
        for (int i = 0; i < n; i++) {
          q.set(i, j, qj.components[i]);
        }
      }
    }

    return QRDecomposition(q: q, r: r);
  }

  /// Compute eigenvalues and eigenvectors using the QR algorithm.
  EigenDecomposition eigenDecompose(Matrix m) {
    if (!m.isSquare) throw ArgumentError('Eigendecomposition requires a square matrix');
    final n = m.rows;

    // QR iteration
    var a = m.copyWith();
    var v = Matrix.identity(n);

    for (int iter = 0; iter < 1000; iter++) {
      final qr = qrDecompose(a);
      a = qr.r * qr.q;
      v = v * qr.q;

      // Check convergence (off-diagonal elements)
      double offDiag = 0;
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          if (i != j) offDiag += a.get(i, j).abs();
        }
      }
      if (offDiag < 1e-10) break;
    }

    final eigenvalues = List.generate(n, (i) => a.get(i, i));
    final eigenvectors = List.generate(n, (j) => Vector(List.generate(n, (i) => v.get(i, j))));

    return EigenDecomposition(eigenvalues: eigenvalues, eigenvectors: eigenvectors);
  }

  /// Compute the characteristic polynomial coefficients.
  List<double> characteristicPolynomial(Matrix m) {
    if (!m.isSquare) throw ArgumentError('Characteristic polynomial requires a square matrix');
    final n = m.rows;
    if (n == 1) return [1.0, -m.get(0, 0)];
    if (n == 2) {
      final tr = trace(m);
      final det = determinant(m);
      return [1.0, -tr, det];
    }
    // For larger matrices, use eigenvalues
    final eigen = eigenDecompose(m);
    // Build polynomial from roots
    var poly = [1.0];
    for (final ev in eigen.eigenvalues) {
      final newPoly = List<double>.filled(poly.length + 1, 0.0);
      for (int i = 0; i < poly.length; i++) {
        newPoly[i] += poly[i];
        newPoly[i + 1] -= ev * poly[i];
      }
      poly = newPoly;
    }
    return poly;
  }

  /// Row reduce a matrix to row echelon form.
  Matrix rowEchelon(Matrix m) => _rowEchelon(m.copyWith());

  Matrix _rowEchelon(Matrix m) {
    int lead = 0;
    for (int row = 0; row < m.rows; row++) {
      if (lead >= m.cols) break;

      int i = row;
      while (m.get(i, lead).abs() < 1e-12) {
        i++;
        if (i == m.rows) {
          i = row;
          lead++;
          if (lead == m.cols) return m;
        }
      }

      final tmp = m.data[i];
      m.data[i] = m.data[row];
      m.data[row] = tmp;

      final pivotVal = m.get(row, lead);
      for (int j = 0; j < m.cols; j++) m.data[row][j] /= pivotVal;

      for (int k = 0; k < m.rows; k++) {
        if (k != row) {
          final factor = m.get(k, lead);
          for (int j = 0; j < m.cols; j++) {
            m.data[k][j] -= factor * m.data[row][j];
          }
        }
      }

      lead++;
    }
    return m;
  }

  // ─── Vector Operations ──────────────────────────────────────────────────────

  Vector addVectors(Vector a, Vector b) => a + b;
  Vector subtractVectors(Vector a, Vector b) => a - b;
  Vector scaleVector(Vector v, double scalar) => v.scale(scalar);
  double dotProduct(Vector a, Vector b) => a.dot(b);
  Vector crossProduct(Vector a, Vector b) => a.cross(b);
  double vectorMagnitude(Vector v) => v.magnitude;
  Vector normalizeVector(Vector v) => v.normalize();
  double angleBetween(Vector a, Vector b) => a.angleTo(b);

  /// Project vector [a] onto vector [b].
  Vector project(Vector a, Vector b) {
    final bMag2 = b.dot(b);
    if (bMag2 == 0) throw ArgumentError('Cannot project onto zero vector');
    return b.scale(a.dot(b) / bMag2);
  }

  /// Compute the outer product of two vectors.
  Matrix outerProduct(Vector a, Vector b) {
    return Matrix(List.generate(a.dimension, (i) =>
        List.generate(b.dimension, (j) => a.components[i] * b.components[j])));
  }

  /// Check if two vectors are orthogonal.
  bool areOrthogonal(Vector a, Vector b, {double tolerance = 1e-10}) {
    return a.dot(b).abs() < tolerance;
  }

  /// Check if two vectors are parallel.
  bool areParallel(Vector a, Vector b, {double tolerance = 1e-10}) {
    if (a.magnitude < tolerance || b.magnitude < tolerance) return true;
    final cosAngle = (a.dot(b) / (a.magnitude * b.magnitude)).clamp(-1.0, 1.0);
    return (cosAngle.abs() - 1).abs() < tolerance;
  }

  // ─── Utility ────────────────────────────────────────────────────────────────

  /// Parse a matrix from a 2D list of strings.
  Matrix parseMatrix(List<List<String>> data) {
    return Matrix(data.map((row) => row.map((s) => double.tryParse(s.trim()) ?? 0.0).toList()).toList());
  }

  /// Parse a vector from a list of strings.
  Vector parseVector(List<String> data) {
    return Vector(data.map((s) => double.tryParse(s.trim()) ?? 0.0).toList());
  }

  /// Format a matrix as a human-readable string.
  String formatMatrix(Matrix m, {int decimalPlaces = 4}) {
    final rows = m.data.map((row) {
      final cells = row.map((v) {
        if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
        return v.toStringAsFixed(decimalPlaces).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }).toList();
      return '[ ${cells.join('  ')} ]';
    }).toList();
    return rows.join('\n');
  }

  /// Format a vector as a human-readable string.
  String formatVector(Vector v, {int decimalPlaces = 4}) {
    final cells = v.components.map((c) {
      if (c == c.roundToDouble() && c.abs() < 1e12) return c.toInt().toString();
      return c.toStringAsFixed(decimalPlaces).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }).toList();
    return '[ ${cells.join(', ')} ]';
  }
}
