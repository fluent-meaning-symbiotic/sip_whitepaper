import 'package:vector_math/vector_math_64.dart';

import 'semantic_intent_types.dart';

class LoadedIntentData extends SemanticIntentData {
  final String path;
  final Vector3 position;

  const LoadedIntentData({
    required this.path,
    required this.position,
    required super.meaning,
    super.description,
    super.file,
  });
}
