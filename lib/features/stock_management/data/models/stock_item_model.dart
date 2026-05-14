import '../../domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.id,
    required super.propertyId,
    required super.name,
    super.nameTelugu,
    required super.category,
    required super.unit,
    required super.currentQuantity,
    required super.minimumThreshold,
    required super.pricePerUnit,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      nameTelugu: json['nameTelugu'],
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      currentQuantity: (json['currentQuantity'] ?? 0).toDouble(),
      minimumThreshold: (json['minimumThreshold'] ?? 0).toDouble(),
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'name': name,
      'nameTelugu': nameTelugu,
      'category': category,
      'unit': unit,
      'currentQuantity': currentQuantity,
      'minimumThreshold': minimumThreshold,
      'pricePerUnit': pricePerUnit,
    };
  }
}
