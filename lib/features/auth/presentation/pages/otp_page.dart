import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_auth/smart_auth.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_button.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/account_recovery_widgets.dart';
import 'LoginOnBoardingScreen.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String? devOtp;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatar;

  const OtpPage({
    super.key,
    required this.phone,
    this.devOtp,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 30;
  Timer? _timer;

  bool _useSmsOtp = false;
  bool _hasAutoSubmitted = false;
  String? _appSignature; // debug helper — see initState

  // --- Account Recovery ---
  bool _showConfirmStartFresh = false;
  bool _isRestoring = false;

  final SmartAuth _smartAuth = SmartAuth.instance;
  late String? _currentDevOtp;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentDevOtp = widget.devOtp;
    _startCountdown();

    // Start listening for an incoming SMS containing the OTP, via the
    // Android SMS User Consent API. Unlike the SMS Retriever API this
    // does NOT require any "<#>" prefix or app-signature hash in the
    // message — it just needs a short code in the SMS body, and shows
    // the user a native "Allow" dialog once the SMS arrives.
    _listenForSmsOtp();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    _smartAuth.removeUserConsentApiListener(); // stop the SMS listener
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

  // Starts (or restarts) listening for the incoming OTP SMS via the
  // Android SMS User Consent API. This call suspends until either an
  // SMS arrives and the user taps "Allow" on the system dialog, the
  // user dismisses it, or it times out (~5 minutes) — so we don't
  // await it inline, just let it resolve in the background.
  Future<void> _listenForSmsOtp() async {
    // Also fetch the app signature — not required for the User Consent
    // API, but handy to log in case you want to fall back to the
    // Retriever API (getSmsWithRetrieverApi) later.
    final signatureResult = await _smartAuth.getAppSignature();
    final signature = signatureResult.hasData
        ? signatureResult.requireData
        : null;
    debugPrint('App signature: $signature');
    if (mounted) setState(() => _appSignature = signature);

    final result = await _smartAuth.getSmsWithUserConsentApi();
    if (!mounted) return;

    if (result.hasData) {
      final detectedCode = result.requireData.code;
      debugPrint('SMS received, extracted code: $detectedCode');
      if (detectedCode != null) {
        _fillOtpFields(detectedCode);
      } else {
        debugPrint(
          'SMS was received and consent granted, but no code could '
              'be extracted from the message text — check the SMS content.',
        );
      }
    } else if (result.isCanceled) {
      debugPrint('User dismissed the SMS consent dialog.');
    } else {
      debugPrint('SMS User Consent API failed: $result');
    }
  }

  void _fillOtpFields(String rawCode) {
    if (!mounted) return;

    // Keep only digits, then take the last 6 in case the SMS text
    // contains other numbers (e.g. a support phone number).
    final digits = rawCode.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return;
    final otp = digits.substring(digits.length - 6);

    setState(() {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = otp[i];
      }
      _useSmsOtp = true;
    });

    FocusScope.of(context).unfocus();
    _focusNodes.last.unfocus();

    // Auto-submit once, right after the fields are filled.
    if (!_hasAutoSubmitted) {
      _hasAutoSubmitted = true;
      // _onVerify(context);
    }
  }

  void _onVerify(BuildContext context) {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the 6-digit OTP.',
            style: GoogleFonts.outfit(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(
      widget.phone,
      _otp,
      email: widget.email,
      firstName: widget.firstName,
      lastName: widget.lastName,
      avatar: widget.avatar,
    );
  }

  void _onResend(BuildContext context) {
    for (final c in _controllers) {
      c.clear();
    }
    _hasAutoSubmitted = false;
    _focusNodes.first.requestFocus();
    context.read<AuthCubit>().resendOtp(widget.phone);
    // Re-arm the listener for the newly sent SMS.
    _listenForSmsOtp();
  }

  void _onRestoreAccount() {
    setState(() => _isRestoring = true);
    context.read<AuthCubit>().restoreAccount(action: "OLD_ACCOUNT");
  }

  void _onStartFresh() {
    setState(() => _showConfirmStartFresh = true);
  }

  void _onConfirmStartFresh() {
    setState(() {
      _showConfirmStartFresh = false;
      _isRestoring = false;
    });
    context.read<AuthCubit>().startFresh(widget.phone);
  }

  void _onGoBackFromStartFresh() {
    setState(() => _showConfirmStartFresh = false);
  }

  void _onCancelRecovery() {
    setState(() {
      _isRestoring = false;
      _showConfirmStartFresh = false;
    });
    context.read<AuthCubit>().logout();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isTimerRunning = _countdown > 0;
    return PopScope(
      canPop: !isTimerRunning,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (_, current) =>
        current is AuthOtpSent ||
            current is AuthError ||
            current is AuthAccountRestored ||
            current is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state is AuthOtpSent && state.isResend) {
            _startCountdown();
            setState(() => _currentDevOtp = state.devOtp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'OTP resent successfully.',
                  style: GoogleFonts.outfit(),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthError) {
            _hasAutoSubmitted = false;
            if (!_isRestoring) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.outfit()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          } else if (state is AuthAccountRestored) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account restored successfully!')),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Scaffold(
              backgroundColor: AppColors.white,
              body: Stack(
                children: [
                  LoginOnBoardingScreen(),
                  // Transparent overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.75,
                      ), // Change opacity as needed
                    ),
                  ),

                  Center(
                    child: Dialog(
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .85,
                          maxWidth: 420.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              24.w,
                              16.h,
                              24.w,
                              24.h,
                            ),
                            child: _buildContent(context, state, isLoading),
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state, bool isLoading) {
    if (_isRestoring && state is AuthError) {
      return RestoreFailedView(
        onRetry: _onRestoreAccount,
        onCancel: _onCancelRecovery,
      );
    }

    if (state is AuthAccountDeletedWithin30Days) {
      if (_showConfirmStartFresh) {
        return ConfirmStartFreshView(
          deletionDate: state.deletionDate,
          onGoBack: _onGoBackFromStartFresh,
          onConfirm: _onConfirmStartFresh,
        );
      }
      return RestoreAccountWithin30DaysView(
        name: state.name,
        deletionDate: state.deletionDate,
        restoreUntilDate: state.restoreUntilDate,
        onRestore: _onRestoreAccount,
        onStartFresh: _onStartFresh,
      );
    }

    if (state is AuthAccountDeletedPast30Days) {
      return Past30DaysRegisterView(onRegister: _onConfirmStartFresh);
    }

    if (state is AuthAccountRestored) {
      return AccountRestoredView(
        onContinue: () {
          setState(() => _isRestoring = false);
          context.read<AuthCubit>().refreshProfile();
        },
      );
    }

    final isTimerRunning = _countdown > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---- close button ----
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: isTimerRunning ? null : () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.close_rounded,
                size: 22.sp,
                color: isTimerRunning
                    ? AppColors.primaryBlue.withValues(alpha: 0.3)
                    : AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        // ---- logo ----
        Center(child: const AuthNewLogoBadge()),
        // ---- heading ----
        Text(
          'Your Hostel control center',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inputBoxColor,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Manage Your Hostels effortlessly',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.kAuthOrangeDark,
          ),
        ),

        // ---- illustration ----
        SizedBox(height: 18.h),

        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/login_lap.png',
            width: 180.w,
            height: 125.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 40.sp,
              );
            },
          ),
        ),
        SizedBox(height: 22.h),

        // ---- mobile number label ----
        _OtpInputGrid(
          controllers: _controllers,
          focusNodes: _focusNodes,
          onOtpPasted: _fillOtpFields,
        ),

        SizedBox(height: 4.h),
        // ---- phone field ----
        _ResendRow(countdown: _countdown, onResend: () => _onResend(context)),

        // ---- password field (staff login only) ----
        SizedBox(height: 8.h),

        // ---- submit button ----
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: isLoading ? null : () => _onVerify(context),
            child: Container(
              height: 52.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.inputBoxColor, AppColors.inputBoxColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.inputBoxColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Text(
                isLoading ? 'VERIFYING...' : 'VERIFY & CONTINUE',
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 18.h),

        // ---- terms footer ----
        Center(
          child: Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              children: [
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(
                    color: AppColors.inputBoxColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.inputBoxColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.orangeColor,
              height: 1.4,
            ),
          ),
        ),
      ],
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
      canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.1),
        50.0 + (i * 40),
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.8),
        30.0 + (i * 30),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _OtpInputGrid extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String)? onOtpPasted;

  const _OtpInputGrid({
    required this.controllers,
    required this.focusNodes,
    this.onOtpPasted,
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
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final hasValue = widget.controllers[i].text.isNotEmpty;

        final isFocused = _focusedIndex == i;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  // Filled box background
                  color: hasValue
                      ? AppColors.inputBoxColor.withValues(alpha: 1)
                      : isFocused
                      ? Colors.white
                      : AppColors.white.withValues(alpha: 1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: hasValue || isFocused
                        ? AppColors.inputBoxColor
                        : Colors.grey.shade200,

                    width: hasValue || isFocused ? 1.5 : 1.5,
                  ),
                  boxShadow: [
                    if (hasValue || isFocused)
                      BoxShadow(
                        color: AppColors.inputBoxColor.withValues(alpha: 0.12),
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
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  showCursor: false,
                  style: GoogleFonts.outfit(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                    color: hasValue ? AppColors.white : AppColors.darkText,
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
                    // Refresh UI after typing
                    setState(() {});

                    // Handle paste OTP
                    if (val.length > 1) {
                      widget.onOtpPasted?.call(val);

                      return;
                    }

                    // Move next
                    if (val.isNotEmpty && i < 5) {
                      widget.focusNodes[i + 1].requestFocus();
                    }
                    // Move previous on delete
                    else if (val.isEmpty && i > 0) {
                      widget.focusNodes[i - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      }),
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
          SizedBox(height: 12.h),
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
            SizedBox(height: 2.h),
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
