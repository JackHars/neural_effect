import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  double x;
  double y;
  double z;
  double radius;
  double speed;
  double directionAngle;
  Map<String, double> vector;
  Set<int> connections = {};

  final double originalX;
  final double originalY;
  final double originalZ;

  Particle({
    required this.x,
    required this.y,
    required this.z,
    required this.radius,
    required this.speed,
    required this.directionAngle,
  })  : originalX = x,
        originalY = y,
        originalZ = z,
        vector = {
          'x': cos(directionAngle) * speed,
          'y': sin(directionAngle) * speed,
          'z': sin(directionAngle + pi / 3) * speed,
        };

  void update(double sphereRadius) {
    x += vector['x']!;
    y += vector['y']!;
    z += vector['z']!;

    final distance = sqrt(x * x + y * y + z * z);
    if (distance > sphereRadius) {
      final nx = x / distance;
      final ny = y / distance;
      final nz = z / distance;

      x = nx * sphereRadius * 0.99;
      y = ny * sphereRadius * 0.99;
      z = nz * sphereRadius * 0.99;

      final dot = vector['x']! * nx + vector['y']! * ny + vector['z']! * nz;
      vector['x'] = vector['x']! - 2 * dot * nx;
      vector['y'] = vector['y']! - 2 * dot * ny;
      vector['z'] = vector['z']! - 2 * dot * nz;

      vector['x'] = vector['x']! + (Random().nextDouble() - 0.5) * 0.1;
      vector['y'] = vector['y']! + (Random().nextDouble() - 0.5) * 0.1;
      vector['z'] = vector['z']! + (Random().nextDouble() - 0.5) * 0.1;
    }
  }

  Offset project(Size size, double rotationX, double rotationY) {
    final cosY = cos(rotationY);
    final sinY = sin(rotationY);
    final rotatedX = x * cosY + z * sinY;
    final rotatedZ = -x * sinY + z * cosY;

    final cosX = cos(rotationX);
    final sinX = sin(rotationX);
    final rotatedY = y * cosX - rotatedZ * sinX;
    final finalZ = y * sinX + rotatedZ * cosX;

    final perspective = 800.0;
    final scale = perspective / (perspective + finalZ);

    return Offset(
      size.width / 2 + rotatedX * scale,
      size.height / 2 + rotatedY * scale,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double width;
  final double height;
  final double rotationX;
  final double rotationY;
  final double sphereRadius;

  ParticlePainter({
    required this.particles,
    required this.width,
    required this.height,
    required this.rotationX,
    required this.rotationY,
    required this.sphereRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = const Color(0xFF00B5FF).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final particleProjected = particle.project(size, rotationX, rotationY);

      for (var connectionIndex in particle.connections) {
        final connectedParticle = particles[connectionIndex];
        final connectedProjected =
            connectedParticle.project(size, rotationX, rotationY);

        final distance = _checkDistance(
          particleProjected.dx,
          particleProjected.dy,
          connectedProjected.dx,
          connectedProjected.dy,
        );

        final linkRadius = 200.0;
        final opacity = 1 - distance / linkRadius;

        if (opacity > 0) {
          linePaint.color =
              const Color(0xFF00B5FF).withOpacity(opacity * 0.4);
          canvas.drawLine(
            particleProjected,
            connectedProjected,
            linePaint,
          );
        }
      }
    }

    for (var particle in particles) {
      final projected = particle.project(size, rotationX, rotationY);
      final perspective = 1000.0;
      final scale = perspective / (perspective + particle.z);

      final zOpacity = (particle.z + sphereRadius) / (sphereRadius * 2);
      particlePaint.color =
          const Color(0xFF00B5FF).withOpacity(0.6 * scale * zOpacity);

      canvas.drawCircle(
        projected,
        particle.radius * scale,
        particlePaint,
      );
    }
  }

  double _checkDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      oldDelegate.rotationX != rotationX ||
      oldDelegate.rotationY != rotationY;
}

class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;
  final random = Random();
  Size? _lastSize;
  Offset _mousePosition = Offset.zero;
  Offset _currentRotation = Offset.zero;
  static const double sphereRadius = 500.0;
  static const double rotationSpeed = 0.05;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
    particles = [];
  }

  bool _shouldReinitialize(Size currentSize) {
    if (_lastSize == null) return true;
    if (_lastSize!.width != currentSize.width ||
        _lastSize!.height != currentSize.height) {
      return true;
    }
    return false;
  }

  void _updateParticleConnections() {
    final maxDistance = sphereRadius * 0.3;

    for (var i = 0; i < particles.length; i++) {
      for (var j = i + 1; j < particles.length; j++) {
        final distance = _checkDistance3D(
          particles[i].x,
          particles[i].y,
          particles[i].z,
          particles[j].x,
          particles[j].y,
          particles[j].z,
        );

        if (distance < maxDistance) {
          particles[i].connections.add(j);
          particles[j].connections.add(i);
        } else {
          particles[i].connections.remove(j);
          particles[j].connections.remove(i);
        }
      }

      if (particles[i].connections.length > 8) {
        particles[i].connections = particles[i].connections.take(8).toSet();
      }
    }
  }

  void _initializeParticles(double width, double height) {
    _lastSize = Size(width, height);

    particles = List.generate(300, (index) {
      final phi = random.nextDouble() * 2 * pi;
      final theta = random.nextDouble() * pi;
      final r = sphereRadius * (0.3 + random.nextDouble() * 0.7);
      return Particle(
        x: r * sin(theta) * cos(phi),
        y: r * sin(theta) * sin(phi),
        z: r * cos(theta),
        radius: 1.2 + random.nextDouble() * 0.8,
        speed: 0.5 + random.nextDouble() * 0.5,
        directionAngle: random.nextDouble() * 2 * pi,
      );
    });
  }

  double _checkDistance3D(
      double x1, double y1, double z1, double x2, double y2, double z2) {
    return sqrt(pow(x2 - x1, 2) +
        pow(y2 - y1, 2) +
        pow(z2 - z1, 2));
  }

  Offset _calculateTargetRotation() {
    return Offset(
      ((_mousePosition.dy / (_lastSize?.height ?? 1)) - 0.5) * pi * 0.5,
      ((_mousePosition.dx / (_lastSize?.width ?? 1)) - 0.5) * pi * 0.5,
    );
  }

  void _updateRotation() {
    final targetRotation = _calculateTargetRotation();
    _currentRotation = Offset(
      _currentRotation.dx +
          (targetRotation.dx - _currentRotation.dx) * rotationSpeed,
      _currentRotation.dy +
          (targetRotation.dy - _currentRotation.dy) * rotationSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final currentSize =
              Size(constraints.maxWidth, constraints.maxHeight);

          if (_shouldReinitialize(currentSize)) {
            _initializeParticles(currentSize.width, currentSize.height);
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              for (var particle in particles) {
                particle.update(sphereRadius);
              }

              _updateRotation();

              if (_controller.value < 0.1) {
                _updateParticleConnections();
              }

              return Center(
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: ParticlePainter(
                    particles: particles,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    rotationX: _currentRotation.dx,
                    rotationY: _currentRotation.dy,
                    sphereRadius: sphereRadius,
                  ),
                  child: widget.child,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}