import 'package:flutter/material.dart';

/// After [FormState.validate], scrolls to the first [FormFieldState] in
/// [fieldKeysInOrder] that has an error and focuses it.
Future<void> scrollToFirstInvalidField(
  GlobalKey<FormState> formKey, {
  required List<GlobalKey<FormFieldState<String>>> fieldKeysInOrder,
  List<FocusNode>? focusNodesInOrder,
}) async {
  final form = formKey.currentState;
  if (form == null) return;
  final valid = form.validate();
  if (valid) return;

  for (var i = 0; i < fieldKeysInOrder.length; i++) {
    final key = fieldKeysInOrder[i];
    final state = key.currentState;
    if (state == null || !state.hasError) continue;
    final ctx = state.context;
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.15,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    if (focusNodesInOrder != null && i < focusNodesInOrder.length) {
      focusNodesInOrder[i].requestFocus();
    }
    break;
  }
}
