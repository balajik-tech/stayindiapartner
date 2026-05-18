import 'package:equatable/equatable.dart';

class StockItem extends Equatable {
  final String id;
  final String propertyId;
  final String name;
  final String? nameTelugu;
  final String category;
  final String unit;
  final double currentQuantity;
  final double minimumThreshold;
  final double pricePerUnit;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockItem({
    required this.id,
    required this.propertyId,
    required this.name,
    this.nameTelugu,
    required this.category,
    required this.unit,
    required this.currentQuantity,
    required this.minimumThreshold,
    required this.pricePerUnit,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    propertyId,
    name,
    category,
    unit,
    currentQuantity,
    minimumThreshold,
    pricePerUnit,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
