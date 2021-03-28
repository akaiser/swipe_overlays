import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(statusBarColor: Colors.red),
            child: Scaffold(body: _Body()),
          ),
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
        Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/main.jpg'),
            ),
          ),
          padding: const EdgeInsets.all(handleSize),
          child: const _TestContent(Colors.white),
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
        child: const _TestContent(Colors.black),
      ),
    );
  }
}

class _TestContent extends StatelessWidget {
  const _TestContent(
    this.textColor, {
    Key? key,
  }) : super(key: key);

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: textColor, fontWeight: FontWeight.bold);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('top left', style: textStyle),
            Text('top right', style: textStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('bottom left', style: textStyle),
            Text('bottom right', style: textStyle),
          ],
        ),
      ],
    );
  }
}
