import 'package:flutter/foundation.dart';
import 'package:semantic_intent_graph/model/semantic_intent_file.dart';

/// Unique identifier for semantic intents
extension type const SemanticIntentType(String value) {}

/// Base class for all semantic intent data
abstract class SemanticIntentData {
  final String meaning;
  final String? description;
  final Map<String, dynamic> properties;
  final SemanticIntentFile? file;

  const SemanticIntentData({
    required this.meaning,
    this.file,
    this.description,
    this.properties = const {},
  });
}

/// Registry for storing and managing semantic intents
class SemanticIntentRegistry extends ChangeNotifier {
  final Map<SemanticIntentType, SemanticIntentData> _intents = {};

  void registerIntent(SemanticIntentType type, SemanticIntentData data) {
    _intents[type] = data;
    notifyListeners();
  }

  SemanticIntentData? getIntent(SemanticIntentType type) => _intents[type];

  void removeIntent(SemanticIntentType type) {
    _intents.remove(type);
    notifyListeners();
  }

  List<SemanticIntentType> get allIntentTypes => _intents.keys.toList();

  // Query methods
  List<SemanticIntentType> findIntentsByMeaning(String meaningPattern) {
    return _intents.entries
        .where((entry) => entry.value.meaning.contains(meaningPattern))
        .map((entry) => entry.key)
        .toList();
  }

  // Validation
  bool validateIntent(SemanticIntentType type, SemanticIntentData data) {
    // Add validation logic here
    return true;
  }
}
