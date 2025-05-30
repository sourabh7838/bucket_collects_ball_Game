import 'package:flutter/material.dart';
import 'dart:math' as math;

class Particle extends StatelessWidget {
  final double size;
  final Color color;
  final Offset velocity;
  final double opacity;

  const Particle({
    super.key,
    required this.size,
    required this.color,
    required this.velocity,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class ParticleSystem extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const ParticleSystem({
    super.key,
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> particles = [];
  late AnimationController _controller;
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Create particles
    for (int i = 0; i < 12; i++) {
      final angle = i * (math.pi * 2 / 12);
      final speed = 2.0 + random.nextDouble() * 2.0;
      particles.add({
        'position': widget.position,
        'velocity': Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        'size': 4.0 + random.nextDouble() * 4.0,
      });
    }

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  void _updateParticles() {
    setState(() {
      for (var particle in particles) {
        particle['position'] = particle['position'] + particle['velocity'];
        particle['velocity'] += const Offset(0, 0.1); // Gravity
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: particles.map((particle) {
        return Positioned(
          left: particle['position'].dx,
          top: particle['position'].dy,
          child: Particle(
            size: particle['size'],
            color: widget.color,
            velocity: particle['velocity'],
            opacity: 1.0 - _controller.value,
          ),
        );
      }).toList(),
    );
  }
} 