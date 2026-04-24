import 'dart:math' as math;

class DescriptiveStats {
  final double mean;
  final double median;
  final List<double> mode;
  final double stdDev;
  final double variance;
  final double q1;
  final double q3;
  final double iqr;
  final double min;
  final double max;
  final double range;
  final double skewness;
  final double kurtosis;
  final int count;
  final double sum;
  final double geometricMean;
  final double harmonicMean;
  final double coefficientOfVariation;
  final double standardError;

  const DescriptiveStats({
    required this.mean,
    required this.median,
    required this.mode,
    required this.stdDev,
    required this.variance,
    required this.q1,
    required this.q3,
    required this.iqr,
    required this.min,
    required this.max,
    required this.range,
    required this.skewness,
    required this.kurtosis,
    required this.count,
    required this.sum,
    required this.geometricMean,
    required this.harmonicMean,
    required this.coefficientOfVariation,
    required this.standardError,
  });
}

class PdfCdfResult {
  final double pdf;
  final double cdf;
  final double survivalFunction;
  final String distribution;
  final Map<String, double> parameters;
  final double x;

  const PdfCdfResult({
    required this.pdf,
    required this.cdf,
    required this.survivalFunction,
    required this.distribution,
    required this.parameters,
    required this.x,
  });
}

class HypothesisTestResult {
  final String testType;
  final double testStatistic;
  final double pValue;
  final double criticalValue;
  final double confidenceLevel;
  final String conclusion;
  final String nullHypothesis;
  final String alternativeHypothesis;
  final double? degreesOfFreedom;
  final double? effectSize;
  final Map<String, double> additionalStats;

  const HypothesisTestResult({
    required this.testType,
    required this.testStatistic,
    required this.pValue,
    required this.criticalValue,
    required this.confidenceLevel,
    required this.conclusion,
    required this.nullHypothesis,
    required this.alternativeHypothesis,
    this.degreesOfFreedom,
    this.effectSize,
    required this.additionalStats,
  });
}

class RegressionResult {
  final String regressionType;
  final List<double> coefficients;
  final double rSquared;
  final double adjustedRSquared;
  final String equation;
  final double rmse;
  final double mae;
  final List<double> residuals;
  final List<double> fittedValues;
  final Map<String, double> additionalStats;

  const RegressionResult({
    required this.regressionType,
    required this.coefficients,
    required this.rSquared,
    required this.adjustedRSquared,
    required this.equation,
    required this.rmse,
    required this.mae,
    required this.residuals,
    required this.fittedValues,
    required this.additionalStats,
  });

  double predict(double x) {
    switch (regressionType) {
      case 'linear':
      case 'Linear':
        return coefficients[0] + coefficients[1] * x;
      case 'quadratic':
      case 'Polynomial':
        if (coefficients.length >= 3) {
          return coefficients[0] + coefficients[1] * x + coefficients[2] * x * x;
        }
        return coefficients[0] + coefficients[1] * x;
      case 'cubic':
        return coefficients[0] + coefficients[1] * x + coefficients[2] * x * x + coefficients[3] * x * x * x;
      case 'polynomial':
        double result = 0;
        for (int i = 0; i < coefficients.length; i++) {
          result += coefficients[i] * math.pow(x, i).toDouble();
        }
        return result;
      case 'exponential':
      case 'Exponential':
        return coefficients[0] * math.exp(coefficients[1] * x);
      case 'logarithmic':
      case 'Logarithmic':
        if (x <= 0) return double.nan;
        return coefficients[0] + coefficients[1] * math.log(x);
      case 'power':
      case 'Power':
        if (x < 0) return double.nan;
        return coefficients[0] * math.pow(x, coefficients[1]).toDouble();
      default:
        return double.nan;
    }
  }
}

class StatisticsService {
  static final StatisticsService instance = StatisticsService._();
  StatisticsService._();

  // ─── DESCRIPTIVE STATISTICS ───────────────────────────────────────────────

  DescriptiveStats descriptiveStats(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Data must not be empty');

    final n = data.length;
    final sorted = List<double>.from(data)..sort();
    final sum = data.fold(0.0, (a, b) => a + b);
    final mean = sum / n;
    final median = _computeMedian(sorted);
    final mode = _computeMode(data);

    final sumSquaredDiffs = data.fold(0.0, (acc, x) => acc + (x - mean) * (x - mean));
    final variance = n > 1 ? sumSquaredDiffs / (n - 1) : 0.0;
    final stdDev = math.sqrt(variance);

    final q1 = _computePercentile(sorted, 25);
    final q3 = _computePercentile(sorted, 75);
    final iqr = q3 - q1;
    final range = sorted.last - sorted.first;

    double skewness = 0.0;
    if (stdDev > 0 && n >= 3) {
      final cubedDiffs = data.fold(0.0, (acc, x) => acc + math.pow((x - mean) / stdDev, 3).toDouble());
      skewness = (n / ((n - 1) * (n - 2))) * cubedDiffs;
    }

    double kurtosis = 0.0;
    if (stdDev > 0 && n >= 4) {
      final fourthDiffs = data.fold(0.0, (acc, x) => acc + math.pow((x - mean) / stdDev, 4).toDouble());
      final term1 = (n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3)) * fourthDiffs;
      final term2 = (3 * (n - 1) * (n - 1)) / ((n - 2) * (n - 3));
      kurtosis = term1 - term2;
    }

    double geometricMean = double.nan;
    if (data.every((x) => x > 0)) {
      final logSum = data.fold(0.0, (acc, x) => acc + math.log(x));
      geometricMean = math.exp(logSum / n);
    }

    double harmonicMean = double.nan;
    if (data.every((x) => x > 0)) {
      final reciprocalSum = data.fold(0.0, (acc, x) => acc + 1.0 / x);
      harmonicMean = n / reciprocalSum;
    }

    final coefficientOfVariation = mean != 0 ? (stdDev / mean.abs()) * 100 : double.nan;
    final standardError = n > 0 ? stdDev / math.sqrt(n) : 0.0;

    return DescriptiveStats(
      mean: mean, median: median, mode: mode, stdDev: stdDev, variance: variance,
      q1: q1, q3: q3, iqr: iqr, min: sorted.first, max: sorted.last, range: range,
      skewness: skewness, kurtosis: kurtosis, count: n, sum: sum,
      geometricMean: geometricMean, harmonicMean: harmonicMean,
      coefficientOfVariation: coefficientOfVariation, standardError: standardError,
    );
  }

  double _computeMedian(List<double> sorted) {
    final n = sorted.length;
    if (n % 2 == 0) return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    return sorted[n ~/ 2];
  }

  List<double> _computeMode(List<double> data) {
    final freq = <double, int>{};
    for (final x in data) freq[x] = (freq[x] ?? 0) + 1;
    final maxFreq = freq.values.fold(0, (a, b) => a > b ? a : b);
    if (maxFreq == 1) return [];
    return freq.entries.where((e) => e.value == maxFreq).map((e) => e.key).toList()..sort();
  }

  double _computePercentile(List<double> sorted, double percentile) {
    final n = sorted.length;
    if (n == 1) return sorted[0];
    final index = (percentile / 100) * (n - 1);
    final lower = index.floor();
    final upper = index.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (index - lower) * (sorted[upper] - sorted[lower]);
  }

  // ─── PROBABILITY DISTRIBUTIONS ────────────────────────────────────────────

  PdfCdfResult pdfCdf(String distribution, Map<String, double> parameters, double x) {
    double pdf;
    double cdf;

    final p1 = parameters['param1'] ?? parameters['mu'] ?? parameters['mean'] ?? 0.0;
    final p2 = parameters['param2'] ?? parameters['sigma'] ?? parameters['std'] ?? 1.0;

    final distKey = distribution.toLowerCase().replaceAll('-', '').replaceAll(' ', '').replaceAll('_', '');

    switch (distKey) {
      case 'normal':
      case 'gaussian':
        pdf = _normalPdf(x, p1, p2);
        cdf = _normalCdf(x, p1, p2);
        break;
      case 'standardnormal':
        pdf = _normalPdf(x, 0, 1);
        cdf = _normalCdf(x, 0, 1);
        break;
      case 't':
      case 'studentt':
        final df = p1 > 0 ? p1 : 1.0;
        pdf = _tPdf(x, df);
        cdf = _tCdf(x, df);
        break;
      case 'chisquared':
      case 'chi2':
      case 'chisq':
        final df = p1 > 0 ? p1 : 1.0;
        if (x < 0) { pdf = 0; cdf = 0; }
        else { pdf = _chi2Pdf(x, df); cdf = _chi2Cdf(x, df); }
        break;
      case 'f':
      case 'fdistribution':
        final d1 = p1 > 0 ? p1 : 1.0;
        final d2 = p2 > 0 ? p2 : 1.0;
        if (x <= 0) { pdf = 0; cdf = 0; }
        else { pdf = _fPdf(x, d1, d2); cdf = _fCdf(x, d1, d2); }
        break;
      case 'exponential':
        final lambda = p1 > 0 ? p1 : 1.0;
        if (x < 0) { pdf = 0; cdf = 0; }
        else { pdf = lambda * math.exp(-lambda * x); cdf = 1 - math.exp(-lambda * x); }
        break;
      case 'uniform':
        final a = p1;
        final b = p2 > p1 ? p2 : p1 + 1;
        if (x < a || x > b) { pdf = 0; cdf = x < a ? 0 : 1; }
        else { pdf = 1 / (b - a); cdf = (x - a) / (b - a); }
        break;
      case 'poisson':
        final lambda = p1 > 0 ? p1 : 1.0;
        final k = x.toInt();
        if (x < 0 || x != x.floorToDouble()) { pdf = 0; cdf = 0; }
        else { pdf = _poissonPmf(k, lambda); cdf = _poissonCdf(k, lambda); }
        break;
      case 'binomial':
        final n = p1.round() > 0 ? p1.round() : 10;
        final p = p2.clamp(0.0, 1.0);
        final k = x.toInt();
        if (x < 0 || x > n || x != x.floorToDouble()) { pdf = 0; cdf = 0; }
        else { pdf = _binomialPmf(k, n, p); cdf = _binomialCdf(k, n, p); }
        break;
      case 'gamma':
        final shape = p1 > 0 ? p1 : 1.0;
        final scale = p2 > 0 ? p2 : 1.0;
        if (x <= 0) { pdf = 0; cdf = 0; }
        else { pdf = _gammaPdf(x, shape, scale); cdf = _gammaCdf(x, shape, scale); }
        break;
      case 'beta':
        final alpha = p1 > 0 ? p1 : 1.0;
        final beta = p2 > 0 ? p2 : 1.0;
        if (x < 0 || x > 1) { pdf = 0; cdf = x < 0 ? 0 : 1; }
        else { pdf = _betaPdf(x, alpha, beta); cdf = _betaCdf(x, alpha, beta); }
        break;
      case 'lognormal':
        final mu = p1;
        final sigma = p2 > 0 ? p2 : 1.0;
        if (x <= 0) { pdf = 0; cdf = 0; }
        else { pdf = _lognormalPdf(x, mu, sigma); cdf = _lognormalCdf(x, mu, sigma); }
        break;
      default:
        pdf = _normalPdf(x, p1, p2);
        cdf = _normalCdf(x, p1, p2);
    }

    return PdfCdfResult(
      pdf: pdf, cdf: cdf, survivalFunction: 1 - cdf,
      distribution: distribution, parameters: parameters, x: x,
    );
  }

  // ─── HYPOTHESIS TESTING ───────────────────────────────────────────────────

  HypothesisTestResult hypothesisTest(
    String testType, List<double> data1, List<double>? data2,
    double mu0, double confidenceLevel,
  ) {
    final alpha = 1.0 - confidenceLevel;
    switch (testType.toLowerCase().replaceAll('-', '').replaceAll(' ', '')) {
      case 'ttest':
      case 't':
        return _oneSampleTTest(data1, mu0, confidenceLevel, alpha);
      case 'ztest':
      case 'z':
        return _zTest(data1, mu0, confidenceLevel, alpha);
      case 'chi2test':
      case 'chitest':
      case 'chisquaredtest':
        return _chiSquaredTest(data1, confidenceLevel, alpha);
      case 'anova':
        if (data2 != null && data2.isNotEmpty) {
          return _anova([data1, data2], confidenceLevel, alpha);
        }
        return _oneSampleTTest(data1, mu0, confidenceLevel, alpha);
      default:
        return _oneSampleTTest(data1, mu0, confidenceLevel, alpha);
    }
  }

  HypothesisTestResult _oneSampleTTest(List<double> data, double mu0, double confidenceLevel, double alpha) {
    final n = data.length;
    if (n < 2) throw ArgumentError('Need at least 2 data points for t-test');
    final mean = data.fold(0.0, (a, b) => a + b) / n;
    final variance = data.fold(0.0, (acc, x) => acc + (x - mean) * (x - mean)) / (n - 1);
    final stdDev = math.sqrt(variance);
    final se = stdDev / math.sqrt(n.toDouble());
    final df = n - 1;
    final tStat = se > 0 ? (mean - mu0) / se : 0.0;
    final pValue = 2 * (1 - _tCdf(tStat.abs(), df.toDouble()));
    final criticalValue = _tInverse(1 - alpha / 2, df.toDouble());
    final reject = pValue < alpha;
    final conclusion = reject
        ? 'Reject H₀: Significant difference (p=${pValue.toStringAsFixed(4)} < α=${alpha.toStringAsFixed(3)})'
        : 'Fail to reject H₀: No significant difference (p=${pValue.toStringAsFixed(4)} ≥ α=${alpha.toStringAsFixed(3)})';
    return HypothesisTestResult(
      testType: 'One-Sample t-Test', testStatistic: tStat, pValue: pValue,
      criticalValue: criticalValue, confidenceLevel: confidenceLevel, conclusion: conclusion,
      nullHypothesis: 'H₀: μ = $mu0', alternativeHypothesis: 'H₁: μ ≠ $mu0',
      degreesOfFreedom: df.toDouble(), effectSize: se > 0 ? (mean - mu0) / stdDev : 0.0,
      additionalStats: {'mean': mean, 'std_dev': stdDev, 'std_error': se, 'n': n.toDouble(), 'df': df.toDouble()},
    );
  }

  HypothesisTestResult _zTest(List<double> data, double mu0, double confidenceLevel, double alpha) {
    final n = data.length;
    if (n < 1) throw ArgumentError('Need at least 1 data point for z-test');
    final mean = data.fold(0.0, (a, b) => a + b) / n;
    final variance = n > 1 ? data.fold(0.0, (acc, x) => acc + (x - mean) * (x - mean)) / (n - 1) : 1.0;
    final stdDev = math.sqrt(variance);
    final se = stdDev / math.sqrt(n.toDouble());
    final zStat = se > 0 ? (mean - mu0) / se : 0.0;
    final pValue = 2 * (1 - _normalCdf(zStat.abs(), 0, 1));
    final criticalValue = _zInverse(1 - alpha / 2);
    final reject = pValue < alpha;
    final conclusion = reject
        ? 'Reject H₀: Significant difference (p=${pValue.toStringAsFixed(4)} < α=${alpha.toStringAsFixed(3)})'
        : 'Fail to reject H₀: No significant difference (p=${pValue.toStringAsFixed(4)} ≥ α=${alpha.toStringAsFixed(3)})';
    return HypothesisTestResult(
      testType: 'Z-Test', testStatistic: zStat, pValue: pValue,
      criticalValue: criticalValue, confidenceLevel: confidenceLevel, conclusion: conclusion,
      nullHypothesis: 'H₀: μ = $mu0', alternativeHypothesis: 'H₁: μ ≠ $mu0',
      additionalStats: {'mean': mean, 'std_dev': stdDev, 'std_error': se, 'n': n.toDouble()},
    );
  }

  HypothesisTestResult _chiSquaredTest(List<double> observed, double confidenceLevel, double alpha) {
    final n = observed.length;
    if (n < 2) throw ArgumentError('Need at least 2 categories for chi-squared test');
    final total = observed.fold(0.0, (a, b) => a + b);
    final expected = total / n;
    double chiSq = 0.0;
    for (final o in observed) {
      chiSq += (o - expected) * (o - expected) / expected;
    }
    final df = n - 1;
    final pValue = 1 - _chi2Cdf(chiSq, df.toDouble());
    final criticalValue = _chi2Inverse(1 - alpha, df.toDouble());
    final reject = pValue < alpha;
    final conclusion = reject
        ? 'Reject H₀: Significant deviation from expected (p=${pValue.toStringAsFixed(4)})'
        : 'Fail to reject H₀: No significant deviation (p=${pValue.toStringAsFixed(4)})';
    return HypothesisTestResult(
      testType: 'Chi-Squared Test', testStatistic: chiSq, pValue: pValue,
      criticalValue: criticalValue, confidenceLevel: confidenceLevel, conclusion: conclusion,
      nullHypothesis: 'H₀: Observed frequencies match expected', alternativeHypothesis: 'H₁: Significant deviation',
      degreesOfFreedom: df.toDouble(),
      additionalStats: {'chi_squared': chiSq, 'df': df.toDouble(), 'n': n.toDouble()},
    );
  }

  HypothesisTestResult _anova(List<List<double>> groups, double confidenceLevel, double alpha) {
    final k = groups.length;
    final N = groups.fold(0, (sum, g) => sum + g.length);
    final grandMean = groups.expand((g) => g).fold(0.0, (a, b) => a + b) / N;

    double ssBetween = 0.0;
    double ssWithin = 0.0;
    for (final group in groups) {
      final groupMean = group.fold(0.0, (a, b) => a + b) / group.length;
      ssBetween += group.length * (groupMean - grandMean) * (groupMean - grandMean);
      for (final x in group) ssWithin += (x - groupMean) * (x - groupMean);
    }

    final dfBetween = k - 1;
    final dfWithin = N - k;
    final msBetween = dfBetween > 0 ? ssBetween / dfBetween : 0.0;
    final msWithin = dfWithin > 0 ? ssWithin / dfWithin : 1.0;
    final fStat = msWithin > 0 ? msBetween / msWithin : 0.0;
    final pValue = 1 - _fCdf(fStat, dfBetween.toDouble(), dfWithin.toDouble());
    final criticalValue = _fInverse(1 - alpha, dfBetween.toDouble(), dfWithin.toDouble());
    final reject = pValue < alpha;
    final conclusion = reject
        ? 'Reject H₀: Significant difference between groups (p=${pValue.toStringAsFixed(4)})'
        : 'Fail to reject H₀: No significant difference (p=${pValue.toStringAsFixed(4)})';
    return HypothesisTestResult(
      testType: 'One-Way ANOVA', testStatistic: fStat, pValue: pValue,
      criticalValue: criticalValue, confidenceLevel: confidenceLevel, conclusion: conclusion,
      nullHypothesis: 'H₀: All group means are equal', alternativeHypothesis: 'H₁: At least one group mean differs',
      degreesOfFreedom: dfWithin.toDouble(),
      additionalStats: {'f_statistic': fStat, 'df_between': dfBetween.toDouble(), 'df_within': dfWithin.toDouble()},
    );
  }

  // ─── REGRESSION ───────────────────────────────────────────────────────────

  RegressionResult regression(String type, List<double> x, List<double> y, {int degree = 2}) {
    if (x.length != y.length || x.isEmpty) throw ArgumentError('X and Y must have equal non-empty lengths');
    switch (type.toLowerCase()) {
      case 'linear': return _linearRegression(x, y);
      case 'polynomial': return _polynomialRegression(x, y, degree);
      case 'exponential': return _exponentialRegression(x, y);
      case 'logarithmic': return _logarithmicRegression(x, y);
      case 'power': return _powerRegression(x, y);
      default: return _linearRegression(x, y);
    }
  }

  RegressionResult _linearRegression(List<double> x, List<double> y) {
    final n = x.length;
    final sumX = x.fold(0.0, (a, b) => a + b);
    final sumY = y.fold(0.0, (a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).fold(0.0, (a, b) => a + b);
    final sumX2 = x.fold(0.0, (a, b) => a + b * b);
    final denom = n * sumX2 - sumX * sumX;
    final slope = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0;
    final intercept = (sumY - slope * sumX) / n;
    final fitted = x.map((xi) => intercept + slope * xi).toList();
    final residuals = List.generate(n, (i) => y[i] - fitted[i]);
    final rSquared = _computeRSquared(y, fitted);
    final adjR2 = n > 2 ? 1 - (1 - rSquared) * (n - 1) / (n - 2) : rSquared;
    final rmse = math.sqrt(residuals.fold(0.0, (a, b) => a + b * b) / n);
    final mae = residuals.fold(0.0, (a, b) => a + b.abs()) / n;
    final sign = intercept >= 0 ? '+' : '-';
    final equation = 'y = ${slope.toStringAsFixed(4)}x $sign ${intercept.abs().toStringAsFixed(4)}';
    return RegressionResult(
      regressionType: 'Linear', coefficients: [intercept, slope],
      rSquared: rSquared, adjustedRSquared: adjR2, equation: equation,
      rmse: rmse, mae: mae, residuals: residuals, fittedValues: fitted,
      additionalStats: {'slope': slope, 'intercept': intercept, 'n': n.toDouble()},
    );
  }

  RegressionResult _polynomialRegression(List<double> x, List<double> y, int degree) {
    final n = x.length;
    // Fix: use explicit int arithmetic to avoid num type issues
    final maxDeg = n - 1 < 6 ? n - 1 : 6;
    final d = degree < 2 ? 2 : (degree > maxDeg ? maxDeg : degree);
    // Build Vandermonde matrix
    final A = List.generate(n, (i) => List.generate(d + 1, (j) => math.pow(x[i], j).toDouble()));
    // Normal equations: A^T A c = A^T y
    final AtA = List.generate(d + 1, (i) => List.generate(d + 1, (j) {
      double sum = 0;
      for (int k = 0; k < n; k++) sum += A[k][i] * A[k][j];
      return sum;
    }));
    final Aty = List.generate(d + 1, (i) {
      double sum = 0;
      for (int k = 0; k < n; k++) sum += A[k][i] * y[k];
      return sum;
    });
    final coeffs = _solveLinearSystem(AtA, Aty);
    final fitted = x.map((xi) {
      double val = 0;
      for (int j = 0; j <= d; j++) val += coeffs[j] * math.pow(xi, j).toDouble();
      return val;
    }).toList();
    final residuals = List.generate(n, (i) => y[i] - fitted[i]);
    final rSquared = _computeRSquared(y, fitted);
    final adjR2 = n > d + 1 ? 1 - (1 - rSquared) * (n - 1) / (n - d - 1) : rSquared;
    final rmse = math.sqrt(residuals.fold(0.0, (a, b) => a + b * b) / n);
    final mae = residuals.fold(0.0, (a, b) => a + b.abs()) / n;
    final terms = coeffs.asMap().entries.map((e) {
      if (e.key == 0) return e.value.toStringAsFixed(4);
      if (e.key == 1) return '${e.value.toStringAsFixed(4)}x';
      return '${e.value.toStringAsFixed(4)}x^${e.key}';
    }).join(' + ');
    return RegressionResult(
      regressionType: 'Polynomial', coefficients: coeffs,
      rSquared: rSquared, adjustedRSquared: adjR2, equation: 'y = $terms',
      rmse: rmse, mae: mae, residuals: residuals, fittedValues: fitted,
      additionalStats: {'degree': d.toDouble(), 'n': n.toDouble()},
    );
  }

  RegressionResult _exponentialRegression(List<double> x, List<double> y) {
    final validPairs = List.generate(x.length, (i) => (x[i], y[i])).where((p) => p.$2 > 0).toList();
    if (validPairs.isEmpty) return _linearRegression(x, y);
    final lnY = validPairs.map((p) => math.log(p.$2)).toList();
    final xVals = validPairs.map((p) => p.$1).toList();
    final linResult = _linearRegression(xVals, lnY);
    final a = math.exp(linResult.coefficients[0]);
    final b = linResult.coefficients[1];
    final fitted = x.map((xi) => a * math.exp(b * xi)).toList();
    final residuals = List.generate(x.length, (i) => y[i] - fitted[i]);
    final rSquared = _computeRSquared(y, fitted);
    final adjR2 = x.length > 2 ? 1 - (1 - rSquared) * (x.length - 1) / (x.length - 2) : rSquared;
    final rmse = math.sqrt(residuals.fold(0.0, (acc, r) => acc + r * r) / x.length);
    final mae = residuals.fold(0.0, (acc, r) => acc + r.abs()) / x.length;
    return RegressionResult(
      regressionType: 'Exponential', coefficients: [a, b],
      rSquared: rSquared, adjustedRSquared: adjR2,
      equation: 'y = ${a.toStringAsFixed(4)} × e^(${b.toStringAsFixed(4)}x)',
      rmse: rmse, mae: mae, residuals: residuals, fittedValues: fitted,
      additionalStats: {'a': a, 'b': b, 'n': x.length.toDouble()},
    );
  }

  RegressionResult _logarithmicRegression(List<double> x, List<double> y) {
    final validPairs = List.generate(x.length, (i) => (x[i], y[i])).where((p) => p.$1 > 0).toList();
    if (validPairs.isEmpty) return _linearRegression(x, y);
    final lnX = validPairs.map((p) => math.log(p.$1)).toList();
    final yVals = validPairs.map((p) => p.$2).toList();
    final linResult = _linearRegression(lnX, yVals);
    final a = linResult.coefficients[0];
    final b = linResult.coefficients[1];
    final fitted = x.map((xi) => xi > 0 ? a + b * math.log(xi) : double.nan).toList();
    final residuals = List.generate(x.length, (i) => y[i] - (fitted[i].isNaN ? y[i] : fitted[i]));
    final rSquared = _computeRSquared(y, fitted.map((f) => f.isNaN ? 0.0 : f).toList());
    final adjR2 = x.length > 2 ? 1 - (1 - rSquared) * (x.length - 1) / (x.length - 2) : rSquared;
    final rmse = math.sqrt(residuals.fold(0.0, (acc, r) => acc + r * r) / x.length);
    final mae = residuals.fold(0.0, (acc, r) => acc + r.abs()) / x.length;
    final sign = b >= 0 ? '+' : '-';
    return RegressionResult(
      regressionType: 'Logarithmic', coefficients: [a, b],
      rSquared: rSquared, adjustedRSquared: adjR2,
      equation: 'y = ${a.toStringAsFixed(4)} $sign ${b.abs().toStringAsFixed(4)} × ln(x)',
      rmse: rmse, mae: mae, residuals: residuals, fittedValues: fitted.map((f) => f.isNaN ? 0.0 : f).toList(),
      additionalStats: {'a': a, 'b': b, 'n': x.length.toDouble()},
    );
  }

  RegressionResult _powerRegression(List<double> x, List<double> y) {
    final validPairs = List.generate(x.length, (i) => (x[i], y[i])).where((p) => p.$1 > 0 && p.$2 > 0).toList();
    if (validPairs.isEmpty) return _linearRegression(x, y);
    final lnX = validPairs.map((p) => math.log(p.$1)).toList();
    final lnY = validPairs.map((p) => math.log(p.$2)).toList();
    final linResult = _linearRegression(lnX, lnY);
    final a = math.exp(linResult.coefficients[0]);
    final b = linResult.coefficients[1];
    final fitted = x.map((xi) => xi > 0 ? a * math.pow(xi, b).toDouble() : double.nan).toList();
    final residuals = List.generate(x.length, (i) => y[i] - (fitted[i].isNaN ? y[i] : fitted[i]));
    final rSquared = _computeRSquared(y, fitted.map((f) => f.isNaN ? 0.0 : f).toList());
    final adjR2 = x.length > 2 ? 1 - (1 - rSquared) * (x.length - 1) / (x.length - 2) : rSquared;
    final rmse = math.sqrt(residuals.fold(0.0, (acc, r) => acc + r * r) / x.length);
    final mae = residuals.fold(0.0, (acc, r) => acc + r.abs()) / x.length;
    return RegressionResult(
      regressionType: 'Power', coefficients: [a, b],
      rSquared: rSquared, adjustedRSquared: adjR2,
      equation: 'y = ${a.toStringAsFixed(4)} × x^${b.toStringAsFixed(4)}',
      rmse: rmse, mae: mae, residuals: residuals, fittedValues: fitted.map((f) => f.isNaN ? 0.0 : f).toList(),
      additionalStats: {'a': a, 'b': b, 'n': x.length.toDouble()},
    );
  }

  double _computeRSquared(List<double> actual, List<double> fitted) {
    final n = actual.length;
    final meanActual = actual.fold(0.0, (a, b) => a + b) / n;
    final ssTot = actual.fold(0.0, (acc, y) => acc + (y - meanActual) * (y - meanActual));
    final ssRes = List.generate(n, (i) => (actual[i] - fitted[i]) * (actual[i] - fitted[i])).fold(0.0, (a, b) => a + b);
    return ssTot > 0 ? 1 - ssRes / ssTot : 0.0;
  }

  List<double> _solveLinearSystem(List<List<double>> A, List<double> b) {
    final n = A.length;
    final aug = List.generate(n, (i) => [...A[i], b[i]]);
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > aug[pivotRow][col].abs()) pivotRow = row;
      }
      final tmp = aug[col]; aug[col] = aug[pivotRow]; aug[pivotRow] = tmp;
      if (aug[col][col].abs() < 1e-12) continue;
      final pivot = aug[col][col];
      for (int c = col; c <= n; c++) aug[col][c] /= pivot;
      for (int row = 0; row < n; row++) {
        if (row != col) {
          final factor = aug[row][col];
          for (int c = col; c <= n; c++) aug[row][c] -= factor * aug[col][c];
        }
      }
    }
    return List.generate(n, (i) => aug[i][n]);
  }

  // ─── DISTRIBUTION HELPERS ─────────────────────────────────────────────────

  double _normalPdf(double x, double mu, double sigma) {
    if (sigma <= 0) return 0;
    final z = (x - mu) / sigma;
    return math.exp(-0.5 * z * z) / (sigma * math.sqrt(2 * math.pi));
  }

  double _normalCdf(double x, double mu, double sigma) {
    if (sigma <= 0) return x < mu ? 0 : 1;
    final z = (x - mu) / sigma;
    return 0.5 * (1 + _erf(z / math.sqrt(2)));
  }

  double _erf(double x) {
    final t = 1.0 / (1.0 + 0.3275911 * x.abs());
    final poly = t * (0.254829592 + t * (-0.284496736 + t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))));
    final result = 1.0 - poly * math.exp(-x * x);
    return x >= 0 ? result : -result;
  }

  double _tPdf(double x, double df) {
    final logPdf = _logGamma((df + 1) / 2) - _logGamma(df / 2) - 0.5 * math.log(df * math.pi) - ((df + 1) / 2) * math.log(1 + x * x / df);
    return math.exp(logPdf);
  }

  double _tCdf(double x, double df) {
    final t2 = x * x;
    final z = df / (df + t2);
    final ibeta = _incompleteBeta(z, df / 2, 0.5);
    return x >= 0 ? 1 - 0.5 * ibeta : 0.5 * ibeta;
  }

  double _tInverse(double p, double df) {
    double lo = -100.0, hi = 100.0;
    for (int i = 0; i < 100; i++) {
      final mid = (lo + hi) / 2;
      if (_tCdf(mid, df) < p) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }

  double _chi2Pdf(double x, double df) {
    if (x <= 0) return 0;
    final logPdf = (df / 2 - 1) * math.log(x) - x / 2 - (df / 2) * math.log(2) - _logGamma(df / 2);
    return math.exp(logPdf);
  }

  double _chi2Cdf(double x, double df) {
    if (x <= 0) return 0;
    return _regularizedGammaP(df / 2, x / 2);
  }

  double _chi2Inverse(double p, double df) {
    double lo = 0.0, hi = 1000.0;
    for (int i = 0; i < 100; i++) {
      final mid = (lo + hi) / 2;
      if (_chi2Cdf(mid, df) < p) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }

  double _fPdf(double x, double d1, double d2) {
    if (x <= 0) return 0;
    final logPdf = (d1 / 2) * math.log(d1) + (d2 / 2) * math.log(d2) + (d1 / 2 - 1) * math.log(x)
        - ((d1 + d2) / 2) * math.log(d2 + d1 * x)
        - _logBeta(d1 / 2, d2 / 2);
    return math.exp(logPdf);
  }

  double _fCdf(double x, double d1, double d2) {
    if (x <= 0) return 0;
    final z = d1 * x / (d1 * x + d2);
    return _incompleteBeta(z, d1 / 2, d2 / 2);
  }

  double _fInverse(double p, double d1, double d2) {
    double lo = 0.0, hi = 1000.0;
    for (int i = 0; i < 100; i++) {
      final mid = (lo + hi) / 2;
      if (_fCdf(mid, d1, d2) < p) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }

  double _poissonPmf(int k, double lambda) {
    if (k < 0 || lambda <= 0) return 0;
    double logPmf = k * math.log(lambda) - lambda;
    for (int i = 1; i <= k; i++) logPmf -= math.log(i.toDouble());
    return math.exp(logPmf);
  }

  double _poissonCdf(int k, double lambda) {
    double cdf = 0;
    for (int i = 0; i <= k; i++) cdf += _poissonPmf(i, lambda);
    return cdf;
  }

  double _binomialPmf(int k, int n, double p) {
    if (k < 0 || k > n || p < 0 || p > 1) return 0;
    if (p == 0) return k == 0 ? 1 : 0;
    if (p == 1) return k == n ? 1 : 0;
    final logPmf = _logBinomialCoeff(n, k) + k * math.log(p) + (n - k) * math.log(1 - p);
    return math.exp(logPmf);
  }

  double _binomialCdf(int k, int n, double p) {
    double cdf = 0;
    for (int i = 0; i <= k; i++) cdf += _binomialPmf(i, n, p);
    return cdf;
  }

  double _logBinomialCoeff(int n, int k) {
    double result = 0;
    for (int i = 1; i <= k; i++) result += math.log((n - k + i).toDouble()) - math.log(i.toDouble());
    return result;
  }

  double _gammaPdf(double x, double shape, double scale) {
    if (x <= 0) return 0;
    final logPdf = (shape - 1) * math.log(x) - x / scale - shape * math.log(scale) - _logGamma(shape);
    return math.exp(logPdf);
  }

  double _gammaCdf(double x, double shape, double scale) {
    if (x <= 0) return 0;
    return _regularizedGammaP(shape, x / scale);
  }

  double _betaPdf(double x, double alpha, double beta) {
    if (x <= 0 || x >= 1) return 0;
    final logPdf = (alpha - 1) * math.log(x) + (beta - 1) * math.log(1 - x) - _logBeta(alpha, beta);
    return math.exp(logPdf);
  }

  double _betaCdf(double x, double alpha, double beta) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    return _incompleteBeta(x, alpha, beta);
  }

  double _lognormalPdf(double x, double mu, double sigma) {
    if (x <= 0 || sigma <= 0) return 0;
    final z = (math.log(x) - mu) / sigma;
    return math.exp(-0.5 * z * z) / (x * sigma * math.sqrt(2 * math.pi));
  }

  double _lognormalCdf(double x, double mu, double sigma) {
    if (x <= 0) return 0;
    return _normalCdf(math.log(x), mu, sigma);
  }

  double _zInverse(double p) {
    if (p <= 0) return double.negativeInfinity;
    if (p >= 1) return double.infinity;
    if (p < 0.5) return -_zInversePositive(1 - p);
    return _zInversePositive(p);
  }

  double _zInversePositive(double p) {
    final t = math.sqrt(-2 * math.log(1 - p));
    const c0 = 2.515517, c1 = 0.802853, c2 = 0.010328;
    const d1 = 1.432788, d2 = 0.189269, d3 = 0.001308;
    return t - (c0 + c1 * t + c2 * t * t) / (1 + d1 * t + d2 * t * t + d3 * t * t * t);
  }

  double _logGamma(double x) {
    if (x <= 0) return double.infinity;
    if (x < 0.5) return math.log(math.pi / math.sin(math.pi * x)) - _logGamma(1 - x);
    final z = x - 1;
    const g = 7;
    const c = [0.99999999999980993, 676.5203681218851, -1259.1392167224028,
      771.32342877765313, -176.61502916214059, 12.507343278686905,
      -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7];
    double sum = c[0];
    for (int i = 1; i < g + 2; i++) sum += c[i] / (z + i);
    final t = z + g + 0.5;
    return 0.5 * math.log(2 * math.pi) + (z + 0.5) * math.log(t) - t + math.log(sum);
  }

  double _logBeta(double a, double b) => _logGamma(a) + _logGamma(b) - _logGamma(a + b);

  double _regularizedGammaP(double a, double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    if (x < a + 1) return _gammaSeries(a, x);
    return 1 - _gammaContinuedFraction(a, x);
  }

  double _gammaSeries(double a, double x) {
    double sum = 1.0 / a;
    double term = sum;
    for (int n = 1; n < 200; n++) {
      term *= x / (a + n);
      sum += term;
      if (term.abs() < 1e-12 * sum.abs()) break;
    }
    return sum * math.exp(-x + a * math.log(x) - _logGamma(a));
  }

  double _gammaContinuedFraction(double a, double x) {
    double b = x + 1 - a;
    double c = 1e30;
    double d = 1 / b;
    double h = d;
    for (int i = 1; i < 200; i++) {
      final an = -i * (i - a);
      b += 2;
      d = an * d + b;
      if (d.abs() < 1e-30) d = 1e-30;
      c = b + an / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1 / d;
      final del = d * c;
      h *= del;
      if ((del - 1).abs() < 1e-12) break;
    }
    return math.exp(-x + a * math.log(x) - _logGamma(a)) * h;
  }

  double _incompleteBeta(double x, double a, double b) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    final logBeta = _logBeta(a, b);
    if (x < (a + 1) / (a + b + 2)) {
      return math.exp(a * math.log(x) + b * math.log(1 - x) - logBeta) * _betaCF(x, a, b) / a;
    }
    return 1 - math.exp(b * math.log(1 - x) + a * math.log(x) - logBeta) * _betaCF(1 - x, b, a) / b;
  }

  double _betaCF(double x, double a, double b) {
    const maxIter = 200;
    const eps = 1e-12;
    double c = 1.0, d = 1 - (a + b) * x / (a + 1);
    if (d.abs() < 1e-30) d = 1e-30;
    d = 1 / d;
    double h = d;
    for (int m = 1; m <= maxIter; m++) {
      final m2 = 2 * m;
      double aa = m * (b - m) * x / ((a + m2 - 1) * (a + m2));
      d = 1 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1 / d;
      h *= d * c;
      aa = -(a + m) * (a + b + m) * x / ((a + m2) * (a + m2 + 1));
      d = 1 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1 / d;
      final del = d * c;
      h *= del;
      if ((del - 1).abs() < eps) break;
    }
    return h;
  }
}
