import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/providers/symbolic_math_service_provider.dart';

enum _SolverMode { single, system }

class EquationSolverScreen extends ConsumerStatefulWidget {
  const EquationSolverScreen({super.key});

  @override
  ConsumerState<EquationSolverScreen> createState() =>
      _EquationSolverScreenState();
}

class _EquationSolverScreenState extends ConsumerState<EquationSolverScreen>
    with SingleTickerProviderStateMixin {
  _SolverMode _mode = _SolverMode.single;

  final TextEditingController _equationController = TextEditingController();
  final TextEditingController _variableController =
      TextEditingController(text: 'x');
  final FocusNode _equationFocus = FocusNode();

  final List<TextEditingController> _systemControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _showComplex = false;
  bool _isLoading = false;
  String? _error;
  List<_SolutionResult> _solutions = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _mode = _tabController.index == 0
              ? _SolverMode.single
              : _SolverMode.system;
          _solutions = [];
          _error = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _equationController.dispose();
    _variableController.dispose();
    _equationFocus.dispose();
    for (final c in _systemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSystemEquation() {
    if (_systemControllers.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 6 equations supported',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF293548),
        ),
      );
      return;
    }
    setState(() {
      _systemControllers.add(TextEditingController());
      _solutions = [];
      _error = null;
    });
  }

  void _removeSystemEquation(int index) {
    if (_systemControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 2 equations required',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF293548),
        ),
      );
      return;
    }
    setState(() {
      _systemControllers[index].dispose();
      _systemControllers.removeAt(index);
      _solutions = [];
      _error = null;
    });
  }

  /// Extract variable names from a list of equations.
  List<String> _extractVariables(List<String> equations) {
    final mathFunctions = {
      'sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt',
      'abs', 'pi', 'e', 'inf', 'i',
    };
    final found = <String>{};
    final variablePattern = RegExp(r'\b([a-zA-Z])\b');
    for (final eq in equations) {
      for (final match in variablePattern.allMatches(eq)) {
        final v = match.group(1)!;
        if (!mathFunctions.contains(v.toLowerCase())) {
          found.add(v);
        }
      }
    }
    final sorted = found.toList()..sort();
    return sorted;
  }

  Future<void> _solve() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
      _solutions = [];
    });

    try {
      final service = ref.read(symbolicMathServiceProvider);

      if (_mode == _SolverMode.single) {
        final equation = _equationController.text.trim();
        final variable = _variableController.text.trim();

        if (equation.isEmpty) {
          setState(() {
            _error = 'Please enter an equation to solve.';
            _isLoading = false;
          });
          return;
        }
        if (variable.isEmpty) {
          setState(() {
            _error = 'Please specify the variable to solve for.';
            _isLoading = false;
          });
          return;
        }

        final results = await service.solveEquation(
          equation,
          variable,
        );

        setState(() {
          _solutions = results.map((r) {
            if (r is String) {
              return _SolutionResult(
                symbolic: r,
                numeric: null,
                isComplex: r.contains('i') || r.contains('√-'),
                variable: variable,
              );
            }
            try {
              return _SolutionResult(
                symbolic: (r as dynamic).symbolic as String? ?? r.toString(),
                numeric: (r as dynamic).numeric as String?,
                isComplex: (r as dynamic).isComplex as bool? ?? false,
                variable: variable,
              );
            } catch (_) {
              return _SolutionResult(
                symbolic: r.toString(),
                numeric: null,
                isComplex: false,
                variable: variable,
              );
            }
          }).toList();
          if (_solutions.isEmpty) {
            _error = 'No solutions found for the given equation.';
          }
          _isLoading = false;
        });
      } else {
        final equations = _systemControllers
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (equations.length < 2) {
          setState(() {
            _error = 'Please enter at least 2 equations.';
            _isLoading = false;
          });
          return;
        }

        // Extract variables from the equations
        final variables = _extractVariables(equations);
        if (variables.isEmpty) {
          setState(() {
            _error = 'No variables detected in the equations.';
            _isLoading = false;
          });
          return;
        }

        // solveSystem takes (equations, variables) — both required
        final results = await service.solveSystem(equations, variables);

        setState(() {
          _solutions = results.entries.map((entry) {
            return _SolutionResult(
              symbolic: '${entry.key} = ${entry.value}',
              numeric: null,
              isComplex: entry.value.contains('i'),
              variable: entry.key,
            );
          }).toList();
          if (_solutions.isEmpty) {
            _error = 'No solutions found for the given system.';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Solver error: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _equationController.clear();
      _variableController.text = 'x';
      for (final c in _systemControllers) {
        c.clear();
      }
      _solutions = [];
      _error = null;
    });
  }

  void _sendToCalculator(String value) {
    Navigator.of(context).pop(value);
  }

  void _insertSymbol(String symbol) {
    final controller = _mode == _SolverMode.single
        ? _equationController
        : (_systemControllers.isNotEmpty ? _systemControllers.last : null);
    if (controller == null) return;

    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, symbol);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + symbol.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Solver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all',
            onPressed: _clearAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Single Variable'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSingleVariableTab(colorScheme, isDark),
          _buildSystemTab(colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildSingleVariableTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoBanner(
            'Enter an equation to solve for a variable. Use "=" to separate sides, or enter an expression equal to zero.',
            isDark,
          ),
          const SizedBox(height: 16),
          _buildQuickSymbolBar(),
          const SizedBox(height: 12),
          TextField(
            controller: _equationController,
            focusNode: _equationFocus,
            decoration: InputDecoration(
              labelText: 'Equation',
              hintText: 'e.g. x^2 - 4 = 0  or  2x + 3 = 7',
              prefixIcon:
                  const Icon(Icons.functions_rounded, size: 20),
              suffixIcon: _equationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _equationController.clear();
                          _solutions = [];
                          _error = null;
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _variableController,
                  decoration: const InputDecoration(
                    labelText: 'Variable',
                    hintText: 'x',
                    prefixIcon: Icon(Icons.abc_rounded, size: 20),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                  ),
                  maxLength: 4,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _solve(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildComplexToggle(colorScheme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSolveButton(),
          const SizedBox(height: 16),
          if (_isLoading) _buildLoadingIndicator(),
          if (_error != null) _buildErrorCard(_error!),
          if (_solutions.isNotEmpty) ...[
            _buildSolutionsHeader(_solutions.length),
            const SizedBox(height: 8),
            ..._solutions.map((s) => _buildSolutionCard(s)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSystemTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoBanner(
            'Enter a system of equations. Variables are detected automatically. Each equation on a separate line.',
            isDark,
          ),
          const SizedBox(height: 16),
          _buildQuickSymbolBar(),
          const SizedBox(height: 12),
          ...List.generate(_systemControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _systemControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Equation ${i + 1}',
                        hintText: i == 0
                            ? 'e.g. x + y = 5'
                            : i == 1
                                ? 'e.g. x - y = 1'
                                : 'e.g. 2x + 3y = 10',
                        prefixIcon: Container(
                          width: 36,
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {
                        _solutions = [];
                        _error = null;
                      }),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                      ),
                      textInputAction: i < _systemControllers.length - 1
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: i == _systemControllers.length - 1
                          ? (_) => _solve()
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: colorScheme.error,
                      size: 22,
                    ),
                    onPressed: () => _removeSystemEquation(i),
                    tooltip: 'Remove equation',
                  ),
                ],
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addSystemEquation,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Equation'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          _buildComplexToggle(colorScheme),
          const SizedBox(height: 16),
          _buildSolveButton(),
          const SizedBox(height: 16),
          if (_isLoading) _buildLoadingIndicator(),
          if (_error != null) _buildErrorCard(_error!),
          if (_solutions.isNotEmpty) ...[
            _buildSolutionsHeader(_solutions.length),
            const SizedBox(height: 8),
            ..._solutions.map((s) => _buildSolutionCard(s)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4C6EF5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4C6EF5).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: Color(0xFF4C6EF5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSymbolBar() {
    const symbols = [
      '=', '^', '√', 'π', 'i', '(', ')', '|x|', 'sin', 'cos', 'tan', 'log', 'ln',
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: symbols.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _insertSymbol(symbols[index] == '|x|' ? 'abs(' : symbols[index]),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF293548),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Text(
                symbols[index],
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontFamily: 'Roboto Mono',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplexToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Switch(
          value: _showComplex,
          onChanged: (v) => setState(() => _showComplex = v),
          activeColor: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        const Text(
          'Include complex solutions',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSolveButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _solve,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.calculate_rounded, size: 20),
        label: Text(
          _isLoading ? 'Solving...' : 'Solve',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C6EF5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF4C6EF5)),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9B1C1C).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsHeader(int count) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF51CF66), size: 18),
        const SizedBox(width: 8),
        Text(
          '$count solution${count == 1 ? '' : 's'} found',
          style: const TextStyle(
            color: Color(0xFF51CF66),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionCard(_SolutionResult solution) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: solution.isComplex
              ? const Color(0xFFCC5DE8).withValues(alpha: 0.4)
              : const Color(0xFF4C6EF5).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: solution.isComplex
                      ? const Color(0xFFCC5DE8).withValues(alpha: 0.15)
                      : const Color(0xFF4C6EF5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  solution.isComplex ? 'Complex' : 'Real',
                  style: TextStyle(
                    fontSize: 10,
                    color: solution.isComplex
                        ? const Color(0xFFCC5DE8)
                        : const Color(0xFF4C6EF5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (solution.variable.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  solution.variable,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: solution.symbolic));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, size: 16),
                onPressed: () => _sendToCalculator(solution.symbolic),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: const Color(0xFF4C6EF5),
                tooltip: 'Send to calculator',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            solution.symbolic,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFE2E8F0),
              fontFamily: 'Roboto Mono',
              fontWeight: FontWeight.w500,
            ),
          ),
          if (solution.numeric != null) ...[
            const SizedBox(height: 4),
            Text(
              '≈ ${solution.numeric}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontFamily: 'Roboto Mono',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Solution Result Model ─────────────────────────────────────────────────────

class _SolutionResult {
  final String symbolic;
  final String? numeric;
  final bool isComplex;
  final String variable;

  const _SolutionResult({
    required this.symbolic,
    this.numeric,
    required this.isComplex,
    required this.variable,
  });
}
