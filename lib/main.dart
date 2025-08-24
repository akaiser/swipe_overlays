import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swipe_overlays/swipe_overlay.dart';
import 'package:swipe_overlays/util/image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await precache(const AssetImage('images/none.webp'));

  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Swipe Overlays',
    theme: ThemeData.dark(),
    home: const Scaffold(body: SafeArea(child: _Body())),
  );
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late StreamController<Location> _currentExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _currentExpandedNotifier = StreamController<Location>.broadcast();
  }

  @override
  void dispose() {
    _currentExpandedNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const _Page(Location.none),
      _OverlayWrapper(Location.left, _currentExpandedNotifier),
      _OverlayWrapper(Location.right, _currentExpandedNotifier),
      _OverlayWrapper(Location.bottom, _currentExpandedNotifier),
      _OverlayWrapper(Location.top, _currentExpandedNotifier),
    ],
  );
}

class _OverlayWrapper extends StatelessWidget {
  const _OverlayWrapper(
    this.location,
    this.currentExpandedNotifier,
  );

  final Location location;
  final StreamController<Location> currentExpandedNotifier;

  @override
  Widget build(BuildContext context) => SwipeOverlay(
    location,
    currentExpandedNotifier: currentExpandedNotifier,
    child: _Page(location),
  );
}

class _Page extends StatelessWidget {
  const _Page(this.location);

  final Location location;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('images/${location.name}.webp'),
      ),
    ),
    child: const Padding(
      padding: EdgeInsets.all(handleSize),
      child: _Content(),
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Text('top left'),
          _Text('top right'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Text('bottom left'),
          _Text('bottom right'),
        ],
      ),
    ],
  );
}

class _Text extends StatelessWidget {
  const _Text(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => ColoredBox(
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
