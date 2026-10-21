import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

class ApiLoggingInterceptor extends Interceptor {
  static const int _maxPayloadLength = 8000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug(
        '[API REQUEST] ${options.method} ${_safeUri(options.uri)}\n'
        'Body: ${_formatPayload(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final request = response.requestOptions;
      AppLogger.debug(
        '[API RESPONSE] ${request.method} ${_safeUri(request.uri)} '
        '-> Status: ${response.statusCode}\n'
        'Body: ${_formatPayload(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final request = err.requestOptions;
      AppLogger.debug(
        '[API RESPONSE] ${request.method} ${_safeUri(request.uri)} '
        '-> Status: ${err.response?.statusCode ?? 'No response'}\n'
        'Body: ${_formatPayload(err.response?.data)}',
      );
    }
    handler.next(err);
  }

  String _safeUri(Uri uri) {
    final query = uri.queryParametersAll.map(
      (key, values) =>
          MapEntry(key, _isSensitiveKey(key) ? <String>['[REDACTED]'] : values),
    );
    return uri.replace(query: Uri(queryParameters: query).query).toString();
  }

  String _formatPayload(dynamic value) {
    final formatted = const JsonEncoder.withIndent(
      '  ',
    ).convert(_sanitize(value));
    if (formatted.length <= _maxPayloadLength) return formatted;
    return '${formatted.substring(0, _maxPayloadLength)}... [truncated]';
  }

  dynamic _sanitize(dynamic value) {
    if (value is FormData) {
      return {
        'fields': {
          for (final field in value.fields)
            field.key: _sanitizeField(field.key, field.value),
        },
        'files': [
          for (final file in value.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'length': file.value.length,
              'contentType': file.value.contentType?.toString(),
            },
        ],
      };
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _sanitizeField(
            entry.key.toString(),
            entry.value,
          ),
      };
    }
    if (value is Uint8List) {
      return '[binary payload omitted: ${value.length} bytes]';
    }
    if (value is Iterable) {
      return value.map(_sanitize).toList();
    }
    if (value is String) {
      try {
        return _sanitize(jsonDecode(value));
      } on FormatException {
        return value.replaceAll(
          RegExp(r'(Bearer\s+)[^\s,"]+', caseSensitive: false),
          r'$1[REDACTED]',
        );
      }
    }
    if (value == null || value is num || value is bool) {
      return value;
    }
    return value.toString();
  }

  dynamic _sanitizeField(String key, dynamic value) =>
      _isSensitiveKey(key) ? '[REDACTED]' : _sanitize(value);

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.contains('authorization') ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('password') ||
        normalized.contains('otp') ||
        normalized.contains('phone') ||
        normalized.contains('mobile') ||
        normalized.contains('email') ||
        normalized.contains('apikey') ||
        normalized == 'name' ||
        normalized == 'userid' ||
        normalized == 'portalid';
  }
}
