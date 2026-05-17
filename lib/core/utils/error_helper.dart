import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class ErrorHelper {
  static String toFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    }
    
    if (error is TimeoutException) {
      return "Request timed out. Please try again.";
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "The server took too long to respond. Please try again.";
        case DioExceptionType.connectionError:
          return "Cannot connect to the server. Check your internet.";
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map && data['message'] != null) {
            return cleanMongooseMessage(data['message'].toString());
          }
          return "Server returned an error (${error.response?.statusCode}).";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        default:
          return "A network error occurred. Please try again.";
      }
    }
    
    if (error is FormatException) {
      return "Server communication error.";
    }

    final String errorStr = error.toString().toLowerCase();

    if (errorStr.contains("401") || errorStr.contains("unauthorized")) {
      return "Session expired. Please login again.";
    }
    
    if (errorStr.contains("403") || errorStr.contains("forbidden")) {
      return "You do not have permission for this action.";
    }

    if (errorStr.startsWith("exception: ")) {
      return cleanMongooseMessage(errorStr.replaceFirst("exception: ", ""));
    }

    if (errorStr.length > 60 || errorStr.contains("null check") || errorStr.contains("type error")) {
      return "An unexpected error occurred. Please try again.";
    }

    return cleanMongooseMessage(error.toString());
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
