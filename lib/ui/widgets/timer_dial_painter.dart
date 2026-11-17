import 'dart:math';
import 'package:flutter/material.dart';

class TimerDialPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  TimerDialPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 18;
    const strokeWidth = 14.0;

    // 1. Draw Dial Tick Marks
    final tickPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.12)
          : const Color(0xFF64748B).withOpacity(0.18)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.28)
          : const Color(0xFF334155).withOpacity(0.35)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 10.0 : 5.0;

      final startRadius = radius + 12;
      final endRadius = startRadius + tickLength;

      final p1 = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final p2 = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : tickPaint);
    }

    // 2. Draw Inactive Background Track
    final trackPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E293B).withOpacity(0.6)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 3. Draw Active Progress Arc
    if (progress > 0.001) {
      final sweepAngle = 2 * pi * progress;
      const startAngle = -pi / 2;

      final rect = Rect.fromCircle(center: center, radius: radius);

      // Sweep gradient along circle
      final gradient = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          secondaryColor,
          primaryColor,
          secondaryColor,
        ],
        transform: const GradientRotation(-pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

      // 4. Draw Glowing Tip Bead
      final tipAngle = startAngle + sweepAngle;
      final tipCenter = Offset(
        center.dx + radius * cos(tipAngle),
        center.dy + radius * sin(tipAngle),
      );

      // Outer glow
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(tipCenter, strokeWidth / 2 + 3, glowPaint);

      // Center bead
      final beadPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tipCenter, strokeWidth / 2 - 2, beadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TimerDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
