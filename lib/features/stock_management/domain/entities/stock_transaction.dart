import 'package:equatable/equatable.dart';

class StockTransaction extends Equatable {
  final String id;
  final String stockItemId;
  final String type;
  final double quantity;
  final double pricePerUnit;
  final double totalCost;
  final String paymentMode;
  final DateTime entryDate;
  final String? note;
  final String createdBy;
  final DateTime createdAt;

  const StockTransaction({
    required this.id,
    required this.stockItemId,
    required this.type,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalCost,
    required this.paymentMode,
    required this.entryDate,
    this.note,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    stockItemId,
    type,
    quantity,
    totalCost,
    note,
    createdBy,
    createdAt,
  ];
}
