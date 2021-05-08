import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_overlays/swipe_overlay.dart';
import 'package:swipe_overlays/util/image.dart' as image_util;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait(
    Location.values
        .map(describeEnum)
        .map((value) => AssetImage('images/$value.jpg'))
        .map(image_util.precacheImage),
  );

  runZonedGuarded<void>(
    () => runApp(
      ProviderScope(
        child: MaterialApp(
          title: 'Swipe Overlays',
          theme: ThemeData(brightness: Brightness.dark),
          debugShowCheckedModeBanner: false,
          home: const Scaffold(body: _Body()),
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
    final queryData = MediaQuery.of(context);
    final padding = queryData.padding;
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            width: queryData.size.width,
            height: queryData.size.height,
            child: const _Background(Location.none),
          ),
          _OverlayWrapper(Location.left, padding),
          _OverlayWrapper(Location.right, padding),
          _OverlayWrapper(Location.bottom, padding),
          _OverlayWrapper(Location.top, padding),
        ],
      ),
    );
  }
}

class _OverlayWrapper extends StatelessWidget {
  const _OverlayWrapper(
    this.location,
    this.padding, {
    Key? key,
  }) : super(key: key);

  final Location location;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SwipeOverlay(
      location,
      padding,
      child: _Background(location),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background(this.location, {Key? key}) : super(key: key);

  final Location location;

  @override
  Widget build(BuildContext context) {
    const content = _TestContent();
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/${describeEnum(location)}.jpg'),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(handleSize),
        child: content,
      ),
    );
  }
}

class _TestContent extends StatelessWidget {
  const _TestContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SomeText('top left'),
            SomeText('top right'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SomeText('bottom left'),
            SomeText('bottom right'),
          ],
        ),
      ],
    );
  }
}

class SomeText extends StatelessWidget {
  const SomeText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
