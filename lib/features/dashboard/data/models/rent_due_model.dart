import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';

class RentDueDetailsModel extends RentDueDetails {
  const RentDueDetailsModel({required super.overdue, required super.upcoming});

  factory RentDueDetailsModel.fromJson(Map<String, dynamic> json) {
    return RentDueDetailsModel(
      overdue:
          (json['overdue'] as List?)
              ?.map((e) => RentPaymentModel.fromJson(e))
              .toList() ??
          [],
      upcoming:
          (json['upcoming'] as List?)
              ?.map((e) => RentPaymentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RentPaymentModel extends RentPayment {
  const RentPaymentModel({
    required super.id,
    required super.tenantName,
    required super.tenantMobile,
    super.tenantAvatar,
    required super.amount,
    required super.dueDate,
    required super.month,
  });

  factory RentPaymentModel.fromJson(Map<String, dynamic> json) {
    final tenantObj = json['tenant'];
    final Map<String, dynamic> tenant = (tenantObj is Map<String, dynamic>)
        ? tenantObj
        : (tenantObj is Map)
        ? Map<String, dynamic>.from(tenantObj)
        : {};
    return RentPaymentModel(
      id: json['_id'] ?? '',
      tenantName: '${tenant['firstName'] ?? ''} ${tenant['lastName'] ?? ''}'
          .trim(),
      tenantMobile: tenant['mobile'] ?? '',
      tenantAvatar: tenant['avatar'] ?? '',
      amount: (json['dueAmount'] ?? json['totalAmount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      month: json['month'] ?? '',
    );
  }
}
