# Semantic Intent Graph

A Flutter/Flame application for visualizing and managing semantic intent graphs. This project implements a language-agnostic, meaning-driven development system based on semantic intents.

## Features

- YAML-based semantic intent definitions
- In-memory graph representation with validation and change propagation
- 3D visualization using Flame and CustomPainter
- Semantic reasoning and inference capabilities
- Integration with AI for intent generation and code generation

## Controls

Orbit: Regular drag/swipe
Pan:
Shift + drag/swipe
Or regular two-finger scroll
Zoom: Ctrl + two-finger scroll

## Project Structure

```
lib/
├── components/     # Flame components and UI widgets
├── logic/          # Core business logic
│   ├── graph/      # Semantic intent graph implementation
│   ├── validation/ # Validation system
│   ├── propagation/# Change propagation system
│   └── property/   # Semantic property system
├── services/       # External services (AI, file system)
└── utils/         # Utility functions and helpers

assets/
├── yaml/          # YAML files and schemas
├── images/        # Image assets
└── icons/         # Icon assets

test/              # Test files mirroring lib/ structure
```

## Getting Started

1. Install Flutter (>=3.3.0)
2. Clone this repository
3. Run `flutter pub get`
4. Run `flutter run`

## Development

### Prerequisites

- Flutter SDK >=3.3.0
- Dart SDK >=3.3.0
- An IDE with Flutter support (VS Code, Android Studio, or IntelliJ)

### Building

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run the app
flutter run
```

### Architecture

The project follows the Semantic Intent Paradigm (SIP) architecture:

1. **Semantic Intents**: YAML-based definitions of meaning and purpose
2. **Graph Representation**: In-memory Dart implementation
3. **Validation System**: Ensures semantic consistency
4. **Change Propagation**: Manages semantic changes across the graph
5. **Property System**: Handles semantic types and tokens

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
