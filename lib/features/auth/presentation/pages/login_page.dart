import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_phone_number_hint/google_phone_number_hint.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_button.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFocused = false;

  String? _googleEmail;
  String? _googleFirstName;
  String? _googleLastName;
  String? _googleAvatar;

  bool _isStaffLogin = false;
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _obscurePassword = true;

  // --- SIM detection ---
  bool _isFetchingSimHint = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() => _isFocused = _phoneFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });

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
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String get _cleanPhone => _phoneController.text
      .replaceAll(' ', '')
      .replaceAll('+91', '')
      .replaceAll('-', '')
      .trim();

  void _onSendOtp(BuildContext context) {
    final phone = _cleanPhone;
    if (phone.length < 10) {
      _showSnackBar(context, 'Please enter a valid 10-digit mobile number.');
      return;
    }
    context.read<AuthCubit>().sendOtp(phone);
  }

  void _onStaffLogin(BuildContext context) {
    final phone = _cleanPhone;
    final password = _passwordController.text.trim();
    if (phone.length < 10) {
      _showSnackBar(context, 'Please enter a valid 10-digit mobile number.');
      return;
    }
    if (password.isEmpty) {
      _showSnackBar(context, 'Please enter your staff password.');
      return;
    }
    context.read<AuthCubit>().staffLogin(phone, password);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
  }

  // ==========================================================================
  // SIM detection — uses Google's Phone Number Hint API (Play Services),
  // the same mechanism apps like PhonePe/GPay use. Unlike reading
  // TelephonyManager/SubscriptionManager directly, this is handled by Play
  // Services with system-level access, so it reliably lists every SIM-linked
  // number regardless of OEM restrictions (e.g. ColorOS on Oppo, MIUI, etc.)
  // and needs no runtime permission at all.
  //
  // Android only — iOS has no equivalent API; no plugin can read a device's
  // own SIM number there, so we simply prompt for manual entry.
  // ==========================================================================

  /// Extracts a clean 10-digit Indian mobile number from whatever format
  /// the OS reports (e.g. "+91 98765 43210", "0091-9876543210").
  String? _extractTenDigitNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final digitsOnly = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) return null;
    return digitsOnly.substring(digitsOnly.length - 10);
  }

  /// Tap handler wired to the existing phone number TextField. Opens
  /// Google's native SIM-number picker (shows every SIM on the device,
  /// including dual-SIM) and fills in whichever one the user selects.
  Future<void> _onPhoneFieldTap() async {
    if (Platform.isIOS) {
      _showIosSimUnsupportedDialog();
      return;
    }
    if (!Platform.isAndroid || _isFetchingSimHint) return;
    // Don't reopen the picker if the user is just re-tapping to edit an
    // already-filled number.
    if (_phoneController.text.isNotEmpty) return;

    setState(() => _isFetchingSimHint = true);
    try {
      final hint = await GooglePhoneNumberHint().getMobileNumber();
      debugPrint('[SIM] Phone number hint returned: $hint');
      final tenDigit = _extractTenDigitNumber(hint);
      if (!mounted) return;
      if (tenDigit != null) {
        setState(() {
          _phoneController.text = tenDigit;
          _phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: _phoneController.text.length),
          );
        });
      }
    } on PlatformException catch (e) {
      debugPrint('[SIM] Phone number hint failed: ${e.code} — ${e.message}');
      if (mounted) {
        _showSnackBar(
          context,
          'Could not detect a SIM number. Please enter it manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingSimHint = false);
    }
  }

  void _showIosSimUnsupportedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Enter your number manually',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            "iOS doesn't allow apps to read a device's SIM phone number, "
            'so this has to be typed in manually.',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.greyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Got it', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (_, current) =>
          current is AuthOtpSent ||
          current is AuthError ||
          current is AuthGoogleNeedsPhone,
      listener: (context, state) {
        if (state is AuthGoogleNeedsPhone) {
          setState(() {
            _googleEmail = state.email;
            _googleFirstName = state.firstName;
            _googleLastName = state.lastName;
            _googleAvatar = state.avatar;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Google account verified! Please enter your phone number to link your account.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
        } else if (state is AuthOtpSent && !state.isResend) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => OtpPage(
                phone: state.phone,
                devOtp: state.devOtp,
                email: _googleEmail,
                firstName: _googleFirstName,
                lastName: _googleLastName,
                avatar: _googleAvatar,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        } else if (state is AuthError) {
          _showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                  child:  Column(
                children: [
                  Container(
                    height: 0.45.sh,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: _HeroPatternPainter(),
                          size: Size(1.sw, 0.45.sh),
                        ),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const AuthLogoBadge(),
                                      // SizedBox(height: 2.h),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 16.h),
                                        color: AppColors.totalBlueText,
                                        child: Center(
                                          child: Text(
                                            "PARTNER",
                                            style: GoogleFonts.outfit(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 4,
                                              height: 1,
                                            ),
                                          ),
                                        ),
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
                  ),

                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child:  Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxHeight: 0.85.sh),
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              top: 24.h,
                              bottom: 20.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your hostel control center',
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
                                  'Manage your hostels effortlessly',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    color: AppColors.greyText.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 24.h),

                                Container(
                                  height: 48.h,
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGrey.withValues(
                                      alpha: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _isStaffLogin = false),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !_isStaffLogin
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(
                                                20.r,
                                              ),
                                              boxShadow: !_isStaffLogin
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.primaryBlue
                                                            .withValues(alpha: 0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              'Owner Login',
                                              style: GoogleFonts.outfit(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: !_isStaffLogin
                                                    ? Colors.white
                                                    : AppColors.greyText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _isStaffLogin = true),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _isStaffLogin
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(
                                                20.r,
                                              ),
                                              boxShadow: _isStaffLogin
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.primaryBlue
                                                            .withValues(alpha: 0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              'Staff Login',
                                              style: GoogleFonts.outfit(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: _isStaffLogin
                                                    ? Colors.white
                                                    : AppColors.greyText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 18.h),

                                Text(
                                  'MOBILE NUMBER',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.greyText.withValues(
                                      alpha: 0.6,
                                    ),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutQuart,
                                  decoration: BoxDecoration(
                                    color: _isFocused
                                        ? Colors.white
                                        : AppColors.backgroundGrey.withValues(
                                            alpha: 0.5,
                                          ),
                                    borderRadius: BorderRadius.circular(22.r),
                                    border: Border.all(
                                      color: _isFocused
                                          ? AppColors.primaryBlue
                                          : Colors.grey.shade200,
                                      width: _isFocused ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      if (_isFocused)
                                        BoxShadow(
                                          color: AppColors.primaryBlue.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '',
                                              style: TextStyle(fontSize: 20.sp),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '+91',
                                              style: GoogleFonts.outfit(
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocusNode,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          style: GoogleFonts.outfit(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkText,
                                            letterSpacing: 2.0,
                                          ),
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          scrollPadding: EdgeInsets.only(
                                            bottom: 150.h,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            hintText: '00000 00000',
                                            hintStyle: GoogleFonts.outfit(
                                              color: Colors.grey.shade400,
                                              fontSize: 18.sp,
                                              letterSpacing: 2.0,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20.w,
                                              vertical: 12.h,
                                            ),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                left: 4.w,
                                                right: 12.w,
                                              ),
                                              child: Icon(
                                                Icons.phone_android_rounded,
                                                color: _isFocused
                                                    ? AppColors.primaryBlue
                                                    : AppColors.greyText,
                                                size: 22,
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 0,
                                                  minHeight: 0,
                                                ),
                                          ),
                                          onTap: _onPhoneFieldTap,
                                          onSubmitted: (_) => _isStaffLogin
                                              ? _onStaffLogin(context)
                                              : _onSendOtp(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (_isStaffLogin) ...[
                                  SizedBox(height: 24.h),
                                  Text(
                                    'PASSWORD',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.greyText.withValues(
                                        alpha: 0.6,
                                      ),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutQuart,
                                    decoration: BoxDecoration(
                                      color: _isPasswordFocused
                                          ? Colors.white
                                          : AppColors.backgroundGrey.withValues(
                                              alpha: 0.5,
                                            ),
                                      borderRadius: BorderRadius.circular(22.r),
                                      border: Border.all(
                                        color: _isPasswordFocused
                                            ? AppColors.primaryBlue
                                            : Colors.grey.shade200,
                                        width: _isPasswordFocused ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        if (_isPasswordFocused)
                                          BoxShadow(
                                            color: AppColors.primaryBlue.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText,
                                        letterSpacing: 1.0,
                                      ),
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        hintStyle: GoogleFonts.outfit(
                                          color: Colors.grey.shade400,
                                          fontSize: 18.sp,
                                          letterSpacing: 2.0,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 16.h,
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(
                                            left: 4.w,
                                            right: 12.w,
                                          ),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            color: _isPasswordFocused
                                                ? AppColors.primaryBlue
                                                : AppColors.greyText,
                                            size: 22,
                                          ),
                                        ),
                                        prefixIconConstraints: const BoxConstraints(
                                          minWidth: 0,
                                          minHeight: 0,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: AppColors.greyText,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (_) => _onStaffLogin(context),
                                    ),
                                  ),
                                ],

                                SizedBox(height: 20.h),

                                AuthPrimaryButton(
                                  label: isLoading
                                      ? 'LOGGING IN...'
                                      : (_isStaffLogin
                                            ? 'LOGIN AS STAFF'
                                            : 'SEND OTP'),
                                  isLoading: isLoading,
                                  onPressed: () => _isStaffLogin
                                      ? _onStaffLogin(context)
                                      : _onSendOtp(context),
                                ),



                                SizedBox(height: 24.h),
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundGrey
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.verified_user_rounded,
                                              size: 14.sp,
                                              color: AppColors.freeGreen,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              '100% SECURE & ENCRYPTED',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.greyText
                                                    .withValues(alpha: 0.7),
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24.h),
                                      Text.rich(
                                        TextSpan(
                                          text: 'By continuing, you agree to our ',
                                          children: [
                                            TextSpan(
                                              text: 'Terms',
                                              style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                            const TextSpan(text: ' & '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.sp,
                                          color: AppColors.greyText.withValues(
                                            alpha: 0.6,
                                          ),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
          ),
        );
      },
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    for (var i = 0; i < 6; i++) {
      path.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.15),
          radius: 60.0 + (i * 45),
        ),
      );
    }
    canvas.drawPath(path, paint);

    final path2 = Path();
    for (var i = 0; i < 4; i++) {
      path2.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.85),
          radius: 40.0 + (i * 35),
        ),
      );
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
