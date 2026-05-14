import '../domain/entities/stock_item.dart';

class StockConstants {
  static const Map<String, List<Map<String, String>>> masterList = {
    'Grocery': [
      {'name': 'Rice', 'unit': 'KG'},
      {'name': 'Dal', 'unit': 'KG'},
      {'name': 'Oil', 'unit': 'LTR'},
      {'name': 'Sugar', 'unit': 'KG'},
      {'name': 'Salt', 'unit': 'KG'},
    ],
    'Cleaning': [
      {'name': 'Phenyl', 'unit': 'LTR'},
      {'name': 'Soap', 'unit': 'PCS'},
      {'name': 'Detergent', 'unit': 'KG'},
    ],
    'Other': [
      {'name': 'Bulb', 'unit': 'PCS'},
      {'name': 'Battery', 'unit': 'PCS'},
    ],
  };

  static List<String> getAllItems() {
    final List<String> items = [];
    for (final category in masterList.values) {
      for (final item in category) {
        if (item['name'] != null) {
          items.add(item['name']!);
        }
      }
    }
    return items;
  }

  static String getLocalizedName(String name) {
    return name; // TODO: Implement localization
  }

  static String getLocalizedNameForEntity(StockItem item) {
    return item.name; // TODO: Implement localization
  }
}