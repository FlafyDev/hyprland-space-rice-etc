import 'package:flutter/material.dart';
import 'package:flutter_background/providers/time.dart';
import 'package:flutter_background/widgets/bar/bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' as intl;

class Time extends HookConsumerWidget {
  const Time({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(timeProvider);
    final lineAC = useAnimationController(duration: Duration(seconds: 1));

    useEffect(() {
      lineAC.repeat();

      return;
    }, [
      lineAC
    ]);

    return ClipRect(
      child: AnimatedBuilder(
        animation: lineAC,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(2),
            width: 120,
            height: double.infinity,
            child: CustomPaint(
              painter: _RectanglePainter(
                lineMovement: lineAC.value,
                time: time.valueOrNull ?? DateTime.now(),
              ),
            ),
          );
        },
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
    required this.time,
    required this.lineMovement,
  });

  final DateTime time;
  final double lineMovement;

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
    final paintFill = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;
    // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
    final paint2 = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 5;
    final paintTrans = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      // ..style = jumpStep > 1 ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke;
    final topBarSize = Size(50, 6);
    final bottomBarSize = Size(30, 6);
    final topBarProgress = time.millisecond/999;
    final bottomBarProgress = time.second / 59 / 1.2;

    // canvas.drawRect(
    //   Rect.fromLTRB(size.width - topBarSize.width, 0, size.width, topBarSize.height),
    //   paint,
    // );

    canvas.drawRect(
      Rect.fromLTRB(size.width - topBarSize.width, 0, size.width - topBarSize.width * (1.0 - topBarProgress), topBarSize.height),
      paintFill,
    );

    canvas.drawLine(
      Offset(size.width - topBarSize.width, 0),
      Offset(size.width - topBarSize.width + 10, topBarSize.height),
      paint2,
    );

    canvas.drawLine(
      Offset(size.width - 10 + 4, -3),
      Offset(size.width + 4, topBarSize.height - 3),
      paint2,
    );

    canvas.drawLine(
      Offset(size.width - topBarSize.width, topBarSize.height),
      Offset(size.width, topBarSize.height),
      paint2,
    );

    canvas.drawRect(
      Rect.fromLTRB(0, size.height - bottomBarSize.height, bottomBarSize.width, size.height),
      paint2,
    );

    canvas.drawRect(
      Rect.fromLTRB(0, size.height - bottomBarSize.height, bottomBarSize.width * bottomBarProgress, size.height),
      paintFill,
    );

    canvas.drawLine(
      Offset(0, size.height - bottomBarSize.height),
      Offset(bottomBarSize.width, size.height - bottomBarSize.height),
      paint2,
    );

    canvas.drawLine(
      Offset(bottomBarSize.width - 10, size.height - bottomBarSize.height),
      Offset(bottomBarSize.width, size.height),
      paint2,
    );

    canvas.drawLine(
      Offset(0 - 3, size.height - bottomBarSize.height + 3),
      Offset(10 - 3, size.height + 3),
      paint2,
    );

    final outlinePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - topBarSize.width, 0)
      ..lineTo(size.width - topBarSize.width + 10, topBarSize.height)
      ..lineTo(size.width, topBarSize.height)
      ..lineTo(size.width, size.height)
      ..lineTo(bottomBarSize.width, size.height)
      ..lineTo(bottomBarSize.width - 10, size.height - bottomBarSize.height)
      ..lineTo(0, size.height - bottomBarSize.height)
      ..lineTo(0, 0);

    canvas.drawPath(outlinePath, paintTrans);

    Rect centerSquare(double squareSize) => Rect.fromLTRB(
          size.width / 2 - squareSize,
          size.height / 2 - squareSize,
          size.width / 2 + squareSize,
          size.height / 2 + squareSize,
        );

    final maskPaint = Paint();
    final srcInPaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..color = paint.color.withOpacity(0.2)
      ..strokeWidth = 2;
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), maskPaint);
    canvas.drawPath(outlinePath, paintTrans);
    const lines = 40;
    const space = 7;
    for (var i = 0; i < lines; i++) {
      final place = lines / 2 - i + lineMovement;
      canvas.drawLine(Offset(size.width - space * place, 0), Offset(0, size.width - space * place), srcInPaint);
    }
    canvas.restore();
    canvas.drawPath(outlinePath, paint);

    final textStyle = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 20,
      fontFamily: 'Space Mono',
    );
    final textStyle2 = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 10,
      fontFamily: 'Space Mono',
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: intl.DateFormat('HH:mm').format(time),
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    var xCenter = (size.width - topBarSize.width - (textPainter.width - 5)) / 2;
    var yCenter = (size.height - bottomBarSize.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: intl.DateFormat('MMMM dd').format(time),
        style: textStyle2,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    xCenter = bottomBarSize.width + 2;
    yCenter = (size.height - bottomBarSize.height + size.height - textPainter2.height - 6) / 2 - 1;
    textPainter2.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
