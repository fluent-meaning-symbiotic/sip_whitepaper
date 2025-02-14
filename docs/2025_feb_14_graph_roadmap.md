# Semantic Intent Graph - Bevy MVP - Scratchpad

**Overall Goal:** Create a language-agnostic, meaning-driven development system based on a Semantic Intent Graph, implemented using Bevy (Rust). This scratchpad outlines the MVP features, implementation steps, and considerations for both AI agents and human developers, drawing heavily from the "Towards Fluid Symbiotic Functionality" whitepaper.

**MVP Goal:** Develop a Semantic Intent Graph implementation that allows for the creation of basic tooling to support further meaning-driven development.

**Target Audience:** AI Agents and Human Developers (collaborative development)

**Technology:** Bevy (Rust)

## 1. Intent Definition (Data Format - YAML)

- **File Format:** YAML (`.yaml`)
- **Structure:** (Simplified from the whitepaper for the MVP, focusing on core elements)

  ```yaml
  intents:
    - id: intent_unique_id_1 # UUID or human-readable string
      type: CommandIntent # Example types: CommandIntent, QueryIntent, UIIntent, DataIntent, SeedSemanticIntent
      meaning: "A concise description of the intent's purpose." # Core Meaning (from whitepaper)
      description: "A more detailed description." # Optional
      properties:
        propertyName1:
          type: string # string, integer, boolean, list, map, intent_reference, vec3
          value: "some value" # Optional initial value
        propertyName2:
          type: integer
          value: 123
        targetIntent: # Example of a property referencing another intent
          type: intent_reference
          value: intent_unique_id_2
      relationships:
        - type: dependsOn # Example types: dependsOn, triggers, modifies, isA, partOf, inputTo, outputFrom
          target: intent_unique_id_2
          direction: unidirectional # unidirectional, bidirectional
        - type: triggers
          target: intent_unique_id_3
          direction: unidirectional
      llm_prompts: # Prompts to guide LLM generation (from whitepaper)
        code_generation: "Generate Rust code for a Bevy system that..."
        test_generation: "Generate a unit test for..."
      scratchpad_todo: # LLM's internal notes and todos (from whitepaper)
        - "Implement the Bevy system for this intent."
        - "Add a unit test."

    - id: intent_unique_id_2
      type: DataIntent
      # ... other properties and relationships ...
  ```

- **TODO (AI/Human):**
  - [ ] Define the core set of `IntentType`s (based on whitepaper).
  - [ ] Define the core set of `RelationshipType`s (based on whitepaper).
  - [ ] Create a formal schema for the YAML format (for validation).
  - [ ] Create example YAML files for different use cases.

## 2. Graph Representation (In-Memory - Bevy ECS)

- **Entities:**
  - `IntentEntity`: Represents a single intent.
- **Components:** (Based on whitepaper and simplified for MVP)

  - `IntentId`: (String/UUID) - Unique identifier.
  - `IntentType`: (Enum) - The type of intent.
  - `IntentMeaning`: (String) - Concise meaning description.
  - `IntentDescription`: (String) - Optional detailed description.
  - `IntentProperties`: (HashMap<String, PropertyValue>) - Stores the properties.
    - `PropertyValue`: (Enum) - Handles different property types (String, Integer, Boolean, List, Map, IntentReference, Vec3).
    - `IntentReference`: (Entity) - Stores a reference to another intent (using Bevy's Entity ID).
  - `Relationships`: (Vec<Relationship>) - Stores relationships to other intents.
    - `Relationship`: (Struct) - Contains `RelationshipType`, `target: Entity`, and `direction: Directionality`.
    - `RelationshipType`: (Enum) - The type of relationship.
    - `Directionality`: (Enum) - Unidirectional or Bidirectional.
  - `IntentLLMPrompts`: (HashMap<String, String>) - Stores LLM prompts (e.g., for code generation, test generation).
  - `IntentScratchpadTodo`: (Vec<String>) - Stores LLM's scratchpad notes.

- **Bevy Resources:**

  - `IntentGraph`: A Bevy `Resource` to hold the overall graph data (adjacency list for efficient querying).
  - `ZAxisMeaning`: A Bevy `Resource` to store the current meaning of the Z-axis (e.g., an enum).

- **API (as Bevy Systems):**

  - `add_intent_system`: Adds a new intent (creates an entity with components).
  - `remove_intent_system`: Removes an intent (and its relationships).
  - `add_relationship_system`: Adds a relationship between two intents.
  - `remove_relationship_system`: Removes a relationship.
  - `get_intent_by_id_system`: Queries for an intent by its ID.
  - `get_related_intents_system`: Queries for related intents.
  - `traverse_graph_system`: Implements graph traversal (depth-first, breadth-first).
  - `detect_cycles_system`: Detects cycles.

- **TODO (AI/Human):**
  - [ ] Implement the Bevy components.
  - [ ] Implement the Bevy systems (add, remove, query, traverse, detect cycles).
  - [ ] Implement unit tests for each system.
  - [ ] Decide on handling of bidirectional relationships.

## 3. Basic Visualization (3D - Bevy)

- **Approach:** Use Bevy's 3D rendering capabilities directly (`PbrBundle`).
- **Node Representation:**
  - `Mesh`es (cubes, spheres, cylinders) for intents.
  - Different colors/materials for different intent types.
  - Text labels (billboards) using `bevy_text3d`.
- **Edge Representation:**
  - Lines (thinner meshes or custom rendering) for relationships.
  - Different colors/styles for different relationship types.
  - Arrows for directionality.
- **Layout Algorithm:**
  - Basic 3D force-directed layout algorithm (adapt 2D or implement).
  - Constraints for "layered" structure (Z-axis meaning).
- **Camera Control:**
  - `PerspectiveCameraBundle`.
  - Orbiting camera controls (`bevy_orbit_controls`).
- **Dimension Switching:**

  - UI elements (buttons, dropdowns) to select Z-axis meaning.
  - Update layout/node positions on Z-axis meaning change.

- **MVP Features:**

  - 3D shapes for nodes (IDs and types).
  - Lines for edges (colors/styles for types).
  - Orbiting camera controls.
  - Basic Z-axis dimension switching (at least two options).

- **TODO (AI/Human):**
  - [ ] Implement node rendering (3D meshes).
  - [ ] Implement edge rendering.
  - [ ] Implement orbiting camera controls.
  - [ ] Implement 3D force-directed layout.
  - [ ] Implement Z-axis dimension switching.
  - [ ] Add UI elements for dimension switching.
  - [ ] Explore `bevy_text3d` for labels.

## 4. Reasoning/Inference (Bevy Systems)

- **Systems:**

  - `dependency_resolution_system`: Find intents a given intent depends on.
  - `impact_analysis_system`: Find intents affected by a given intent.
  - `consistency_checking_system`:
    - Check for missing dependencies.
    - Check for type mismatches.
    - Check for circular dependencies (graph representation).
  - Define a set of consistency rules.

- **TODO (AI/Human):**
  - [ ] Implement `dependency_resolution_system`.
  - [ ] Implement `impact_analysis_system`.
  - [ ] Implement `consistency_checking_system`.
  - [ ] Define consistency rules.

## 5. Serialization/Deserialization (Bevy, Serde)

- **Library:** `serde` and `serde_yaml`.
- **Bevy Integration:** Systems to serialize/deserialize the graph to/from YAML.
- Use Bevy's asset loading (`AssetServer`).

- **TODO (AI/Human):**
  - [ ] Implement serialization system.
  - [ ] Implement deserialization system.
  - [ ] Add tests.

## 6. Codebase Integration

- **Method:** Embed intents as comments in code.
- **Markers:**

  ````
  // --- BEGIN SEMANTIC INTENT ---
  // ```yaml
  // ... YAML content ...
  // ```
  // --- END SEMANTIC INTENT ---
  ````

- **Extraction System (Bevy):**
  - `extract_intents_system`: Reads files, finds comment blocks, parses YAML, creates entities.
  - Use regular expressions or a parser.
  - Use `serde_yaml`.
- **File Watching (Optional):** `AssetServer` and `FileSystemWatcher` (or `notify`).

- **TODO (AI/Human):**
  - [ ] Implement `extract_intents_system`.
  - [ ] Implement file watching (optional).

## 7. AI Integration

- **Use Cases:** Intent generation, modification, code generation, reasoning.
- **Bevy Systems:** Systems for LLM API calls.
- **Prompt Engineering:** Develop crafted prompts.
- **TODO (AI/Human):**
  - [ ] Create system for LLM API calls (`llm_request_system`).
  - [ ] Implement intent generation from code.
  - [ ] Implement intent generation from natural language.
  - [ ] Implement code generation from intent.

## 8. Project Setup and Structure

- **Cargo.toml:** Bevy project with dependencies (`bevy`, `serde`, `serde_yaml`, `uuid`, `bevy_prototype_lyon`, `bevy_orbit_controls`, `bevy_text3d`).
- **Modules:** `intents`, `graph`, `visualization`, `reasoning`, `serialization`, `extraction`, `ai`.
- **Tests:** Unit tests for each component and system.

- **TODO (Human):**
  - [ ] Create Bevy project.
  - [ ] Add dependencies to `Cargo.toml`.
  - [ ] Create module structure.

## 9. AI Agent Collaboration

- **AI Agent Tasks:** Code generation, unit tests, reasoning, refactoring, schema suggestions, documentation.
- **Human Tasks:** Project setup, YAML schema, visualization, code review, guidance, testing.
- **Communication:** Use this scratchpad.

## 10. Example Workflow (First Iteration)

1.  **Human:** Project setup, module structure, dependencies.
2.  **Human:** Initial YAML schema (e.g., "MoveCharacter" command).
3.  **AI:** Generate Bevy components.
4.  **AI:** Generate `add_intent_system`.
5.  **Human:** Simple 3D visualization (cube for intent).
6.  **AI:** Generate serialization system.
7.  **AI:** Generate `extract_intents_system`.
8.  **Human:** Review and integrate.
9.  **Iterate:** Add more features.

## 11. Roadmap (Simplified)

- **MVP:** Core graph functionality, 3D visualization, basic reasoning, codebase integration, basic AI integration.
- **Near-Term:** Expand intent library, improve tooling, refine AI integration, explore Z-axis dimension switching options.
- **Mid-Term:** Reactive Semantic Command Invoker (as described in the whitepaper), semantic orchestration engine, context-aware software, dynamic UI generation.

This upgraded scratchpad is now much more comprehensive, drawing on the whitepaper for structure, terminology, and detailed explanations. It provides a solid foundation for the Bevy MVP development, guiding both human and AI contributions. The `TODO` markers clearly delineate tasks, and the example workflow provides a practical starting point. The roadmap outlines the short-term and long-term goals. This scratchpad should be a living document, updated as the project progresses.
