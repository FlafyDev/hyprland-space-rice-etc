// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background/providers/hyprland.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:hyprland_ipc/hyprland_ipc.dart';

class WorkspacesIndicator extends HookConsumerWidget {
  const WorkspacesIndicator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hyprland = ref.watch(hyprlandProvider);

    final dotsAC = useAnimationController(duration: const Duration(milliseconds: 1000));
    final arcsAC = useAnimationController(duration: const Duration(milliseconds: 1000));
    final linesAC = useAnimationController(duration: const Duration(milliseconds: 1500));
    final random = useRef(Random()).value;
    final activeWorkspace = useState<int>(-1);

    useEffect(() {
      dotsAC.value = random.nextInt(2).toDouble();
      dotsAC.animateTo(random.nextDouble() * 0.4 + 0.3, curve: Curves.easeOutExpo, duration: Duration(milliseconds: 1000));
      arcsAC.value = random.nextInt(2).toDouble();
      arcsAC.animateTo(random.nextDouble() * 0.4 + 0.3, curve: Curves.easeOutExpo, duration: Duration(milliseconds: 1000));
      return;
    }, [
      activeWorkspace.value
    ]);

    useEffect(
      () {
        linesAC.repeat();

        final timers = [
          Timer.periodic(const Duration(milliseconds: 600), (_) {
            if (dotsAC.status != AnimationStatus.completed) return;
            if (random.nextDouble() < 0.6) {
              final to = random.nextDouble();
              final distance = (dotsAC.value - to).abs();
              dotsAC.animateTo(to, curve: Curves.easeOutExpo, duration: Duration(milliseconds: min((800 / distance).floor(), 1500)));
            }
          }),
          Timer.periodic(const Duration(milliseconds: 400), (_) {
            if (arcsAC.status != AnimationStatus.completed) return;
            if (random.nextDouble() < 0.6) {
              final to = random.nextDouble();
              final distance = (dotsAC.value - to).abs();
              arcsAC.animateTo(to, curve: Curves.easeOutExpo, duration: Duration(milliseconds: min((800 / distance).floor(), 1500)));
            }
          }),
        ];

        return () {
          timers.map((t) => t.cancel());
        };
      },
      [],
    );

    useEffect(
      () {
        final subscription = hyprland.value?.eventsStream.listen((event) async {
          if (event is WorkspaceEvent) {
            activeWorkspace.value = (int.tryParse(event.workspaceName) ?? -1) - 1;
          }
        });
        return () => subscription?.cancel();
      },
      [
        hyprland
      ],
    );

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          11,
          (i) => AnimatedBuilder(
            animation: Listenable.merge([
              dotsAC,
              linesAC,
              arcsAC
            ]),
            builder: (context, child) {
              return SizedBox(
                width: 40,
                height: 38,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _Workspace(
                        dots: dotsAC.value,
                        arcs: arcsAC.value,
                        lines: i == activeWorkspace.value ? linesAC.value * 2 % 1.0 : linesAC.value,
                        opened: i == activeWorkspace.value,
                      ),
                    ),
                    // Positioned.fill(
                    //   child: CustomPaint(
                    //     painter: _RectangleCoverPainter(
                    //       jumpStep: jumpAC.value,
                    //       devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Workspace extends HookConsumerWidget {
  const _Workspace({
    super.key,
    required this.dots,
    required this.arcs,
    required this.lines,
    required this.opened,
  });

  final double dots;
  final double arcs;
  final double lines;
  final bool opened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openedAC = useAnimationController(duration: const Duration(milliseconds: 500));

    useEffect(() {
      if (opened) {
        openedAC.animateTo(1, curve: Curves.elasticOut);
      } else {
        openedAC.animateTo(0, curve: Curves.easeOutExpo);
      }
      return;
    }, [
      opened,
    ]);

    return AnimatedBuilder(
      animation: openedAC,
      builder: (context, child) {
        return CustomPaint(
          painter: _RectanglePainter(
            dotsRotation: dots * 2 * pi,
            arcsRotation: arcs * 2 * pi,
            lineMovement: lines,
            opened: openedAC.value,
          ),
        );
      },
    );
  }
}

class _RectanglePainter extends CustomPainter {
  _RectanglePainter({
    required this.dotsRotation,
    required this.arcsRotation,
    required this.lineMovement,
    required this.opened,
  });

  final double arcsRotation;
  final double dotsRotation;
  final double lineMovement;
  final double opened;

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
      ..style = PaintingStyle.fill
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke;
    final paintTrans = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke;

    final ballSize = 12.0 + 5 * opened;
    final outlineWidth = 2.0 * opened;
    final width = 2.0 * opened;
    final linesMargin = 1.0 + (1 - opened) * 4;
    const dotsSpace = 2.0;
    final holeSize = 5.0 * opened;

    // final arcsRotation = 0.0;
    // final dotsRotation = 0.0;
    // final lineMovement = 0.0;

    Rect centerSquare(double squareSize) => Rect.fromLTRB(
          size.width / 2 - squareSize,
          size.height / 2 - squareSize,
          size.width / 2 + squareSize,
          size.height / 2 + squareSize,
        );

    // Dots
    if (opened > 0.0) {
      paint.color = paint.color.withOpacity(opened);
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(dotsRotation);
      canvas.translate(-size.width / 2, -size.height / 2);
      canvas.drawCircle(Offset(size.width / 2 + ballSize + dotsSpace, size.height / 2), 1, paint);
      canvas.drawCircle(Offset(size.width / 2 - ballSize - dotsSpace, size.height / 2), 1, paint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2 - ballSize - dotsSpace), 1, paint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2 + ballSize + dotsSpace), 1, paint);
      canvas.restore();

      // Outline
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), ballSize, paint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), ballSize - outlineWidth, paintTrans);

      // Arcs
      canvas.drawArc(centerSquare(ballSize - outlineWidth), arcsRotation, 1.9, true, paint);
      canvas.drawArc(centerSquare(ballSize - outlineWidth), pi + arcsRotation, 1.9, true, paint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), ballSize - outlineWidth - width, paintTrans);
      paint.color = paint.color.withOpacity(1); // Assuming original color is opaque.
    }

    // Lines
    final maskPaint = Paint();
    final srcInPaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..color = paint.color
      ..strokeWidth = 2;
    final linesRadius = ballSize - outlineWidth - width - linesMargin;
    canvas.saveLayer(centerSquare(linesRadius), maskPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), linesRadius, maskPaint);
    const lines = 12;
    const space = 6;
    for (var i = 0; i < lines; i++) {
      final place = lines / 2 - i + lineMovement;
      canvas.drawLine(Offset(size.width - space * place, 0), Offset(0, size.height - space * place), srcInPaint);
    }
    canvas.restore();
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), holeSize, paintTrans);
    // if (jumpStep > 1) jumpStep = 2 - jumpStep;
    //
    // canvas.translate(0, -size.height / 2 * jumpStep);
    // rotate(canvas, size.width / 2, size.height / 2, pi / 4 * jumpStep);
    // canvas.drawRect(
    //   Rect.fromLTRB(stroke, stroke, size.width - stroke, size.height - stroke),
    //   paint,
    // );
    // canvas.translate(0, size.height / 2 * jumpStep);
    // canvas.rotate(-pi / 4 * jumpStep);
    // canvas.translate(-size.width / 2, size.height / 2);
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}

// class _RectangleCoverPainter extends CustomPainter {
//   _RectangleCoverPainter({
//     required this.jumpStep,
//     required this.devicePixelRatio,
//   });
//
//   final double jumpStep;
//   final double devicePixelRatio;
//
//   void rotate(Canvas canvas, double cx, double cy, double angle) {
//     canvas
//       ..translate(cx, cy)
//       ..rotate(angle)
//       ..translate(-cx, -cy);
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // values = [...values, ...values.reversed];
//     final paint = Paint()
//       ..color = Colors.lightBlueAccent
//       ..style = PaintingStyle.fill;
//
//     print(jumpStep);
//     for (var i = 0.0; i < 6; i += 1) {
//       if (jumpStep <= 1) {
//         canvas.drawRect(
//           Rect.fromLTWH(-10 + 10 * i, -10 + (10 + size.width) * (1 - jumpStep), size.width / 4, size.height + 30),
//           paint,
//         );
//       } else if (jumpStep <= 2) {
//         final t = switch (i) {
//           0 => 2.0,
//           1 => 1.0,
//           2 => 0.0,
//           3 => 0.0,
//           4 => 1.0,
//           5 => 2.0,
//           _ => 0.0
//         };
//         // 0 -> 0
//         // 1 -> 1
//         // 2 -> 2
//         // 3 -> 2 -1
//         // 4 -> 1 -3
//         // 5 -> 0 -5
//         canvas.drawRect(
//           Rect.fromLTWH(-10 + 10 * i, -10 + (10 + size.width) * ((jumpStep - 1) * (t + 1)), size.width / 4, size.height + 30),
//           paint,
//         );
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(_RectangleCoverPainter oldDelegate) {
//     return true;
//     // return !listEquals(this.values, oldDelegate.values);
//   }
// }
