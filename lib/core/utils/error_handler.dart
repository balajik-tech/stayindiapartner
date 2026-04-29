import 'dart:io';
import 'package:dio/dio.dart';
import '../error/app_exceptions.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is SocketException) {
      return "No internet connection. Please check your network.";
    } else if (error is FormatException) {
      return "Invalid data format received from server.";
    } else if (error is DioException) {
      final appException = mapDioException(error);
      return appException.message;
    } else {
      return "Something went wrong. Please try again later.";
    }
  }
}
