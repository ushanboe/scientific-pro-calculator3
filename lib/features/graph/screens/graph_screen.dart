import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/graph_function_2d.dart';
import 'package:scientific_pro_calculator/models/graph_function_3d.dart';
import 'package:scientific_pro_calculator/providers/graphing_service_provider.dart';
import 'package:scientific_pro_calculator/providers/symbolic_math_service_provider.dart';
import 'package:scientific_pro_calculator/services/export_service.dart';
import 'package:scientific_pro_calculator/services/graphing_service.dart';

class GraphScreen extends ConsumerStatefulWidget {
  final String? initialExpression;

  const GraphScreen({super.key, this.initialExpression});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen>
    with TickerProviderStateMixin {
  bool _graphMode2D = true;
  List<GraphFunction2D> _functions2D = [];
  GraphFunction3D? _function3D;

  double _xMin = -10.0;
  double _xMax = 10.0;
  double _yMin = -10.0;
  double _yMax = 10.0;

  bool _showIntegralArea = false;
  double _integralLower = -5.0;
  double _integralUpper = 5.0;
  double _integralValue = 0.0;

  bool _showLimitVisualization = false;
  double _limitTargetX = 0.0;
  double _limitValue = 0.0;

  bool _showRegressionOverlay = false;
  String? _regressionFunction;

  bool _traceMode = false;
  double _traceX = 0.0;
  double _traceY = 0.0;

  // 3D state
  double _rotationX = 0.4;
  double _rotationY = 0.3;
  double _zoom3D = 1.0;
  int _meshDensity = 20;

  // Plot data cache: expression -> list of nullable PlotPoints (null = gap/discontinuity)
  final Map<String, List<PlotPoint?>> _plotDataCache = {};

  // Repaint key for export
  final GlobalKey _repaintKey = GlobalKey();

  // Animation for limit visualization
  late AnimationController _limitAnimController;

  // Gesture tracking
  Offset? _lastPanOffset;
  double? _lastPinchScale;
  Size _canvasSize = Size.zero;

  // Axis range controllers
  final _xMinController = TextEditingController();
  final _xMaxController = TextEditingController();
  final _yMinController = TextEditingController();
  final _yMaxController = TextEditingController();
  final _integralLowerController = TextEditingController();
  final _integralUpperController = TextEditingController();
  final _limitTargetController = TextEditingController();

  bool _isExporting = false;

  static const List<Color> _functionColors = [
    Color(0xFF4C6EF5),
    Color(0xFFFF6B6B),
    Color(0xFF51CF66),
    Color(0xFFFFD43B),
    Color(0xFFCC5DE8),
    Color(0xFF20C997),
    Color(0xFFFF922B),
    Color(0xFF74C0FC),
  ];

  @override
  void initState() {
    super.initState();
    _limitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncAxisControllers();
    _integralLowerController.text = _integralLower.toStringAsFixed(1);
    _integralUpperController.text = _integralUpper.toStringAsFixed(1);
    _limitTargetController.text = _limitTargetX.toStringAsFixed(1);

    if (widget.initialExpression != null && widget.initialExpression!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addFunctionWithExpression(widget.initialExpression!);
      });
    }
  }

  @override
  void dispose() {
    _limitAnimController.dispose();
    _xMinController.dispose();
    _xMaxController.dispose();
    _yMinController.dispose();
    _yMaxController.dispose();
    _integralLowerController.dispose();
    _integralUpperController.dispose();
    _limitTargetController.dispose();
    super.dispose();
  }

  void _syncAxisControllers() {
    _xMinController.text = _xMin.toStringAsFixed(1);
    _xMaxController.text = _xMax.toStringAsFixed(1);
    _yMinController.text = _yMin.toStringAsFixed(1);
    _yMaxController.text = _yMax.toStringAsFixed(1);
  }

  void _switchTo2D() {
    setState(() {
      _graphMode2D = true;
      _plotDataCache.clear();
    });
    _regenerateAllPlots();
  }

  void _switchTo3D() {
    setState(() {
      _graphMode2D = false;
    });
    if (_function3D == null) {
      _show3DFunctionDialog();
    }
  }

  Future<void> _regenerateAllPlots() async {
    final graphingService = ref.read(graphingServiceProvider);
    for (final fn in _functions2D) {
      try {
        final points = graphingService.generatePlotData(
          fn.expression,
          xMin: _xMin,
          xMax: _xMax,
          resolution: 500,
        );
        if (mounted) {
          setState(() {
            _plotDataCache[fn.expression] = points;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _addFunctionWithExpression(String expr) async {
    final color = _functionColors[_functions2D.length % _functionColors.length];
    final graphingService = ref.read(graphingServiceProvider);
    try {
      final points = graphingService.generatePlotData(
        expr,
        xMin: _xMin,
        xMax: _xMax,
        resolution: 500,
      );
      final fn = GraphFunction2D(
        expression: expr,
        color: color,
        label: expr,
      );
      if (mounted) {
        setState(() {
          _functions2D = [..._functions2D, fn];
          _plotDataCache[expr] = points;
        });
      }
    } catch (_) {}
  }

  Future<void> _addFunction() async {
    final result = await _showAddFunctionDialog();
    if (result == null) return;
    final expr = result.$1;
    final color = result.$2;
    final graphingService = ref.read(graphingServiceProvider);
    try {
      final points = graphingService.generatePlotData(
        expr,
        xMin: _xMin,
        xMax: _xMax,
        resolution: 500,
      );
      final fn = GraphFunction2D(
        expression: expr,
        color: color,
        label: expr,
      );
      setState(() {
        _functions2D = [..._functions2D, fn];
        _plotDataCache[expr] = points;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid expression: $expr',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeFunction(int index) {
    final fn = _functions2D[index];
    setState(() {
      _plotDataCache.remove(fn.expression);
      final list = [..._functions2D];
      list.removeAt(index);
      _functions2D = list;
    });
  }

  Future<(String, Color)?> _showAddFunctionDialog() async {
    String chosenExpr = '';
    Color selectedColor = _functionColors[_functions2D.length % _functionColors.length];
    final controller = TextEditingController();

    return showDialog<(String, Color)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Add Function',
            style: TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontFamily: 'RobotoMono',
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  labelText: 'f(x) =',
                  hintText: 'e.g. x^2, sin(x), x*cos(x)',
                  hintStyle: TextStyle(color: Color(0xFF64748B)),
                ),
                onChanged: (v) => chosenExpr = v.trim(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Color',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _functionColors.map((c) {
                  final isSelected = c.value == selectedColor.value;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () {
                final e = controller.text.trim();
                if (e.isEmpty) return;
                Navigator.pop(ctx, (e, selectedColor));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _show3DFunctionDialog() async {
    final controller = TextEditingController(text: 'x^2 + y^2');

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          '3D Surface Function',
          style: TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontFamily: 'RobotoMono',
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            labelText: 'f(x,y) =',
            hintText: 'e.g. x^2 + y^2, sin(x)*cos(y)',
            hintStyle: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () {
              final e = controller.text.trim();
              if (e.isEmpty) return;
              Navigator.pop(ctx, e);
            },
            child: const Text('Plot'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _function3D = GraphFunction3D(
          expression: result,
          uMin: -5.0,
          uMax: 5.0,
          vMin: -5.0,
          vMax: 5.0,
          meshDensity: _meshDensity,
          isParametric: false,
        );
      });
    }
  }

  void _showGraphMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2436),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded, color: Color(0xFF4C6EF5)),
              title: const Text('Axis Settings', style: TextStyle(color: Color(0xFFE2E8F0))),
              onTap: () {
                Navigator.pop(ctx);
                _showAxisSettingsSheet();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.integration_instructions_rounded,
                color: _showIntegralArea ? const Color(0xFF51CF66) : const Color(0xFF94A3B8),
              ),
              title: Text(
                _showIntegralArea ? 'Hide Integral Area' : 'Show Integral Area',
                style: const TextStyle(color: Color(0xFFE2E8F0)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleIntegralArea();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.trending_flat_rounded,
                color: _showLimitVisualization ? const Color(0xFFFFD43B) : const Color(0xFF94A3B8),
              ),
              title: Text(
                _showLimitVisualization ? 'Hide Limit Visualization' : 'Show Limit Visualization',
                style: const TextStyle(color: Color(0xFFE2E8F0)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleLimitVisualization();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.show_chart_rounded,
                color: _showRegressionOverlay ? const Color(0xFFCC5DE8) : const Color(0xFF94A3B8),
              ),
              title: Text(
                _showRegressionOverlay ? 'Hide Regression Overlay' : 'Show Regression Overlay',
                style: const TextStyle(color: Color(0xFFE2E8F0)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleRegressionOverlay();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.touch_app_rounded,
                color: _traceMode ? const Color(0xFF20C997) : const Color(0xFF94A3B8),
              ),
              title: Text(
                _traceMode ? 'Disable Trace Mode' : 'Enable Trace Mode',
                style: const TextStyle(color: Color(0xFFE2E8F0)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _traceMode = !_traceMode);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.save_alt_rounded,
                color: _isExporting ? const Color(0xFF94A3B8) : const Color(0xFF4C6EF5),
              ),
              title: const Text('Export Graph', style: TextStyle(color: Color(0xFFE2E8F0))),
              onTap: _isExporting
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _exportGraph();
                    },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
              title: const Text('Reset View', style: TextStyle(color: Color(0xFFE2E8F0))),
              onTap: () {
                Navigator.pop(ctx);
                _resetView();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRegressionOverlay() {
    setState(() {
      _showRegressionOverlay = !_showRegressionOverlay;
    });
    if (_showRegressionOverlay && _regressionFunction != null) {
      _addFunctionWithExpression(_regressionFunction!);
    }
  }

  /// Export graph: capture the RepaintBoundary as a PNG image, then save via ExportService.
  Future<void> _exportGraph() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('Graph not ready for export', isError: true);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnackBar('Failed to capture graph', isError: true);
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      final filePath = await ExportService.instance.graphToImage(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Graph exported to: $filePath',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF293548),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Share',
              textColor: const Color(0xFF4C6EF5),
              onPressed: () => ExportService.instance.shareFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFF9B1C1C) : const Color(0xFF293548),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetView() {
    setState(() {
      _xMin = -10.0;
      _xMax = 10.0;
      _yMin = -10.0;
      _yMax = 10.0;
      _syncAxisControllers();
    });
    _regenerateAllPlots();
  }

  void _showAxisSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2436),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Axis Range',
              style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xMinController,
                    style: const TextStyle(color: Color(0xFFE2E8F0)),
                    decoration: const InputDecoration(labelText: 'X Min'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onSubmitted: (_) => _applyAxisSettings(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _xMaxController,
                    style: const TextStyle(color: Color(0xFFE2E8F0)),
                    decoration: const InputDecoration(labelText: 'X Max'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onSubmitted: (_) => _applyAxisSettings(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yMinController,
                    style: const TextStyle(color: Color(0xFFE2E8F0)),
                    decoration: const InputDecoration(labelText: 'Y Min'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onSubmitted: (_) => _applyAxisSettings(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yMaxController,
                    style: const TextStyle(color: Color(0xFFE2E8F0)),
                    decoration: const InputDecoration(labelText: 'Y Max'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onSubmitted: (_) => _applyAxisSettings(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _applyAxisSettings();
                  Navigator.pop(ctx);
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyAxisSettings() {
    final xMin = double.tryParse(_xMinController.text);
    final xMax = double.tryParse(_xMaxController.text);
    final yMin = double.tryParse(_yMinController.text);
    final yMax = double.tryParse(_yMaxController.text);
    if (xMin != null && xMax != null && xMin < xMax) {
      setState(() {
        _xMin = xMin;
        _xMax = xMax;
      });
    }
    if (yMin != null && yMax != null && yMin < yMax) {
      setState(() {
        _yMin = yMin;
        _yMax = yMax;
      });
    }
    _syncAxisControllers();
    _regenerateAllPlots();
  }

  void _toggleIntegralArea() {
    setState(() {
      _showIntegralArea = !_showIntegralArea;
    });
    if (_showIntegralArea && _functions2D.isNotEmpty) {
      _computeIntegral();
    }
  }

  void _toggleLimitVisualization() {
    setState(() {
      _showLimitVisualization = !_showLimitVisualization;
    });
    if (_showLimitVisualization && _functions2D.isNotEmpty) {
      _computeLimit();
    }
  }

  Future<void> _computeIntegral() async {
    if (_functions2D.isEmpty) return;
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final result = await service.integralDefinite(
        _functions2D.first.expression,
        'x',
        _integralLower,
        _integralUpper,
      );
      final value = double.tryParse(result) ?? 0.0;
      if (mounted) {
        setState(() {
          _integralValue = value;
        });
      }
    } catch (_) {}
  }

  Future<void> _computeLimit() async {
    if (_functions2D.isEmpty) return;
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final result = await service.limit(
        _functions2D.first.expression,
        'x',
        _limitTargetX.toString(),
      );
      final value = double.tryParse(result) ?? 0.0;
      if (mounted) {
        setState(() {
          _limitValue = value;
        });
        _limitAnimController.forward(from: 0.0);
      }
    } catch (_) {}
  }

  /// Convert canvas pixel position to graph coordinates.
  (double, double) _canvasToGraph(Offset canvasPos) {
    if (_canvasSize == Size.zero) return (0, 0);
    final x = _xMin + (canvasPos.dx / _canvasSize.width) * (_xMax - _xMin);
    final y = _yMax - (canvasPos.dy / _canvasSize.height) * (_yMax - _yMin);
    return (x, y);
  }

  /// Evaluate the first function at a given x value using the plot data cache.
  double _evaluateFunctionAtX(double x) {
    if (_functions2D.isEmpty) return 0;
    final fn = _functions2D.first;
    final points = _plotDataCache[fn.expression];
    if (points == null || points.isEmpty) return 0;
    double closestY = 0;
    double minDist = double.infinity;
    for (final pt in points) {
      if (pt == null) continue;
      final dist = (pt.x - x).abs();
      if (dist < minDist) {
        minDist = dist;
        closestY = pt.y;
      }
    }
    return closestY;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_graphMode2D ? '2D Graph' : '3D Surface'),
        actions: [
          if (_showIntegralArea && _integralValue != 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF51CF66).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '∫ = ${_integralValue.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Color(0xFF51CF66),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_showLimitVisualization && _limitValue != 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD43B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'lim = ${_limitValue.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Color(0xFFFFD43B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Graph options',
            onPressed: _showGraphMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('2D', style: TextStyle(fontSize: 12)),
                    selected: _graphMode2D,
                    onSelected: (_) => _switchTo2D(),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFF4C6EF5),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('3D', style: TextStyle(fontSize: 12)),
                    selected: !_graphMode2D,
                    onSelected: (_) => _switchTo3D(),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFF4C6EF5),
                  ),
                  if (_traceMode && _graphMode2D) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20C997).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF20C997).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'x=${_traceX.toStringAsFixed(3)}  y=${_traceY.toStringAsFixed(3)}',
                        style: const TextStyle(
                          color: Color(0xFF20C997),
                          fontSize: 11,
                          fontFamily: 'Roboto Mono',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _graphMode2D ? _build2DGraph(cs) : _build3DGraph(cs),
            ),
            if (_graphMode2D)
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(
                    top: BorderSide(color: Color(0xFF334155), width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Functions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded),
                              onPressed: _addFunction,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: const Color(0xFF4C6EF5),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _functions2D.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _functions2D[index].color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _functions2D[index].expression,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'Roboto Mono',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => _removeFunction(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 18,
                                color: const Color(0xFFEF4444),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _build2DGraph(ColorScheme cs) {
    if (_functions2D.isEmpty) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 64,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Add a function to plot',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addFunction,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Function'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6EF5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onScaleStart: (details) {
        _lastPanOffset = details.focalPoint;
        _lastPinchScale = 1.0;
      },
      onScaleUpdate: (details) {
        if (_canvasSize == Size.zero) return;

        if (_traceMode) {
          final (gx, _) = _canvasToGraph(details.localFocalPoint);
          final traceY = _evaluateFunctionAtX(gx);
          setState(() {
            _traceX = gx;
            _traceY = traceY;
          });
          return;
        }

        if (_lastPanOffset != null && details.pointerCount == 1) {
          final delta = details.focalPoint - _lastPanOffset!;
          final xRange = _xMax - _xMin;
          final yRange = _yMax - _yMin;
          final dx = -delta.dx / _canvasSize.width * xRange;
          final dy = delta.dy / _canvasSize.height * yRange;
          setState(() {
            _xMin += dx;
            _xMax += dx;
            _yMin += dy;
            _yMax += dy;
            _syncAxisControllers();
          });
          _lastPanOffset = details.focalPoint;
        }

        if (details.pointerCount >= 2 && _lastPinchScale != null) {
          final scaleDelta = details.scale / _lastPinchScale!;
          if (scaleDelta != 1.0 && scaleDelta > 0) {
            final xCenter = (_xMin + _xMax) / 2;
            final yCenter = (_yMin + _yMax) / 2;
            final xHalf = (_xMax - _xMin) / 2 / scaleDelta;
            final yHalf = (_yMax - _yMin) / 2 / scaleDelta;
            setState(() {
              _xMin = xCenter - xHalf;
              _xMax = xCenter + xHalf;
              _yMin = yCenter - yHalf;
              _yMax = yCenter + yHalf;
              _syncAxisControllers();
            });
          }
          _lastPinchScale = details.scale;
        }
      },
      onScaleEnd: (_) {
        if (!_traceMode) {
          _lastPanOffset = null;
          _lastPinchScale = null;
          _regenerateAllPlots();
        }
      },
      child: RepaintBoundary(
        key: _repaintKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            return CustomPaint(
              size: _canvasSize,
              painter: _GraphPainter(
                functions: _functions2D,
                plotDataCache: _plotDataCache,
                xMin: _xMin,
                xMax: _xMax,
                yMin: _yMin,
                yMax: _yMax,
                showIntegralArea: _showIntegralArea,
                integralLower: _integralLower,
                integralUpper: _integralUpper,
                showLimitVisualization: _showLimitVisualization,
                limitTargetX: _limitTargetX,
                traceMode: _traceMode,
                traceX: _traceX,
                traceY: _traceY,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _build3DGraph(ColorScheme cs) {
    return GestureDetector(
      onScaleStart: (details) {
        _lastPanOffset = details.focalPoint;
        _lastPinchScale = 1.0;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount == 1 && _lastPanOffset != null) {
          final delta = details.focalPoint - _lastPanOffset!;
          setState(() {
            _rotationY += delta.dx * 0.005;
            _rotationX += delta.dy * 0.005;
          });
          _lastPanOffset = details.focalPoint;
        }
        if (details.pointerCount >= 2 && _lastPinchScale != null) {
          final scaleDelta = details.scale / _lastPinchScale!;
          if (scaleDelta > 0) {
            setState(() {
              _zoom3D = (_zoom3D * scaleDelta).clamp(0.1, 10.0);
            });
          }
          _lastPinchScale = details.scale;
        }
      },
      onScaleEnd: (_) {
        _lastPanOffset = null;
        _lastPinchScale = null;
      },
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.view_in_ar_rounded,
                size: 64,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _function3D != null
                    ? 'f(x,y) = ${_function3D!.expression}'
                    : 'No 3D function set',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontFamily: 'Roboto Mono',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rotation: (${_rotationX.toStringAsFixed(2)}, ${_rotationY.toStringAsFixed(2)})  '
                'Zoom: ${_zoom3D.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontFamily: 'Roboto Mono',
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Text(
                      'Mesh: $_meshDensity',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _meshDensity.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 9,
                        onChanged: (v) {
                          setState(() {
                            _meshDensity = v.round();
                            if (_function3D != null) {
                              _function3D = GraphFunction3D(
                                expression: _function3D!.expression,
                                uMin: _function3D!.uMin,
                                uMax: _function3D!.uMax,
                                vMin: _function3D!.vMin,
                                vMax: _function3D!.vMax,
                                meshDensity: _meshDensity,
                                isParametric: _function3D!.isParametric,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _show3DFunctionDialog,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Set 3D Function'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6EF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Graph Painter ────────────────────────────────────────────────────────────

class _GraphPainter extends CustomPainter {
  final List<GraphFunction2D> functions;
  final Map<String, List<PlotPoint?>> plotDataCache;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final bool showIntegralArea;
  final double integralLower;
  final double integralUpper;
  final bool showLimitVisualization;
  final double limitTargetX;
  final bool traceMode;
  final double traceX;
  final double traceY;

  const _GraphPainter({
    required this.functions,
    required this.plotDataCache,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.showIntegralArea,
    required this.integralLower,
    required this.integralUpper,
    required this.showLimitVisualization,
    required this.limitTargetX,
    required this.traceMode,
    required this.traceX,
    required this.traceY,
  });

  Offset _toCanvas(double x, double y, Size size) {
    final cx = (x - xMin) / (xMax - xMin) * size.width;
    final cy = (1.0 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(cx, cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 0.5;

    final xStep = _niceStep((xMax - xMin) / 10);
    final xStart = (xMin / xStep).ceil() * xStep;
    for (double x = xStart; x <= xMax; x += xStep) {
      final cx = (x - xMin) / (xMax - xMin) * size.width;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), gridPaint);
    }

    final yStep = _niceStep((yMax - yMin) / 10);
    final yStart = (yMin / yStep).ceil() * yStep;
    for (double y = yStart; y <= yMax; y += yStep) {
      final cy = (1.0 - (y - yMin) / (yMax - yMin)) * size.height;
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.5;

    if (yMin <= 0 && yMax >= 0) {
      final cy = (1.0 - (0 - yMin) / (yMax - yMin)) * size.height;
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);
    }
    if (xMin <= 0 && xMax >= 0) {
      final cx = (0 - xMin) / (xMax - xMin) * size.width;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint);
    }

    // Axis labels
    const labelStyle = TextStyle(color: Color(0xFF94A3B8), fontSize: 10);

    for (double x = xStart; x <= xMax; x += xStep) {
      final cx = (x - xMin) / (xMax - xMin) * size.width;
      final cy = yMin <= 0 && yMax >= 0
          ? (1.0 - (0 - yMin) / (yMax - yMin)) * size.height
          : size.height - 4;
      final tp = TextPainter(
        text: TextSpan(text: _formatAxisLabel(x), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy + 2));
    }

    for (double y = yStart; y <= yMax; y += yStep) {
      if (y.abs() < yStep * 0.01) continue;
      final cy = (1.0 - (y - yMin) / (yMax - yMin)) * size.height;
      final cx = xMin <= 0 && xMax >= 0
          ? (0 - xMin) / (xMax - xMin) * size.width
          : 4.0;
      final tp = TextPainter(
        text: TextSpan(text: _formatAxisLabel(y), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + 2, cy - tp.height / 2));
    }

    // Plot functions
    for (final fn in functions) {
      final points = plotDataCache[fn.expression];
      if (points == null || points.isEmpty) continue;

      final paint = Paint()
        ..color = fn.color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool started = false;

      for (final pt in points) {
        if (pt == null) {
          started = false;
          continue;
        }
        final cp = _toCanvas(pt.x, pt.y, size);
        if (!started) {
          path.moveTo(cp.dx, cp.dy);
          started = true;
        } else {
          path.lineTo(cp.dx, cp.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Integral area shading
    if (showIntegralArea && functions.isNotEmpty) {
      final fn = functions.first;
      final points = plotDataCache[fn.expression];
      if (points != null && points.isNotEmpty) {
        final shadePaint = Paint()
          ..color = fn.color.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;

        final path = Path();
        bool started = false;
        for (final pt in points) {
          if (pt == null) continue;
          if (pt.x < integralLower || pt.x > integralUpper) continue;
          final cp = _toCanvas(pt.x, pt.y, size);
          if (!started) {
            path.moveTo(cp.dx, cp.dy);
            started = true;
          } else {
            path.lineTo(cp.dx, cp.dy);
          }
        }
        if (started) {
          final upperC = _toCanvas(integralUpper, 0, size);
          final lowerC = _toCanvas(integralLower, 0, size);
          path.lineTo(upperC.dx, upperC.dy);
          path.lineTo(lowerC.dx, lowerC.dy);
          path.close();
          canvas.drawPath(path, shadePaint);
        }
      }
    }

    // Limit visualization — dashed vertical line
    if (showLimitVisualization) {
      final limitPaint = Paint()
        ..color = const Color(0xFFFFD43B)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      final cx = (limitTargetX - xMin) / (xMax - xMin) * size.width;
      const dashLen = 6.0;
      const gapLen = 4.0;
      double dy = 0.0;
      while (dy < size.height) {
        final endY = (dy + dashLen).clamp(0.0, size.height);
        canvas.drawLine(Offset(cx, dy), Offset(cx, endY), limitPaint);
        dy += dashLen + gapLen;
      }
    }

    // Trace crosshair
    if (traceMode) {
      final tracePaint = Paint()
        ..color = const Color(0xFF20C997)
        ..strokeWidth = 1.0;
      final tc = _toCanvas(traceX, traceY, size);
      canvas.drawLine(Offset(tc.dx, 0), Offset(tc.dx, size.height), tracePaint);
      canvas.drawLine(Offset(0, tc.dy), Offset(size.width, tc.dy), tracePaint);
      canvas.drawCircle(tc, 5, Paint()..color = const Color(0xFF20C997));

      final labelText = '(${traceX.toStringAsFixed(3)}, ${traceY.toStringAsFixed(3)})';
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Color(0xFF20C997),
            fontSize: 11,
            fontFamily: 'Roboto Mono',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final lx = (tc.dx + 8).clamp(0.0, size.width - tp.width);
      final ly = (tc.dy - 20).clamp(0.0, size.height - tp.height);
      tp.paint(canvas, Offset(lx, ly));
    }
  }

  double _niceStep(double rawStep) {
    if (rawStep <= 0) return 1.0;
    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final normalized = rawStep / magnitude;
    if (normalized < 1.5) return magnitude;
    if (normalized < 3.5) return 2 * magnitude;
    if (normalized < 7.5) return 5 * magnitude;
    return 10 * magnitude;
  }

  String _formatAxisLabel(double value) {
    if (value.abs() >= 1000 || (value.abs() < 0.01 && value != 0)) {
      return value.toStringAsExponential(1);
    }
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) {
    return oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.functions.length != functions.length ||
        oldDelegate.plotDataCache != plotDataCache ||
        oldDelegate.traceMode != traceMode ||
        oldDelegate.traceX != traceX ||
        oldDelegate.traceY != traceY ||
        oldDelegate.showIntegralArea != showIntegralArea ||
        oldDelegate.showLimitVisualization != showLimitVisualization;
  }
}
