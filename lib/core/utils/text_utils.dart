import 'package:easy_localization/easy_localization.dart';

class TextUtils {
  TextUtils._(); // Prevent instantiation

  /// Converts text to Title Case
  static String toTitleCase(String text) {
    if (text.trim().isEmpty) return text;

    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    })
        .join(' ');
  }

  /// Capitalizes only the first letter
  static String capitalize(String text) {
    if (text.trim().isEmpty) return text;

    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
  static String formatDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return '-';
    }

    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return '-';
    }
  }
}