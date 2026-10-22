import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../firebase_options.dart';
import '../../injection_container.dart' as di;
import '../constants/api_constants.dart';
import '../services/token_storage.dart';
import '../widgets/app_scaffold_messenger.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../services/app_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_cubit.dart';
import '../utils/logger.dart';
import '../widgets/animated_splash_text.dart';

// Features / Auth imports
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/guest_session_cubit.dart';
import '../../features/auth/presentation/pages/LoginOnBoardingScreen.dart';
import '../../features/auth/presentation/pages/link_phone_page.dart';
import '../../features/auth/presentation/pages/registration_personal_page.dart';
import '../../features/profile/presentation/cubit/hostel_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../features/bookings/cubit/bookings_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/tenants/presentation/cubit/tenant_cubit.dart';
import '../../features/maintenance/presentation/cubit/maintenance_cubit.dart';
import '../../features/notices/presentation/cubit/notice_cubit.dart';
import '../../features/staff/presentation/cubit/staff_cubit.dart';
import '../../features/payments/presentation/cubit/payment_cubit.dart';
import '../../features/communities/presentation/cubit/community_cubit.dart';
import '../../features/communities/presentation/cubit/owner_community_cubit.dart';
import '../../features/communities/presentation/cubit/association_cubit.dart';
import '../../features/communities/presentation/cubit/association_membership_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Preparing system...';
  bool _hasError = false;
  String _errorDetails = '';
  bool _systemInitialized = false;

  // Onboarding/Auth Decision State
  bool _hasSeenOnboarding = false;
  bool _isCheckingOnboarding = true;
  AuthState? _lastActiveState;

  @override
  void initState() {
    super.initState();
    _startStagedInitialization();
  }

  Future<void> _startStagedInitialization() async {
    setState(() {
      _progress = 0.05;
      _statusText = 'Loading localization system...';
      _hasError = false;
      _errorDetails = '';
    });

    try {
      // 1. Initial system checks
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      // 2. App-Config
      AppLogger.info('Bootstrapping App Config...');
      final configService = AppConfigService();
      await configService.load(force: true);

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      await EasyLocalization.ensureInitialized();

      setState(() {
        _progress = 0.20;
        _statusText = 'Building secure storage...';
      });

      final storageDir = await getApplicationDocumentsDirectory();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: storageDir,
      );
      await Hive.initFlutter();

      setState(() {
        _progress = 0.45;
        _statusText = 'Connecting Stay India Cloud...';
      });

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        final errorString = details.exception.toString();
        if (!errorString.contains('parentDataDirty')) {
          AppLogger.error(
            'FLUTTER FRAMEWORK ERROR: ${details.exception}',
            details.exception,
            details.stack,
          );
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        AppLogger.error('ASYNC/PLATFORM ERROR: $error', error, stack);
        return true;
      };

      setState(() {
        _progress = 0.65;
        _statusText = 'Initializing services & dependencies...';
      });

      await di.init();

      if (di.sl.isRegistered<AppConfigService>()) {
        await di.sl.unregister<AppConfigService>();
      }
      di.sl.registerSingleton<AppConfigService>(configService);

      setState(() {
        _progress = 0.80;
        _statusText = 'Optimizing caches & notifications...';
      });

      await di.sl<CacheService>().checkAndFlushOnUpdate();
      await di.sl<NotificationService>().init();
      await di.sl<NotificationService>().requestPermissions();

      // Fetch user profile if logged in to warm up caches/state
      try {
        final token = await di.sl<TokenStorage>().getToken();
        if (token != null && token.isNotEmpty) {
          AppLogger.info('Warm-booting user profile...');
          
          // Using di directly to avoid circular dependency
          if (di.sl.isRegistered<ProfileCubit>()) {
             // Explicitly awaiting to ensure state is ready before dashboard
            await di.sl<ProfileCubit>().loadProfile();
          }
        }
      } catch (e) {
        AppLogger.warning('Silent profile fetch failed during bootstrap: $e');
      }

      // Trigger session restoration immediately
      await di.sl<AuthCubit>().restoreSession();

      AppLogger.info('Stay India Owner App Initialized via Bootstrapper');

      setState(() {
        _progress = 1.0;
        _statusText = 'Welcome Owner';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _systemInitialized = true;
          _isCheckingOnboarding = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error(
        'OWNER STARTUP INITIALIZATION CRITICAL ERROR: $e',
        e,
        stack,
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorDetails = e.toString();
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
    final guestCubit = di.sl<GuestSessionCubit>();
    await guestCubit.setGuest(true);
    await guestCubit.setKycComplete(false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_systemInitialized) {
      return _buildRawSplash(animate: true);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthCubit>()),
        BlocProvider.value(value: di.sl<ThemeCubit>()),
        BlocProvider.value(value: di.sl<GuestSessionCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return EasyLocalization(
                supportedLocales: const [
                  Locale('en'),
                  Locale('hi'),
                  Locale('te'),
                  Locale('ta'),
                  Locale('kn'),
                  Locale('ml'),
                ],
                path: 'assets/translations',
                fallbackLocale: const Locale('en'),
                child: BlocListener<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated ||
                        state is AuthProfileCompleted) {
                      context.read<GuestSessionCubit>().setGuest(false);
                      context.read<HostelCubit>().getHostels(forceRefresh: true);
                      context.read<NotificationCubit>().fetchNotifications();
                    }
                    if (state is AuthUnauthenticated) {
                      navigatorKey.currentState?.popUntil(
                        (route) => route.isFirst,
                      );
                    }
                  },
                  child: BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (prev, curr) {
                      if (curr is AuthLoading ||
                          curr is AuthError ||
                          curr is AuthOtpSent) {
                        return false;
                      }
                      
                      // Always rebuild when moving between authenticated and unauthenticated states
                      // or when logging out to ensure UI transitions properly.
                      if (curr is AuthLoggingOut || prev is AuthLoggingOut || 
                          curr is AuthUnauthenticated || prev is AuthUnauthenticated) {
                        return true;
                      }

                      final prevKey = prev is AuthAuthenticated
                          ? prev.owner.id
                          : 'unauthenticated';
                      final currKey = curr is AuthAuthenticated
                          ? curr.owner.id
                          : 'unauthenticated';
                      return prevKey != currKey;
                    },
                    builder: (context, authState) {
                      final sessionKey = authState is AuthAuthenticated
                          ? authState.owner.id
                          : 'unauthenticated';

                      return MultiBlocProvider(
                        key: ValueKey(sessionKey),
                        providers: [
                          BlocProvider(
                            create: (context) =>
                                di.sl<HostelCubit>()..getHostels(),
                          ),
                          BlocProvider(create: (context) => di.sl<BookingsCubit>()),
                          BlocProvider(
                            create: (context) => di.sl<DashboardCubit>(),
                          ),
                          BlocProvider(create: (context) => di.sl<TenantCubit>()),
                          BlocProvider(
                            create: (context) => di.sl<MaintenanceCubit>(),
                          ),
                          BlocProvider(create: (context) => di.sl<NoticeCubit>()),
                          BlocProvider(create: (context) => di.sl<StaffCubit>()),
                          BlocProvider(create: (context) => di.sl<PaymentCubit>()),
                          BlocProvider(
                            create: (context) => di.sl<ProfileCubit>(),
                          ),
                          BlocProvider(create: (context) => di.sl<SettingsCubit>()),
                          BlocProvider(create: (context) => di.sl<CommunityCubit>()),
                          BlocProvider(
                            create: (context) => di.sl<OwnerCommunityCubit>(),
                          ),
                          BlocProvider(
                            create: (context) => di.sl<AssociationCubit>(),
                          ),
                          BlocProvider(
                            create: (context) =>
                                di.sl<NotificationCubit>()..fetchNotifications(),
                          ),
                          BlocProvider(
                            create: (context) =>
                                di.sl<AssociationMembershipCubit>(),
                          ),
                        ],
                        child: MaterialApp(
                          navigatorKey: navigatorKey,
                          navigatorObservers: [routeObserver],
                          title: 'Stay India Owner',
                          debugShowCheckedModeBanner: false,
                          theme: AppTheme.lightTheme,
                          darkTheme: AppTheme.darkTheme,
                          themeMode: themeMode,
                          localizationsDelegates: context.localizationDelegates,
                          supportedLocales: context.supportedLocales,
                          locale: context.locale,
                          builder: (context, child) {
                            Intl.defaultLocale = context.locale.toString();
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              child: AppScaffoldMessenger(
                                child: SafeArea(
                                  top: false,
                                  bottom: true,
                                  child: child!,
                                ),
                              ),
                            );
                          },
                          home: _buildHome(authState),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthState state) {
    if (!_hasSeenOnboarding) {
      return OnboardingPage(onComplete: _markOnboardingComplete);
    }

    if (state is! AuthLoading && state is! AuthError) {
      _lastActiveState = state;
    }

    final activeState = _lastActiveState ?? state;

    if (activeState is AuthInitial || activeState is AuthSessionRestoring || activeState is AuthLoggingOut) {
      return _buildRawSplash(animate: false, wrapInMaterialApp: false);
    }

    if (activeState is AuthGoogleNeedsPhone) {
      return const LinkPhonePage();
    }

    if (activeState is AuthAuthenticated || activeState is AuthProfileCompleted) {
      final bool requiresRegistration = activeState is AuthAuthenticated
          ? activeState.requiresRegistration
          : false;

      if (requiresRegistration) {
        return const RegistrationPersonalPage();
      }
      return const MainNavigationPage();
    }

    if (activeState is AuthUnauthenticated || activeState is AuthOtpSent) {
      return const LoginOnBoardingScreen();
    }

    if (activeState is AuthSessionRestoreError) {
      return _SessionErrorScreen(
        message: activeState.message,
        onRetry: () => di.sl<AuthCubit>().restoreSession(),
        onLogin: () => di.sl<AuthCubit>().logout(),
      );
    }

    return const LoginOnBoardingScreen();
  }

  Widget _buildRawSplash({required bool animate, bool wrapInMaterialApp = true}) {
    // Before system is initialized, we don't have ScreenUtil or Theme
    // So we use hardcoded values matching the splash design
    final splashContent = Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 160, // Fixed pixel height
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.apartment_rounded, size: 100, color: Color(0xFF16539B)),
            ),
            const SizedBox(height: 24),
            AnimatedFutureOfLivingText(animate: animate),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    if (!wrapInMaterialApp) return splashContent;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splashContent,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16539B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLogin,
                child: const Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
