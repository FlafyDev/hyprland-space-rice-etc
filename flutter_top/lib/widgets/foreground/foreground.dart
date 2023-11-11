import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/providers/notifications.dart';
import 'package:flutter_background/providers/regions.dart';
import 'package:flutter_background/widgets/volume/volume.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

class Foreground extends HookConsumerWidget {
  const Foreground({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final lineAC = useAnimationController(duration: Duration(seconds: 1));
    final openedAC = useAnimationController(duration: Duration(seconds: 1));

    useEffect(
      () {
        openedAC.addListener(() {
          ref.read(regionsProvider.notifier).isVolume(openedAC.value.round() == 1);
        });
        return;
      },
      [
        openedAC,
      ],
    );

    return AnimatedBuilder(
      animation: openedAC,
      builder: (context, child) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          decoration: openedAC.value > 0
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.withOpacity(0.0),
                      Colors.lightBlue.withOpacity(0.2 * openedAC.value),
                      Colors.lightBlue.withOpacity(0.4 * openedAC.value),
                    ],
                    stops: [
                      0,
                      0.4,
                      1.0,
                    ],
                    end: Alignment.bottomCenter,
                    begin: Alignment.center,
                  ),
                )
              : null,
          // padding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 1920,
                  height: 1080 / 1.5,
                  child: MouseRegion(
                    onEnter: (_) {
                      openedAC.animateTo(0, curve: Curves.easeOutExpo);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 1920,
                  height: 1,
                  child: MouseRegion(
                    onEnter: (_) {
                      openedAC.animateTo(1, curve: Curves.easeOutExpo);
                    },
                  ),
                ),
              ),
              if (openedAC.value != 0)
                Positioned(
                  left: 80,
                  top: 800 + 500 * (1 - openedAC.value),
                  child: const Volume(),
                ),
              // CustomPaint(
              //   painter: _RectanglePainter(),
              // ),
            ],
          ),
        );
      },
    );
  }
}

class _RectanglePainter extends CustomPainter {
  _RectanglePainter();

  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas
      ..translate(cx, cy)
      ..rotate(angle)
      ..translate(-cx, -cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // values = [...values, ...values.reversed];
    const stroke = 2.0;
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final paint2 = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 4;
    final paintTrans = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = stroke;

    // final outline = Path()
    //   ..moveTo(50, 50)
    //   ..relativeLineTo(370, 0)
    //   ..relativeLineTo(15, 15)
    //   ..relativeLineTo(-20*3, 36*3)
    //   ..relativeLineTo(0, -30)
    //   ..relativeLineTo(20*2, -36*2)
    //   ..relativeLineTo(-345, 0)
    //   ..relativeLineTo(0, 300)
    //   ..relativeLineTo(20*2, -36*2)
    //   ..relativeLineTo(0, 30)
    //   ..relativeLineTo(-20*2.2, 36*2.2)
    //   ..relativeLineTo(-20, -10)
    //   ..close()
    //   ;
    // canvas.drawPath(outline, paint);

    // canvas.drawRect(
    //   Rect.fromLTRB(size.width, 0, size.width, size.height),
    //   paint,
    // );

    // canvas.drawLine(
    //   Offset(size.width-slide, 0),
    //   Offset(size.width, size.height),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(0, 0),
    //   Offset(slide, size.height),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(0, 0),
    //   Offset(size.width-slide, 0),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(slide, size.height),
    //   Offset(size.width, size.height),
    //   paint,
    // );

    // canvas.translate(-30, 0);
    // canvas.drawLine(
    //   Offset(50-slide, 0),
    //   Offset(50, size.height),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(0, 0),
    //   Offset(slide, size.height),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(0, 0),
    //   Offset(50-slide, 0),
    //   paint,
    // );
    //
    // canvas.drawLine(
    //   Offset(slide, size.height),
    //   Offset(50, size.height),
    //   paint,
    // );

    // canvas.drawLine(
    //   Offset(size.width - 8, size.height),
    //   Offset(size.width - 8 - size.height / 2, size.height),
    //   paint2,
    // );
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
