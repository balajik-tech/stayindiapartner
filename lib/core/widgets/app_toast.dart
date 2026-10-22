import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Short message shown at the top of the screen.
///
/// Only one toast is visible at a time. Showing the same message again while
/// it is still on screen is ignored, so repeated taps don't stack alerts.
class AppToast {
  AppToast._();

  static const Duration displayDuration = Duration(seconds: 3);

  static OverlayEntry? _entry;
  static String? _message;
  static Timer? _timer;

  static void show(BuildContext context, String message) {
    if (_entry != null && _message == message) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    hide();
    _message = message;
    _entry = OverlayEntry(
      builder: (_) => _ToastView(message: message, onTap: hide),
    );
    overlay.insert(_entry!);
    _timer = Timer(displayDuration, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _message = null;
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final VoidCallback onTap;

  const _ToastView({required this.message, required this.onTap});

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12.h,
      left: 16.w,
      right: 16.w,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.4),
            end: Offset.zero,
          ).animate(curved),
          child: Material(
            color: const Color(0xFF323232),
            elevation: 6,
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.r),
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Text(
                  widget.message,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
