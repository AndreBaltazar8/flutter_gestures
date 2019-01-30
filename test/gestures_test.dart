import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestures/gestures.dart';

void main() {
  test('test completion with failure afterwards', () {
    final gestureLine = GestureLine(
      AxisDirection.down,
      triggerDistance: 30,
      distance: 100,
      failDistance: 50,
    );
    expect(gestureLine.triggered, false);
    expect(gestureLine.complete, false);
    expect(gestureLine.failed, false);
    gestureLine.update(Offset(0, 10));
    expect(gestureLine.triggered, false);
    expect(gestureLine.complete, false);
    expect(gestureLine.failed, false);
    gestureLine.update(Offset(0, 20));
    expect(gestureLine.triggered, true);
    expect(gestureLine.complete, false);
    expect(gestureLine.failed, false);
    gestureLine.update(Offset(0, 30));
    expect(gestureLine.triggered, true);
    expect(gestureLine.complete, false);
    expect(gestureLine.failed, false);
    gestureLine.update(Offset(0, 70));
    expect(gestureLine.triggered, true);
    expect(gestureLine.complete, true);
    expect(gestureLine.failed, false);
    gestureLine.update(Offset(50, 0));
    expect(gestureLine.triggered, true);
    expect(gestureLine.complete, true);
    expect(gestureLine.failed, true);
  });
}
