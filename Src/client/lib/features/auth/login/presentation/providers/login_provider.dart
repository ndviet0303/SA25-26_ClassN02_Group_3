// controllers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usernameControllerProvider =
Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final passwordControllerProvider =
Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final userFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final n = FocusNode();
  ref.onDispose(n.dispose);
  return n;
});

final passFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final n = FocusNode();
  ref.onDispose(n.dispose);
  return n;
});
