import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Asteroid extends HookConsumerWidget {
  const Asteroid({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image(
      width: 150,
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.high,
      image: AssetImage('assets/asteroid.png'),
    );
  }
}
