import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSection extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ProfileSection({
    super.key,
    required this.children,
    this.spacing = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.map((widget) {
        if (widget == children.last) return widget;
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.h),
          child: widget,
        );
      }).toList(),
    );
  }
}
