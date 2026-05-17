class FoodItem {
  final Map<String, String> name;
  final Map<String, String> desc;
  final double price;
  final bool isVeg;
  final bool isActive;

  FoodItem({
    required this.name,
    this.desc = const {},
    this.price = 0.0,
    this.isVeg = true,
    this.isActive = true,
  });

  String getName(String locale) => name[locale] ?? name['en'] ?? '';
  String getDesc(String locale) => desc[locale] ?? desc['en'] ?? '';
}

class FoodMenu {
  final String hostelId;
  final String day; 
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
  final List<FoodItem> snacks;

  FoodMenu({
    required this.hostelId,
    required this.day,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
  });
}
