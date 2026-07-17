import 'dart:io';
import 'dart:ui';

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
import 'OnBoardingScreen.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {

  final bool? isStaffLogin;

  const LoginPage({
    super.key,
    this.isStaffLogin,
  });

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
  bool _useSmsOtp = false;
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

    setState(() {
      _isStaffLogin = widget.isStaffLogin ?? false;
    });
    _onPhoneFieldTap();
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
      // debugPrint('[SIM] Phone number hint returned: $hint');
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
      // debugPrint('[SIM] Phone number hint failed: ${e.code} — ${e.message}');
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
          body: Stack(
            children: [
              OnBoardingScreen(),
              // Transparent overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8,
                    sigmaY: 8,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),
              ),

              Center(
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 24.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ---- close button ----
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.all(4.r),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22.sp,
                                    color: AppColors.primaryBlue,
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

                                color: AppColors.primaryBlue,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Mobile Number',
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkText.withValues(alpha: 0.85),
                                ),
                              ),
                            ),

                            SizedBox(height: 8.h),
                            // ---- phone field ----
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuart,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: _isFocused
                                      ? AppColors.kAuthOrange
                                      : AppColors.inputBoxColor.withValues(alpha: 0.7),
                                  width: _isFocused ? 2 : 1.4,
                                ),
                                boxShadow: [
                                  if (_isFocused)
                                    BoxShadow(
                                      color: AppColors.inputBoxColor.withValues(alpha: 0.12),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '+91',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Icon(
                                          Icons.unfold_more_rounded,
                                          size: 16.sp,
                                          color: AppColors.primaryBlue,
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
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText,
                                        letterSpacing: 1.0,
                                      ),
                                      textAlignVertical: TextAlignVertical.center,
                                      scrollPadding: EdgeInsets.only(bottom: 150.h),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: '(000) 000-0000',
                                        hintStyle: GoogleFonts.outfit(
                                          color: Colors.grey.shade400,
                                          fontSize: 16.sp,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 14.h,
                                        ),
                                      ),
                                      onSubmitted: (_) => _isStaffLogin
                                          ? _onStaffLogin(context)
                                          : _onSendOtp(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ---- password field (staff login only) ----
                            if (_isStaffLogin) ...[
                              SizedBox(height: 16.h),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Password',
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkText.withValues(alpha: 0.85),
                                ),
                              )),

                              SizedBox(height: 8.h),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutQuart,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: _isPasswordFocused
                                        ? AppColors.kAuthOrange
                                        : AppColors.inputBoxColor.withValues(alpha: 0.7),
                                    width: _isPasswordFocused ? 2 : 1.4,
                                  ),
                                  boxShadow: [
                                    if (_isPasswordFocused)
                                      BoxShadow(
                                        color: AppColors.kAuthOrange.withValues(alpha: 0.12),
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
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkText,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: GoogleFonts.outfit(
                                      color: Colors.grey.shade400,
                                      fontSize: 15.sp,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                                      child: Icon(
                                        Icons.lock_rounded,
                                        color: _isPasswordFocused
                                            ? AppColors.primaryBlue
                                            : AppColors.greyText,
                                        size: 20,
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
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  onSubmitted: (_) => _onStaffLogin(context),
                                ),
                              ),
                            ],

                            SizedBox(height: 24.h),

                            // ---- submit button ----
                            // Same onPressed/label/isLoading contract as AuthPrimaryButton —
                            // rebuilt inline so the orange gradient can be applied without
                            // touching AuthPrimaryButton's own source.
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.r),
                                onTap: isLoading
                                    ? null
                                    : () => _isStaffLogin
                                    ? _onStaffLogin(context)
                                    : _onSendOtp(context),
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
                                        color: AppColors.kAuthOrange.withValues(alpha: 0.35),
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
                                    _isStaffLogin ? 'LOGIN AS STAFF' : 'Send OTP',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
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
                                        color: AppColors.kAuthOrange,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' & '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.kAuthOrange,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: AppColors.primaryBlue.withValues(alpha: 0.7),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
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
