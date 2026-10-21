import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/network/api_logging_interceptor.dart';

import '../utils/logger.dart';

class AppConfigData {
  final String app;
  final String razorpayKey;
  final String digilockerCompanyName;
  final String partnerCode;
  final String secretToken;
  final String digilockerRedirectUrl;

  const AppConfigData({
    required this.app,
    required this.razorpayKey,
    required this.digilockerCompanyName,
    required this.partnerCode,
    required this.secretToken,
    required this.digilockerRedirectUrl,
  });

  factory AppConfigData.fallback() {
    return const AppConfigData(
      app: '',
      razorpayKey: '',
      digilockerCompanyName: '',
      partnerCode: '',
      secretToken: '',
      digilockerRedirectUrl: '',
    );
  }

  factory AppConfigData.fromMap(Map<String, dynamic> map) {
    final digilockerMap = map['digilocker'] is Map
        ? Map<String, dynamic>.from(map['digilocker'] as Map)
        : <String, dynamic>{};

    return AppConfigData(
      app: (map['app'] ?? '').toString(),
      razorpayKey: (map['razorpayKey'] ?? '').toString(),
      digilockerCompanyName: (digilockerMap['companyName'] ?? '').toString(),
      partnerCode: (digilockerMap['partnerCode'] ?? '').toString(),
      secretToken: (digilockerMap['secretToken'] ?? '').toString(),
      digilockerRedirectUrl: (digilockerMap['redirectUrl'] ?? '').toString(),
    );
  }
}

class AppConfigService {
  static const String _appKey = String.fromEnvironment(
    'APP_CONFIG_APP',
    defaultValue: 'PARTNER',
  );
  static const String _apiKey = String.fromEnvironment(
    'APP_CONFIG_API_KEY',
    defaultValue: 'OOcC7N4PxAy4LZbIKk8hfVC6',
  );

  final Dio _dio;
  AppConfigData? _config;
  bool _isLoading = false;

  AppConfigService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            ) {
    _dio.interceptors.add(ApiLoggingInterceptor());
  }

  bool get isLoaded => _config != null;
  AppConfigData get data => _config ?? AppConfigData.fallback();

  String get app => data.app;
  String get razorpayKey => data.razorpayKey;
  String get digilockerCompanyName => data.digilockerCompanyName;
  String get partnerCode => data.partnerCode;
  String get secretToken => data.secretToken;
  String get digilockerRedirectUrl => data.digilockerRedirectUrl;

  Future<AppConfigData?> load({bool force = true}) async {
    if (_isLoading) {
      AppLogger.debug('AppConfig load already in progress...');
      return _config;
    }

    // If not forcing and already loaded, return existing
    if (!force && _config != null) return _config;

    _isLoading = true;
    AppLogger.info('Initializing app-config from remote API...');

    try {
      final String url = ApiConstants.effectiveBaseUrl + ApiConstants.remoteConfig;
      AppLogger.debug('AppConfig GET: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'x-app': _appKey,
            'x-api-key': _apiKey,
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );

      final payload = response.data;
      if (payload is! Map || payload['success'] != true || payload['data'] is! Map) {
        AppLogger.error('Invalid app-config response structure: $payload');
        throw StateError('Invalid app-config response payload');
      }

      final configMap = Map<String, dynamic>.from(payload['data'] as Map);
      _config = AppConfigData.fromMap(configMap);
      AppLogger.success('App config loaded successfully for ${_config!.app}.');
      return _config;
    } catch (error, stackTrace) {
      AppLogger.error('CRITICAL: Failed to load remote app config.', error, stackTrace);
      // Ensure we have at least fallback data if it's the first run
      _config ??= AppConfigData.fallback();
      return _config;
    } finally {
      _isLoading = false;
    }
  }

  static AppConfigService get instance {
    if (GetIt.instance.isRegistered<AppConfigService>()) {
      return GetIt.instance<AppConfigService>();
    }
    return AppConfigService();
  }
}
