import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../firebase_options.dart';
import '../../injection_container.dart' as di;
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

class AppBootstrapper extends StatefulWidget {
  final Widget child;

  const AppBootstrapper({super.key, required this.child});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Preparing system...';
  bool _hasError = false;
  String _errorDetails = '';
  bool _initialized = false;

  late AnimationController _animationController;
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
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _startStagedInitialization();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
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
          AppLogger.error('FLUTTER FRAMEWORK ERROR: ${details.exception}', details.exception, details.stack);
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

      setState(() {
        _progress = 0.80;
        _statusText = 'Optimizing caches & notifications...';
      });

      
      await di.sl<CacheService>().checkAndFlushOnUpdate();
      await di.sl<NotificationService>().init();
      await di.sl<NotificationService>().requestPermissions();

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
      AppLogger.error('OWNER STARTUP INITIALIZATION CRITICAL ERROR: $e', e, stack);
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                const Color(0xFF1E3A8A).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      
                      
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png', 
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.business_rounded,
                                color: Color(0xFF1E3A8A),
                                size: 60,
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      const Text(
                        'STAY INDIA OWNER',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Enterprise Property & Tenant Console',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const Spacer(),

                      if (_hasError) ...[
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'System Boot Failed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorDetails,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _startStagedInitialization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Retry Booting',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ] else ...[
                        
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 6,
                            width: 220,
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _statusText,
                            key: ValueKey<String>(_statusText),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
