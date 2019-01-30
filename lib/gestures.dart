library gestures;

import 'package:flutter/material.dart';

abstract class Gesture {
  bool get triggered;
  bool get complete;
  bool get failed;
  void update(Offset delta);
  void reset();
}

class GestureLine extends Gesture {
  final AxisDirection direction;
  final double distance;
  final double triggerDistance;
  final double failDistance;
  Axis _counterAxis;

  GestureLine(
      this.direction, {
        this.triggerDistance = 25.0,
        this.distance = 100.0,
        this.failDistance = 40.0,
      }) {
    assert(direction != null);
    assert(distance != null);
    assert(failDistance != null);
    _counterAxis = flipAxis(axisDirectionToAxis(direction));
    reset();
  }

  double _gestureX;
  double _gestureY;

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

class CustomGestureDetector extends StatefulWidget {
  final Widget child;
  final List<Gesture> gestures;
  final Function onGestureStart;
  final Function(bool success) onGestureEnd;

  CustomGestureDetector({
    Key key,
    @required Widget child,
    @required this.gestures,
    this.onGestureStart,
    @required this.onGestureEnd,
  })  : assert(child != null),
        this.child = child,
        assert(gestures != null),
        assert(gestures.length > 0),
        assert(onGestureEnd != null),
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
      onPanStart: (_) {
        _trackingGesture = true;
        _currentGesture = 0;
        widget.gestures.forEach((g) => g.reset());
        if (widget.onGestureStart != null) widget.onGestureStart();
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
