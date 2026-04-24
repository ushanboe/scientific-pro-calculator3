// Step 1: Inventory
// This file DEFINES: UndoRedoEntry class with fields:
//   - expression (String, non-nullable) — Expression state
//   - cursorPosition (int, non-nullable) — Cursor position in expression
//   - rpnStack (List<String>, non-nullable) — RPN stack state (if in RPN mode)
//   - sequenceIndex (int, non-nullable) — Index in undo/redo sequence
// Methods: none specified in spec
// In-memory only — no persistence needed (no toMap/fromMap/toJson/fromJson)
// No imports from other project files needed — pure in-memory data model
//
// Step 2: Connections
// Used by: calculator_screen.dart (undo/redo stack management)
// Used by: rpn_stack_service.dart or rpn_stack_provider.dart (RPN state tracking)
// No navigation, no services, no providers needed here
//
// Step 3: User Journey Trace
// CalculatorScreen user types expression → UndoRedoEntry created with current expression,
//   cursorPosition, rpnStack snapshot, and sequenceIndex
// Undo → pop from undo stack → restore expression/cursor/rpnStack from entry
// Redo → pop from redo stack → restore expression/cursor/rpnStack from entry
// sequenceIndex tracks position in the undo/redo sequence for ordering
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// copyWith follows the same pattern as all other models in this project
// operator== and hashCode based on sequenceIndex (unique per entry in the sequence)
// List<String> rpnStack — immutable copy should be stored to avoid aliasing issues

class UndoRedoEntry {
  final String expression;
  final int cursorPosition;
  final List<String> rpnStack;
  final int sequenceIndex;

  const UndoRedoEntry({
    required this.expression,
    required this.cursorPosition,
    required this.rpnStack,
    required this.sequenceIndex,
  });

  UndoRedoEntry copyWith({
    String? expression,
    int? cursorPosition,
    List<String>? rpnStack,
    int? sequenceIndex,
  }) {
    return UndoRedoEntry(
      expression: expression ?? this.expression,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      rpnStack: rpnStack ?? List<String>.unmodifiable(this.rpnStack),
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    );
  }

  @override
  String toString() {
    return 'UndoRedoEntry(expression: $expression, cursorPosition: $cursorPosition, '
        'rpnStack: $rpnStack, sequenceIndex: $sequenceIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UndoRedoEntry && other.sequenceIndex == sequenceIndex;
  }

  @override
  int get hashCode => sequenceIndex.hashCode;
}