import 'dart:async';

import 'package:flutter/material.dart';

const handleSize = 36.0;

const _animationMillis = Duration(milliseconds: 500);

enum Location { left, bottom, right, top, none }

class SwipeOverlay extends StatefulWidget {
  const SwipeOverlay(
    this.location,
    this.padding, {
    required this.child,
    this.currentExpandedNotifier,
    Key? key,
  }) : super(key: key);

  final Location location;
  final EdgeInsets padding;
  final Widget child;
  final StreamController<Location>? currentExpandedNotifier;

  double get verticalSafeArea => padding.top + padding.bottom;

  double get horizontalSafeArea => padding.left + padding.right;

  bool get isHorizontal =>
      location == Location.left || location == Location.right;

  @override
  _SwipeOverlayState createState() => _SwipeOverlayState();
}

class _SwipeOverlayState extends State<SwipeOverlay> {
  Location _currentExpanded = Location.none;
  bool _isExpanded = false;
  double _offset = 0;

  StreamSubscription<Location>? currentExpandedSub;

  static const _handleIcon = Icon(
    Icons.drag_handle,
    size: handleSize,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    currentExpandedSub = widget.currentExpandedNotifier?.stream
        .where((event) => event != widget.location)
        .listen((event) => setState(() => _currentExpanded = event));
  }

  @override
  void dispose() {
    currentExpandedSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _isExpanded = false;
    _calculateOffset(init: true);
    widget.currentExpandedNotifier?.sink.add(Location.none);
    super.didChangeDependencies();
  }

  void _setExpanded(bool isExpanded) {
    setState(() => _isExpanded = isExpanded);
    widget.currentExpandedNotifier?.sink.add(
      _isExpanded ? widget.location : Location.none,
    );
    _calculateOffset();
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

    final correction = _isExpanded
        ? 0
        : location == Location.top
            ? widget.verticalSafeArea
            : location == Location.bottom
                ? -widget.verticalSafeArea
                : location == Location.left
                    ? widget.horizontalSafeArea
                    : location == Location.right
                        ? -widget.horizontalSafeArea
                        : 0;

    final offset = location == Location.left || location == Location.top
        ? handleSize - _offset
        : _offset - handleSize;

    return offset + correction;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width - widget.horizontalSafeArea;
    final screenHeight = screenSize.height - widget.verticalSafeArea;

    final isHorizontal = widget.isHorizontal;
    final location = widget.location;

    final handleArea = InkWell(
      onTap: () => _setExpanded(!_isExpanded),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.2),
        child: SizedBox(
          width: !isHorizontal ? screenWidth : null,
          height: isHorizontal ? screenHeight : null,
          child: isHorizontal
              ? const RotatedBox(quarterTurns: 1, child: _handleIcon)
              : _handleIcon,
        ),
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

    final current = _currentExpanded;
    return AnimatedPositioned(
      left: isHorizontal
          ? offsetByDirection +
              (current == Location.left && location == Location.right
                  ? handleSize
                  : (current == Location.right && location == Location.left
                      ? -handleSize
                      : current == Location.bottom || current == Location.top
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
                      : current == Location.left || current == Location.right
                          ? location == Location.bottom
                              ? handleSize
                              : -handleSize
                          : 0))
          : null,
      duration: _animationMillis,
      curve: Curves.easeOut,
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
            widget.currentExpandedNotifier?.sink.add(widget.location);
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
