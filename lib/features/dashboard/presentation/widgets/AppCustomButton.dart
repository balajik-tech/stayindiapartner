import 'package:flutter/material.dart';

class AppCustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Gradient gradient;
  final TextStyle textStyle;
  final Widget? child;
  final bool isLoading;

  const AppCustomButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.gradient,
    required this.textStyle,
    this.height,
    this.width,
    this.borderRadius,
    this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: isLoading ? null : onTap,

        child: Ink(
          height: height ?? 52,
          width: width ?? double.infinity,

          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: radius,
          ),

          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor:
                AlwaysStoppedAnimation(
                  Colors.white,
                ),
              ),
            )
                : child ??
                Text(
                  label,
                  style: textStyle,
                ),
          ),
        ),
      ),
    );
  }
}