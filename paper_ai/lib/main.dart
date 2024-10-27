import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_ai/paper_ai.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PaperAI(),
    ),
  );
}
