import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../error/app_exceptions.dart';

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
    
    return handler.next(options);
  }
}
