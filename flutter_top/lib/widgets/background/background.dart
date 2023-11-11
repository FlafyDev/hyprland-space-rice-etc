// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/providers/hyprland.dart';
import 'package:flutter_background/providers/time.dart';
import 'package:flutter_background/providers/waveforms.dart';
import 'package:flutter_background/utils/bouncher.dart';
import 'package:flutter_background/utils/rect_custom_clipper.dart';
import 'package:flutter_background/widgets/asteroid/asteroid.dart';
import 'package:flutter_background/widgets/bar/parts/music.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyprland_ipc/hyprland_ipc.dart';
import 'package:intl/intl.dart';

class Background extends HookConsumerWidget {
  const Background({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hyprland = ref.watch(hyprlandProvider);
    final workspaceNumber = useState(0);
    final shownAC = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    useEffect(
      () {
        var activeWorkspace = '';
        var workspaces = <String, int>{};
        Future<void> checkWorkspaces(Event? event) async {
          if (event is CloseWindowEvent || event is OpenWindowEvent || event is WorkspaceEvent || true) {
            workspaces = {};
            for (final client in await hyprland.value!.getClients()) {
              workspaces[client.workspaceName] = (workspaces[client.workspaceName] ?? 0) + (client.floating ? 0 : 1);
            }
            if (event is WorkspaceEvent) {
              activeWorkspace = event.workspaceName;
              workspaceNumber.value = int.parse(event.workspaceName);
            }
          }
          // print(workspaces);
          // print(activeWorkspace);
          if ((workspaces[activeWorkspace] ?? 0) < 1) {
            if (shownAC.status != AnimationStatus.forward) {
              unawaited(shownAC.forward());
            }
          } else {
            if (shownAC.status != AnimationStatus.reverse) {
              unawaited(shownAC.reverse());
            }
          }
          // emptyWorkspace.value = (workspaces[activeWorkspace] ?? 0) < 1;
        }

        final subscription = hyprland.value?.eventsStream.listen(checkWorkspaces);
        return () => subscription?.cancel();
      },
      [
        hyprland
      ],
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Image(
            image: AssetImage('assets/wallpaper.png'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 400),
          //   curve: Curves.easeOut,
          //   // left: -5.0 * (5 - workspaceNumber.value) - 2.5,
          //   child: Image(
          //     image: AssetImage(
          //       '/nix/store/spna4cfdd6r3g2pbdwldz3k55fq9nvm3-windows11-flower.jpg',
          //     ),
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 400),
          //   curve: Curves.easeOut,
          //   left: -5.0 * (5 - workspaceNumber.value) - 2.5,
          //   child: Transform.scale(
          //     scale: 1.02,
          //     child: Image(
          //       image: AssetImage(
          //         '/home/flafy/Pictures/flower-front.png',
          //       ),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          // Visibility(
          //   visible: !kDebugMode,
          //   child: AnimatedBuilder(
          //     animation: shownAC,
          //     builder: (context, child) {
          //       return Visibility(
          //         visible: shownAC.value > 0,
          //         child: Opacity(
          //           opacity: shownAC.value,
          //           child: Bubbles(
          //             horizontalDistance: 200 *
          //                 (1 - Curves.easeInOutExpo.transform(shownAC.value)),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // Positioned.fill(
          //   child: AnimatedBuilder(
          //     animation: shownAC,
          //     builder: (context, child) {
          //       return Align(
          //         alignment: Alignment(
          //           0,
          //           (0.1 * Curves.easeOutExpo.transform(shownAC.value)) - 1,
          //         ),
          //         child: Visibility(
          //           visible: shownAC.value > 0,
          //           child: Opacity(
          //             opacity: shownAC.value,
          //             child: child,
          //           ),
          //         ),
          //       );
          //     },
          //     child: Consumer(
          //       builder: (context, ref, child) {
          //         final time = ref.watch(timeProvider);
          //         return time
          //                 .whenData(
          //                   (time) => Text(
          //                     DateFormat('HH:mm').format(time),
          //                     style: TextStyle(
          //                       fontSize: 100,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.white,
          //                       decoration: TextDecoration.none,
          //                       shadows: <Shadow>[
          //                         Shadow(
          //                           offset: Offset(5.0, 5.0),
          //                           blurRadius: 10.0,
          //                           color: Color.fromARGB(255, 0, 0, 0),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 )
          //                 .value ??
          //             const SizedBox();
          //       },
          //     ),
          //   ),
          // ),

          Positioned(
            top: 432,
            left: 1370,
            child: Consumer(
              builder: (context, ref, child) {
                final time = ref.watch(timeProvider);
                return time
                        .whenData(
                          (time) => Text(
                            DateFormat('HH:mm').format(time),
                            style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(5.0, 5.0),
                                  blurRadius: 10.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        )
                        .value ??
                    const SizedBox();
              },
            ),
          ),
          // Positioned(
          //   left: 1920 / 2,
          //   top: 1080 / 2,
          //   child: AnimatedBuilder(
          //     animation: shownAC,
          //     builder: (context, child) {
          //       return Visibility(
          //         visible: shownAC.value > 0,
          //         child: Align(
          //           alignment: Alignment(
          //             0,
          //             1.4 - (0.4 * Curves.easeOutExpo.transform(shownAC.value)),
          //           ),
          //           child: Opacity(
          //             opacity: shownAC.value / 9,
          //             child: child,
          //           ),
          //         ),
          //       );
          //     },
          //     child: Container(
          //       width: 930,
          //       height: 930,
          //       child: _BackgroundWaveforms(
          //         blur: false,
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            left: 1920 / 2,
            top: 1080 / 2,
            child: AnimatedBuilder(
              animation: shownAC,
              builder: (context, child) {
                return Visibility(
                  visible: shownAC.value > 0,
                  child: Align(
                    alignment: Alignment(
                      0,
                      1.4 - (0.4 * Curves.easeOutExpo.transform(shownAC.value)),
                    ),
                    child: Opacity(
                      opacity: shownAC.value / 6,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                width: 830,
                height: 830,
                child: _BackgroundWaveforms(
                  blur: 10,
                  out: true,
                ),
              ),
            ),
          ),
          Image(
            image: AssetImage('assets/wallpaper-planet-ring.png'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 1920 / 2,
            top: 1080 / 2,
            child: AnimatedBuilder(
              animation: shownAC,
              builder: (context, child) {
                return Visibility(
                  visible: shownAC.value > 0,
                  child: Align(
                    alignment: Alignment(
                      0,
                      1.4 - (0.4 * Curves.easeOutExpo.transform(shownAC.value)),
                    ),
                    child: Opacity(
                      opacity: shownAC.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                width: 400,
                height: 400,
                child: _BackgroundWaveforms(
                  blur: 90,
                  out: false,
                ),
              ),
            ),
          ),
          Image(
            image: AssetImage('assets/wallpaper-planet-ring-top.png'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 650,
            top: 420,
            child: Asteroid(),
          ),
          Image(
            image: AssetImage('assets/wallpaper-top.png'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 400,
            top: 700,
            child: Asteroid(),
          ),
          Positioned(
            left: 600,
            top: 620,
            child: Asteroid(),
          ),
          Positioned(
            left: 800,
            top: 620,
            child: Asteroid(),
          ),
          Positioned(
            left: 800,
            top: 620,
            child: Asteroid(),
          ),
        ],
      ),
    );
  }
}

class _BackgroundWaveforms extends HookConsumerWidget {
  const _BackgroundWaveforms({super.key, required this.blur, required this.out});

  final double blur;
  final bool out;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waveforms = ref.watch(waveformsProvider(50));
    return CustomPaint(
      painter: CircularWaveformPainter(
        values: waveforms.valueOrNull ?? [],
        strokeWidth: 20,
        round: true,
        blur: blur,
        out: out,
      ),
    );
  }
}

double _convertRadiusToSigma(double radius) {
  return radius * 0.57735 + 0.5;
}

class CircularWaveformPainter extends CustomPainter {
  CircularWaveformPainter({
    required this.values,
    required this.strokeWidth,
    required this.round,
    required this.blur,
    required this.out,
  });

  List<double> values;
  final double strokeWidth;
  final bool round;
  final double blur;
  final bool out;

  @override
  void paint(Canvas canvas, Size size) {
    // values = [...values, ...values.reversed];
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(0, 0),
        size.width,
        [
          Colors.blue.withOpacity(0),
          Colors.blue.withOpacity(0),
          Colors.blueAccent.withOpacity(0.7),
          Colors.blue.withOpacity(0.2),
          // Colors.purpleAccent.withOpacity(0.2),
          // Colors.blue.withOpacity(0),
        ],
        [
          0.17,
          0.57,
          0.7,
          0.8,
          // 0.9,
          // 1,
        ],
      )
      // ..shader = ui.Gradient.radial(
      //   Offset(0, 0),
      //   size.width,
      //   [
      //     Colors.blue.withOpacity(0),
      //     Colors.greenAccent.withOpacity(0.7),
      //     Colors.blue.withOpacity(0.9),
      //   ],
      //   [
      //     0.4,
      //     0.7,
      //     1.0
      //   ],
      // )
      // blur
      ..maskFilter = blur != 0
          ? MaskFilter.blur(
              BlurStyle.normal,
              _convertRadiusToSigma(blur),
            )
          : null
      ..style = PaintingStyle.fill
      ..strokeCap = round ? StrokeCap.round : StrokeCap.square
      ..strokeWidth = 4;

    final paint2 = Paint()
      ..shader = ui.Gradient.radial(
        Offset(0, 0),
        size.width,
        [
          Colors.blue.withOpacity(0),
          Colors.blueAccent.withOpacity(0.1),
        ],
        [
          0.709,
          0.709,
        ],
      )
      ..maskFilter = blur != 0
          ? MaskFilter.blur(
              BlurStyle.normal,
              _convertRadiusToSigma(2),
            )
          : null
      ..style = PaintingStyle.fill
      ..strokeCap = round ? StrokeCap.round : StrokeCap.square
      ..strokeWidth = 20;

    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final a = out ? 2 : 1.3;
      final b = out ? 1 : 1.2;
      // final length = a * (1 - pow(e, -b * values[i]));
      final length = a * pow(values[i], b);
      final progress = i / (values.length - 1);
      // I was about to start my brain, but then github copilot did it all for me :^)
      // final start = Offset(sin(progress * pi * 2) * size.width / 2, cos(progress * pi * 2) * size.height / 2);
      final end = Offset(sin(progress * pi * 2) * size.width / 2 * (1 + length), cos(progress * pi * 2) * size.height / 2 * (1 + length));
      points.add(end);
      // canvas.drawLine(
      //   start,
      //   end,
      //   paint,
      // );
    }
    final path = Path();

    final splinePoints = <Offset>[
      ...points,
    ];

    for (var i = 1; i < points.length - 1; i++) {
      final xc = (points[i].dx + points[i + 1].dx) / 2;
      final yc = (points[i].dy + points[i + 1].dy) / 2;
      splinePoints[i] = Offset(xc, yc);
    }

    path.moveTo(splinePoints.first.dx, splinePoints.first.dy);

    for (var i = 1; i < splinePoints.length; i++) {
      final xc = (splinePoints[i].dx + splinePoints[i - 1].dx) / 2;
      final yc = (splinePoints[i].dy + splinePoints[i - 1].dy) / 2;
      path.quadraticBezierTo(splinePoints[i - 1].dx, splinePoints[i - 1].dy, xc, yc);
    }
    if (!out) {
      canvas
        ..drawPath(path, paint)
        ..drawPath(path, paint2);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CircularWaveformPainter oldDelegate) {
    return true;
    // return !listEquals(this.values, oldDelegate.values);
  }
}
