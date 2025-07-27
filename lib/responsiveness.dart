import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class ResponsiveSize {
  // These are reference sizes based on your design (e.g., iPhone X: 375 x 812)
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  static double font(double px) {
    return (px / baseHeight) * 100.h;
  }

  static double width(double px) {
    return (px / baseWidth) * 100.w;
  }

  static double height(double px) {
    return (px / baseHeight) * 100.h;
  }
}

extension ResponsiveSpacing on num {
  // Responsive text size
  double get sp => ResponsiveSize.font(toDouble());

  // Responsive width & height
  double get rw => ResponsiveSize.width(toDouble());
  double get rh => ResponsiveSize.height(toDouble());

  // Padding helpers
  EdgeInsets get allPadding => EdgeInsets.all(rh);
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: rw);
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: rh);

  EdgeInsets symmetricPadding({num? horizontal, num? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: (horizontal ?? 0).rw,
      vertical: (vertical ?? 0).rh,
    );
  }

  EdgeInsets onlyPadding({num? left, num? top, num? right, num? bottom}) {
    return EdgeInsets.only(
      left: (left ?? 0).rw,
      top: (top ?? 0).rh,
      right: (right ?? 0).rw,
      bottom: (bottom ?? 0).rh,
    );
  }

  // Spacing widgets
  Widget get vSpace => SizedBox(height: rh);
  Widget get hSpace => SizedBox(width: rw);
}
