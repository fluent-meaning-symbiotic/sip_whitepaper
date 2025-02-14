import 'package:vector_math/vector_math_64.dart' hide Colors;

/// A particle with basic physics properties
class Particle {
  Vector3 position;
  Vector3 velocity;
  double mass;
  double damping;

  Particle({
    required this.position,
    Vector3? velocity,
    this.mass = 1.0,
    this.damping = 0.95,
  }) : velocity = velocity ?? Vector3.zero();

  void applyForce(Vector3 force) {
    velocity += force / mass;
  }

  void update(double dt) {
    position += velocity * dt;
    velocity *= damping;
  }
}
