

import 'package:flutter/material.dart';

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14.0,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          String dots = '.' * (_animation.value % 4);
          return Text(
            dots,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          );
        },
      ),
    );
  }
}
