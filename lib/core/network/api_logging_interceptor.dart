import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggingInterceptor extends Interceptor {
  static const int _maxPayloadLength = 8000;

  static const String _cyan = '\x1B[36m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _reset = '\x1B[0m';
  static const String _divider =
      '────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _print(_cyan, [
        _divider,
        '➡️  REQUEST  ${options.method} ${_safeUri(options.uri)}',
        _divider,
        'Headers: ${_formatPayload(options.headers)}',
        if (options.data != null) 'Body: ${_formatPayload(options.data)}',
        _divider,
      ]);
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
      _print(_yellow, [
        _divider,
        '⬅️  RESPONSE ${response.statusCode} ${request.method} '
            '${_safeUri(request.uri)}',
        _divider,
        _formatPayload(response.data),
        _divider,
      ]);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final request = err.requestOptions;
      _print(_red, [
        _divider,
        '❌ ERROR ${err.response?.statusCode ?? 'No response'} '
            '${request.method} ${_safeUri(request.uri)}',
        _divider,
        if (err.response?.data != null)
          _formatPayload(err.response?.data)
        else
          '${err.type.name}: ${err.message}',
        _divider,
      ]);
    }
    handler.next(err);
  }

  /// Uses `dart:developer` log instead of `print` so the output isn't
  /// prefixed with `I/flutter (pid):` per line or split by logcat.
  void _print(String color, List<String> blocks) {
    final colored = blocks
        .expand((block) => block.split('\n'))
        .map((line) => '$color$line$_reset')
        .join('\n');
    developer.log(colored, name: 'API');
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
    return normalized.contains('authorization');
    //     normalized.contains('token') || 
    // return normalized.contains('authorization') ||
    //     normalized.contains('token') ||
    //     normalized.contains('secret') ||
    //     normalized.contains('password') ||
    //     normalized.contains('otp') ||
    //     normalized.contains('phone') ||
    //     normalized.contains('mobile') ||
    //     normalized.contains('email') ||
    //     normalized.contains('apikey') ||
    //     normalized == 'name' ||
    //     normalized == 'userid' ||
    //     normalized == 'portalid';
  }
}
