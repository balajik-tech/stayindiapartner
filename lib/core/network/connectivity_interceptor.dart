import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../error/app_exceptions.dart';
import '../services/offline_queue_service.dart';
import '../../injection_container.dart';
import '../utils/logger.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    final isLocalRequest = options.baseUrl.contains('localhost') || 
                          options.baseUrl.contains('127.0.0.1');

    if (connectivityResult.contains(ConnectivityResult.none) && !isLocalRequest) {
      if (options.method != 'GET') {
        
        try {
          final queueService = sl<OfflineQueueService>();
          
          
          final idempotencyKey = options.headers['X-Idempotency-Key'] ?? 
              'idem-${DateTime.now().microsecondsSinceEpoch}-${options.path.hashCode}';
          options.headers['X-Idempotency-Key'] = idempotencyKey;

          
          Map<String, dynamic> serializableData = {};
          if (options.data is Map<String, dynamic>) {
            serializableData = options.data as Map<String, dynamic>;
          } else if (options.data is String) {
            
          }

          final actionPayload = {
            'path': options.path,
            'method': options.method,
            'data': serializableData,
            'headers': Map<String, dynamic>.from(options.headers),
            'queryParameters': Map<String, dynamic>.from(options.queryParameters),
          };

          await queueService.enqueueAction('MUTATION', actionPayload);
          AppLogger.info('[OFFLINE QUEUE] Interceptor queued offline mutation: ${options.method} ${options.path}');

          return handler.reject(
            DioException(
              requestOptions: options,
              error: NetworkException(
                message: 'You are offline. Your request has been queued and will replay automatically when you reconnect.',
                code: 'OFFLINE_MUTATION_QUEUED',
              ),
              type: DioExceptionType.connectionError,
            ),
          );
        } catch (e) {
          AppLogger.error('[OFFLINE QUEUE] Failed to queue request', e);
        }
      }

      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkException(
            message: 'No internet connection available.',
            code: 'OFFLINE',
          ),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    
    
    if (options.method != 'GET') {
      options.headers['X-Idempotency-Key'] ??= 
          'idem-${DateTime.now().microsecondsSinceEpoch}-${options.path.hashCode}';
    }

    return handler.next(options);
  }
}
