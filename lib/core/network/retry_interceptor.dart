import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/logger.dart';



class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final int baseDelayMs;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    int retryCount = extra['retry_count'] ?? 0;

    
    bool isIdempotent = err.requestOptions.method.toUpperCase() == 'GET';
    bool isNetworkError = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isIdempotent && isNetworkError && retryCount < maxRetries) {
      retryCount++;
      err.requestOptions.extra['retry_count'] = retryCount;

      final delayMs = baseDelayMs * retryCount;
      AppLogger.warning(
        '[RETRY] Network error on ${err.requestOptions.path}. '
        'Retrying ($retryCount/$maxRetries) in ${delayMs}ms...',
      );

      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        
        final response = await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: err.requestOptions.extra,
            responseType: err.requestOptions.responseType,
            contentType: err.requestOptions.contentType,
            validateStatus: err.requestOptions.validateStatus,
            receiveDataWhenStatusError: err.requestOptions.receiveDataWhenStatusError,
            followRedirects: err.requestOptions.followRedirects,
            maxRedirects: err.requestOptions.maxRedirects,
            requestEncoder: err.requestOptions.requestEncoder,
            responseDecoder: err.requestOptions.responseDecoder,
            listFormat: err.requestOptions.listFormat,
          ),
        );
        return handler.resolve(response);
      } catch (e) {
        
        AppLogger.error('[RETRY FAILED] ${err.requestOptions.path} after $retryCount retries.');
      }
    }

    return handler.next(err);
  }
}
