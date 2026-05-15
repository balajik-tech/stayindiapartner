import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/registration_personal_page.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/profile/presentation/cubit/hostel_cubit.dart';
import 'features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'features/notices/presentation/cubit/notice_cubit.dart';
import 'features/staff/presentation/cubit/staff_cubit.dart';
import 'features/payments/presentation/cubit/payment_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/theme_cubit.dart';


import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FlutterError.onError = (details) {
    // Skip logging parentDataDirty assertion errors in debug mode
    final errorString = details.exception.toString();
    if (!errorString.contains('parentDataDirty')) {
      AppLogger.error('FLUTTER FRAMEWORK ERROR: ${details.exception}', details.exception, details.stack);
    }
  };
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'An unexpected error occurred. Our team has been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('ASYNC/PLATFORM ERROR: $error', error, stack);
    return true;
  };

  await di.init();
  await di.sl<NotificationService>().init();
  await di.sl<NotificationService>().requestPermissions();
  
  AppLogger.info('Stay India Owner App Initialized');
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
        Locale('ta'),
        Locale('kn'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const StayIndiaOwnerApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StayIndiaOwnerApp extends StatelessWidget {
  const StayIndiaOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..restoreSession(),
        ),
        BlocProvider(
          create: (context) => di.sl<HostelCubit>()..getHostels(),
        ),
        BlocProvider(
          create: (context) => di.sl<BookingsCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<DashboardCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TenantCubit>(),
        ),
        BlocProvider(create: (context) => di.sl<MaintenanceCubit>()),
        BlocProvider(create: (context) => di.sl<NoticeCubit>()),
        BlocProvider(create: (context) => di.sl<StaffCubit>()),
        BlocProvider(create: (context) => di.sl<PaymentCubit>()),
        BlocProvider(create: (context) => di.sl<ProfileCubit>()),
        BlocProvider(create: (context) => di.sl<CommunityCubit>()),
        BlocProvider(create: (context) => di.sl<OwnerCommunityCubit>()),
        BlocProvider(create: (context) => di.sl<AssociationCubit>()),
        BlocProvider(create: (context) => di.sl<ThemeCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    navigatorKey.currentState?.popUntil((route) => route.isFirst);
                  }
                },
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  title: 'Stay India Owner',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: AuthGate(
                    dashboard: const MainNavigationPage(),
                    registration: const RegistrationPersonalPage(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


