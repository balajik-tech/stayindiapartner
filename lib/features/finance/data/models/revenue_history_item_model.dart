import 'package:stayindia_owner/features/finance/domain/entities/revenue_history_item.dart';

class RevenueHistoryItemModel extends RevenueHistoryItem {
  const RevenueHistoryItemModel({
    required super.id,
    required super.tenantName,
    required super.hostelName,
    required super.rent,
    required super.maintenance,
    required super.deposit,
    required super.total,
    required super.totalPaid,
    required super.paymentDate,
    required super.month,
    super.paymentType,
  });

  factory RevenueHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueHistoryItemModel(
      id: json['id'] ?? '',
      tenantName: json['tenantName'] ?? '',
      hostelName: json['hostelName'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      maintenance: (json['maintenance'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      month: json['month'] ?? '',
      paymentType: json['paymentType'],
    );
  }
}
