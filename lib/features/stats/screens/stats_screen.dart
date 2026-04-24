import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/features/graph/screens/graph_screen.dart';
import 'package:scientific_pro_calculator/providers/app_settings_provider.dart';
import 'package:scientific_pro_calculator/services/statistics_service.dart';
import 'package:scientific_pro_calculator/services/export_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Descriptive tab
  final TextEditingController _descriptiveDataController =
      TextEditingController();
  DescriptiveStats? _descriptiveResults;
  bool _descriptiveLoading = false;
  String? _descriptiveError;

  // Distributions tab
  String _selectedDistribution = 'Normal';
  final TextEditingController _distParam1Controller =
      TextEditingController(text: '0');
  final TextEditingController _distParam2Controller =
      TextEditingController(text: '1');
  final TextEditingController _distXController =
      TextEditingController(text: '0');
  PdfCdfResult? _distributionResults;
  bool _distributionLoading = false;
  String? _distributionError;

  // Hypothesis tab
  String _selectedHypothesisTest = 't-test';
  final TextEditingController _hypoData1Controller = TextEditingController();
  final TextEditingController _hypoData2Controller = TextEditingController();
  final TextEditingController _hypoMuController =
      TextEditingController(text: '0');
  final TextEditingController _confLevelController =
      TextEditingController(text: '0.95');
  HypothesisTestResult? _hypothesisResults;
  bool _hypothesisLoading = false;
  String? _hypothesisError;

  // Regression tab
  String _selectedRegression = 'Linear';
  final TextEditingController _regXController = TextEditingController();
  final TextEditingController _regYController = TextEditingController();
  final TextEditingController _polyDegreeController =
      TextEditingController(text: '2');
  RegressionResult? _regressionResults;
  bool _regressionLoading = false;
  String? _regressionError;

  final List<String> _distributions = [
    'Normal',
    'Binomial',
    'Poisson',
    'Exponential',
    'Uniform',
    'Chi-squared',
    'Student-t',
    'F-distribution',
  ];

  final List<String> _hypothesisTests = [
    't-test',
    'z-test',
    'chi²-test',
    'ANOVA',
  ];

  final List<String> _regressionTypes = [
    'Linear',
    'Polynomial',
    'Exponential',
    'Logarithmic',
    'Power',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptiveDataController.dispose();
    _distParam1Controller.dispose();
    _distParam2Controller.dispose();
    _distXController.dispose();
    _hypoData1Controller.dispose();
    _hypoData2Controller.dispose();
    _hypoMuController.dispose();
    _confLevelController.dispose();
    _regXController.dispose();
    _regYController.dispose();
    _polyDegreeController.dispose();
    super.dispose();
  }

  List<double> _parseDataString(String raw) {
    final parts = raw
        .split(RegExp(r'[,\s\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final result = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p);
      if (v != null) result.add(v);
    }
    return result;
  }

  Future<void> _computeDescriptive() async {
    final data = _parseDataString(_descriptiveDataController.text);
    if (data.isEmpty) {
      setState(() {
        _descriptiveError = 'Please enter at least one numeric value.';
        _descriptiveResults = null;
      });
      return;
    }
    setState(() {
      _descriptiveLoading = true;
      _descriptiveError = null;
    });
    try {
      final results = StatisticsService.instance.descriptiveStats(data);
      setState(() {
        _descriptiveResults = results;
        _descriptiveLoading = false;
      });
    } catch (e) {
      setState(() {
        _descriptiveError = 'Computation error: $e';
        _descriptiveLoading = false;
      });
    }
  }

  Future<void> _evaluateDistribution() async {
    final p1 = double.tryParse(_distParam1Controller.text);
    final p2 = double.tryParse(_distParam2Controller.text);
    final x = double.tryParse(_distXController.text);
    if (x == null) {
      setState(() {
        _distributionError = 'Invalid x value.';
        _distributionResults = null;
      });
      return;
    }
    setState(() {
      _distributionLoading = true;
      _distributionError = null;
    });
    try {
      final params = <String, double>{};
      if (p1 != null) params['param1'] = p1;
      if (p2 != null) params['param2'] = p2;
      final results = StatisticsService.instance.pdfCdf(
        _selectedDistribution,
        params,
        x,
      );
      setState(() {
        _distributionResults = results;
        _distributionLoading = false;
      });
    } catch (e) {
      setState(() {
        _distributionError = 'Computation error: $e';
        _distributionLoading = false;
      });
    }
  }

  Future<void> _runHypothesisTest() async {
    final data1 = _parseDataString(_hypoData1Controller.text);
    if (data1.isEmpty) {
      setState(() {
        _hypothesisError = 'Please enter data for Sample 1.';
        _hypothesisResults = null;
      });
      return;
    }
    final data2 = _parseDataString(_hypoData2Controller.text);
    final mu = double.tryParse(_hypoMuController.text) ?? 0.0;
    final confLevel = double.tryParse(_confLevelController.text) ?? 0.95;
    setState(() {
      _hypothesisLoading = true;
      _hypothesisError = null;
    });
    try {
      final results = StatisticsService.instance.hypothesisTest(
        _selectedHypothesisTest,
        data1,
        data2.isEmpty ? null : data2,
        mu,
        confLevel,
      );
      setState(() {
        _hypothesisResults = results;
        _hypothesisLoading = false;
      });
    } catch (e) {
      setState(() {
        _hypothesisError = 'Computation error: $e';
        _hypothesisLoading = false;
      });
    }
  }

  Future<void> _fitRegression() async {
    final xData = _parseDataString(_regXController.text);
    final yData = _parseDataString(_regYController.text);
    if (xData.isEmpty || yData.isEmpty) {
      setState(() {
        _regressionError = 'Please enter X and Y data.';
        _regressionResults = null;
      });
      return;
    }
    if (xData.length != yData.length) {
      setState(() {
        _regressionError =
            'X and Y must have the same number of values (X: ${xData.length}, Y: ${yData.length}).';
        _regressionResults = null;
      });
      return;
    }
    final degree = int.tryParse(_polyDegreeController.text) ?? 2;
    setState(() {
      _regressionLoading = true;
      _regressionError = null;
    });
    try {
      final results = StatisticsService.instance.regression(
        _selectedRegression,
        xData,
        yData,
        degree: degree,
      );
      setState(() {
        _regressionResults = results;
        _regressionLoading = false;
      });
    } catch (e) {
      setState(() {
        _regressionError = 'Computation error: $e';
        _regressionLoading = false;
      });
    }
  }

  void _sendRegressionToGraph() {
    if (_regressionResults == null) return;
    final equation = _regressionResults!.equation;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraphScreen(initialExpression: equation),
      ),
    );
  }

  Future<void> _exportData() async {
    final data1 = _parseDataString(_descriptiveDataController.text);
    if (data1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No data to export. Enter data in the Descriptive tab first.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('Export as CSV'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final path = await ExportService.instance.exportDatasetAsCsv(
                    data1,
                    'stats_data',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exported to $path'),
                        action: SnackBarAction(
                          label: 'Share',
                          onPressed: () =>
                              ExportService.instance.shareFile(path),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final path = await ExportService.instance.exportDatasetAsPdf(
                    data1,
                    'stats_data',
                    null,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exported to $path'),
                        action: SnackBarAction(
                          label: 'Share',
                          onPressed: () =>
                              ExportService.instance.shareFile(path),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Export Data',
            onPressed: _exportData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Descriptive'),
            Tab(text: 'Distributions'),
            Tab(text: 'Hypothesis'),
            Tab(text: 'Regression'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DescriptiveTab(
            dataController: _descriptiveDataController,
            results: _descriptiveResults,
            isLoading: _descriptiveLoading,
            error: _descriptiveError,
            onCompute: _computeDescriptive,
            cs: cs,
            theme: theme,
          ),
          _DistributionsTab(
            distributions: _distributions,
            selectedDistribution: _selectedDistribution,
            param1Controller: _distParam1Controller,
            param2Controller: _distParam2Controller,
            xController: _distXController,
            results: _distributionResults,
            isLoading: _distributionLoading,
            error: _distributionError,
            onDistributionChanged: (v) =>
                setState(() => _selectedDistribution = v),
            onEvaluate: _evaluateDistribution,
            cs: cs,
            theme: theme,
          ),
          _HypothesisTab(
            tests: _hypothesisTests,
            selectedTest: _selectedHypothesisTest,
            data1Controller: _hypoData1Controller,
            data2Controller: _hypoData2Controller,
            muController: _hypoMuController,
            confLevelController: _confLevelController,
            results: _hypothesisResults,
            isLoading: _hypothesisLoading,
            error: _hypothesisError,
            onTestChanged: (v) => setState(() => _selectedHypothesisTest = v),
            onRunTest: _runHypothesisTest,
            cs: cs,
            theme: theme,
          ),
          _RegressionTab(
            regressionTypes: _regressionTypes,
            selectedRegression: _selectedRegression,
            xController: _regXController,
            yController: _regYController,
            degreeController: _polyDegreeController,
            results: _regressionResults,
            isLoading: _regressionLoading,
            error: _regressionError,
            onRegressionChanged: (v) =>
                setState(() => _selectedRegression = v),
            onFit: _fitRegression,
            onSendToGraph: _sendRegressionToGraph,
            cs: cs,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ColorScheme cs;

  const _SectionCard({
    required this.title,
    required this.children,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final ColorScheme cs;

  const _ErrorCard({required this.message, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.errorContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRowWidget extends StatelessWidget {
  final _StatRow row;
  final ColorScheme cs;

  const _StatRowWidget({required this.row, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            row.label,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            row.value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);
}

// ─── Descriptive Tab ──────────────────────────────────────────────────────────

class _DescriptiveTab extends StatelessWidget {
  final TextEditingController dataController;
  final DescriptiveStats? results;
  final bool isLoading;
  final String? error;
  final VoidCallback onCompute;
  final ColorScheme cs;
  final ThemeData theme;

  const _DescriptiveTab({
    required this.dataController,
    required this.results,
    required this.isLoading,
    required this.error,
    required this.onCompute,
    required this.cs,
    required this.theme,
  });

  String _fmt(double v) {
    if (v.isNaN) return 'N/A';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    if (v == v.truncateToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Data Input',
            cs: cs,
            children: [
              TextField(
                controller: dataController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter numbers separated by commas or spaces\ne.g. 1, 2, 3, 4, 5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onCompute,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calculate_rounded),
                  label: Text(isLoading ? 'Computing...' : 'Compute Statistics'),
                ),
              ),
            ],
          ),
          if (error != null) _ErrorCard(message: error!, cs: cs),
          if (results != null) _DescriptiveResultsCard(results: results!, cs: cs, fmt: _fmt),
        ],
      ),
    );
  }
}

class _DescriptiveResultsCard extends StatelessWidget {
  final DescriptiveStats results;
  final ColorScheme cs;
  final String Function(double) fmt;

  const _DescriptiveResultsCard({
    required this.results,
    required this.cs,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _StatRow('Count', results.count.toString()),
      _StatRow('Sum', fmt(results.sum)),
      _StatRow('Mean', fmt(results.mean)),
      _StatRow('Median', fmt(results.median)),
      _StatRow('Mode', results.mode.isEmpty ? 'None' : results.mode.map(fmt).join(', ')),
      _StatRow('Std Dev', fmt(results.stdDev)),
      _StatRow('Variance', fmt(results.variance)),
      _StatRow('Min', fmt(results.min)),
      _StatRow('Max', fmt(results.max)),
      _StatRow('Range', fmt(results.range)),
      _StatRow('Q1', fmt(results.q1)),
      _StatRow('Q3', fmt(results.q3)),
      _StatRow('IQR', fmt(results.iqr)),
      _StatRow('Skewness', fmt(results.skewness)),
      _StatRow('Kurtosis', fmt(results.kurtosis)),
      _StatRow('Geo. Mean', fmt(results.geometricMean)),
      _StatRow('Harm. Mean', fmt(results.harmonicMean)),
      _StatRow('CV (%)', fmt(results.coefficientOfVariation)),
      _StatRow('Std Error', fmt(results.standardError)),
    ];

    return _SectionCard(
      title: 'Results',
      cs: cs,
      children: [
        ...rows.map((r) => _StatRowWidget(row: r, cs: cs)),
      ],
    );
  }
}

// ─── Distributions Tab ────────────────────────────────────────────────────────

class _DistributionsTab extends StatelessWidget {
  final List<String> distributions;
  final String selectedDistribution;
  final TextEditingController param1Controller;
  final TextEditingController param2Controller;
  final TextEditingController xController;
  final PdfCdfResult? results;
  final bool isLoading;
  final String? error;
  final ValueChanged<String> onDistributionChanged;
  final VoidCallback onEvaluate;
  final ColorScheme cs;
  final ThemeData theme;

  const _DistributionsTab({
    required this.distributions,
    required this.selectedDistribution,
    required this.param1Controller,
    required this.param2Controller,
    required this.xController,
    required this.results,
    required this.isLoading,
    required this.error,
    required this.onDistributionChanged,
    required this.onEvaluate,
    required this.cs,
    required this.theme,
  });

  String _fmt(double v) {
    if (v.isNaN) return 'N/A';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Distribution Parameters',
            cs: cs,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDistribution,
                decoration: const InputDecoration(
                  labelText: 'Distribution',
                  border: OutlineInputBorder(),
                ),
                items: distributions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onDistributionChanged(v);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: param1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Param 1 (μ / λ / n)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: param2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Param 2 (σ / p)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xController,
                decoration: const InputDecoration(
                  labelText: 'x value',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onEvaluate,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.functions_rounded),
                  label: Text(isLoading ? 'Evaluating...' : 'Evaluate'),
                ),
              ),
            ],
          ),
          if (error != null) _ErrorCard(message: error!, cs: cs),
          if (results != null)
            _SectionCard(
              title: 'Results',
              cs: cs,
              children: [
                _StatRowWidget(
                    row: _StatRow('PDF', _fmt(results!.pdf)), cs: cs),
                _StatRowWidget(
                    row: _StatRow('CDF', _fmt(results!.cdf)), cs: cs),
                _StatRowWidget(
                    row: _StatRow(
                        'Survival (1-CDF)', _fmt(results!.survivalFunction)),
                    cs: cs),
                _StatRowWidget(
                    row: _StatRow('x', _fmt(results!.x)), cs: cs),
                _StatRowWidget(
                    row: _StatRow('Distribution', results!.distribution),
                    cs: cs),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Hypothesis Tab ───────────────────────────────────────────────────────────

class _HypothesisTab extends StatelessWidget {
  final List<String> tests;
  final String selectedTest;
  final TextEditingController data1Controller;
  final TextEditingController data2Controller;
  final TextEditingController muController;
  final TextEditingController confLevelController;
  final HypothesisTestResult? results;
  final bool isLoading;
  final String? error;
  final ValueChanged<String> onTestChanged;
  final VoidCallback onRunTest;
  final ColorScheme cs;
  final ThemeData theme;

  const _HypothesisTab({
    required this.tests,
    required this.selectedTest,
    required this.data1Controller,
    required this.data2Controller,
    required this.muController,
    required this.confLevelController,
    required this.results,
    required this.isLoading,
    required this.error,
    required this.onTestChanged,
    required this.onRunTest,
    required this.cs,
    required this.theme,
  });

  bool get _needsSample2 =>
      selectedTest == 'ANOVA' || selectedTest == 't-test (two-sample)';

  String _fmt(double v) {
    if (v.isNaN) return 'N/A';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Test Configuration',
            cs: cs,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTest,
                decoration: const InputDecoration(
                  labelText: 'Test Type',
                  border: OutlineInputBorder(),
                ),
                items: tests
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onTestChanged(v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: data1Controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sample 1 data (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              if (_needsSample2) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: data2Controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Sample 2 data (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: muController,
                      decoration: const InputDecoration(
                        labelText: 'H₀ mean (μ₀)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: confLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Confidence level',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onRunTest,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.science_rounded),
                  label: Text(isLoading ? 'Running...' : 'Run Test'),
                ),
              ),
            ],
          ),
          if (error != null) _ErrorCard(message: error!, cs: cs),
          if (results != null)
            _SectionCard(
              title: 'Test Results',
              cs: cs,
              children: [
                _StatRowWidget(
                    row: _StatRow('Test', results!.testType), cs: cs),
                _StatRowWidget(
                    row: _StatRow(
                        'Test Statistic', _fmt(results!.testStatistic)),
                    cs: cs),
                _StatRowWidget(
                    row: _StatRow('p-value', _fmt(results!.pValue)), cs: cs),
                _StatRowWidget(
                    row: _StatRow(
                        'Critical Value', _fmt(results!.criticalValue)),
                    cs: cs),
                if (results!.degreesOfFreedom != null)
                  _StatRowWidget(
                      row: _StatRow('df', _fmt(results!.degreesOfFreedom!)),
                      cs: cs),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    results!.nullHypothesis,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    results!.alternativeHypothesis,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: results!.pValue < (1 - results!.confidenceLevel)
                        ? cs.errorContainer
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    results!.conclusion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: results!.pValue < (1 - results!.confidenceLevel)
                          ? cs.onErrorContainer
                          : cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Regression Tab ───────────────────────────────────────────────────────────

class _RegressionTab extends StatelessWidget {
  final List<String> regressionTypes;
  final String selectedRegression;
  final TextEditingController xController;
  final TextEditingController yController;
  final TextEditingController degreeController;
  final RegressionResult? results;
  final bool isLoading;
  final String? error;
  final ValueChanged<String> onRegressionChanged;
  final VoidCallback onFit;
  final VoidCallback onSendToGraph;
  final ColorScheme cs;
  final ThemeData theme;

  const _RegressionTab({
    required this.regressionTypes,
    required this.selectedRegression,
    required this.xController,
    required this.yController,
    required this.degreeController,
    required this.results,
    required this.isLoading,
    required this.error,
    required this.onRegressionChanged,
    required this.onFit,
    required this.onSendToGraph,
    required this.cs,
    required this.theme,
  });

  String _fmt(double v) {
    if (v.isNaN) return 'N/A';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Regression Configuration',
            cs: cs,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRegression,
                decoration: const InputDecoration(
                  labelText: 'Regression Type',
                  border: OutlineInputBorder(),
                ),
                items: regressionTypes
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRegressionChanged(v);
                },
              ),
              if (selectedRegression == 'Polynomial') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(
                    labelText: 'Polynomial Degree',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: xController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'X data (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Y data (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onFit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.trending_up_rounded),
                  label: Text(isLoading ? 'Fitting...' : 'Fit Regression'),
                ),
              ),
            ],
          ),
          if (error != null) _ErrorCard(message: error!, cs: cs),
          if (results != null)
            _SectionCard(
              title: 'Regression Results',
              cs: cs,
              children: [
                _StatRowWidget(
                    row: _StatRow('Type', results!.regressionType), cs: cs),
                _StatRowWidget(
                    row: _StatRow('Equation', results!.equation), cs: cs),
                _StatRowWidget(
                    row: _StatRow('R²', _fmt(results!.rSquared)), cs: cs),
                _StatRowWidget(
                    row: _StatRow(
                        'Adj. R²', _fmt(results!.adjustedRSquared)),
                    cs: cs),
                _StatRowWidget(
                    row: _StatRow('RMSE', _fmt(results!.rmse)), cs: cs),
                _StatRowWidget(
                    row: _StatRow('MAE', _fmt(results!.mae)), cs: cs),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSendToGraph,
                    icon: const Icon(Icons.show_chart_rounded),
                    label: const Text('Send to Graph'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
