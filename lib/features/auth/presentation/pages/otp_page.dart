import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_button.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String? devOtp;

  const OtpPage({super.key, required this.phone, this.devOtp});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 30;
  Timer? _timer;

  late String? _currentDevOtp;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentDevOtp = widget.devOtp;
    _startCountdown();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onVerify(BuildContext context) {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the 6-digit OTP.', style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(widget.phone, _otp);
  }

  void _onResend(BuildContext context) {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    context.read<AuthCubit>().resendOtp(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) =>
          current is AuthOtpSent || current is AuthError || current is AuthAuthenticated,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is AuthOtpSent && state.isResend) {
          _startCountdown();
          setState(() => _currentDevOtp = state.devOtp);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP resent successfully.', style: GoogleFonts.outfit()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.outfit()),
              behavior: SnackBarBehavior.floating,
            ));
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.backgroundGrey,
            body: Stack(
              children: [
                
                Container(
                  height: 0.4.sh,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlue.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _HeroPatternPainter(),
                        size: Size(1.sw, 0.4.sh),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: const AuthLogoBadge(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        height: 0.65.sh,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40.r),
                            topRight: Radius.circular(40.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Code',
                                style: GoogleFonts.outfit(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                  letterSpacing: -0.8,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Enter the code sent to +91 ${widget.phone}',
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  color: AppColors.greyText.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              
                              if (_currentDevOtp != null && _currentDevOtp!.isNotEmpty) ...[
                                SizedBox(height: 24.h),
                                _DevOtpBanner(otp: _currentDevOtp!),
                              ],
                              
                              SizedBox(height: 48.h),

                              _OtpInputGrid(
                                controllers: _controllers,
                                focusNodes: _focusNodes,
                              ),
                              
                              SizedBox(height: 40.h),

                              AuthPrimaryButton(
                                label: isLoading ? 'VERIFYING...' : 'VERIFY & CONTINUE',
                                isLoading: isLoading,
                                onPressed: () => _onVerify(context),
                              ),

                              SizedBox(height: 32.h),
                              _ResendRow(
                                countdown: _countdown,
                                onResend: () => _onResend(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 50.0 + (i * 40), paint);
      canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 30.0 + (i * 30), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



class _OtpInputGrid extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const _OtpInputGrid({
    required this.controllers,
    required this.focusNodes,
  });

  @override
  State<_OtpInputGrid> createState() => _OtpInputGridState();
}

class _OtpInputGridState extends State<_OtpInputGrid> {
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.focusNodes.length; i++) {
      widget.focusNodes[i].addListener(() {
        if (widget.focusNodes[i].hasFocus) {
          setState(() => _focusedIndex = i);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: _focusedIndex == i ? Colors.white : AppColors.backgroundGrey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _focusedIndex == i ? AppColors.primaryBlue : Colors.grey.shade200,
                    width: _focusedIndex == i ? 2 : 1.5,
                  ),
                  boxShadow: [
                    if (_focusedIndex == i)
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: widget.controllers[i],
                  focusNode: widget.focusNodes[i],
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  showCursor: false,
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    height: 1.0,
                  ),
                  scrollPadding: EdgeInsets.only(bottom: 140.h),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      widget.focusNodes[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      widget.focusNodes[i - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final int countdown;
  final VoidCallback onResend;

  const _ResendRow({required this.countdown, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            countdown > 0
                ? 'Resend code in 00:${countdown.toString().padLeft(2, '0')}'
                : "Didn't receive the code?",
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.greyText.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (countdown == 0) ...[
            SizedBox(height: 12.h),
            BouncingButton(
              onTap: onResend,
              backgroundColor: Colors.transparent,
              height: 40.h,
              child: Text(
                'Resend OTP',
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DevOtpBanner extends StatelessWidget {
  final String otp;
  const _DevOtpBanner({required this.otp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.freeGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.freeGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 16.sp, color: AppColors.freeGreen),
          SizedBox(width: 8.w),
          Text(
            'TEST OTP: $otp',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.freeGreen,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
