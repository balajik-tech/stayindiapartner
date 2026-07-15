import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/auth/domain/models/guest_session.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/guest_session_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/onboarding/presentation/pages/onboarding_page.dart';
import '../cubit/auth_cubit.dart';
import 'login_page.dart';
import 'link_phone_page.dart';
import 'package:stayindia_owner/core/widgets/animated_splash_text.dart';

class AuthGate extends StatefulWidget {
  final Widget dashboard;
  final Widget registration;

  const AuthGate({
    super.key,
    required this.dashboard,
    required this.registration,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthState? _lastActiveState;
  bool _hasSeenOnboarding = false;
  bool _isCheckingOnboarding = true;
  bool _isSplashDelayDone = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSplashDelayDone = true;
        });
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
      if (mounted) {
        setState(() {
          _hasSeenOnboarding = hasSeen;
          _isCheckingOnboarding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingOnboarding = false;
        });
      }
    }
  }

  Future<void> _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = true;
      });
    }
    final guestCubit = context.read<GuestSessionCubit>();
    await guestCubit.setGuest(true);
    await guestCubit.setKycComplete(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding || !_isSplashDelayDone) {
      return const _SplashScreen();
    }

    if (!_hasSeenOnboarding) {
      return OnboardingPage(onComplete: _markOnboardingComplete);
    }

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthProfileCompleted) {
          context.read<GuestSessionCubit>().setGuest(false);
          context.read<HostelCubit>().getHostels(forceRefresh: true);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            current is! AuthLoading &&
            current is! AuthError &&
            current is! AuthOtpSent,
        builder: (context, state) {
          if (state is! AuthLoading && state is! AuthError) {
            _lastActiveState = state;
          }

          final activeState = _lastActiveState ?? state;

          if (activeState is AuthInitial ||
              activeState is AuthSessionRestoring ||
              !_isSplashDelayDone) {
            return const _SplashScreen();
          }

          if (activeState is AuthGoogleNeedsPhone) {
            return const LinkPhonePage();
          }

          if (activeState is AuthAuthenticated ||
              activeState is AuthProfileCompleted) {
            final bool requiresRegistration = activeState is AuthAuthenticated
                ? activeState.requiresRegistration
                : false;

            if (requiresRegistration) {
              return widget.registration;
            }
            return widget.dashboard;
          }

          if (activeState is AuthUnauthenticated ||
              activeState is AuthOtpSent) {
            context.read<HostelCubit>().reset();
            return const LoginPage();
          }

          if (activeState is AuthSessionRestoreError) {
            return _SessionErrorScreen(
              message: activeState.message,
              onRetry: () => context.read<AuthCubit>().restoreSession(),
              onLogin: () => context.read<AuthCubit>().logout(),
            );
          }

          return const LoginPage();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 160.h,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.apartment_rounded,
                size: 100.sp,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 24.h),
            const AnimatedFutureOfLivingText(),
            SizedBox(height: 32.h),
            // const CircularProgressIndicator(color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}

class _SessionErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogin;

  const _SessionErrorScreen({
    required this.message,
    required this.onRetry,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 72.sp, color: Colors.grey),
              SizedBox(height: 24.h),
              Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: AppColors.greyText),
              ),
              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onLogin,
                child: Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
