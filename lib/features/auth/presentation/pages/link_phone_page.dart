import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

class LinkPhonePage extends StatefulWidget {
  const LinkPhonePage({super.key});

  @override
  State<LinkPhonePage> createState() => _LinkPhonePageState();
}

class _LinkPhonePageState extends State<LinkPhonePage> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFocused = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() => _isFocused = _phoneFocusNode.hasFocus);
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
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
    _entranceController.dispose();
    super.dispose();
  }

  String get _cleanPhone => _phoneController.text
      .replaceAll(' ', '')
      .replaceAll('+91', '')
      .replaceAll('-', '')
      .trim();

  void _onSubmit(BuildContext context) {
    final phone = _cleanPhone;
    if (phone.length < 10 || !RegExp(r'^[6-9]').hasMatch(phone)) {
      _showSnackBar(context, 'Please enter a valid 10-digit mobile number starting with 6-9.');
      return;
    }
    context.read<AuthCubit>().linkPhone(phone);
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (_, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          _showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundGrey,
          body: Stack(
            children: [
              Container(
                height: 0.45.sh,
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
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 25.h),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(14.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.security_rounded,
                                  color: Colors.white,
                                  size: 40.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "STAY INDIA",
                                style: GoogleFonts.outfit(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "OWNER SECURITY PROFILE",
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxHeight: 0.70.sh),
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 28.h,
                        bottom: 24.h,
                      ),
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
                              'Link Mobile Number',
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
                              'Please link a compulsory 10-digit mobile number to complete your profile verification.',
                              style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                color: AppColors.greyText.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'MOBILE NUMBER',
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greyText.withValues(alpha: 0.6),
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
                                    : AppColors.backgroundGrey.withValues(alpha: 0.5),
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
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
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
                                      textAlignVertical: TextAlignVertical.center,
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
                                        prefixIconConstraints: const BoxConstraints(
                                          minWidth: 0,
                                          minHeight: 0,
                                        ),
                                      ),
                                      onSubmitted: (_) => _onSubmit(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),
                            AuthPrimaryButton(
                              label: isLoading ? 'VERIFYING...' : 'VERIFY & SAVE',
                              isLoading: isLoading,
                              onPressed: () => _onSubmit(context),
                            ),
                            SizedBox(height: 20.h),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.read<AuthCubit>().logout();
                                },
                                child: Text(
                                  'Logout & Cancel',
                                  style: GoogleFonts.outfit(
                                    color: Colors.red.shade600,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}
