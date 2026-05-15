class StringUtils {
  static String formatRoomNumber(String rNum, [dynamic floor]) {
    String formatted = rNum.replaceAll(RegExp(r'^Room\s*', caseSensitive: false), '').trim();
    
    bool isGroundFloor = false;
    if (floor != null) {
      if (floor is num && floor == 0) {
        isGroundFloor = true;
      } else if (floor is String) {
        final f = floor.toUpperCase();
        if (f == 'GROUND FLOOR' || f == '0' || f == 'G') {
          isGroundFloor = true;
        }
      }
    }
    
    if (isGroundFloor) {
      if (formatted.startsWith('0')) {
        formatted = 'G${formatted.substring(1)}';
      } else if (!formatted.startsWith('G')) {
        formatted = 'G$formatted';
      }
    }
    
    return formatted;
  }

  static String formatSharingType(String type) {
    switch (type.toUpperCase()) {
      case 'SINGLE':
        return '1-SHARING';
      case 'DOUBLE':
        return '2-SHARING';
      case 'TRIPLE':
        return '3-SHARING';
      case 'QUADRUPLE':
        return '4-SHARING';
      case 'QUINTUPLE':
        return '5-SHARING';
      case 'DORMITORY':
        return 'DORM';
      default:
        return type;
    }
  }

  static String mapCapacityToSharing(int capacity) {
    switch (capacity) {
      case 1:
        return 'SINGLE';
      case 2:
        return 'DOUBLE';
      case 3:
        return 'TRIPLE';
      case 4:
        return 'QUADRUPLE';
      case 5:
        return 'QUINTUPLE';
      default:
        return 'DORMITORY';
    }
  }
}
