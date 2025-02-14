# Semantic Intent Graph - Flutter/Flame MVP - Scratchpad

**Overall Goal:** Create a language-agnostic, meaning-driven development system based on a Semantic Intent Graph, implemented using Flutter and Flame. This scratchpad outlines the MVP features, implementation steps, and considerations for both AI agents and human developers.

**MVP Goal:** Develop a Semantic Intent Graph implementation that allows for the creation of basic tooling to support further meaning-driven development.

**Target Audience:** AI Agents and Human Developers (collaborative development)

**Technology:** Flutter, Flame (Dart)

## 1. Intent Definition (Data Format - YAML)

- **File Format:** YAML (`.yaml`)
- **Structure:** (Aligned with SIP Architectural Principles)

  ```yaml
  semantic_intent:
    version: 1 # Version of the Semantic Intent Paradigm
    name: intent_unique_id_1 # Unique Intent Name (e.g., MoveCircleCommandIntent)
    type: SemanticCommandIntent # SemanticCommandIntent, SemanticUiIntent, SemanticAssetIntent, SemanticTypeIntent, SemanticThemeTokensIntent, SemanticTestIntent
      meaning: "A concise description of the intent's purpose."
      description: "A more detailed description." # Optional
    semantic_properties: # Semantic properties specific to the Intent Type
      {semantic_property_name}:
        type: SemanticTypeIntent
        value: "SemanticTypeValue"
      {semantic_property_name}:
        type: SemanticTokenIntent
        value: "SemanticTokenValue"
    semantic_interactions: # For UI intents, maps UI events to Semantic Intents
      {semantic_interaction_name}:
        type: SemanticCommandIntent
        meaning: "How this intent is interacted with current intent."
    test_categories: # Test metadata
      style: ["functional", "golden"]
      priority: "high"
      meanings: ["visual_accuracy", "interaction_flow"]
    semantic_validations: # Validation rules
      - rule: {rule meaning}
      - rule: "position must be within screen bounds"
      - rule: "color must be from theme tokens"
    output_artifacts: # Generated artifacts
      code: ["lib/commands/update_position_command.dart"]
      tests: ["test/commands/update_position_command_test.dart"]
    llm_prompts:
      code_generation: "Generate Dart code for a command handler that updates pixel position..."
      test_generation: "Generate tests to verify position bounds and color token validity..."
    scratchpad_todo:
      - "Implement position bounds validation"
      - "Add color token verification"
  ```

- **TODO (AI/Human):**
  - [ ] Create validation rule schema
  - [ ] Create example files for each intent type

## 2. Graph Representation (In-Memory - Dart)

- **Data Structures:** (Implements SIP Architecture)

  ```dart
  // Core semantic types
  extension type const SemanticIntentId(String value) implements String {}
  extension type const SemanticRelationshipId(String value) implements String {}

  // Base semantic intent class
  abstract class SemanticIntent {
    final SemanticIntentId id;
    final String type;
    final String meaning;
    final String? description;
    final Map<String, SemanticPropertyValue> semanticProperties;
    final Map<String, SemanticInteraction> semanticInteractions;
    final List<String> testCategories;
    final List<String> semanticValidations;
    final List<SemanticRelationship> relationships;
    final Map<String, List<String>> outputArtifacts;
    final Map<String, String> llmPrompts;
    final List<String> scratchpadTodo;

    const SemanticIntent({
      required this.id,
      required this.type,
      required this.meaning,
      this.description,
      required this.semanticProperties,
      required this.semanticInteractions,
      required this.testCategories,
      required this.semanticValidations,
      required this.relationships,
      required this.outputArtifacts,
      required this.llmPrompts,
      required this.scratchpadTodo,
    });

    // Semantic validation
    List<String> validate();

    // Change propagation
    void propagateChange(String changeType, dynamic value);
  }

  // Semantic property system
  sealed class SemanticPropertyValue {
    final String type;
    final dynamic value;

    const SemanticPropertyValue({required this.type, required this.value});

    // Validation against semantic rules
    List<String> validate();
  }

  class SemanticTypeValue extends SemanticPropertyValue {
    const SemanticTypeValue(String type, dynamic value) : super(type: type, value: value);

    @override
    List<String> validate() {
      // Implement type-specific validation
      return [];
    }
  }

  class SemanticTokenValue extends SemanticPropertyValue {
    const SemanticTokenValue(String type, String token) : super(type: type, value: token);

    @override
    List<String> validate() {
      // Validate token exists in theme
      return [];
    }
  }

  // Semantic interaction system
  class SemanticInteraction {
    final String type;
    final String targetIntentId;
    final Map<String, dynamic> parameters;

    const SemanticInteraction({
      required this.type,
      required this.targetIntentId,
      required this.parameters,
    });
  }

  // Semantic relationship system
  class SemanticRelationship {
    final String type;
    final IntentId targetIntentId;
    final String direction;
    final Map<String, dynamic> metadata;

    const SemanticRelationship({
      required this.type,
      required this.targetIntentId,
      required this.direction,
      this.metadata = const {},
    });
  }

  // Semantic Intent Graph with change propagation
  class SemanticIntentGraph {
    final Map<String, SemanticIntent> _intents = {};
    final List<void Function(String intentId, String changeType, dynamic value)> _changeListeners = [];

    void addIntent(SemanticIntent intent) {
      _intents[intent.id.value] = intent;
      _validateGraph();
    }

    SemanticIntent? getIntent(IntentId id) {
      return _intents[id.value];
    }

    void addRelationship(IntentId sourceId, SemanticRelationship relationship) {
      final intent = _intents[sourceId.value];
      if (intent != null) {
        intent.relationships.add(relationship);
        _validateGraph();
      }
    }

    // Semantic validation
    List<String> _validateGraph() {
      final errors = <String>[];
      for (final intent in _intents.values) {
        errors.addAll(intent.validate());
      }
      return errors;
    }

    // Change propagation
    void addChangeListener(void Function(String intentId, String changeType, dynamic value) listener) {
      _changeListeners.add(listener);
    }

    void propagateChange(String sourceIntentId, String changeType, dynamic value) {
      final sourceIntent = _intents[sourceIntentId];
      if (sourceIntent == null) return;

      // Notify listeners
      for (final listener in _changeListeners) {
        listener(sourceIntentId, changeType, value);
      }

      // Propagate to related intents
      for (final relationship in sourceIntent.relationships) {
        final targetIntent = _intents[relationship.targetIntentId.value];
        targetIntent?.propagateChange(changeType, value);
      }
    }
  }
  ```

- **TODO (AI/Human):**
  - [ ] Implement specific semantic intent types (CommandIntent, UIIntent, etc.)
  - [ ] Implement validation rules for each semantic type
  - [ ] Implement change propagation logic for different relationship types
  - [ ] Add comprehensive unit tests for validation and propagation

## 2.1 Semantic Validation System

- **Core Concepts:**
  - Validation Rules: Define constraints and requirements for semantic intents
  - Rule Types: Type validation, relationship validation, semantic consistency
  - Validation Context: Access to the full graph for complex validations

```dart
// Semantic validation system
abstract class SemanticValidationRule {
  final String name;
  final String description;

  const SemanticValidationRule({
    required this.name,
    required this.description,
  });

  List<String> validate(SemanticIntent intent, SemanticIntentGraph graph);
}

// Example validation rules
class TypeValidationRule extends SemanticValidationRule {
  final Set<String> allowedTypes;

  const TypeValidationRule({
    required super.name,
    required super.description,
    required this.allowedTypes,
  });

  @override
  List<String> validate(SemanticIntent intent, SemanticIntentGraph graph) {
    if (!allowedTypes.contains(intent.type)) {
      return ['Invalid type: ${intent.type}. Allowed types: ${allowedTypes.join(", ")}'];
    }
    return [];
  }
}

class RelationshipValidationRule extends SemanticValidationRule {
  final String sourceType;
  final String targetType;
  final String relationshipType;

  const RelationshipValidationRule({
    required super.name,
    required super.description,
    required this.sourceType,
    required this.targetType,
    required this.relationshipType,
  });

  @override
  List<String> validate(SemanticIntent intent, SemanticIntentGraph graph) {
    if (intent.type != sourceType) return [];

    final errors = <String>[];
    for (final relationship in intent.relationships) {
      if (relationship.type != relationshipType) continue;

      final targetIntent = graph.getIntent(relationship.targetIntentId);
      if (targetIntent == null) {
        errors.add('Missing target intent: ${relationship.targetIntentId}');
        continue;
      }

      if (targetIntent.type != targetType) {
        errors.add('Invalid target type: ${targetIntent.type}. Expected: $targetType');
      }
    }
    return errors;
  }
}

class SemanticConsistencyRule extends SemanticValidationRule {
  final bool Function(SemanticIntent intent, SemanticIntentGraph graph) checkConsistency;

  const SemanticConsistencyRule({
    required super.name,
    required super.description,
    required this.checkConsistency,
  });

  @override
  List<String> validate(SemanticIntent intent, SemanticIntentGraph graph) {
    return checkConsistency(intent, graph) ? [] : ['Semantic consistency check failed: $name'];
  }
}

// Validation registry
class SemanticValidationRegistry {
  final Map<String, List<SemanticValidationRule>> _rulesByType = {};
  final List<SemanticValidationRule> _globalRules = [];

  void addTypeRule(String intentType, SemanticValidationRule rule) {
    _rulesByType.putIfAbsent(intentType, () => []).add(rule);
  }

  void addGlobalRule(SemanticValidationRule rule) {
    _globalRules.add(rule);
  }

  List<String> validateIntent(SemanticIntent intent, SemanticIntentGraph graph) {
    final errors = <String>[];

    // Apply global rules
    for (final rule in _globalRules) {
      errors.addAll(rule.validate(intent, graph));
    }

    // Apply type-specific rules
    final typeRules = _rulesByType[intent.type] ?? [];
    for (final rule in typeRules) {
      errors.addAll(rule.validate(intent, graph));
    }

    return errors;
  }
}

// Example usage
final validationRegistry = SemanticValidationRegistry()
  ..addGlobalRule(
    TypeValidationRule(
      name: 'Valid Intent Types',
      description: 'Ensures intent type is one of the allowed types',
      allowedTypes: {
        'SemanticCommandIntent',
        'SemanticUiIntent',
        'SemanticAssetIntent',
        'SemanticTypeIntent',
        'SemanticThemeTokensIntent',
        'SemanticTestIntent',
      },
    ),
  )
  ..addTypeRule(
    'SemanticCommandIntent',
    RelationshipValidationRule(
      name: 'Command Handler Relationship',
      description: 'Commands must have a handler relationship',
      sourceType: 'SemanticCommandIntent',
      targetType: 'SemanticHandlerIntent',
      relationshipType: 'hasHandler',
    ),
  );
```

- **TODO (AI/Human):**
  - [ ] Implement core validation rules for each intent type
  - [ ] Add validation for semantic properties
  - [ ] Add validation for semantic interactions
  - [ ] Create test suite for validation system

## 2.2 Semantic Change Propagation System

- **Core Concepts:**
  - Change Types: Different types of semantic changes (property, relationship, validation)
  - Propagation Rules: How changes flow through the semantic graph
  - Change Listeners: Components that react to semantic changes

```dart
// Change types
enum SemanticChangeType {
  propertyUpdate,
  relationshipAdd,
  relationshipRemove,
  validationStateChange,
  intentStateChange,
}

// Change event
class SemanticChangeEvent {
  final String sourceIntentId;
  final SemanticChangeType type;
  final String? propertyName;
  final dynamic oldValue;
  final dynamic newValue;
  final Map<String, dynamic> metadata;

  const SemanticChangeEvent({
    required this.sourceIntentId,
    required this.type,
    this.propertyName,
    this.oldValue,
    this.newValue,
    this.metadata = const {},
  });
}

// Propagation rule
abstract class SemanticPropagationRule {
  final String name;
  final String description;

  const SemanticPropagationRule({
    required this.name,
    required this.description,
  });

  List<String> getAffectedIntentIds(
    SemanticChangeEvent event,
    SemanticIntent sourceIntent,
    SemanticIntentGraph graph,
  );

  void propagateChange(
    SemanticChangeEvent event,
    SemanticIntent targetIntent,
    SemanticIntentGraph graph,
  );
}

// Example propagation rules
class DependencyPropagationRule extends SemanticPropagationRule {
  const DependencyPropagationRule({
    required super.name,
    required super.description,
  });

  @override
  List<String> getAffectedIntentIds(
    SemanticChangeEvent event,
    SemanticIntent sourceIntent,
    SemanticIntentGraph graph,
  ) {
    return sourceIntent.relationships
        .where((r) => r.type == 'dependsOn' && r.direction == 'unidirectional')
        .map((r) => r.targetIntentId.value)
        .toList();
  }

  @override
  void propagateChange(
    SemanticChangeEvent event,
    SemanticIntent targetIntent,
    SemanticIntentGraph graph,
  ) {
    if (event.type == SemanticChangeType.propertyUpdate) {
      // Update dependent properties
      if (targetIntent.semanticProperties.containsKey(event.propertyName)) {
        graph.propagateChange(
          targetIntent.id.value,
          SemanticChangeType.propertyUpdate,
          event.newValue,
          propertyName: event.propertyName,
        );
      }
    }
  }
}

// Enhanced SemanticIntentGraph with propagation rules
  class SemanticIntentGraph {
  final Map<String, SemanticIntent> _intents = {};
  final List<SemanticPropagationRule> _propagationRules = [];
  final List<void Function(SemanticChangeEvent)> _changeListeners = [];

  void addPropagationRule(SemanticPropagationRule rule) {
    _propagationRules.add(rule);
  }

  void addChangeListener(void Function(SemanticChangeEvent) listener) {
    _changeListeners.add(listener);
  }

  void propagateChange(
    String sourceIntentId,
    SemanticChangeType type,
    dynamic value, {
    String? propertyName,
    Map<String, dynamic> metadata = const {},
  }) {
    final sourceIntent = _intents[sourceIntentId];
    if (sourceIntent == null) return;

    final event = SemanticChangeEvent(
      sourceIntentId: sourceIntentId,
      type: type,
      propertyName: propertyName,
      oldValue: propertyName != null ? sourceIntent.semanticProperties[propertyName]?.value : null,
      newValue: value,
      metadata: metadata,
    );

    // Notify listeners
    for (final listener in _changeListeners) {
      listener(event);
    }

    // Apply propagation rules
    for (final rule in _propagationRules) {
      final affectedIds = rule.getAffectedIntentIds(event, sourceIntent, this);
      for (final id in affectedIds) {
        final targetIntent = _intents[id];
        if (targetIntent != null) {
          rule.propagateChange(event, targetIntent, this);
        }
      }
    }
  }
}

// Example usage
final graph = SemanticIntentGraph()
  ..addPropagationRule(
    DependencyPropagationRule(
      name: 'Property Dependency Propagation',
      description: 'Propagates property changes to dependent intents',
    ),
  )
  ..addChangeListener((event) {
    print('Change detected: ${event.type} in intent ${event.sourceIntentId}');
    if (event.propertyName != null) {
      print('Property ${event.propertyName} changed from ${event.oldValue} to ${event.newValue}');
    }
  });
```

- **TODO (AI/Human):**
  - [ ] Implement specific propagation rules for each relationship type
  - [ ] Add change tracking and history
  - [ ] Implement undo/redo functionality
  - [ ] Create test suite for change propagation

## 2.3 Semantic Property System

- **Core Concepts:**
  - Semantic Types: Reusable data types with domain meaning
  - Semantic Tokens: Named semantic units for styling/configuration
  - Property Validation: Type-specific validation rules
  - Value Conversion: Type-safe conversion between semantic types

```dart
// Semantic type system
abstract class SemanticType {
  final String name;
  final String description;

  const SemanticType({
    required this.name,
    required this.description,
  });

  bool validate(dynamic value);
  dynamic convert(dynamic value);
}

// Example semantic types
class PixelPositionType extends SemanticType {
  const PixelPositionType()
      : super(
          name: 'PixelPositionType',
          description: 'Represents a position in pixel coordinates',
        );

  @override
  bool validate(dynamic value) {
    if (value is! Map<String, num>) return false;
    return value.containsKey('x') && value.containsKey('y');
  }

  @override
  Map<String, num> convert(dynamic value) {
    if (value is Map<String, num>) return value;
    throw FormatException('Cannot convert $value to PixelPositionType');
  }
}

// Semantic token system
class SemanticTokenRegistry {
  final Map<String, Map<String, dynamic>> _tokens = {};

  void registerToken(String category, String name, dynamic value) {
    _tokens.putIfAbsent(category, () => {}).putIfAbsent(name, () => value);
  }

  dynamic getToken(String category, String name) {
    return _tokens[category]?[name];
  }

  bool hasToken(String category, String name) {
    return _tokens[category]?.containsKey(name) ?? false;
  }
}

// Enhanced property system
class SemanticProperty {
  final String name;
  final SemanticType type;
  final dynamic defaultValue;
  final bool required;
  final List<SemanticValidationRule> validationRules;

  const SemanticProperty({
    required this.name,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.validationRules = const [],
  });

  List<String> validate(dynamic value) {
    final errors = <String>[];

    if (required && value == null) {
      errors.add('Property $name is required');
      return errors;
    }

    if (value != null) {
      if (!type.validate(value)) {
        errors.add('Invalid value for ${type.name}: $value');
      }

      for (final rule in validationRules) {
        errors.addAll(rule.validate(value));
      }
    }

    return errors;
  }

  dynamic convertValue(dynamic value) {
    if (value == null) return defaultValue;
    return type.convert(value);
  }
}

// Example usage
final tokenRegistry = SemanticTokenRegistry()
  ..registerToken('color', 'primary', '#007AFF')
  ..registerToken('color', 'secondary', '#5856D6')
  ..registerToken('spacing', 'small', 8)
  ..registerToken('spacing', 'medium', 16);

final properties = [
  SemanticProperty(
    name: 'position',
    type: const PixelPositionType(),
    required: true,
    validationRules: [
      BoundsValidationRule(
        name: 'Screen Bounds',
        description: 'Position must be within screen bounds',
        minX: 0,
        minY: 0,
        maxX: 1920,
        maxY: 1080,
      ),
    ],
  ),
  SemanticProperty(
    name: 'color',
    type: const ColorType(),
    defaultValue: '#000000',
    validationRules: [
      TokenValidationRule(
        name: 'Color Token',
        description: 'Color must be a valid token',
        registry: tokenRegistry,
        category: 'color',
      ),
    ],
  ),
];

// Example validation rules
class BoundsValidationRule extends SemanticValidationRule {
  final num minX;
  final num minY;
  final num maxX;
  final num maxY;

  const BoundsValidationRule({
    required super.name,
    required super.description,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  @override
  List<String> validate(dynamic value) {
    if (value is! Map<String, num>) return ['Invalid position format'];

    final x = value['x'] ?? 0;
    final y = value['y'] ?? 0;

    final errors = <String>[];
    if (x < minX || x > maxX) errors.add('X position out of bounds');
    if (y < minY || y > maxY) errors.add('Y position out of bounds');
    return errors;
  }
}

class TokenValidationRule extends SemanticValidationRule {
  final SemanticTokenRegistry registry;
  final String category;

  const TokenValidationRule({
    required super.name,
    required super.description,
    required this.registry,
    required this.category,
  });

  @override
  List<String> validate(dynamic value) {
    if (value is! String) return ['Invalid token format'];
    if (!registry.hasToken(category, value)) {
      return ['Invalid token: $value'];
    }
    return [];
  }
}
```

- **TODO (AI/Human):**
  - [x] Implement core semantic types (GameState, AnimationState, etc.)
  - [x] Create theme token system
  - [x] Add property conversion utilities
  - [x] Create test suite for property system
  - [ ] Add more specialized semantic types as needed
  - [ ] Implement property value caching
  - [ ] Add property change notifications

## 3. Basic Visualization (3D - Flame with `CustomPainter`)

- **Approach:** Use Flame as a base, but implement a custom 3D engine using Flutter's `CustomPainter`.
- **Flame Component:** Create a `Graph3DEngineComponent` that extends Flame's `Component`.
- **CustomPainter:** The `Graph3DEngineComponent` will use a `CustomPainter` (e.g., `Graph3DPainter`) to draw the 3D scene.
- **3D Math Library:** Implement (or adapt) a basic 3D math library in Dart (`Vector3`, `Matrix4`, basic operations).
- **Rendering Pipeline (Simplified):**
  - Model Space -> World Space -> View Space (Camera) -> Projection -> Rasterization (using `CustomPainter`).
- **Node Representation:**
  - Each node will have a `Vector3` position.
  - Represent nodes as simple shapes (cubes, spheres).
  - Define the vertices of these shapes.
- **Edge Representation:**
  - Edges as lines connecting nodes.
  - Calculate line endpoints in screen space after projection.
- **Camera:**
  - Define a camera with position, target, and up direction.
  - Use a `Matrix4` for the camera's view transformation.
  - Implement camera controls (orbiting, panning, zooming).
- **Z-Axis Dimension Switching:**

  - Store the Z-axis meaning in a state management solution (e.g., `Bloc`, `Provider`).
  - Update node positions when the meaning changes.

- **TODO (AI/Human):**
  - [ ] Implement the `Graph3DEngineComponent` (Flame component).
  - [ ] Implement the `Graph3DPainter` (`CustomPainter`).
  - [ ] Implement the basic 3D math library (`Vector3`, `Matrix4`).
  - [ ] Implement the rendering pipeline (transformations, projection).
  - [ ] Implement node and edge rendering.
  - [ ] Implement camera controls.
  - [ ] Implement Z-axis dimension switching (using state management).

## 4. Reasoning/Inference (Dart Functions/Classes)

- **Implementation:** Implement reasoning logic as Dart functions or classes. These will operate on the `SemanticIntentGraph` data structure.
- **Functions/Classes:**

  - `dependencyResolution(graph, intentId)`: Returns a list of intent IDs that the given intent depends on.
  - `impactAnalysis(graph, intentId)`: Returns a list of intent IDs that are affected by the given intent.
  - `consistencyChecking(graph)`: Performs consistency checks (missing dependencies, type mismatches, circular dependencies).

- **TODO (AI/Human):**
  - [ ] Implement `dependencyResolution`.
  - [ ] Implement `impactAnalysis`.
  - [ ] Implement `consistencyChecking`.
  - [ ] Define consistency rules.

## 5. Serialization/Deserialization (Dart, `yaml` package)

- **Library:** Use the `yaml` package for YAML parsing.
- **Functions:**

  - `serializeGraph(graph)`: Serializes the `SemanticIntentGraph` to a YAML string.
  - `deserializeGraph(yamlString)`: Deserializes a YAML string into a `SemanticIntentGraph`.

- **TODO (AI/Human):**
  - [ ] Implement `serializeGraph`.
  - [ ] Implement `deserializeGraph`.
  - [ ] Add tests.

## 6. Codebase Integration

- **Method:** (Remains the same - embed intents as comments)
- **Markers:**

  ````
  // --- BEGIN SEMANTIC INTENT ---
  // ```yaml
  // ... YAML content ...
  // ```
  // --- END SEMANTIC INTENT ---
  ````

- **Extraction System (Dart):**

  - `extractIntents(filePath)`: Reads a file, finds comment blocks, parses YAML, creates `Intent` objects.
  - Use regular expressions.
  - Use the `yaml` package.

- **TODO (AI/Human):**
  - [ ] Implement `extractIntents`.

## 7. AI Integration

- **Use Cases:** (Remains largely the same) Intent generation, modification, code generation, reasoning.
- **Dart `http` package:** Use for making API calls to LLMs.
- **Prompt Engineering:** Develop crafted prompts.

- **TODO (AI/Human):**
  - [ ] Create a function for making LLM API calls (`llmRequest`).
  - [ ] Implement intent generation from code.
  - [ ] Implement intent generation from natural language.
  - [ ] Implement code generation from intent.

## 8. Project Setup and Structure

- **pubspec.yaml:** Flutter/Flame project with dependencies (`flame`, `flutter_bloc`, `yaml`, `http`).
- **Directories:** `lib` (main code), `assets` (YAML files), `intents` (extracted intent files - optional), `components` (Flame components), `logic` (reasoning, graph management), `services` (AI integration), `utils` (3D math).

- **TODO (Human):**
  - [x] Create the Flutter/Flame project.
  - [x] Add dependencies to `pubspec.yaml`.
  - [x] Create the directory structure.
  - [ ] Set up CI/CD pipeline (optional).
  - [ ] Configure linting rules.
