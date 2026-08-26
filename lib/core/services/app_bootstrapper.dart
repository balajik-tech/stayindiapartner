import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../firebase_options.dart';
import '../../injection_container.dart' as di;
import '../services/token_storage.dart';
import '../services/cache_service.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../services/notification_service.dart';
import '../services/app_config_service.dart';
import '../theme/app_colors.dart';
import '../utils/logger.dart';
import '../widgets/animated_splash_text.dart';

class AppBootstrapper extends StatefulWidget {
  final Widget child;

  const AppBootstrapper({super.key, required this.child});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Preparing system...';
  bool _hasError = false;
  String _errorDetails = '';
  bool _initialized = false;

  AnimationController? _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController!.forward();
    _startStagedInitialization();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _startStagedInitialization() async {
    setState(() {
      _progress = 0.05;
      _statusText = 'Loading localization system...';
      _hasError = false;
      _errorDetails = '';
    });

    try {
      // 1. App-Config MUST be first to ensure keys/tokens are ready for other services
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

      // Update the singleton in DI with the one we just loaded
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
          await di.sl<ProfileCubit>().loadProfile();
        }
      } catch (e) {
        AppLogger.warning('Silent profile fetch failed during bootstrap: $e');
      }

      AppLogger.info('Stay India Owner App Initialized via Bootstrapper');

      setState(() {
        _progress = 1.0;
        _statusText = 'Welcome Owner';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _initialized = true;
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

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: widget.child,
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
