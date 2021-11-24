library gestures;

import 'package:flutter/material.dart';

/// A gesture to be used in [CustomGestureDetector].
///
/// This class needs to be extended to implement the necessary gesture.
abstract class Gesture {
  /// Whether this gesture has been triggered.
  bool get triggered;

  /// Whether this gesture has been complete.
  bool get complete;

  /// Whether this gesture failed.
  bool get failed;

  /// Updates the gesture when gesture detection is happening.
  void update(Offset delta);

  /// Resets the gesture for reuse.
  void reset();
}

/// A line gesture to used in [CustomGestureDetector].
///
/// Detects gestures on based on lines on the screen.
class GestureLine extends Gesture {
  /// Direction of the gesture line.
  final AxisDirection direction;

  /// Distance required to complete the gesture.
  final double distance;

  /// Distance required to trigger the start of the gesture line.
  final double triggerDistance;

  /// Distance from the line what will make the gesture recognition fail.
  final double failDistance;
  late Axis _counterAxis;

  /// Constructs a [GestureLine] with the provided arguments.
  GestureLine(
    this.direction, {
    this.triggerDistance = 25.0,
    this.distance = 100.0,
    this.failDistance = 40.0,
  }) {
    _counterAxis = flipAxis(axisDirectionToAxis(direction));
    reset();
  }

  late double _gestureX;
  late double _gestureY;

  bool _triggered = false;
  @override
  bool get triggered => _triggered;

  bool _complete = false;
  @override
  bool get complete => _complete;

  bool _failed = false;
  @override
  bool get failed => _failed;

  @override
  void update(Offset delta) {
    if (!_triggered) {
      _gestureX += delta.dx;
      _gestureY += delta.dy;
      if ((direction == AxisDirection.left && _gestureX <= -triggerDistance) ||
          (direction == AxisDirection.right && _gestureX >= triggerDistance) ||
          (direction == AxisDirection.up && _gestureY <= -triggerDistance) ||
          (direction == AxisDirection.down && _gestureY >= triggerDistance)) {
        _triggered = true;
        _gestureX = 0;
        _gestureY = 0;
      }

      if (!_triggered) return;
    }

    if (_failed) return;

    _gestureX += delta.dx;
    _gestureY += delta.dy;

    if ((_counterAxis == Axis.horizontal && _gestureX.abs() >= failDistance) ||
        (_counterAxis == Axis.vertical && _gestureY.abs() >= failDistance)) {
      _failed = true;
      return;
    }

    if ((direction == AxisDirection.left && _gestureX < -distance) ||
        (direction == AxisDirection.right && _gestureX > distance) ||
        (direction == AxisDirection.up && _gestureY < -distance) ||
        (direction == AxisDirection.down && _gestureY > distance)) {
      _complete = true;
    }
  }

  @override
  void reset() {
    _gestureX = 0;
    _gestureY = 0;
    _triggered = false;
    _complete = false;
    _failed = false;
  }
}

/// Recognizes custom gestures.
///
/// Custom gestures can be created by extending from [Gesture] class.
class CustomGestureDetector extends StatefulWidget {
  /// Child wrapped by the gesture detector.
  final Widget child;

  /// List of gestures that need to be triggered to complete the gesture.
  final List<Gesture> gestures;

  /// Callback when a gesture starts being detected.
  final Function? onGestureStart;

  /// Callback when a gesture ends. Whether it failed or succeeded is determined
  /// by the parameter [success].
  final Function(bool success) onGestureEnd;

  /// How this gesture detector should behave during hit testing.
  ///
  /// See [GestureDetector.behavior] for defaults.
  final HitTestBehavior? behavior;

  CustomGestureDetector({
    Key? key,
    required Widget child,
    required this.gestures,
    this.onGestureStart,
    required this.onGestureEnd,
    this.behavior,
  })  : this.child = child,
        assert(gestures.length > 0),
        super(key: key);

  @override
  _CustomGestureDetectorState createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  int _currentGesture = 0;
  bool _trackingGesture = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onPanStart: (_) {
        _trackingGesture = true;
        _currentGesture = 0;
        widget.gestures.forEach((g) => g.reset());
        widget.onGestureStart?.call();
      },
      onPanUpdate: (details) {
        if (_trackingGesture) {
          var currentGesture = widget.gestures[_currentGesture];
          currentGesture.update(details.delta);
          if (!currentGesture.triggered && _currentGesture > 0) {
            var previousGesture = widget.gestures[_currentGesture - 1];
            previousGesture.update(details.delta);
            if (previousGesture.failed) {
              _trackingGesture = false;
            }
          } else if (currentGesture.complete) {
            _currentGesture++;
            if (_currentGesture == widget.gestures.length) {
              _trackingGesture = false;
              widget.onGestureEnd(true);
            }
          }
        }
      },
      onPanEnd: (_) {
        if (_trackingGesture) {
          widget.onGestureEnd(false);
          _trackingGesture = false;
        }
      },
      child: widget.child,
    );
  }
}
