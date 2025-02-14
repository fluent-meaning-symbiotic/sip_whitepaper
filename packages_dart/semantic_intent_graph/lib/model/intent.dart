class Intent {
  final String name;
  final String description;
  final String path;
  final Map<String, dynamic> data;

  const Intent({
    required this.name,
    required this.description,
    required this.path,
    required this.data,
  });

  factory Intent.fromYaml(String path, Map<String, dynamic> yaml) {
    return Intent(
      name: yaml['name'] as String? ?? 'Unnamed Intent',
      description: yaml['description'] as String? ?? '',
      path: path,
      data: yaml,
    );
  }

  double get contentHeight {
    // Calculate height based on content
    double height = 60.0; // Base height
    height += description.split('\n').length * 20.0;
    height += data.length * 15.0;
    return height;
  }
}
