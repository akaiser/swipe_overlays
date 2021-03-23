import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_overlays/swipe_overlay.dart';
import 'package:swipe_overlays/util/preload.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await preload(const AssetImage('images/main.jpg'));

  runZonedGuarded<void>(
    () => runApp(
      const ProviderScope(
        child: MaterialApp(
          title: 'Swipe Overlays',
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: _MainBody()),
        ),
      ),
    ),
    (dynamic error, dynamic stack) {
      log('Some explosion here...', error: error, stackTrace: stack);
    },
  );
}

class _MainBody extends StatelessWidget {
  const _MainBody({Key? key}) : super(key: key);

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
            child: const Center(
              child: Text(
                'Main Content goes here',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SwipeOverlay(
          direction: SwipeDirection.left,
          child: ListView(
            children: List.generate(
              100,
              (index) => Text('item $index'),
            ),
          ),
        ),
        const SwipeOverlay(
          direction: SwipeDirection.up,
          child: Text('up'),
        ),
        const SwipeOverlay(
          direction: SwipeDirection.right,
          child: Text('right'),
        ),
        const SwipeOverlay(
          direction: SwipeDirection.down,
          child: Text('down'),
        ),
      ],
    );
  }
}
