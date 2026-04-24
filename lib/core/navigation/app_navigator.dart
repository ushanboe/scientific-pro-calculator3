import 'package:flutter/material.dart';
import 'package:scientific_pro_calculator/features/calculator/screens/calculator_screen.dart';
import 'package:scientific_pro_calculator/features/graph/screens/graph_screen.dart';
import 'package:scientific_pro_calculator/features/equation_solver/screens/equation_solver_screen.dart';
import 'package:scientific_pro_calculator/features/matrix_vector/screens/matrix_vector_screen.dart';
import 'package:scientific_pro_calculator/features/units/screens/units_screen.dart';
import 'package:scientific_pro_calculator/features/stats/screens/stats_screen.dart';
import 'package:scientific_pro_calculator/features/settings/screens/settings_screen.dart';
import 'package:scientific_pro_calculator/features/help/screens/help_screen.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Calculator',
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate_rounded,
    ),
    _NavItem(
      label: 'Graphs',
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart_rounded,
    ),
    _NavItem(
      label: 'Equations',
      icon: Icons.functions_outlined,
      selectedIcon: Icons.functions_rounded,
    ),
    _NavItem(
      label: 'Matrices',
      icon: Icons.grid_on_outlined,
      selectedIcon: Icons.grid_on_rounded,
    ),
    _NavItem(
      label: 'Units',
      icon: Icons.straighten_outlined,
      selectedIcon: Icons.straighten_rounded,
    ),
    _NavItem(
      label: 'Stats',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
    _NavItem(
      label: 'Help',
      icon: Icons.help_outline_rounded,
      selectedIcon: Icons.help_rounded,
    ),
  ];

  final List<Widget> _screens = const [
    CalculatorScreen(),
    GraphScreen(),
    EquationSolverScreen(),
    MatrixVectorScreen(),
    UnitsScreen(),
    StatsScreen(),
    SettingsScreen(),
    HelpScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
            tooltip: item.label,
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}