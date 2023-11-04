// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import 'dart:ui' as ui;

class WorkspacesIndicator extends HookConsumerWidget {
  const WorkspacesIndicator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jumpAC = useAnimationController(
      duration: const Duration(milliseconds: 1000),
      initialValue: 0,
      upperBound: 2,
    );

    useEffect(
      () {
        jumpAC.animateTo(1, curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 200));
        jumpAC.addStatusListener((s) {
          if (jumpAC.value == 1 && s == AnimationStatus.completed) {
            jumpAC.animateTo(2, curve: Curves.easeOutExpo, duration: const Duration(milliseconds: 300));
          }
        });
        return;
      },
      [],
    );

    return Container(
      color: Colors.red,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: jumpAC,
            builder: (context, child) {
              return SizedBox(
                width: 40,
                height: 38,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RectanglePainter(
                          jumpStep: jumpAC.value,
                          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RectangleCoverPainter(
                          jumpStep: jumpAC.value,
                          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RectanglePainter extends CustomPainter {
  _RectanglePainter({
    required this.jumpStep,
    required this.devicePixelRatio,
  });

  double jumpStep;
  final double devicePixelRatio;

  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas
      ..translate(cx, cy)
      ..rotate(angle)
      ..translate(-cx, -cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // values = [...values, ...values.reversed];
    const stroke = 1.0;
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke / devicePixelRatio;
    if (jumpStep > 1) jumpStep = 2 - jumpStep;

    canvas.translate(0, -size.height / 2 * jumpStep);
    rotate(canvas, size.width / 2, size.height / 2, pi / 4 * jumpStep);
    canvas.drawRect(
      Rect.fromLTRB(stroke, stroke, size.width - stroke, size.height - stroke),
      paint,
    );
    canvas.translate(0, size.height / 2 * jumpStep);
    canvas.rotate(-pi / 4 * jumpStep);
    canvas.translate(-size.width / 2, size.height / 2);
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}

class _RectangleCoverPainter extends CustomPainter {
  _RectangleCoverPainter({
    required this.jumpStep,
    required this.devicePixelRatio,
  });

  final double jumpStep;
  final double devicePixelRatio;

  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas
      ..translate(cx, cy)
      ..rotate(angle)
      ..translate(-cx, -cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // values = [...values, ...values.reversed];
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;

    print(jumpStep);
    for (var i = 0.0; i < 6; i += 1) {
      if (jumpStep <= 1) {
        canvas.drawRect(
          Rect.fromLTWH(-10 + 10 * i, -10 + (10 + size.width) * (1 - jumpStep), size.width / 4, size.height + 30),
          paint,
        );
      } else if (jumpStep <= 2) {
        final t = switch (i) {
          0 => 2.0,
          1 => 1.0,
          2 => 0.0,
          3 => 0.0,
          4 => 1.0,
          5 => 2.0,
          _ => 0.0
        };
        // 0 -> 0
        // 1 -> 1
        // 2 -> 2
        // 3 -> 2 -1
        // 4 -> 1 -3
        // 5 -> 0 -5
        canvas.drawRect(
          Rect.fromLTWH(-10 + 10 * i, -10 + (10 + size.width) * ((jumpStep - 1) * (t + 1)), size.width / 4, size.height + 30),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RectangleCoverPainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
