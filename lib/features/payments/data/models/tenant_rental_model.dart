import 'package:stayindia_owner/features/payments/domain/entities/tenant_rental_entity.dart';

double _toDouble(dynamic val) {
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic val) {
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

class TenantRentalModel extends TenantRentalEntity {
  const TenantRentalModel({
    required super.id,
    required super.bookingAmount,
    required super.deposit,
    required super.maintenance,
    required super.electricityBill,
    required super.parkingBill,
    required super.discountAmount,
    required super.payableAmount,
    required super.currency,
    super.receiptNumber,
    required super.paymentStatus,
    required super.transferStatus,
    super.paymentDate,
    super.notes,
    super.createdAt,
    super.updatedAt,
    super.electricityBillShare,
    super.electricityBillStatus,
    super.booking,
    super.payment,
  });

  factory TenantRentalModel.fromJson(Map<String, dynamic> json) {
    final elecShare = _toDouble(json['electricityBillShare']);
    final elecStatus = json['electricityBillStatus']?.toString() ?? '';
    double elecBill = _toDouble(json['electricityBill']);
    if (elecBill == 0 && elecShare > 0 && elecStatus.toUpperCase() != 'PAID') {
      elecBill = elecShare;
    }

    return TenantRentalModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      bookingAmount: _toDouble(json['bookingAmount']),
      deposit: _toDouble(json['deposit']),
      maintenance: _toDouble(json['maintenance']),
      electricityBill: elecBill,
      parkingBill: _toDouble(json['parkingBill']),
      discountAmount: _toDouble(json['discountAmount']),
      payableAmount: _toDouble(json['payableAmount']),
      currency: json['currency']?.toString() ?? 'INR',
      receiptNumber: json['receiptNumber']?.toString(),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      transferStatus: json['transferStatus']?.toString() ?? '',
      paymentDate: json['paymentDate']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      electricityBillShare: elecShare,
      electricityBillStatus: elecStatus,
      booking: json['booking'] is Map<String, dynamic>
          ? TenantRentalBookingModel.fromJson(
              json['booking'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] is Map<String, dynamic>
          ? TenantRentalPaymentDetailModel.fromJson(
              json['payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TenantRentalBookingModel extends TenantRentalBookingEntity {
  const TenantRentalBookingModel({
    required super.id,
    super.sharingType,
    super.bookingType,
    super.bedNumber,
    super.startDate,
    super.endDate,
    super.checkInDate,
    required super.rent,
    required super.deposit,
    required super.maintenance,
    super.status,
    super.paymentStatus,
    super.room,
  });

  factory TenantRentalBookingModel.fromJson(Map<String, dynamic> json) {
    return TenantRentalBookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sharingType: json['sharingType']?.toString(),
      bookingType: json['bookingType']?.toString(),
      bedNumber: json['bedNumber']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      checkInDate: json['checkInDate']?.toString(),
      rent: _toDouble(json['rent']),
      deposit: _toDouble(json['deposit']),
      maintenance: _toDouble(json['maintenance']),
      status: json['status']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      room: json['room'] is Map<String, dynamic>
          ? TenantRentalRoomModel.fromJson(
              json['room'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TenantRentalRoomModel extends TenantRentalRoomEntity {
  const TenantRentalRoomModel({
    required super.id,
    super.roomTypename,
    required super.floor,
    super.roomType,
    super.sharingType,
  });

  factory TenantRentalRoomModel.fromJson(Map<String, dynamic> json) {
    return TenantRentalRoomModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      roomTypename: json['roomTypename']?.toString(),
      floor: _toInt(json['floor']),
      roomType: json['roomType']?.toString(),
      sharingType: json['sharingType']?.toString(),
    );
  }
}

class TenantRentalPaymentDetailModel extends TenantRentalPaymentDetailEntity {
  const TenantRentalPaymentDetailModel({
    super.method,
    super.status,
    required super.amount,
    super.paidAt,
    super.reference,
    super.notes,
  });

  factory TenantRentalPaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return TenantRentalPaymentDetailModel(
      method: json['method']?.toString(),
      status: json['status']?.toString(),
      amount: _toDouble(json['amount']),
      paidAt: json['paidAt']?.toString(),
      reference: json['reference']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
