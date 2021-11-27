import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swipe_overlays/swipe_overlay.dart';
import 'package:swipe_overlays/util/image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await precache(const AssetImage('images/none.jpg'));

  runZonedGuarded<void>(
    () => runApp(const _App()),
    (error, stack) => log(
      'Some explosion here...',
      error: error,
      stackTrace: stack,
    ),
  );
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Overlays',
      theme: ThemeData.dark(),
      home: const Scaffold(body: SafeArea(child: _Body())),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    final queryData = MediaQuery.of(context);
    final padding = queryData.padding;
    return Stack(
      children: [
        SizedBox(
          width: queryData.size.width,
          height: queryData.size.height,
          child: const _Page(Location.none),
        ),
        _OverlayWrapper(Location.left, padding, _currentExpandedNotifier),
        _OverlayWrapper(Location.right, padding, _currentExpandedNotifier),
        _OverlayWrapper(Location.bottom, padding, _currentExpandedNotifier),
        _OverlayWrapper(Location.top, padding, _currentExpandedNotifier),
      ],
    );
  }
}

class _OverlayWrapper extends StatelessWidget {
  const _OverlayWrapper(
    this.location,
    this.padding,
    this.currentExpandedNotifier, {
    Key? key,
  }) : super(key: key);

  final Location location;
  final EdgeInsets padding;
  final StreamController<Location> currentExpandedNotifier;

  @override
  Widget build(BuildContext context) {
    return SwipeOverlay(
      location,
      padding,
      currentExpandedNotifier: currentExpandedNotifier,
      child: _Page(location),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page(this.location, {Key? key}) : super(key: key);

  final Location location;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/${describeEnum(location)}.jpg'),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(handleSize),
        child: _Content(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _Text('top left'),
            _Text('top right'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _Text('bottom left'),
            _Text('bottom right'),
          ],
        ),
      ],
    );
  }
}

class _Text extends StatelessWidget {
  const _Text(this.text, {Key? key}) : super(key: key);

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
