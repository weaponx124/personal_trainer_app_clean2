import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart'; // Updated import path
import '../../utils/cross_painter.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF2A2A2A).withOpacity(0.2), AppTheme.matteBlack]
              : [AppTheme.lightBlue.withOpacity(0.2), AppTheme.matteBlack],
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