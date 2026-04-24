import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/rpn_stack_service.dart';

class RpnStackNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return const [];
  }

  /// Push a value onto the top of the RPN stack.
  void push(String value) {
    RpnStackService.instance.push(value);
    state = RpnStackService.instance.getStack();
  }

  /// Pop and return the top value from the stack.
  /// Returns null if the stack is empty.
  String? pop() {
    final value = RpnStackService.instance.pop();
    state = RpnStackService.instance.getStack();
    return value;
  }

  /// Swap the top two elements of the stack.
  void swap() {
    RpnStackService.instance.swap();
    state = RpnStackService.instance.getStack();
  }

  /// Remove the top element without returning it.
  void drop() {
    RpnStackService.instance.drop();
    state = RpnStackService.instance.getStack();
  }

  /// Clear all elements from the stack.
  void clear() {
    RpnStackService.instance.clear();
    state = RpnStackService.instance.getStack();
  }

  /// Return the top value without removing it.
  String? peek() {
    return RpnStackService.instance.peek();
  }

  /// Replace the entire stack with the provided values.
  void replaceStack(List<String> values) {
    RpnStackService.instance.replaceStack(values);
    state = RpnStackService.instance.getStack();
  }
}

final rpnStackProvider =
    NotifierProvider<RpnStackNotifier, List<String>>(
  RpnStackNotifier.new,
);
