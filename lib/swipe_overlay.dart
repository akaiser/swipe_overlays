import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_overlays/main.dart';

const handleSize = 40.0;
const _duration = Duration(seconds: 1);

enum SwipeDirection { left, up, right, down, none }

class SwipeOverlay extends StatefulWidget {
  const SwipeOverlay({
    Key? key,
    required this.direction,
    required this.child,
  }) : super(key: key);

  final SwipeDirection direction;
  final Widget child;

  bool get isHorizontal =>
      direction == SwipeDirection.left || direction == SwipeDirection.right;

  @override
  _SwipeOverlayState createState() => _SwipeOverlayState();
}

class _SwipeOverlayState extends State<SwipeOverlay> {
  bool _isExpanded = false;
  double _offset = 0;

  final _handleIcon = Icon(
    Icons.drag_handle,
    size: handleSize,
    color: Colors.white.withOpacity(0.4),
  );

  void _setExpanded(bool isExpanded) {
    setState(() => _isExpanded = isExpanded);
    _calculateOffset();

    context.read(currentExpanded).state =
        _isExpanded ? widget.direction : SwipeDirection.none;
  }

  void _calculateOffset({bool init = false}) {
    final screenSize = MediaQuery.of(context).size;
    _offset = !_isExpanded || init
        ? widget.isHorizontal
            ? screenSize.width
            : screenSize.height -
                (widget.direction == SwipeDirection.up
                    ? 0 // 24 on mobile if we would add SafeArea
                    : 0)
        : 0 + handleSize;
  }

  double get offsetByDirection {
    final direction = widget.direction;
    return direction == SwipeDirection.right || direction == SwipeDirection.down
        ? handleSize - _offset
        : _offset - handleSize;
  }

  @override
  void didChangeDependencies() {
    _calculateOffset(init: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.isHorizontal;

    return Consumer(
      builder: (context, watch, child) {
        final current = watch(currentExpanded).state;
        return AnimatedPositioned(
          left: isHorizontal
              ? offsetByDirection +
                  (current == SwipeDirection.right &&
                          widget.direction == SwipeDirection.left
                      ? handleSize
                      : (current == SwipeDirection.left &&
                              widget.direction == SwipeDirection.right
                          ? -handleSize
                          : current == SwipeDirection.up ||
                                  current == SwipeDirection.down
                              ? widget.direction == SwipeDirection.left
                                  ? handleSize
                                  : -handleSize
                              : 0))
              : null,
          top: !isHorizontal
              ? offsetByDirection +
                  (current == SwipeDirection.down &&
                          widget.direction == SwipeDirection.up
                      ? handleSize
                      : (current == SwipeDirection.up &&
                              widget.direction == SwipeDirection.down
                          ? -handleSize
                          : current == SwipeDirection.right ||
                                  current == SwipeDirection.left
                              ? widget.direction == SwipeDirection.up
                                  ? handleSize
                                  : -handleSize
                              : 0))
              : null,
          curve: Curves.ease,
          duration: _duration,
          child: child!,
        );
      },
      child: Builder(
        builder: (context) {
          final direction = widget.direction;
          final screenSize = MediaQuery.of(context).size;

          final handleArea = GestureDetector(
            onTap: () {
              Feedback.forTap(context);
              _setExpanded(!_isExpanded);
            },
            child: Container(
              color: Colors.transparent,
              width: !isHorizontal ? screenSize.width : null,
              height: isHorizontal ? screenSize.height : null,
              child: direction == SwipeDirection.right ||
                      direction == SwipeDirection.left
                  ? RotatedBox(quarterTurns: 1, child: _handleIcon)
                  : _handleIcon,
            ),
          );

          final content = [
            if (direction == SwipeDirection.left ||
                direction == SwipeDirection.up)
              handleArea,
            SizedBox(
              width: screenSize.width - (isHorizontal ? handleSize : 0),
              height: screenSize.height - (!isHorizontal ? handleSize : 0),
              child: widget.child,
            ),
            if (direction == SwipeDirection.right ||
                direction == SwipeDirection.down)
              handleArea,
          ];

          GestureDragUpdateCallback? onDragUpdate(double? primaryDelta) {
            final offset = _offset +
                primaryDelta! *
                    (direction == SwipeDirection.right ||
                            direction == SwipeDirection.down
                        ? -1
                        : 1) *
                    2;
            if (offset >= 0 &&
                offset <=
                    (isHorizontal ? screenSize.width : screenSize.height)) {
              setState(() => _offset = offset);
            }
          }

          GestureDragEndCallback? onDragEnd() {
            _setExpanded(
              _offset <
                  (isHorizontal ? screenSize.width : screenSize.height) / 2,
            );
          }

          GestureDragStartCallback? onDragStart(DragStartDetails _) {
            context.read(currentExpanded).state = widget.direction;
          }

          return GestureDetector(
            onHorizontalDragStart: isHorizontal ? onDragStart : null,
            onVerticalDragStart: !isHorizontal ? onDragStart : null,
            onHorizontalDragUpdate: isHorizontal
                ? (details) => onDragUpdate(details.primaryDelta)
                : null,
            onVerticalDragUpdate: !isHorizontal
                ? (details) => onDragUpdate(details.primaryDelta)
                : null,
            onHorizontalDragEnd: isHorizontal ? (_) => onDragEnd() : null,
            onVerticalDragEnd: !isHorizontal ? (_) => onDragEnd() : null,
            child: isHorizontal
                ? Row(children: content)
                : Column(children: content),
          );
        },
      ),
    );
  }
}
