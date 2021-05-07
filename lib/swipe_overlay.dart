import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentExpanded = StateProvider<Location>((_) => Location.none);

const handleSize = 40.0;

const _duration = Duration(seconds: 1);

enum Location { left, bottom, right, top, none }

class SwipeOverlay extends StatefulWidget {
  const SwipeOverlay(
    this.location,
    this.padding, {
    required this.child,
    Key? key,
  }) : super(key: key);

  final Location location;
  final EdgeInsets padding;
  final Widget child;

  double get verticalSafeArea => padding.top + padding.bottom;

  double get horizontalSafeArea => padding.left + padding.right;

  bool get isHorizontal =>
      location == Location.left || location == Location.right;

  @override
  _SwipeOverlayState createState() => _SwipeOverlayState();
}

class _SwipeOverlayState extends State<SwipeOverlay> {
  bool _isExpanded = false;
  double _offset = 0;

  static const _handleIcon = Icon(
    Icons.drag_handle,
    size: handleSize,
    color: Colors.black,
  );

  void _setExpanded(bool isExpanded) {
    setState(() => _isExpanded = isExpanded);
    _calculateOffset();
    context.read(currentExpanded).state =
        _isExpanded ? widget.location : Location.none;
  }

  void _calculateOffset({bool init = false}) {
    final screenSize = MediaQuery.of(context).size;
    _offset = !_isExpanded || init
        ? widget.isHorizontal
            ? screenSize.width
            : screenSize.height
        : handleSize;
  }

  double get offsetByDirection {
    final location = widget.location;
    final verticalSafeArea = widget.verticalSafeArea;
    final horizontalSafeArea = widget.horizontalSafeArea;

    final correction = _isExpanded
        ? 0
        : location == Location.top
            ? verticalSafeArea
            : location == Location.bottom
                ? -verticalSafeArea
                : location == Location.left
                    ? horizontalSafeArea
                    : location == Location.right
                        ? -horizontalSafeArea
                        : 0;

    final offset = location == Location.left || location == Location.top
        ? handleSize - _offset
        : _offset - handleSize;

    return offset + correction;
  }

  @override
  void didChangeDependencies() {
    _isExpanded = false;
    _calculateOffset(init: true);

    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => context.read(currentExpanded).state = Location.none,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final queryData = MediaQuery.of(context);
    final screenSize = queryData.size;
    final screenWidth = screenSize.width - widget.horizontalSafeArea;
    final screenHeight = screenSize.height - widget.verticalSafeArea;

    final isHorizontal = widget.isHorizontal;
    final location = widget.location;

    final handleArea = InkWell(
      onTap: Feedback.wrapForTap(
        () => _setExpanded(!_isExpanded),
        context,
      ),
      child: SizedBox(
        width: !isHorizontal ? screenWidth : null,
        height: isHorizontal ? screenHeight : null,
        child: isHorizontal
            ? const RotatedBox(quarterTurns: 1, child: _handleIcon)
            : _handleIcon,
      ),
    );

    final content = [
      if (location == Location.right || location == Location.bottom) handleArea,
      SizedBox(
        width: screenWidth - (isHorizontal ? handleSize : 0),
        height: screenHeight - (!isHorizontal ? handleSize : 0),
        child: widget.child,
      ),
      if (location == Location.left || location == Location.top) handleArea,
    ];

    return Consumer(
      builder: (context, watch, child) {
        final current = watch(currentExpanded).state;
        return AnimatedPositioned(
          left: isHorizontal
              ? offsetByDirection +
                  (current == Location.left && location == Location.right
                      ? handleSize
                      : (current == Location.right && location == Location.left
                          ? -handleSize
                          : current == Location.bottom ||
                                  current == Location.top
                              ? location == Location.right
                                  ? handleSize
                                  : -handleSize
                              : 0))
              : null,
          top: !isHorizontal
              ? offsetByDirection +
                  (current == Location.top && location == Location.bottom
                      ? handleSize
                      : (current == Location.bottom && location == Location.top
                          ? -handleSize
                          : current == Location.left ||
                                  current == Location.right
                              ? location == Location.bottom
                                  ? handleSize
                                  : -handleSize
                              : 0))
              : null,
          duration: _duration,
          curve: Curves.ease,
          child: child!,
        );
      },
      child: Builder(
        builder: (context) {
          GestureDragUpdateCallback? onDragUpdate(DragUpdateDetails details) {
            final offset = _offset +
                details.primaryDelta! *
                    (location == Location.left || location == Location.top
                        ? -1
                        : 1) *
                    2;

            setState(() => _offset = offset);
          }

          GestureDragEndCallback? onDragEnd(_) {
            _setExpanded(
              _offset < (isHorizontal ? screenWidth : screenHeight) / 2,
            );
          }

          GestureDragStartCallback? onDragStart(_) {
            context.read(currentExpanded).state = widget.location;
          }

          return GestureDetector(
            onHorizontalDragUpdate: isHorizontal ? onDragUpdate : null,
            onHorizontalDragStart: isHorizontal ? onDragStart : null,
            onHorizontalDragEnd: isHorizontal ? onDragEnd : null,
            onVerticalDragUpdate: !isHorizontal ? onDragUpdate : null,
            onVerticalDragStart: !isHorizontal ? onDragStart : null,
            onVerticalDragEnd: !isHorizontal ? onDragEnd : null,
            child: isHorizontal
                ? Row(children: content)
                : Column(children: content),
          );
        },
      ),
    );
  }
}
