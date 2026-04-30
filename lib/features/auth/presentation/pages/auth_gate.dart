import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import 'login_page.dart';









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
  Widget? _activeView;

  Widget? _determineView(AuthState state) {
    if (state is AuthInitial || state is AuthSessionRestoring) {
      return const _SplashScreen();
    } else if (state is AuthAuthenticated) {
      final reqReg = state.requiresRegistration;
      if (reqReg || state is AuthProfileCompleted) {
        return widget.registration;
      } else {
        return widget.dashboard;
      }
    } else if (state is AuthUnauthenticated) {
      return const LoginPage();
    } else if (state is AuthSessionRestoreError) {
      return _SessionErrorScreen(
        message: state.message,
        onRetry: () => context.read<AuthCubit>().restoreSession(),
        onLogin: () => context.read<AuthCubit>().logout(),
      );
    } else if (state is AuthOtpSent) {
      return const LoginPage();
    }
    return null; 
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => _determineView(current) != null,
      listener: (context, state) {
        final nextView = _determineView(state);
        if (nextView != null) {
          setState(() {
            _activeView = nextView;
          });
        }
      },
      builder: (context, state) {
        
        _activeView ??= _determineView(state) ?? const _SplashScreen();
        return _activeView!;
      },
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
              'assets/images/logo.png',
              height: 120.h,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.apartment_rounded,
                size: 100.sp,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 48.h),
            const CircularProgressIndicator(color: AppColors.primaryBlue),
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
                    color: AppColors.darkText),
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
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text('Try Again',
                      style:
                          TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onLogin,
                child: Text('Go to Login',
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.greyText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
