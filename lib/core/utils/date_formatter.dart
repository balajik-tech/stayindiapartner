import 'package:intl/intl.dart';

class DateFormatter {
  static String formatISO(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Not set') {
      return 'Not set';
    }
    try {
      String normalized = dateStr;
      if (dateStr.contains('T')) {
        normalized = dateStr.split('T')[0];
      }

      if (normalized.length >= 10) {
        final parts = normalized.substring(0, 10).split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return DateFormat('MMM dd, yyyy').format(date);
        }
      }

      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static String formatFull(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Not set';
    try {
      String normalized = dateStr;
      if (dateStr.contains('T')) {
        normalized = dateStr.split('T')[0];
      }
      if (normalized.length >= 10) {
        final parts = normalized.substring(0, 10).split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return DateFormat('EEE, MMM dd, yyyy').format(date);
        }
      }
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('EEE, MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static String formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}
