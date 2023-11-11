// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/providers/mpris.dart';
import 'package:flutter_background/providers/waveforms.dart';
import 'package:flutter_background/widgets/bar/bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends CustomPainter {
  const WaveformPainter({
    required this.values,
    required this.strokeWidth,
    required this.round,
    required this.middle,
    this.color,
  });

  final List<double> values;
  final double strokeWidth;
  final bool middle;
  final bool round;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white.withOpacity(middle ? 1 : 0)
      ..style = PaintingStyle.stroke
      ..strokeCap = round ? StrokeCap.round : StrokeCap.round
      ..strokeWidth = strokeWidth;
    final paint2 = Paint()
      ..color = color ?? Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = round ? StrokeCap.round : StrokeCap.round
      ..strokeWidth = strokeWidth + 8;

    final widthBetween = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = widthBetween * i;
      if (middle) {
        canvas.drawLine(
          Offset(x, size.height / 2 * (1 - values[i])),
          Offset(x, size.height - size.height / 2 * (1 - values[i])),
          paint,
        );
      } else {
        canvas
          ..drawLine(
            Offset(x, size.height - size.height * values[i] + (strokeWidth + 8) / 2),
            Offset(x, size.height + (strokeWidth + 8) / 2),
            paint2,
          )
          ..drawLine(
            Offset(x, size.height - size.height * values[i] + (strokeWidth + 8) / 2),
            Offset(x, size.height + (strokeWidth + 8) / 2),
            paint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}

class Music extends HookConsumerWidget {
  const Music({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final waveforms = ref.watch(waveformsProvider);

    final lineAC = useAnimationController(duration: Duration(seconds: 1));

    useEffect(() {
      lineAC.repeat();

      return;
    }, [
      lineAC
    ]);

    final toggleAnimController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    return MouseRegion(
      onEnter: (_) => toggleAnimController.animateTo(1, curve: Curves.easeOutExpo, duration: const Duration(milliseconds: 1000)),
      onExit: (_) => toggleAnimController.animateTo(0, curve: Curves.easeOutExpo, duration: const Duration(milliseconds: 300)),
      child: Stack(
        children: [
          // Positioned.fill(child: Container(color: Colors.red)),
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  lineAC,
                  toggleAnimController
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: min(toggleAnimController.value * 5, 1),
                    child: CustomPaint(
                      painter: _BackgroundPainter(
                        lineMovement: lineAC.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: toggleAnimController,
              builder: (context, child) {
                final progress = Curves.easeOutExpo.transform(
                  toggleAnimController.value,
                );

                return Container(
                  padding: EdgeInsets.all(progress * 1),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final playing = ref.watch(mprisProvider.select((value) => value.playing));
                          final cover = ref.watch(mprisProvider.select((value) => value.cover));

                          return Stack(
                            children: [
                              if (cover == null)
                                Container(
                                  margin: EdgeInsets.only(right: progress * 8),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                    ),
                                  ),
                                ),
                              if (cover != null)
                                Opacity(
                                  opacity: progress * 0.8 + 0.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white.withOpacity(0.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.all(progress * 2).copyWith(right: progress * 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          foregroundDecoration: BoxDecoration(
                                            color: playing ? Colors.transparent : Colors.grey, // On pause
                                            backgroundBlendMode: BlendMode.saturation,
                                          ),
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: cover,
                                            filterQuality: FilterQuality.medium,
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned.fill(
                                child: Container(
                                  padding: EdgeInsets.all((1 - progress) * 8).copyWith(right: 8),
                                  child: Opacity(
                                    opacity: cover == null ? 1 : 1 - progress,
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        final waveforms = ref.watch(waveformsProvider(6));
                                        return CustomPaint(
                                          painter: WaveformPainter(
                                            color: HSVColor.fromColor(Colors.lightBlueAccent).withSaturation(0.4).toColor(),
                                            strokeWidth: 2,
                                            values: waveforms.valueOrNull ?? [],
                                            round: true,
                                            middle: true,
                                            // values: [1, 0.2, 0.3, 0.8, 0.3],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (progress != 0)
                        SizedOverflowBox(
                          alignment: Alignment.centerLeft,
                          size: Size(progress * 224, 0),
                          child: Container(
                            width: 224,
                            child: _MusicInfoControls(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _RectanglePainter(
                opened: 0.0,
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.flip(
              flipX: true,
              child: CustomPaint(
                painter: _RectanglePainter(
                  opened: 0.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicInfoControls extends StatelessWidget {
  const _MusicInfoControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Consumer(
                builder: (context, ref, child) {
                  final title = ref.watch(
                        mprisProvider.select(
                          (value) => value.title,
                        ),
                      ) ??
                      '';
                  return Text(
                    title,
                    maxLines: 1,
                    // overflow: TextOverflow.clip,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: HSVColor.fromColor(Colors.lightBlueAccent).withSaturation(0.4).toColor(),
                        ),
                  );
                },
              ),
              // Expanded(
              //   child: Marquee(
              //     text:
              //         '"Revenge" - A Minecraft Parody of Usher\'s DJ Got Us Fallin\' In Love (Music Video)',
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //     startAfter: Duration(seconds: 4),
              //     fadingEdgeEndFraction: 0.1,
              //     showFadingOnlyWhenScrolling: false,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     blankSpace: 40,
              //     velocity: 40,
              //     pauseAfterRound: Duration(seconds: 4),
              //     accelerationDuration: Duration(seconds: 1),
              //     accelerationCurve: Curves.linear,
              //     decelerationDuration: Duration(milliseconds: 500),
              //     decelerationCurve: Curves.easeOut,
              //   ),
              // ),
              // const SizedBox(height: 1),
              Consumer(
                builder: (context, ref, child) {
                  final author = ref.watch(
                        mprisProvider.select(
                          (value) => value.author,
                        ),
                      ) ??
                      '';
                  return Text(
                    author,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment(0, 1.2),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final position = ref.watch(
                          mprisProvider.select(
                            (value) => value.position,
                          ),
                        );
                        final length = ref.watch(
                          mprisProvider.select(
                            (value) => value.length,
                          ),
                        );
                        if (length == null || position == null) {
                          return const SizedBox();
                        }
                        return LinearProgressIndicator(
                          value: position.inSeconds / length.inSeconds,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // const SizedBox(width: 6),
                // Icon(
                //   Icons.skip_previous,
                //   color: Colors.white,
                //   size: 20,
                // ),
                // Icon(
                //   Icons.play_arrow,
                //   color: Colors.white,
                //   size: 20,
                // ),
                // Icon(
                //   Icons.skip_next,
                //   color: Colors.white,
                //   size: 20,
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({
    required this.lineMovement,
  });

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
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paintTrans);
    const lines = 80;
    const space = 7;
    for (var i = 0; i < lines; i++) {
      final place = lines / 2 - i + lineMovement;
      canvas.drawLine(Offset(size.width - space * place, 0), Offset(0, size.width - space * place), srcInPaint);
    }
    canvas.restore();
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.lineMovement != lineMovement;
    // return !listEquals(this.values, oldDelegate.values);
  }
}

class _RectanglePainter extends CustomPainter {
  _RectanglePainter({
    required this.opened,
  });

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

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height / 2 - 8),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height / 2 + 8),
      Offset(size.width, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height / 2 - 8),
      Offset(size.width - 2, size.height / 2 - 4),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height / 2 + 8),
      Offset(size.width - 2, size.height / 2 + 4),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 3, size.height / 2 - 4),
      Offset(size.width - 3, size.height / 2 + 4),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 8, 0),
      Offset(size.width, 0),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 8, size.height),
      Offset(size.width, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 8, 0),
      Offset(size.width - 8 - size.height / 2, 0),
      paint2,
    );

    canvas.drawLine(
      Offset(size.width - 8, size.height),
      Offset(size.width - 8 - size.height / 2, size.height),
      paint2,
    );
  }

  @override
  bool shouldRepaint(_RectanglePainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
