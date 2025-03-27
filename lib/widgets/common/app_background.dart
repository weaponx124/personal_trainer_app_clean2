import 'package:flutter/material.dart';
import '../../utils/cross_painter.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: CrossPainter(),
                child: Container(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}