import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_overlays/swipe_overlay.dart';
import 'package:swipe_overlays/util/preload.dart';

final currentExpanded = StateProvider<SwipeDirection>(
  (_) => SwipeDirection.none,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait(
    ['main', 'left', 'up', 'right', 'down']
        .map((e) => AssetImage('images/$e.jpg'))
        .map(preload),
  );

  runZonedGuarded<void>(
    () => runApp(
      const ProviderScope(
        child: MaterialApp(
          title: 'Swipe Overlays',
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: _Body()),
        ),
      ),
    ),
    (dynamic error, dynamic stack) {
      log('Some explosion here...', error: error, stackTrace: stack);
    },
  );
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/main.jpg'),
            ),
          ),
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            padding: const EdgeInsets.all(handleSize),
            child: const Text(
              'main',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const _OverlayWrapper(SwipeDirection.left),
        const _OverlayWrapper(SwipeDirection.up),
        const _OverlayWrapper(SwipeDirection.right),
        const _OverlayWrapper(SwipeDirection.down),
      ],
    );
  }
}

class _OverlayWrapper extends StatelessWidget {
  const _OverlayWrapper(this.direction, {Key? key}) : super(key: key);

  final SwipeDirection direction;

  @override
  Widget build(BuildContext context) {
    final directionValue = describeEnum(direction);
    return SwipeOverlay(
      direction: direction,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('images/$directionValue.jpg'),
          ),
        ),
        child: Text(
          directionValue,
          style: const TextStyle(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}
