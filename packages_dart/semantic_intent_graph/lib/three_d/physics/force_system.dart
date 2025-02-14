import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'particle.dart';

/// A force that can be applied to particles
abstract class Force {
  /// Apply this force to a particle
  void applyTo(Particle particle, double dt);
}

/// A constant force like gravity
class ConstantForce implements Force {
  final Vector3 force;

  const ConstantForce(this.force);

  @override
  void applyTo(Particle particle, double dt) {
    particle.applyForce(force * particle.mass);
  }
}

/// A spring force between two particles
class SpringForce implements Force {
  final Particle particleA;
  final Particle particleB;
  final double springConstant;
  final double restLength;
  final double damping;

  SpringForce({
    required this.particleA,
    required this.particleB,
    this.springConstant = 1.0,
    this.restLength = 1.0,
    this.damping = 0.1,
  });

  @override
  void applyTo(Particle particle, double dt) {
    if (particle != particleA && particle != particleB) return;

    final delta = particleB.position - particleA.position;
    final distance = delta.length;
    if (distance < 0.0001) return;

    final direction = delta.normalized();
    final displacement = distance - restLength;
    final springForce = direction * (springConstant * displacement);

    // Add damping force
    final relativeVelocity = particleB.velocity - particleA.velocity;
    final dampingForce =
        direction * (damping * direction.dot(relativeVelocity));

    final totalForce = springForce + dampingForce;

    if (particle == particleA) {
      particle.applyForce(totalForce);
    } else {
      particle.applyForce(-totalForce);
    }
  }
}

/// A system that manages and applies forces to particles
class ForceSystem {
  final List<Force> _forces = [];
  final List<Particle> _particles = [];

  void addForce(Force force) {
    _forces.add(force);
  }

  void removeForce(Force force) {
    _forces.remove(force);
  }

  void addParticle(Particle particle) {
    _particles.add(particle);
  }

  void removeParticle(Particle particle) {
    _particles.remove(particle);
  }

  void update(double dt) {
    // Apply forces
    for (final force in _forces) {
      for (final particle in _particles) {
        force.applyTo(particle, dt);
      }
    }

    // Update particles
    for (final particle in _particles) {
      particle.update(dt);
    }
  }

  void clear() {
    _forces.clear();
    _particles.clear();
  }
}
