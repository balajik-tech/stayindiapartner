import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  static final Map<String, dynamic> _crashContext = {};

  /// Enriches crash reports with user or system metadata
  static void setContext(String key, dynamic value) {
    _crashContext[key] = value;
  }

  static void clearCustomContext() {
    _crashContext.clear();
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void success(String message) {
    _logger.i('SUCCESS: $message');
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void debug(String message) {
    _logger.d(message);
  }
  
  static void purple(String message) {
     _logger.t(message); 
  }
}
