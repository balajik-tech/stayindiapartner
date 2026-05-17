import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';


class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.bookingId,
    required super.hostelId,
    required super.roomId,
    required super.roomTypename,
    required super.floor,
    required super.bedNumber,
    required super.firstName,
    required super.lastName,
    required super.mobile,
    super.email,
    super.avatar,
    required super.kycVerified,
    super.checkInDate,
    super.checkOutDate,
    super.parentMobile,
    super.isAway = false,
    super.awayMessage,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      hostelId: (json['hostel'] is Map ? json['hostel']['_id'] : json['hostel'])?.toString() ?? '',
      roomId: (json['roomId'] ?? (json['room'] is Map ? json['room']['_id'] : json['room']))?.toString() ?? '',
      roomTypename: StringUtils.formatRoomNumber(
        json['roomTypename']?.toString() ?? '', 
        json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? '0') ?? 0,
      ),
      floor: json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? '0') ?? 0,
      bedNumber: json['bedNumber']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobile: (json['mobile'] ?? json['phone'])?.toString() ?? '',
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      kycVerified: json['kycVerified'] == true || (json['kyc'] is Map && json['kyc']['verified'] == true),
      checkInDate: (json['checkInDate'] ?? json['createdAt'])?.toString(),
      checkOutDate: json['checkOutDate']?.toString(),
      parentMobile: json['parentMobile']?.toString(),
      isAway: json['isAway'] == true,
      awayMessage: json['awayMessage']?.toString(),
    );
  }
}

class TenantDetailModel extends TenantDetailEntity {
  const TenantDetailModel({
    required super.id,
    required super.name,
    required super.mobile,
    super.email,
    super.avatar,
    required super.kycVerified,
    super.stay,
    required super.payments,
    required super.outstandingAmount,
    super.parentMobile,
    super.isAway = false,
    super.awayMessage,
  });

  factory TenantDetailModel.fromJson(Map<String, dynamic> json) {
    final tenantData = (json['tenant'] as Map<String, dynamic>?) ?? {};
    final stayData = json['stay'] as Map<String, dynamic>?;
    final paymentsData = (json['payments'] as Map<String, dynamic>?) ?? {};
    final paymentItems = (paymentsData['items'] as List<dynamic>?) ?? [];

    final name = tenantData['name']?.toString() ??
        [tenantData['firstName'], tenantData['lastName']]
            .where((e) => e != null && e.toString().isNotEmpty)
            .join(' ');

    return TenantDetailModel(
      id: (tenantData['_id'] ?? tenantData['id'] ?? '').toString(),
      name: name,
      mobile: (tenantData['mobile'] ?? tenantData['phone'] ?? '').toString(),
      email: tenantData['email']?.toString(),
      avatar: tenantData['avatar']?.toString(),
      kycVerified: tenantData['kyc']?['verified'] == true,
      stay: stayData != null ? TenantStayDetailModel.fromJson(stayData) : null,
      payments: paymentItems
          .map((p) => TenantPaymentItemModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      outstandingAmount: _toDouble(paymentsData['outstandingAmount']),
      parentMobile: tenantData['parentMobile']?.toString(),
      isAway: tenantData['isAway'] == true,
      awayMessage: tenantData['awayMessage']?.toString(),
    );
  }
}

class TenantStayDetailModel extends TenantStayDetailEntity {
  const TenantStayDetailModel({
    required super.bookingId,
    required super.roomId,
    required super.roomTypename,
    required super.floor,
    required super.bedNumber,
    required super.rent,
    required super.deposit,
    super.checkInDate,
    super.accessCode,
    super.qrToken,
    super.status,
  });

  factory TenantStayDetailModel.fromJson(Map<String, dynamic> json) {
    final room = (json['room'] as Map<String, dynamic>?) ?? {};
    final floorRaw = room['floor'];
    return TenantStayDetailModel(
      bookingId: (json['bookingId'] is Map
              ? json['bookingId']['_id']
              : json['bookingId'])
          ?.toString() ?? '',
      roomId: (room['_id'] ?? room['id'] ?? '').toString(),
      roomTypename: StringUtils.formatRoomNumber(
        room['roomTypename']?.toString() ?? '', 
        floorRaw is int ? floorRaw : int.tryParse(floorRaw?.toString() ?? '0') ?? 0,
      ),
      floor: floorRaw is int
          ? floorRaw
          : int.tryParse(floorRaw?.toString() ?? '0') ?? 0,
      bedNumber: (json['bedNumber'] ?? room['bedNumber'] ?? json['bed']?.toString() ?? '').toString(),
      rent: _toDouble(json['rent'] ?? room['rent']),
      deposit: _toDouble(json['deposit']),
      checkInDate: (json['checkInDate'] ?? json['startDate'])?.toString(),
      accessCode: json['accessCode']?.toString(),
      qrToken: json['qrToken']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class TenantPaymentItemModel extends TenantPaymentItemEntity {
  const TenantPaymentItemModel({
    required super.id,
    required super.month,
    required super.totalAmount,
    required super.paidAmount,
    required super.dueAmount,
    required super.status,
    required super.paymentType,
    super.paymentDate,
    super.dueDate,
  });

  factory TenantPaymentItemModel.fromJson(Map<String, dynamic> json) {
    return TenantPaymentItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      month: json['month']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']),
      paidAmount: _toDouble(json['paidAmount']),
      dueAmount: _toDouble(json['dueAmount']),
      status: json['status']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      paymentDate: json['paymentDate']?.toString(),
      dueDate: json['dueDate']?.toString(),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
