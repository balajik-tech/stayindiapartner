import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_phone_number_hint/google_phone_number_hint.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';
import 'login_on_boarding_screen.dart';
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
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _obscurePassword = true;

  // --- SIM detection ---
  bool _isFetchingSimHint = false;

  bool _isTermsAccepted = false;
  bool _isPhoneValid = false;

  // Set while OTP login is blocked after too many attempts.
  DateTime? _otpLockedUntil;
  Timer? _otpLockTimer;

  final SmartAuth _smartAuth = SmartAuth.instance;
  String? _appSignature;

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() => _isFocused = _phoneFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
    _phoneController.addListener(_onPhoneChanged);

    setState(() {
      _isStaffLogin = widget.isStaffLogin ?? false;
    });
    _onPhoneFieldTap();
    _loadAppSignature();
    _loadOtpLock();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _otpLockTimer?.cancel();
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

  bool get _isOtpLocked => _otpLockedUntil != null;

  /// Send OTP stays disabled until the number is a valid Indian mobile
  /// number, the terms are accepted and OTP login isn't locked.
  bool get _canSubmit =>
      _isTermsAccepted && _isPhoneValid && (_isStaffLogin || !_isOtpLocked);

  void _onPhoneChanged() {
    final isValid = RegExp(r'^[6-9]\d{9}$').hasMatch(_cleanPhone);
    if (isValid != _isPhoneValid) setState(() => _isPhoneValid = isValid);
  }

  Future<void> _loadOtpLock() async {
    final lockedUntil = await context.read<AuthCubit>().otpLockedUntil();
    if (mounted) _setOtpLock(lockedUntil);
  }

  void _setOtpLock(DateTime? lockedUntil) {
    _otpLockTimer?.cancel();
    setState(() => _otpLockedUntil = lockedUntil);
    if (lockedUntil == null) return;
    _otpLockTimer = Timer(lockedUntil.difference(DateTime.now()), () {
      if (mounted) setState(() => _otpLockedUntil = null);
    });
  }

  void _onSendOtp(BuildContext context) {
    if (!_canSubmit) return;
    final phone = _cleanPhone;
    if (phone.length < 10) {
      _showToast(context, 'Please enter a valid 10-digit mobile number.');
      return;
    }
    context.read<AuthCubit>().sendOtp(
      phone,
      hashId: _appSignature,
      fileType: 2,
    );
  }

  void _onStaffLogin(BuildContext context) {
    final phone = _cleanPhone;
    final password = _passwordController.text.trim();
    if (phone.length < 10) {
      _showToast(context, 'Please enter a valid 10-digit mobile number.');
      return;
    }
    if (password.isEmpty) {
      _showToast(context, 'Please enter your staff password.');
      return;
    }
    context.read<AuthCubit>().staffLogin(phone, password);
  }

  void _showToast(BuildContext context, String message) {
    AppToast.show(context, message);
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
    } on PlatformException {
      // debugPrint('[SIM] Phone number hint failed: ${e.code} — ${e.message}');
      if (mounted) {
        _showToast(
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


  /// Only fetches the app signature (sent as `hashid` with the OTP request).
  /// The OTP page owns SMS listening: smart_auth keeps a single listener, so
  /// listening here as well could swallow the OTP SMS and break auto-fill.
  Future<void> _loadAppSignature() async {
    final signatureResult = await _smartAuth.getAppSignature();

    final signature =
    signatureResult.hasData
        ? signatureResult.requireData
        : null;

    debugPrint('App Signature: $signature');

    if (mounted) {
      setState(() {
        _appSignature = signature;
      });
    }
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
          if (state is AuthOtpLimitReached) _setOtpLock(state.lockedUntil);
          // The OTP page shows its own errors; only alert when this page is
          // on top, otherwise the same alert shows twice.
          if (ModalRoute.of(context)?.isCurrent ?? true) {
            _showToast(context, state.message);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          // The Dialog below already lifts itself above the keyboard; also
          // resizing the Scaffold relaid out the whole page every frame.
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Static background: isolate it from keyboard insets and
              // repaints so the blur isn't recomputed while typing.
              Positioned.fill(
                child: RepaintBoundary(
                  child: MediaQuery.removeViewInsets(
                    context: context,
                    removeBottom: true,
                    child: Stack(
                      children: [
                        const LoginOnBoardingScreen(),
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
                      ],
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
                      maxHeight: MediaQuery.sizeOf(context).height * .85,
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

                                color: const Color(0xffF58220),
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
                                        // Icon(
                                        //   Icons.unfold_more_rounded,
                                        //   size: 16.sp,
                                        //   color: AppColors.primaryBlue,
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      focusNode: _phoneFocusNode,
                                      enabled: _isStaffLogin || !_isOtpLocked,
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
                                        hintText: 'Enter 10-digit mobile number ',
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
                                onTap: isLoading || !_canSubmit
                                    ? null
                                    : () {
                                  _isStaffLogin
                                      ? _onStaffLogin(context)
                                      : _onSendOtp(context);
                                },
                                child: Container(
                                  height: 52.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _canSubmit
                                          ? [
                                        AppColors.inputBoxColor,
                                        AppColors.inputBoxColor,
                                      ]
                                          : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade400,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: _canSubmit
                                        ? [
                                      BoxShadow(
                                        color: AppColors.inputBoxColor.withValues(alpha: 0.35),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                        : [],
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
                            if (_isOtpLocked && !_isStaffLogin) ...[
                              SizedBox(height: 12.h),
                              Text(
                                AuthOtpLimitReached.otpLimitMessage(
                                  _otpLockedUntil!,
                                ),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.sosRed,
                                ),
                              ),
                            ],
                            SizedBox(height: 18.h),

                            // ---- terms footer ----
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                    value: _isTermsAccepted,
                                    onChanged: (value) {
                                      setState(() {
                                        _isTermsAccepted = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.inputBoxColor,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 8.h),
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
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _openUrl(ApiConstants.termsAndConditions);
                                              },
                                          ),
                                          const TextSpan(text: ' & '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors.inputBoxColor,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _openUrl(ApiConstants.termsAndConditions);
                                              },
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
                                ),
                              ],
                            ),


                            const SizedBox(height: 12),

                            FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final info = snapshot.data!;

                                return Text(
                                  '${ApiConstants.environment} • v${info.version} (${info.buildNumber})',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                );
                              },
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

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version} (${info.buildNumber})';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

