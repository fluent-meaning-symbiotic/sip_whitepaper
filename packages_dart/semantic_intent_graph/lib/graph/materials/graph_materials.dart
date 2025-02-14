import 'package:flutter/material.dart';

import '../../three_d/core/material.dart';

/// Material specialized for graph edges
class EdgeMaterial extends TransparentMaterial {
  EdgeMaterial({
    super.color = Colors.grey,
    super.strokeWidth = 2.0,
    super.opacity = 0.8,
  }) : super(
          style: PaintingStyle.stroke,
        );
}

/// Material specialized for graph nodes
class NodeMaterial extends TransparentMaterial {
  final bool selected;

  NodeMaterial({
    Color color = Colors.blue,
    this.selected = false,
    super.opacity = 1.0,
  }) : super(
          color: selected ? Colors.orange : color,
          style: PaintingStyle.fill,
        );
}
