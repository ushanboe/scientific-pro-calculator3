import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/features/graph/screens/graph_screen.dart';
import 'package:scientific_pro_calculator/providers/symbolic_math_service_provider.dart';

class SymbolicScreen extends ConsumerStatefulWidget {
  final String? initialExpression;

  const SymbolicScreen({super.key, this.initialExpression});

  @override
  ConsumerState<SymbolicScreen> createState() => _SymbolicScreenState();
}

class _SymbolicScreenState extends ConsumerState<SymbolicScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _expressionController;
  late TabController _tabController;

  List<String> _detectedVariables = [];
  String _resultExpression = 'Enter an expression and compute';
  bool _isLoading = false;

  // Derivative tab state
  String _derivativeVariable = 'x';
  int _derivativeOrder = 1;

  // Integral tab state
  String _integralVariable = 'x';
  bool _integralDefinite = false;
  final TextEditingController _integralLowerController =
      TextEditingController(text: '0');
  final TextEditingController _integralUpperController =
      TextEditingController(text: '1');

  // Limit tab state
  String _limitVariable = 'x';
  final TextEditingController _limitTargetController =
      TextEditingController(text: '0');

  // Taylor tab state
  String _taylorVariable = 'x';
  final TextEditingController _taylorPointController =
      TextEditingController(text: '0');
  int _taylorOrder = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _expressionController =
        TextEditingController(text: widget.initialExpression ?? '');
    if (widget.initialExpression != null &&
        widget.initialExpression!.isNotEmpty) {
      _detectVariables(widget.initialExpression!);
    }
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _tabController.dispose();
    _integralLowerController.dispose();
    _integralUpperController.dispose();
    _limitTargetController.dispose();
    _taylorPointController.dispose();
    super.dispose();
  }

  void _detectVariables(String expression) {
    if (expression.isEmpty) {
      setState(() => _detectedVariables = []);
      return;
    }
    final variablePattern = RegExp(r'\b([a-zA-Z])\b');
    final mathFunctions = {
      'sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt',
      'abs', 'pi', 'e', 'inf', 'i',
    };
    final found = <String>{};
    for (final match in variablePattern.allMatches(expression)) {
      final v = match.group(1)!;
      if (!mathFunctions.contains(v.toLowerCase())) {
        found.add(v);
      }
    }
    final sorted = found.toList()..sort();
    if (sorted.isNotEmpty && !sorted.contains(_derivativeVariable)) {
      _derivativeVariable = sorted.first;
      _integralVariable = sorted.first;
      _limitVariable = sorted.first;
      _taylorVariable = sorted.first;
    }
    setState(() => _detectedVariables = sorted);
  }

  String _ordinalSuffix(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }

  Future<void> _computeDerivative() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      _showError('Please enter an expression');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final result = await service.derivative(
        expression,
        _derivativeVariable,
        _derivativeOrder,
      );
      setState(() => _resultExpression = result);
    } catch (e) {
      setState(() => _resultExpression = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _computeIntegral() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      _showError('Please enter an expression');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = ref.read(symbolicMathServiceProvider);
      String result;
      if (_integralDefinite) {
        final lower = double.tryParse(_integralLowerController.text) ?? 0.0;
        final upper = double.tryParse(_integralUpperController.text) ?? 1.0;
        result = await service.integralDefinite(
          expression,
          _integralVariable,
          lower,
          upper,
        );
      } else {
        result = await service.integralIndefinite(
          expression,
          _integralVariable,
        );
      }
      setState(() => _resultExpression = result);
    } catch (e) {
      setState(() => _resultExpression = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _computeLimit() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      _showError('Please enter an expression');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final targetValue = _limitTargetController.text.trim().isEmpty
          ? '0'
          : _limitTargetController.text.trim();
      final result = await service.limit(
        expression,
        _limitVariable,
        targetValue,
      );
      setState(() => _resultExpression = result);
    } catch (e) {
      setState(() => _resultExpression = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _computeTaylor() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      _showError('Please enter an expression');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final point = _taylorPointController.text.trim().isEmpty
          ? '0'
          : _taylorPointController.text.trim();
      final result = await service.taylorSeries(
        expression,
        _taylorVariable,
        point,
        _taylorOrder,
      );
      setState(() => _resultExpression = result);
    } catch (e) {
      setState(() => _resultExpression = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _computeSimplify() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      _showError('Please enter an expression');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = ref.read(symbolicMathServiceProvider);
      final result = await service.simplify(expression);
      setState(() => _resultExpression = result);
    } catch (e) {
      setState(() => _resultExpression = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendToGraph() {
    final result = _resultExpression;
    if (result.isEmpty ||
        result.startsWith('Enter') ||
        result.startsWith('Error')) {
      _showError('Compute a result first before plotting');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraphScreen(initialExpression: result),
      ),
    );
  }

  void _copyResult() {
    final result = _resultExpression;
    if (result.isEmpty ||
        result.startsWith('Enter') ||
        result.startsWith('Error')) {
      _showError('Nothing to copy');
      return;
    }
    Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result copied to clipboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF293548),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendToCalculator() {
    final result = _resultExpression;
    if (result.isEmpty ||
        result.startsWith('Enter') ||
        result.startsWith('Error')) {
      _showError('Compute a result first');
      return;
    }
    Navigator.pop(context, result);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9B1C1C),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDerivativeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Variable',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF293548),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _detectedVariables
                                  .contains(_derivativeVariable)
                              ? _derivativeVariable
                              : (_detectedVariables.isNotEmpty
                                  ? _detectedVariables.first
                                  : 'x'),
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: (_detectedVariables.isEmpty
                                  ? ['x', 'y', 't', 'n']
                                  : _detectedVariables)
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _derivativeVariable = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF293548),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _derivativeOrder,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: [1, 2, 3, 4, 5]
                              .map((o) => DropdownMenuItem(
                                    value: o,
                                    child: Text('$o${_ordinalSuffix(o)}'),
                                  ))
                              .toList(),
                          onChanged: (o) {
                            if (o != null) {
                              setState(() => _derivativeOrder = o);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _computeDerivative,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6EF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                _isLoading ? 'Computing...' : 'Compute Derivative',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4C6EF5),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Use ^ for powers: x^3. Use * for multiplication: 3*x. '
                  'Functions: sin(x), cos(x), exp(x), ln(x), sqrt(x).',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variable selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Variable',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF293548),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _detectedVariables.contains(_integralVariable)
                        ? _integralVariable
                        : (_detectedVariables.isNotEmpty
                            ? _detectedVariables.first
                            : 'x'),
                    dropdownColor: const Color(0xFF1E293B),
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    items: (_detectedVariables.isEmpty
                            ? ['x', 'y', 't', 'n']
                            : _detectedVariables)
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _integralVariable = v);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Definite toggle
          Row(
            children: [
              const Text(
                'Definite integral',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Switch(
                value: _integralDefinite,
                onChanged: (v) => setState(() => _integralDefinite = v),
                activeColor: const Color(0xFF4C6EF5),
              ),
            ],
          ),
          if (_integralDefinite) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _integralLowerController,
                    decoration: InputDecoration(
                      labelText: 'Lower bound',
                      labelStyle:
                          const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF293548),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _integralUpperController,
                    decoration: InputDecoration(
                      labelText: 'Upper bound',
                      labelStyle:
                          const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF293548),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _computeIntegral,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6EF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                _isLoading
                    ? 'Computing...'
                    : (_integralDefinite
                        ? 'Compute Definite Integral'
                        : 'Compute Indefinite Integral'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Variable',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF293548),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _detectedVariables.contains(_limitVariable)
                              ? _limitVariable
                              : (_detectedVariables.isNotEmpty
                                  ? _detectedVariables.first
                                  : 'x'),
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: (_detectedVariables.isEmpty
                                  ? ['x', 'y', 't', 'n']
                                  : _detectedVariables)
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _limitVariable = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approaches',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _limitTargetController,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle:
                            const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF293548),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _computeLimit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6EF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                _isLoading ? 'Computing...' : 'Compute Limit',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaylorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Variable',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF293548),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _detectedVariables.contains(_taylorVariable)
                              ? _taylorVariable
                              : (_detectedVariables.isNotEmpty
                                  ? _detectedVariables.first
                                  : 'x'),
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: (_detectedVariables.isEmpty
                                  ? ['x', 'y', 't', 'n']
                                  : _detectedVariables)
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _taylorVariable = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expansion Point',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _taylorPointController,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle:
                            const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF293548),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF293548),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _taylorOrder,
                    dropdownColor: const Color(0xFF1E293B),
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    items: [2, 3, 4, 5, 6, 7, 8, 10]
                        .map((o) => DropdownMenuItem(
                              value: o,
                              child: Text('Order $o'),
                            ))
                        .toList(),
                    onChanged: (o) {
                      if (o != null) {
                        setState(() => _taylorOrder = o);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _computeTaylor,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6EF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                _isLoading ? 'Computing...' : 'Compute Taylor Series',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Text(
              'Simplify algebraic expressions. Enter an expression above and tap Compute.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _computeSimplify,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6EF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: Text(
                _isLoading ? 'Simplifying...' : 'Simplify Expression',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symbolic Math'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: 'Send to Graph',
            onPressed: _sendToGraph,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Result',
            onPressed: _copyResult,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_return_rounded),
            tooltip: 'Send to Calculator',
            onPressed: _sendToCalculator,
          ),
        ],
      ),
      body: Column(
        children: [
          // Expression input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _expressionController,
              onChanged: _detectVariables,
              decoration: InputDecoration(
                hintText: 'Enter expression (e.g. x^2 + 3*x + 2)',
                prefixIcon: const Icon(Icons.functions_rounded),
                suffixIcon: _expressionController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _expressionController.clear();
                          setState(() {
                            _detectedVariables = [];
                            _resultExpression =
                                'Enter an expression and compute';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
            ),
          ),
          // Detected variables
          if (_detectedVariables.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Variables: ',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  ..._detectedVariables.map((v) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(v,
                              style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )),
                ],
              ),
            ),
          // Result panel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _resultExpression,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: _resultExpression.startsWith('Error')
                          ? cs.error
                          : cs.onSurface,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Derivative'),
              Tab(text: 'Integral'),
              Tab(text: 'Limit'),
              Tab(text: 'Taylor'),
              Tab(text: 'Simplify'),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDerivativeTab(),
                _buildIntegralTab(),
                _buildLimitTab(),
                _buildTaylorTab(),
                _buildSimplifyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
