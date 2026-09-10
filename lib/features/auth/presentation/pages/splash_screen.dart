import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/features/auth/presentation/pages/registration_personal_page.dart';
import 'package:stayindia_owner/features/auth/presentation/pages/login_page.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/widgets/animated_splash_text.dart';

import 'LoginOnBoardingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isTimerDone = false;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    if (!_isTimerDone || _isNavigated) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthInitial || authState is AuthSessionRestoring) {
      return;
    }

    _navigateToNext(authState);
  }

  void _navigateToNext(AuthState state) {
    if (!mounted || _isNavigated) return;
    _isNavigated = true;

    Widget nextScreen;
    if (state is AuthAuthenticated || state is AuthProfileCompleted) {
      final bool requiresRegistration = state is AuthAuthenticated
          ? state.requiresRegistration
          : false;
      if (requiresRegistration) {
        nextScreen = const RegistrationPersonalPage();
      } else {
        nextScreen = const MainNavigationPage();
      }
    } else if (state is AuthUnauthenticated || state is AuthOtpSent) {
      // nextScreen = const LoginPage();
      nextScreen = const LoginOnBoardingScreen();
    } else {
      nextScreen = const LoginOnBoardingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _checkAndNavigate();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.w,
                      height: 150.w,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const AnimatedFutureOfLivingText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
