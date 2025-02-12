import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'package:neural_effect/neural_effect.dart';
import 'dart:ui';

void main() {
  test('Particle.project returns center offset when particle is at origin', () {
    final particle = Particle(
      x: 0,
      y: 0,
      z: 0,
      radius: 1,
      speed: 1,
      directionAngle: 0,
    );
    const size = Size(100, 100);
    final offset = particle.project(size, 0, 0);
    expect(offset, equals(const Offset(50, 50)));
  });

  test('ParticlePainter shouldRepaint returns true when rotationX changes', () {
    final painter1 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0,
      rotationY: 0,
      sphereRadius: 500,
    );
    final painter2 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0.1, // changed rotationX
      rotationY: 0,
      sphereRadius: 500,
    );
    expect(painter1.shouldRepaint(painter2), isTrue);
  });

  test('ParticlePainter shouldRepaint returns true when rotationY changes', () {
    final painter1 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0,
      rotationY: 0,
      sphereRadius: 500,
    );
    final painter2 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0,
      rotationY: 0.1, // changed rotationY
      sphereRadius: 500,
    );
    expect(painter1.shouldRepaint(painter2), isTrue);
  });

  test('ParticlePainter shouldRepaint returns false when rotations are unchanged', () {
    final painter1 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0.2,
      rotationY: 0.3,
      sphereRadius: 500,
    );
    final painter2 = ParticlePainter(
      particles: [],
      width: 100,
      height: 100,
      rotationX: 0.2,
      rotationY: 0.3,
      sphereRadius: 500,
    );
    expect(painter1.shouldRepaint(painter2), isFalse);
  });

  test('Particle.update clamps particle within sphere boundary', () {
    final sphereRadius = 500.0;
    // Create a particle outside the sphere boundary along the x-axis.
    final particle = Particle(
      x: 600,
      y: 0,
      z: 0,
      radius: 1,
      speed: 0, // so no movement from speed, only the clamping logic applies
      directionAngle: 0,
    );
    particle.update(sphereRadius);

    // After update particle should be clamped near 500 * 0.99 = 495 (with slight variation because of random offset).
    expect(particle.x, closeTo(495, 1.0));

    // Also check that the particle's overall distance from the origin is within the sphere.
    final distance = sqrt(particle.x * particle.x + particle.y * particle.y + particle.z * particle.z);
    expect(distance, lessThan(sphereRadius));
  });
}
