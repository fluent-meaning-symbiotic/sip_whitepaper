import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../types/semantic_intent_types.dart';

class SemanticIntentProvider extends StatelessWidget {
  final Widget child;

  const SemanticIntentProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SemanticIntentRegistry(),
      child: child,
    );
  }
}
