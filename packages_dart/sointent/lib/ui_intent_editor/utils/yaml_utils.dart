import 'package:yaml/yaml.dart';

/// Converts a JSON-like Map to YAML string
String jsonToYaml(final Map<String, dynamic> json) {
  final StringBuffer buffer = StringBuffer();
  _writeYamlNode(json, buffer, 0);
  return buffer.toString();
}

void _writeYamlNode(final node, final StringBuffer buffer, final int indent) {
  final String padding = ' ' * indent;

  if (node is Map) {
    if (indent > 0) buffer.writeln();
    node.forEach((final key, final value) {
      buffer.write('$padding$key:');
      if (value is Map || value is List) {
        _writeYamlNode(value, buffer, indent + 2);
      } else {
        buffer.write(' $value\n');
      }
    });
  } else if (node is List) {
    if (node.isEmpty) {
      buffer.write(' []\n');
      return;
    }
    buffer.writeln();
    for (final item in node) {
      buffer.write('$padding- ');
      if (item is Map || item is List) {
        _writeYamlNode(item, buffer, indent + 2);
      } else {
        buffer.write('$item\n');
      }
    }
  } else {
    buffer.write(' $node\n');
  }
}

/// Converts a YAML string to a JSON-like Map
Map<String, dynamic> yamlToJson(final String yaml) {
  final yamlMap = loadYaml(yaml) as YamlMap;
  return _convertYamlNode(yamlMap) as Map<String, dynamic>;
}

dynamic _convertYamlNode(final node) {
  switch (node.runtimeType) {
    case YamlMap:
      return (node as YamlMap).map(
        (final key, final value) =>
            MapEntry(key.toString(), _convertYamlNode(value)),
      );
    case YamlList:
      return (node as YamlList).map(_convertYamlNode).toList();
    default:
      return node;
  }
}
