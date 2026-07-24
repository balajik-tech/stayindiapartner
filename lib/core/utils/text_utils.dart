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
}