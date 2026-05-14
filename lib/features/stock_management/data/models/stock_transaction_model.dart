import '../../domain/entities/stock_transaction.dart';

class StockTransactionModel extends StockTransaction {
  const StockTransactionModel({
    required super.id,
    required super.stockItemId,
    required super.type,
    required super.quantity,
    required super.pricePerUnit,
    required super.totalCost,
    required super.paymentMode,
    required super.entryDate,
    super.note,
    required super.createdBy,
    required super.createdAt,
  });

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['_id'] ?? '',
      stockItemId: json['stockItemId'] ?? '',
      type: json['type'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? 'Cash',
      entryDate: json['entryDate'] != null ? DateTime.parse(json['entryDate']) : DateTime.now(),
      note: json['note'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
