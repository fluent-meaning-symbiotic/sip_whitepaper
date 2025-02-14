import 'package:meta/meta.dart';

/// A semantic token category that groups related tokens.
@immutable
class SemanticTokenCategory {
  final String name;
  final String description;
  final Map<String, dynamic> tokens;

  const SemanticTokenCategory({
    required this.name,
    required this.description,
    required this.tokens,
  });

  bool hasToken(String name) => tokens.containsKey(name);
  dynamic getToken(String name) => tokens[name];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticTokenCategory &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => name.hashCode ^ description.hashCode;
}

/// Registry for managing semantic tokens across the application.
class SemanticTokenRegistry {
  final Map<String, SemanticTokenCategory> _categories = {};

  /// Registers a new token category.
  void registerCategory(SemanticTokenCategory category) {
    _categories[category.name] = category;
  }

  /// Gets a token category by name.
  SemanticTokenCategory? getCategory(String name) => _categories[name];

  /// Checks if a category exists.
  bool hasCategory(String name) => _categories.containsKey(name);

  /// Gets a token value from a category.
  dynamic getToken(String category, String name) {
    return _categories[category]?.getToken(name);
  }

  /// Checks if a token exists in a category.
  bool hasToken(String category, String name) {
    return _categories[category]?.hasToken(name) ?? false;
  }

  /// Gets all category names.
  Set<String> get categories => _categories.keys.toSet();

  /// Gets all tokens in a category.
  Map<String, dynamic>? getTokens(String category) =>
      _categories[category]?.tokens;
}

/// Default semantic token categories for the application.
class DefaultSemanticTokens {
  static const colors = SemanticTokenCategory(
    name: 'colors',
    description: 'Color tokens for the application',
    tokens: {
      'primary': '#007AFF',
      'secondary': '#5856D6',
      'success': '#34C759',
      'warning': '#FF9500',
      'error': '#FF3B30',
      'background': '#FFFFFF',
      'surface': '#F2F2F7',
      'text': '#000000',
    },
  );

  static const spacing = SemanticTokenCategory(
    name: 'spacing',
    description: 'Spacing tokens for layout',
    tokens: {
      'xxsmall': 2,
      'xsmall': 4,
      'small': 8,
      'medium': 16,
      'large': 24,
      'xlarge': 32,
      'xxlarge': 48,
    },
  );

  static const fontSize = SemanticTokenCategory(
    name: 'fontSize',
    description: 'Font size tokens for typography',
    tokens: {
      'caption': 12,
      'body': 14,
      'title': 16,
      'headline': 20,
      'display': 24,
    },
  );

  static const radius = SemanticTokenCategory(
    name: 'radius',
    description: 'Border radius tokens for components',
    tokens: {
      'none': 0,
      'small': 4,
      'medium': 8,
      'large': 12,
      'circular': 9999,
    },
  );

  static const animation = SemanticTokenCategory(
    name: 'animation',
    description: 'Animation duration tokens',
    tokens: {
      'fast': 150,
      'normal': 250,
      'slow': 350,
    },
  );

  /// Creates a new registry with default tokens.
  static SemanticTokenRegistry createDefaultRegistry() {
    final registry = SemanticTokenRegistry()
      ..registerCategory(colors)
      ..registerCategory(spacing)
      ..registerCategory(fontSize)
      ..registerCategory(radius)
      ..registerCategory(animation);
    return registry;
  }
}
