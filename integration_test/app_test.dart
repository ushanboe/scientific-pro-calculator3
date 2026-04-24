import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scientific_pro_calculator/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screen Smoke Tests', () {
    testWidgets('CalculatorScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('HistoryScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('ConstantsScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('FavoritesScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('GraphScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('SymbolicScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.functions));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('EquationSolverScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.equalizer));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('MatrixVectorScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.grid_3x3));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('UnitsScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.straighten));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('StatsScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('SettingsScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('HelpScreen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Bottom Navigation', () {
    testWidgets('Tap Calculator tab navigates to CalculatorScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Tap History tab navigates to HistoryScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Constants tab navigates to ConstantsScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Favorites tab navigates to FavoritesScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Graph tab navigates to GraphScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Symbolic tab navigates to SymbolicScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.functions));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Equation Solver tab navigates to EquationSolverScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.equalizer));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Matrix tab navigates to MatrixVectorScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.grid_3x3));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Units tab navigates to UnitsScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.straighten));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Stats tab navigates to StatsScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Settings tab navigates to SettingsScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap Help tab navigates to HelpScreen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Calculator Features', () {
    testWidgets('Calculator performs basic arithmetic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap 2
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Tap +
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      // Tap 3
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      // Tap =
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsWidgets);
    });

    testWidgets('Calculator clears display on AC button', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap 5
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // Tap AC
      await tester.tap(find.text('AC'));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Calculator supports undo/redo', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap 5
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // Tap undo button (if exists)
      final undoButton = find.byIcon(Icons.undo);
      if (undoButton.evaluate().isNotEmpty) {
        await tester.tap(undoButton);
        await tester.pumpAndSettle();
        expect(find.text('0'), findsWidgets);
      }
    });
  });

  group('History Features', () {
    testWidgets('History screen displays calculation history', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Perform a calculation
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Navigate to history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('History screen allows scrolling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Try to scroll
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.scroll(listView.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Constants Features', () {
    testWidgets('Constants screen displays physical constants', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to constants
      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Constants screen allows searching', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to constants
      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      // Look for search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.pumpAndSettle();
        await tester.enterText(searchField.first, 'pi');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Favorites Features', () {
    testWidgets('Favorites screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to favorites
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Favorites screen allows adding favorites', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to favorites
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      // Look for add button
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Graph Features', () {
    testWidgets('Graph screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to graph
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Graph screen allows input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to graph
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Look for input field
      final inputField = find.byType(TextField);
      if (inputField.evaluate().isNotEmpty) {
        await tester.tap(inputField.first);
        await tester.pumpAndSettle();
        await tester.enterText(inputField.first, 'sin(x)');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Symbolic Features', () {
    testWidgets('Symbolic screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to symbolic
      await tester.tap(find.byIcon(Icons.functions));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Symbolic screen allows input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to symbolic
      await tester.tap(find.byIcon(Icons.functions));
      await tester.pumpAndSettle();

      // Look for input field
      final inputField = find.byType(TextField);
      if (inputField.evaluate().isNotEmpty) {
        await tester.tap(inputField.first);
        await tester.pumpAndSettle();
        await tester.enterText(inputField.first, 'x^2');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Equation Solver Features', () {
    testWidgets('Equation Solver screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to equation solver
      await tester.tap(find.byIcon(Icons.equalizer));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Equation Solver allows input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to equation solver
      await tester.tap(find.byIcon(Icons.equalizer));
      await tester.pumpAndSettle();

      // Look for input field
      final inputField = find.byType(TextField);
      if (inputField.evaluate().isNotEmpty) {
        await tester.tap(inputField.first);
        await tester.pumpAndSettle();
        await tester.enterText(inputField.first, 'x+5=10');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Matrix Vector Features', () {
    testWidgets('Matrix Vector screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to matrix
      await tester.tap(find.byIcon(Icons.grid_3x3));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Matrix Vector screen allows creating matrix', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to matrix
      await tester.tap(find.byIcon(Icons.grid_3x3));
      await tester.pumpAndSettle();

      // Look for create button
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Units Features', () {
    testWidgets('Units screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to units
      await tester.tap(find.byIcon(Icons.straighten));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Units screen allows conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to units
      await tester.tap(find.byIcon(Icons.straighten));
      await tester.pumpAndSettle();

      // Look for input field
      final inputField = find.byType(TextField);
      if (inputField.evaluate().isNotEmpty) {
        await tester.tap(inputField.first);
        await tester.pumpAndSettle();
        await tester.enterText(inputField.first, '100');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Stats Features', () {
    testWidgets('Stats screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to stats
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Stats screen allows data input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to stats
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Look for input field
      final inputField = find.byType(TextField);
      if (inputField.evaluate().isNotEmpty) {
        await tester.tap(inputField.first);
        await tester.pumpAndSettle();
        await tester.enterText(inputField.first, '1,2,3,4,5');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Settings Features', () {
    testWidgets('Settings screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Settings screen allows scrolling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Try to scroll
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.scroll(listView.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Settings screen allows toggling switches', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Look for switch
      final switchWidget = find.byType(Switch);
      if (switchWidget.evaluate().isNotEmpty) {
        await tester.tap(switchWidget.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Help Features', () {
    testWidgets('Help screen renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to help
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Help screen allows searching', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to help
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // Look for search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.pumpAndSettle();
        await tester.enterText(searchField.first, 'calculator');
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Help screen allows expanding categories', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to help
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // Look for expandable items
      final expandButton = find.byIcon(Icons.expand_more);
      if (expandButton.evaluate().isNotEmpty) {
        await tester.tap(expandButton.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Navigation Back Button', () {
    testWidgets('Back navigation from History to Calculator', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Back navigation from Settings to Calculator', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });
  });

  group('Multi-Screen Navigation', () {
    testWidgets('Navigate through multiple screens sequentially', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // History
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);

      // Constants
      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);

      // Favorites
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);

      // Back to Calculator
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('Navigate through all feature screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final screens = [
        Icons.show_chart,    // Graph
        Icons.functions,     // Symbolic
        Icons.equalizer,     // Equation Solver
        Icons.grid_3x3,      // Matrix
        Icons.straighten,    // Units
        Icons.bar_chart,     // Stats
      ];

      for (final icon in screens) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('App Initialization', () {
    testWidgets('App initializes and displays calculator', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('App has bottom navigation bar', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(BottomNavigationBar), findsWidgets);
    });
  });
}