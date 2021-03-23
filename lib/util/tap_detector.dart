import 'package:flutter/material.dart';

class TapDetector extends StatelessWidget {
  const TapDetector({
    Key? key,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Feedback.wrapForTap(onTap, context),
      child: child is Container
          ? child
          : Container(
              color: Colors.transparent,
              child: child,
            ),
    );
  }
}
