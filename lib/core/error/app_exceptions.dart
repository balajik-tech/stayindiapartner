import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.originalError});
}

class ServerException extends AppException {
  final int? statusCode;
  ServerException({required super.message, this.statusCode, super.code, super.originalError});
}

class AuthException extends AppException {
  AuthException({required super.message, super.code, super.originalError});
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.code, super.originalError});
}

class CacheException extends AppException {
  CacheException({required super.message, super.code, super.originalError});
}

class UnexpectedException extends AppException {
  UnexpectedException({required super.message, super.code, super.originalError});
}

class ErrorSanitizer {
  static final List<String> _technicalKeywords = [
    'exception', 'error', 'stacktrace', 'null', 'undefined', 'mongoose', 'mongodb', 'sql',
    'internal server', 'socket', 'connection', 'dio', 'firebase', 'unexpected', 'failed to',
    'lookup', 'host lookup', 'invalid', 'argument', 'type cast', 'missing', 'field'
  ];

  static String sanitize(String message) {
    if (message.isEmpty) return 'An unexpected error occurred.';
    
    final lowerMessage = message.toLowerCase();
    
    // Check for Mongoose validation error specifically!
    if (lowerMessage.contains("validation failed")) {
      return cleanMongooseMessage(message);
    }
    
    // If it looks like a raw technical error, return a generic one
    bool isTechnical = _technicalKeywords.any((keyword) => lowerMessage.contains(keyword));
    
    // Check for common raw patterns
    if (isTechnical || message.contains('[') || message.contains('{') || message.contains(':')) {
      // If it contains specific friendly parts, we might keep it, but generally we want to be safe
      if (lowerMessage.contains('not found') && !lowerMessage.contains('404')) return 'Requested item not found.';
      if (lowerMessage.contains('already exists')) return 'This record already exists.';
      if (lowerMessage.contains('invalid credentials')) return 'Invalid email or password.';
      
      return 'Something went wrong. Please try again later.';
    }
    
    return message;
  }

  static String cleanMongooseMessage(String msg) {
    final lowerMsg = msg.toLowerCase();
    if (lowerMsg.contains("validation failed")) {
      if (lowerMsg.contains("phone") || lowerMsg.contains("mobile")) {
        if (lowerMsg.contains("invalid") || lowerMsg.contains("is invalid")) {
          return "Please enter a valid 10-digit mobile number.";
        }
      }
      if (lowerMsg.contains("email") && lowerMsg.contains("invalid")) {
        return "Please enter a valid email address.";
      }
      
      String clean = msg;
      clean = clean.replaceAll(RegExp(r'^.*validation failed:\s*', caseSensitive: false), '');
      
      clean = clean.replaceAllMapped(RegExp(r"Path\s+`([^`]+)`\s+is\s+required", caseSensitive: false), (match) {
        final field = match.group(1) ?? 'field';
        return "${_capitalize(field)} is required";
      });
      clean = clean.replaceAllMapped(RegExp(r"Path\s+`([^`]+)`\s+is\s+invalid", caseSensitive: false), (match) {
        final field = match.group(1) ?? 'field';
        return "${_capitalize(field)} is invalid";
      });
      
      clean = clean.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
      
      clean = clean.replaceAllMapped(RegExp(r"(\w+):\s+\1\s+"), (match) {
        return "${match.group(1)}: ";
      });
      
      clean = clean.replaceAll("phone:", "Phone:")
                   .replaceAll("mobile:", "Mobile:")
                   .replaceAll("email:", "Email:")
                   .replaceAll("firstName:", "First Name:")
                   .replaceAll("lastName:", "Last Name:")
                   .replaceAll("sharingType:", "Sharing Type:")
                   .replaceAll("startDate:", "Start Date:");
      
      clean = clean.trim();
      if (clean.endsWith(",") || clean.endsWith(".")) {
        clean = clean.substring(0, clean.length - 1);
      }
      return clean;
    }
    return msg;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class GlobalErrorMapper {
  static AppException map(dynamic e) {
    if (e is AppException) return e;

    if (e is DioException) {
      return _mapDioException(e);
    }

    if (e is FirebaseException) {
      return AuthException(
        message: _mapFirebaseError(e.code),
        code: e.code,
        originalError: e,
      );
    }

    if (e is SocketException) {
      return NetworkException(
        message: 'No internet connection. Please check your network.',
        code: 'SOCKET_ERROR',
        originalError: e,
      );
    }

    if (e is PlatformException) {
      return UnexpectedException(
        message: 'A system error occurred. Please try again.',
        code: e.code,
        originalError: e,
      );
    }

    return UnexpectedException(
      message: ErrorSanitizer.sanitize(e.toString()),
      code: 'UNKNOWN',
      originalError: e,
    );
  }

  static AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timed out. Please check your internet.',
          code: 'TIMEOUT',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Could not connect to server. Please check your network.',
          code: 'NO_CONNECTION',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server error occurred.';
        String? backendCode;

        if (data is Map) {
          if (data['code'] != null) {
            backendCode = data['code'].toString();
          }
          if (data['message'] != null) {
            message = ErrorSanitizer.sanitize(data['message'].toString());
          }
        }

        // Try dictionary translation first
        if (backendCode != null) {
          final translated = ErrorCodeDictionary.translate(backendCode);
          if (translated != null) {
            message = translated;
          }
        }

        if (statusCode == 401 || statusCode == 403) {
          return AuthException(
            message: message.isNotEmpty ? message : 'Session expired. Please login again.',
            code: backendCode ?? 'UNAUTHORIZED',
            originalError: e,
          );
        }

        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return ValidationException(
            message: message,
            code: backendCode ?? 'BAD_REQUEST',
            originalError: e,
          );
        }

        return ServerException(
          message: message,
          statusCode: statusCode,
          code: 'SERVER_ERROR',
          originalError: e,
        );
      case DioExceptionType.cancel:
        return UnexpectedException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
          originalError: e,
        );
      default:
        return UnexpectedException(
          message: 'An unexpected network error occurred.',
          code: 'UNKNOWN_NETWORK',
          originalError: e,
        );
    }
  }

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class ErrorCodeDictionary {
  static final Map<String, String> _dictionary = {
    'BOOKING_ALREADY_EXISTS': 'This booking already exists in the system.',
    'INSUFFICIENT_STOCK': 'Not enough items in stock to complete this operation.',
    'INVALID_COUPON': 'The applied coupon is invalid or has expired.',
    'PAYMENT_FAILED': 'The payment could not be processed. Please try again.',
    'ROOM_NOT_AVAILABLE': 'The selected room is no longer available.',
    'TENANT_NOT_FOUND': 'The specified tenant could not be found.',
    'UNAUTHORIZED_ACTION': 'You do not have permission to perform this action.',
  };

  /// Returns a localized user-friendly string if the code exists, otherwise null.
  static String? translate(String code) {
    return _dictionary[code];
  }
}
