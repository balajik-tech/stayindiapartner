import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UIConstants {
  static double get navBarHeight => 76.h;
  static double get navBarMargin => 12.h;

  static double bottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return navBarHeight + navBarMargin + bottomInset + 8.h;
  }

  static Widget bottomPaddingSliver(BuildContext context) =>
      SliverToBoxAdapter(child: SizedBox(height: bottomPadding(context)));

  static Widget bottomPaddingBox(BuildContext context) =>
      SizedBox(height: bottomPadding(context));

  static EdgeInsets listBottomPadding(BuildContext context) =>
      EdgeInsets.only(bottom: bottomPadding(context));
}
