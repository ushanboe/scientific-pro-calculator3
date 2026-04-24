// Step 1: Inventory
// This file DEFINES: RpnStackService class with methods:
//   - push(String value) → void
//   - pop() → String? (returns top value and removes it)
//   - swap() → void (swaps top two elements)
//   - drop() → void (removes top element)
//   - clear() → void (clears entire stack)
//   - peek() → String? (returns top value without removing)
//   - getStack() → List<String> (returns unmodifiable copy)
//   - isEmpty → bool getter
//   - size → int getter
// Internal state: List<String> _stack
// No imports from other project files needed — pure service, no models/providers
//
// Step 2: Connections
// Used by: lib/providers/rpn_stack_provider.dart (RpnStackNotifier delegates to this service)
// No navigation, no database, no SharedPreferences
// Pure in-memory stack operations
//
// Step 3: User Journey Trace
// CalculatorScreen in RPN mode → user enters number → presses Enter → rpnStackProvider.push(value)
// RpnStackNotifier.push() calls RpnStackService.instance.push(value) → stack grows
// User presses operator (+) → rpnStackProvider.pop() twice → ArithmeticService.evaluate() → push result
// User presses SWAP → rpnStackProvider.swap() → top two elements exchange positions
// User presses DROP → rpnStackProvider.drop() → top element removed
// User presses CLR → rpnStackProvider.clear() → entire stack cleared
// CalculatorScreen watches rpnStackProvider → displays current stack state
//
// Step 4: Layout Sanity
// Pure service — no widgets, no layout concerns
// Singleton pattern for consistent state access
// Stack is List<String> with index 0 = bottom, last index = top
// All operations are O(1) or O(n) as appropriate
// Thread safety not required (single-threaded Flutter UI)

class RpnStackService {
  static final RpnStackService instance = RpnStackService._();
  RpnStackService._();

  final List<String> _stack = [];

  /// Push a value onto the top of the stack.
  void push(String value) {
    _stack.add(value);
  }

  /// Pop and return the top value from the stack.
  /// Returns null if the stack is empty.
  String? pop() {
    if (_stack.isEmpty) return null;
    return _stack.removeLast();
  }

  /// Swap the top two elements of the stack.
  /// Does nothing if fewer than two elements exist.
  void swap() {
    if (_stack.length < 2) return;
    final top = _stack[_stack.length - 1];
    final second = _stack[_stack.length - 2];
    _stack[_stack.length - 1] = second;
    _stack[_stack.length - 2] = top;
  }

  /// Remove the top element without returning it.
  /// Does nothing if the stack is empty.
  void drop() {
    if (_stack.isEmpty) return;
    _stack.removeLast();
  }

  /// Clear all elements from the stack.
  void clear() {
    _stack.clear();
  }

  /// Return the top value without removing it.
  /// Returns null if the stack is empty.
  String? peek() {
    if (_stack.isEmpty) return null;
    return _stack.last;
  }

  /// Return an unmodifiable snapshot of the current stack.
  /// Index 0 is the bottom of the stack, last index is the top.
  List<String> getStack() {
    return List<String>.unmodifiable(_stack);
  }

  /// Whether the stack has no elements.
  bool get isEmpty => _stack.isEmpty;

  /// Number of elements currently on the stack.
  int get size => _stack.length;

  /// Replace the entire stack contents with the provided list.
  /// Used when restoring state from an UndoRedoEntry.
  void replaceStack(List<String> values) {
    _stack.clear();
    _stack.addAll(values);
  }
}