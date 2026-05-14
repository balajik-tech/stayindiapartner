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

  static List<Map<String, String>> getAllItems() {
    final List<Map<String, String>> items = [];
    for (final category in masterList.keys) {
      for (final item in masterList[category]!) {
        if (item['name'] != null) {
          final Map<String, String> copy = Map.from(item);
          copy['category'] = category;
          items.add(copy);
        }
      }
    }
    return items;
  }

  static String getLocalizedName(Map<String, String> item, [String? langCode]) {
    if (langCode == 'te' && item['nameTelugu'] != null) return item['nameTelugu']!;
    if (langCode == 'hi' && item['nameHindi'] != null) return item['nameHindi']!;
    if (langCode == 'ta' && item['nameTamil'] != null) return item['nameTamil']!;
    if (langCode == 'kn' && item['nameKannada'] != null) return item['nameKannada']!;
    return item['name'] ?? '';
  }

  static String getLocalizedNameForEntity(StockItem item, [String? langCode]) {
    return item.name; // TODO: Implement actual localization based on langCode
  }
}