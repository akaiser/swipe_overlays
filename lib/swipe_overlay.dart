import 'package:flutter/material.dart';
import 'package:swipe_overlays/util/tap_detector.dart';

const handleSize = 40.0;
const _duration = Duration(seconds: 1);

enum SwipeDirection { left, up, right, down }

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
  bool _isExpanded = true;
  double _offset = 0;

  final _handleIcon = Icon(
    Icons.drag_handle,
    size: handleSize,
    color: Colors.white.withOpacity(0.4),
  );

  void _setExpanded(bool isExpanded) {
    setState(() => _isExpanded = isExpanded);
    _calculateOffset();
  }

  void _calculateOffset({bool init = false}) {
    final screenSize = MediaQuery.of(context).size;
    _offset = _isExpanded || init
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
        ? -_offset
        : _offset - handleSize;
  }

  @override
  void didChangeDependencies() {
    _calculateOffset(init: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.direction;
    final isHorizontal = widget.isHorizontal;
    final screenSize = MediaQuery.of(context).size;

    final arrowIcon = TapDetector(
      onTap: () => _setExpanded(!_isExpanded),
      child: SizedBox(
        width: !isHorizontal ? screenSize.width : null,
        height: isHorizontal ? screenSize.height : null,
        child: direction == SwipeDirection.right ||
                direction == SwipeDirection.left
            ? RotatedBox(quarterTurns: 1, child: _handleIcon)
            : _handleIcon,
      ),
    );

    GestureDragUpdateCallback? onDragUpdate(double? primaryDelta) {
      final offset = _offset +
          primaryDelta! *
              (direction == SwipeDirection.right ||
                      direction == SwipeDirection.down
                  ? -1
                  : 1) *
              2;
      if (offset >= 0 &&
          offset <= (isHorizontal ? screenSize.width : screenSize.height)) {
        setState(() => _offset = offset);
      }
    }

    GestureDragEndCallback? onDragEnd() {
      _setExpanded(
        _offset >= (isHorizontal ? screenSize.width : screenSize.height) / 2,
      );
    }

    final content = [
      if (direction == SwipeDirection.left || direction == SwipeDirection.up)
        arrowIcon,
      Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Colors.orangeAccent,
        child: widget.child,
      ),
      if (direction == SwipeDirection.right || direction == SwipeDirection.down)
        arrowIcon,
    ];
    return AnimatedPositioned(
      left: isHorizontal ? offsetByDirection : null,
      top: !isHorizontal ? offsetByDirection : null,
      curve: Curves.ease,
      duration: _duration,
      child: GestureDetector(
        onHorizontalDragUpdate: isHorizontal
            ? (details) => onDragUpdate(details.primaryDelta)
            : null,
        onVerticalDragUpdate: !isHorizontal
            ? (details) => onDragUpdate(details.primaryDelta)
            : null,
        onHorizontalDragEnd: isHorizontal ? (_) => onDragEnd() : null,
        onVerticalDragEnd: !isHorizontal ? (_) => onDragEnd() : null,
        child:
            isHorizontal ? Row(children: content) : Column(children: content),
      ),
    );
  }
}
