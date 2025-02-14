# Semantic Intent Graph - Flutter/Flame MVP - Scratchpad

**Overall Goal:** Create a language-agnostic, meaning-driven development system based on a Semantic Intent Graph, implemented using Flutter and Flame. This scratchpad outlines the MVP features, implementation steps, and considerations for both AI agents and human developers.

**MVP Goal:** Develop a Semantic Intent Graph implementation that allows for the creation of basic tooling to support further meaning-driven development.

**Target Audience:** AI Agents and Human Developers (collaborative development)

**Technology:** Flutter, Flame (Dart)

## 1. Intent Definition (Data Format - YAML)

- **File Format:** YAML (`.yaml`)
- **Structure:** (Remains largely unchanged from the Bevy version, focusing on core elements)

  ```yaml
  intents:
    - id: intent_unique_id_1 # UUID or human-readable string
      type: CommandIntent # Example types: CommandIntent, QueryIntent, UIIntent, DataIntent, SeedSemanticIntent
      meaning: "A concise description of the intent's purpose."
      description: "A more detailed description." # Optional
      properties:
        propertyName1:
          type: string # string, integer, boolean, list, map, intent_reference, vec3 #Keep vec3 for 3D position
          value: "some value" # Optional initial value
        propertyName2:
          type: integer
          value: 123
        targetIntent:
          type: intent_reference
          value: intent_unique_id_2
      relationships:
        - type: dependsOn
          target: intent_unique_id_2
          direction: unidirectional
        - type: triggers
          target: intent_unique_id_3
          direction: unidirectional
      llm_prompts: # Simplified for MVP
        code_generation: "Generate Dart code for a command handler that..."
      scratchpad_todo:
        - "Implement the command handler."
        - "Add a unit test."

    - id: intent_unique_id_2
      type: DataIntent
      # ... other properties and relationships ...
  ```

- **TODO (AI/Human):**
  - [ ] Define the core set of `IntentType`s.
  - [ ] Define the core set of `RelationshipType`s.
  - [ ] Create a formal schema for the YAML format.
  - [ ] Create example YAML files.

## 2. Graph Representation (In-Memory - Dart)

- **Data Structures:** (Replaces Bevy ECS with Dart classes)

  - `Intent`: A class representing a single intent.
  - `Relationship`: A class representing a relationship between intents.
  - `PropertyValue`: An enum or sealed class to handle different property types.
  - `SemanticIntentGraph`: A class to manage the graph (add, remove, query intents and relationships).

  ```dart
  // Example Dart classes (simplified)
  extension type const IntentId(String value) implements String {}
  extension type const RelationshipId(String value) implements String {}

  class Intent {
    final IntentId id; // Use the extension type
    final String type;
    final String meaning;
    final String? description;
    final Map<String, PropertyValue> properties;
    final List<Relationship> relationships;
    final Map<String, String> llmPrompts;
    final List<String> scratchpadTodo;

    Intent({
      required this.id,
      required this.type,
      required this.meaning,
      this.description,
      required this.properties,
      required this.relationships,
      required this.llmPrompts,
      required this.scratchpadTodo,
    });
  }

  class Relationship {
    final String type;
    final IntentId targetIntentId; // Use the extension type
    final String direction;

    Relationship({
      required this.type,
      required this.targetIntentId,
      required this.direction,
    });
  }

  // Example using a sealed class (you could also use an enum)
  sealed class PropertyValue {
    final Object value;
    PropertyValue(this.value);
  }
  class StringValue extends PropertyValue {
    StringValue(super.value);
  }
  class IntValue extends PropertyValue {
    IntValue(super.value);
  }
  class Vec3Value extends PropertyValue{
    Vec3Value(super.value);
  }
  // ... other property types ...
  class IntentReferenceValue extends PropertyValue {
    IntentReferenceValue(super.value);
  }
  class SemanticIntentGraph {
    final Map<String, Intent> _intents = {}; // Use a Map for efficient lookup by ID

    void addIntent(Intent intent) {
      _intents[intent.id.value] = intent; // Access the underlying string value
    }

    Intent? getIntent(IntentId id) { // Use IntentId as parameter type
      return _intents[id.value]; // Access string value for map lookup
    }

    void addRelationship(IntentId sourceIntentId, Relationship relationship) {
      _intents[sourceIntentId.value]?.relationships.add(relationship); // Access string value
    }
    // ... other methods (removeIntent, removeRelationship, getRelatedIntents, etc.) ...
  }

  ```

- **TODO (AI/Human):**
  - [ ] Implement the `Intent`, `Relationship`, `PropertyValue`, and `SemanticIntentGraph` classes.
  - [ ] Implement methods for adding, removing, and querying intents and relationships.
  - [ ] Implement unit tests.

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

- **pubspec.yaml:** Flutter/Flame project with dependencies (`flame`, `flutter_bloc` (or other state management), `yaml`, `http`).
- **Directories:** `lib` (main code), `assets` (YAML files), `intents` (extracted intent files - optional), `components` (Flame components), `logic` (reasoning, graph management), `services` (AI integration), `utils` (3D math).

- **TODO (Human):**
  - [ ] Create the Flutter/Flame project.
  - [ ] Add dependencies to `pubspec.yaml`.
  - [ ] Create the directory structure.

## 9. AI Agent Collaboration

- **AI Agent Tasks:** Code generation, unit tests, reasoning logic, refactoring, prompt engineering, documentation.
- **Human Tasks:** Project setup, YAML schema definition, 3D engine implementation, visualization, code review, guidance, testing.
- **Communication:** Use this scratchpad.

## 10. Example Workflow (First Iteration)

1.  **Human:** Project setup, directory structure, dependencies.
2.  **Human:** Initial YAML schema (e.g., a simple command intent).
3.  **AI:** Generate Dart classes for `Intent`, `Relationship`, `PropertyValue`.
4.  **AI:** Generate a basic `SemanticIntentGraph` class.
5.  **Human:** Implement the `Graph3DEngineComponent` and `Graph3DPainter` (basic 3D engine).
6.  **AI:** Generate serialization/deserialization functions.
7.  **AI:** Generate the `extractIntents` function.
8.  **Human:** Review and integrate.
9.  **Iterate:** Add more features.

## 11. Roadmap (Simplified)

- **MVP:** Core graph functionality, 3D visualization (using custom engine), basic reasoning, codebase integration, basic AI integration.
- **Near-Term:** Expand intent library, improve tooling, refine AI integration, explore Z-axis dimension switching.
- **Mid-Term:** Reactive command processing (consider `flame_bloc`), semantic orchestration, context-aware software, dynamic UI generation (longer-term).
