# Gestures

[![pub package](https://img.shields.io/pub/v/gestures.svg)](https://pub.dartlang.org/packages/gestures)

Custom Gesture Detector for Flutter. Empower your users with custom gestures.

## How to use

In your pubspec.yaml:
```yaml
dependencies:
  gestures: ^0.0.1
```

```dart
import 'package:gestures/gestures.dart';
```

Basic construction of the widget:

```dart
CustomGestureDetector(
  gestures: [
    GestureLine(AxisDirection.down),
    GestureLine(AxisDirection.right),
    GestureLine(AxisDirection.up),
  ],
  onGestureEnd: (success) {
    if (success) {
      // TODO: your action here..
    }
  },
  child: Container(),
)
```

## License
Licensed under the [MIT license](https://opensource.org/licenses/MIT).
