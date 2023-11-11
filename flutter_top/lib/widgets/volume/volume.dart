import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/providers/time.dart';
import 'package:flutter_background/widgets/bar/bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_drawing/path_drawing.dart';

class Volume extends HookConsumerWidget {
  const Volume({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineAC = useAnimationController(duration: Duration(seconds: 1));
    final slowerAC = useAnimationController(duration: Duration(seconds: 150));
    final volume = useState<double>(0);

    useEffect(
      () {
        Process.run(
          'pactl',
          [
            'get-sink-volume',
            '@DEFAULT_SINK@',
          ],
        ).then((res) {
          final percentage = res.stdout.toString().split('/')[1].trim();
          volume.value = int.parse(percentage.substring(0, percentage.length - 1)) / 100.0;
        });
        return;
      },
      [],
    );

    useEffect(() {
      lineAC.repeat();

      return;
    }, [
      lineAC
    ]);

    useEffect(() {
      slowerAC.repeat();

      return;
    }, [
      slowerAC
    ]);

    // useEffect(
    //   () {
    //     FlutterVolumeController.addListener(
    //       (v) {
    //         volume.value = v;
    //       },
    //     );
    //     return;
    //   },
    //   [volume],
    // );

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          volume.value = (volume.value - 0.02 * pointerSignal.scrollDelta.dy / 40).clamp(0.0, 1.0);
          Process.run(
            'pactl',
            [
              'set-sink-volume',
              '@DEFAULT_SINK@',
              '${(volume.value * 100).round()}%',
            ],
          );
        }
      },
      child: Container(
        height: 200,
        width: 500,
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            lineAC,
            slowerAC
          ]),
          builder: (context, child) {
            return CustomPaint(
              painter: _RectanglePainter(
                lineMovement: lineAC.value,
                slowerMovement: slowerAC.value,
                progress: volume.value,
              ),
            );
          },
        ),
      ),
    );
    // return BarContainer(
    //   child: Container(
    //     width: 150,
    //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         time.whenData(
    //               (time) {
    //                 return Column(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(
    //                       DateFormat('HH:mm').format(time),
    //                       style:
    //                           Theme.of(context).textTheme.titleSmall!.copyWith(
    //                                 fontSize: 13,
    //                               ),
    //                     ),
    //                     Text(
    //                       DateFormat('MMMM dd, yyyy').format(time),
    //                       style: Theme.of(context)
    //                           .textTheme
    //                           .labelMedium!
    //                           .copyWith(fontSize: 11),
    //                     ),
    //                   ],
    //                 );
    //               },
    //             ).valueOrNull ??
    //             Container(),
    //         const Icon(Icons.notifications_outlined, color: Colors.white),
    //       ],
    //     ),
    //   ),
    // );
  }
}

// return CustomPaint(
//   painter: _RectanglePainter(
//     dotsRotation: dots * 2 * pi,
//     arcsRotation: arcs * 2 * pi,
//     lineMovement: lines,
//     opened: openedAC.value,
//   ),
// );

class _RectanglePainter extends CustomPainter {
  _RectanglePainter({
    required this.lineMovement,
    required this.slowerMovement,
    required this.progress,
  });

  final double lineMovement;
  final double slowerMovement;
  final double progress;

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
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke;
    final paintBack = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke;
    final paintFill = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = stroke
      ..style = PaintingStyle.fill;
    final paintFillProgress = Paint()
      ..color = Colors.blue
      ..strokeWidth = stroke
      ..style = PaintingStyle.fill;
    // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
    final paint2 = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 5;
    final paintTrans = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke

    final outer = Path()
      ..moveTo(90 * cos(pi * 1.8) + 100, 90 * sin(pi * 1.8) + 100)
      ..relativeLineTo(200, 0)
      ..relativeLineTo(30, 30)
      ..relativeLineTo(80, 0)
      ..relativeLineTo(15, 15)
      ..relativeLineTo(0, 50)
      ..relativeLineTo(-5, 5)
      ..relativeLineTo(-110, 0)
      ..relativeLineTo(-15, 15)
      ..relativeLineTo(-202, 0);

    Rect centerSquare(double squareSize) => Rect.fromLTRB(
          size.width / 2 - squareSize,
          size.height / 2 - squareSize,
          size.width / 2 + squareSize,
          size.height / 2 + squareSize,
        );

    canvas.drawPath(outer, paintTrans);

    final maskPaint = Paint();
    final srcInPaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..color = paint.color.withOpacity(0.2)
      ..strokeWidth = 2;
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), maskPaint);
    canvas.drawPath(outer, paintTrans);

    canvas.drawCircle(
      Offset(100, 100),
      91,
      paintTrans,
    );
    const lines = 80;
    const space = 7;
    for (var i = 0; i < lines; i++) {
      final place = lines / 2 - i + lineMovement;
      canvas.drawLine(Offset(size.width - space * place, 0), Offset(0, size.width - space * place), srcInPaint);
    }
    canvas.restore();

    final innerTop = Path()
      ..moveTo(90 * cos(pi * 1.8) + 100 + 12, 90 * sin(pi * 1.8) + 100 + 10 - 3)
      ..relativeLineTo(188 - 3, 0)
      ..relativeLineTo(30, 30)
      ..relativeLineTo(82, 0)
      ..relativeLineTo(10, 10)
      ..relativeLineTo(-122, 0)
      ..relativeLineTo(-31, -32)
      ..relativeLineTo(-290, 0)
      ..close();

    canvas.drawPath(innerTop, paintFill);

    final innerBottom = Path()
      ..moveTo(90 * cos(pi * 0.14) + 100, 90 * sin(pi * 0.14) + 100)
      ..relativeLineTo(312 - 3, 0)
      ..relativeLineTo(-4, 4)
      ..relativeLineTo(-108 + 3, 0)
      ..relativeLineTo(-15, 15)
      ..relativeLineTo(-200, 0);

    canvas.drawPath(innerBottom, paint);

    canvas.drawRect(
      Rect.fromLTWH(
        90 * cos(pi * 2) + 100,
        90 * sin(pi * 2) + 100,
        302,
        32,
      ),
      paintTrans,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        90 * cos(pi * 2) + 100,
        90 * sin(pi * 2) + 100,
        302 * progress,
        32,
      ),
      paintFillProgress,
    );

    canvas.drawArc(
      Rect.fromLTRB(100 - 95, 100 - 95, 195, 195),
      pi * 1.8,
      pi * 0.4,
      true,
      paintTrans,
    );

    canvas.save();
    rotate(canvas, 100, 100, pi * 2 * 4 * progress + pi * 2 * slowerMovement);
    final circle = Path()..addOval(Rect.fromLTRB(10, 10, 190, 190));
    canvas.drawPath(
        dashPath(
          circle,
          dashArray: CircularIntervalList<double>([
            5,
            3,
          ]),
        ),
        paint);
    canvas.restore();

    canvas.drawCircle(
      Offset(100, 100),
      87.5,
      paintBack,
    );

    canvas.save();
    rotate(canvas, 100, 100, -pi * 2 * slowerMovement);
    canvas.drawArc(
      Rect.fromLTRB(14, 14, 186, 186),
      pi + pi * progress,
      pi * 0.8,
      true,
      paintFill,
    );

    canvas.drawArc(
      Rect.fromLTRB(14, 14, 186, 186),
      pi + pi + pi * progress / 1.25,
      pi * 0.8 + pi * progress / 2.5,
      true,
      paintFill,
    );
    canvas.restore();

    canvas.drawCircle(
      Offset(100, 100),
      82,
      paint,
    );

    canvas.drawCircle(
      Offset(100, 100),
      78,
      paintTrans,
    );

    canvas.drawPath(outer, paint);

    final textStyle = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 40,
      fontFamily: 'Orbitron',
    );
    final textStyle2 = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 35,
      fontFamily: 'Orbitron',
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).round()}%',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    var xCenter = (200 - textPainter.width) / 2;
    var yCenter = (200 - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'Volume',
        style: textStyle2,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    xCenter = 190;
    yCenter = 60;
    textPainter2.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
