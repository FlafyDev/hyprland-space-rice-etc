import 'package:flutter/material.dart';
import 'package:flutter_background/providers/notifications.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

class NotificationsViewer extends HookConsumerWidget {
  const NotificationsViewer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final lineAC = useAnimationController(duration: Duration(seconds: 1));

    return Container(
      height: double.infinity,
      width: double.infinity,
      // padding: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: notifications.asMap().entries.map(
            (entry) {
              final n = entry.value;
              final i = entry.key;
              return _NotificationTile(
                index: i.toDouble(),
                key: ValueKey(n),
                onPressed: () {
                  ref.read(notificationProvider.notifier).closeNotification(i);
                },
                n: n,
              );
            },
          ).toList(),
          // BarContainer(
          //   child: AspectRatio(
          //     aspectRatio: 1,
          //     child: Center(
          //         // child: Icon(Icons.window_rounded, color: Colors.white),
          //         child: Image(
          //       width: 16,
          //       filterQuality: FilterQuality.medium,
          //       image: FileImage(
          //         File(Platform.environment['FB_OS_LOGO']!),
          //       ),
          //       color: Colors.white,
          //     )),
          //   ),
          // ),
          // SizedBox(width: 4),
          // WorkspacesIndicator(),
          // Spacer(),
          // Music(),
          // // SizedBox(width: 4),
          // // Sound(),
          // SizedBox(width: 4),
          // Time(),
        ),
      ),
    );
  }
}

class _NotificationTile extends HookConsumerWidget {
  const _NotificationTile({
    super.key,
    required this.index,
    required this.n,
    required this.onPressed,
  });

  final double index;
  final NotificationData n;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineAC = useAnimationController(duration: Duration(seconds: 1));
    final animatedIndex = useAnimationController(
      duration: Duration(seconds: 1),
      upperBound: 100,
      lowerBound: -1,
      initialValue: -1,
    );
    final created = useAnimationController(duration: Duration(seconds: 1), upperBound: 100, initialValue: 0);

    useEffect(
      () {
        created.animateTo(1, duration: Duration(milliseconds: 1000), curve: Curves.ease);
        return;
      },
      [
        created,
      ],
    );

    useEffect(
      () {
        animatedIndex.animateTo(index, duration: Duration(seconds: 1), curve: Curves.easeOutExpo);
        return;
      },
      [
        animatedIndex,
        index
      ],
    );

    useEffect(() {
      lineAC.repeat();
      return;
    }, [
      lineAC
    ]);

    return AnimatedBuilder(
      animation: Listenable.merge([
        created,
        animatedIndex
      ]),
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 - (300 + 10 * 2) / 2 + 22 * animatedIndex.value,
          top: (100 + 10 * 2) * animatedIndex.value,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 300 + 10 * 2,
              height: 100 + 10 * 2,
              padding: EdgeInsets.all(10),
              child: AnimatedBuilder(
                animation: lineAC,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RectanglePainter(
                      opened: created.value,
                      // opened: 1.0,
                      lineMovement: lineAC.value,
                      title: n.title,
                      description: n.description,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RectanglePainter extends CustomPainter {
  _RectanglePainter({
    required this.lineMovement,
    required this.opened,
    required this.title,
    required this.description,
  });

  final double opened;
  final double lineMovement;
  final String title;
  final String description;

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

    // canvas.drawRect(
    //   Rect.fromLTRB(size.width, 0, size.width, size.height),
    //   paint,
    // );

    final slope = 1.6 + 3.4 * opened;
    final main = Path()
      ..moveTo(0, 0)
      ..lineTo(size.height / slope, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - size.height / slope, 0)
      ..lineTo(0, 0);

    final side1 = Path()
      ..moveTo(0, 0)
      // ..lineTo((size.height - 50) / slope, size.height - 50)
      ..lineTo(30, size.height - 50)
      ..lineTo(30 - (size.height - 50) / slope, 0)
      ..lineTo(0, 0);

    final side2 = Path()
      ..moveTo(0, 0)
      ..lineTo((size.height - 50) / slope, size.height - 50)
      ..lineTo(30, size.height - 50)
      // ..lineTo(30 - (size.height - 50) / slope, 0)
      ..lineTo(0, 0);

    Rect centerSquare(double squareSize) => Rect.fromLTRB(
          size.width / 2 - squareSize,
          size.height / 2 - squareSize,
          size.width / 2 + squareSize,
          size.height / 2 + squareSize,
        );

    canvas
      ..drawPath(main, paintTrans)
      ..save()
      ..translate(-25, 0)
      ..drawPath(side1, paintTrans)
      ..restore()
      ..save()
      ..translate(size.width - 5, size.height - 50)
      ..drawPath(side2, paintTrans)
      ..restore();

    final maskPaint = Paint();
    final srcInPaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..color = paint.color.withOpacity(0.2)
      ..strokeWidth = 2;
    canvas.saveLayer(Rect.fromLTRB(-50, 0, size.width+50, size.height), maskPaint);
    canvas
      ..drawPath(main, paintTrans)
      ..save()
      ..translate(-25, 0)
      ..drawPath(side1, paintTrans)
      ..restore()
      ..save()
      ..translate(size.width - 5, size.height - 50)
      ..drawPath(side2, paintTrans)
      ..restore();
    const lines = 85;
    const space = 7;
    for (var i = 0; i < lines; i++) {
      final place = lines / 2 - i + lineMovement;
      canvas.drawLine(Offset(size.width - space * place-20, 0), Offset(-20, size.width - space * place), srcInPaint);
    }
    canvas.restore();

    canvas
      ..drawPath(main, paint)
      ..save()
      ..translate(-25, 0)
      ..drawPath(side1, paint)
      ..restore()
      ..save()
      ..translate(size.width - 5, size.height - 50)
      ..drawPath(side2, paint)
      ..restore();

    final textStyle = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 20,
      fontFamily: 'Space Mono',
    );
    final textStyle2 = TextStyle(
      color: HSVColor.fromColor(paint.color).withSaturation(0.4).toColor(),
      fontSize: 12,
      fontFamily: 'Orbitron',
      letterSpacing: 0.9,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width - (size.height / slope * 2),
      );
    var xCenter = 10.0;
    var yCenter = 0.0;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: description,
        style: textStyle2,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    xCenter = 15;
    yCenter = 28;
    textPainter2.paint(canvas, Offset(xCenter, yCenter));

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
