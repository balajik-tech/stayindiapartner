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
      hostelId:
          (json['hostel'] is Map ? json['hostel']['_id'] : json['hostel'])
              ?.toString() ??
          '',
      roomId:
          (json['roomId'] ??
                  (json['room'] is Map ? json['room']['_id'] : json['room']))
              ?.toString() ??
          '',
      roomTypename: StringUtils.formatRoomNumber(
        json['roomTypename']?.toString() ?? '',
        json['floor'] is int
            ? json['floor']
            : int.tryParse(json['floor']?.toString() ?? '0') ?? 0,
      ),
      floor: json['floor'] is int
          ? json['floor']
          : int.tryParse(json['floor']?.toString() ?? '0') ?? 0,
      bedNumber: json['bedNumber']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobile: (json['mobile'] ?? json['phone'])?.toString() ?? '',
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      kycVerified:
          json['kycVerified'] == true ||
          (json['kyc'] is Map && json['kyc']['verified'] == true),
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
    super.aadharCardPhoto,
    super.idPhotoBack,
    super.aadhaarNumber,
    super.stay,
    required super.payments,
    required super.outstandingAmount,
    super.parentMobile,
    super.guardianMobiles = const [],
    super.employeeIdProof,
    super.isAway = false,
    super.awayMessage,
    super.dlKyc,
  });

  factory TenantDetailModel.fromJson(Map<String, dynamic> json) {
    final tenantData = (json['tenant'] as Map<String, dynamic>?) ?? {};
    final stayData = json['stay'] as Map<String, dynamic>?;
    final paymentsData = (json['payments'] as Map<String, dynamic>?) ?? {};
    final paymentItems = (paymentsData['items'] as List<dynamic>?) ?? [];

    final name =
        tenantData['name']?.toString() ??
        [
          tenantData['firstName'],
          tenantData['lastName'],
        ].where((e) => e != null && e.toString().isNotEmpty).join(' ');

    final kycData = tenantData['kyc'] as Map<String, dynamic>?;
    final dlKycData = tenantData['dlKyc'] as Map<String, dynamic>?;

    final rawGuardianMobiles = (json['guardianMobiles'] as List<dynamic>?) ??
        (tenantData['guardianMobiles'] as List<dynamic>?) ?? [];

    final guardianMobilesList = rawGuardianMobiles
        .whereType<Map<String, dynamic>>()
        .map((g) => GuardianMobileModel.fromJson(g))
        .toList();

    final employeeIdProofStr = json['employeeIdProof']?.toString() ??
        tenantData['employeeIdProof']?.toString();

    return TenantDetailModel(
      id: (tenantData['_id'] ?? tenantData['id'] ?? '').toString(),
      name: name,
      mobile: (tenantData['mobile'] ?? tenantData['phone'] ?? '').toString(),
      email: tenantData['email']?.toString(),
      avatar: tenantData['avatar']?.toString(),
      kycVerified: kycData?['verified'] == true,
      aadharCardPhoto:
          kycData?['aadharCardPhoto']?.toString() ??
          kycData?['idPhotoFront']?.toString(),
      idPhotoBack:
        kycData?['idPhotoBack']?.toString() ?? '',
      aadhaarNumber:
        kycData?['aadhaarNumber']?.toString() ?? '',
      stay: stayData != null ? TenantStayDetailModel.fromJson(stayData) : null,
      payments: paymentItems
          .map(
            (p) => TenantPaymentItemModel.fromJson(p as Map<String, dynamic>),
          )
          .toList(),
      outstandingAmount: _toDouble(paymentsData['outstandingAmount']),
      parentMobile: tenantData['parentMobile']?.toString() ?? json['parentMobile']?.toString(),
      guardianMobiles: guardianMobilesList,
      employeeIdProof: employeeIdProofStr,
      isAway: tenantData['isAway'] == true,
      awayMessage: tenantData['awayMessage']?.toString(),
      dlKyc: dlKycData != null ? DlKycModel.fromJson(dlKycData) : null,
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
    super.startDate,
    super.endDate,
    super.accessCode,
    super.qrToken,
    super.status,
    super.electricityBill,
    super.parkingBill,
    super.sharingType,
    super.acType,
  });

  factory TenantStayDetailModel.fromJson(Map<String, dynamic> json) {
    final room = (json['room'] as Map<String, dynamic>?) ?? {};
    final floorRaw = room['floor'];
    return TenantStayDetailModel(
      bookingId:
          (json['bookingId'] is Map
                  ? json['bookingId']['_id']
                  : json['bookingId'])
              ?.toString() ??
          '',
      roomId: (room['_id'] ?? room['id'] ?? '').toString(),
      roomTypename: StringUtils.formatRoomNumber(
        room['roomTypename']?.toString() ?? '',
        floorRaw is int
            ? floorRaw
            : int.tryParse(floorRaw?.toString() ?? '0') ?? 0,
      ),
      floor: floorRaw is int
          ? floorRaw
          : int.tryParse(floorRaw?.toString() ?? '0') ?? 0,
      bedNumber:
          (json['bedNumber'] ??
                  room['bedNumber'] ??
                  json['bed']?.toString() ??
                  '')
              .toString(),
      rent: _toDouble(json['rent'] ?? room['rent']),
      deposit: _toDouble(json['deposit']),
      checkInDate: (json['checkInDate'] ?? json['startDate'])?.toString(),
      startDate: (json['startDate'] ?? json['checkInDate'])?.toString(),
      endDate: json['endDate']?.toString(),
      accessCode: json['accessCode']?.toString(),
      qrToken: json['qrToken']?.toString(),
      status: json['status']?.toString(),
      electricityBill: _toDouble(json['electricityBill']),
      parkingBill: _toDouble(json['parkingBill']),
      sharingType: (room['sharingType'] ?? json['sharingType'])?.toString(),
      acType: (room['roomType'] ?? json['roomType'])?.toString(),
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
    super.rent,
    super.deposit,
    super.maintenance,
  });

  factory TenantPaymentItemModel.fromJson(Map<String, dynamic> item) {
    final id = (item['_id'] ?? item['id'] ?? '').toString();

    final paymentObj = item['payment'] is Map<String, dynamic>
        ? item['payment'] as Map<String, dynamic>
        : null;

    final bookingObj = item['booking'] is Map<String, dynamic>
        ? item['booking'] as Map<String, dynamic>
        : null;

    final statusStr = (item['paymentStatus'] ??
            paymentObj?['status'] ??
            item['status'] ??
            '')
        .toString()
        .toUpperCase();
    final isPaid = statusStr == 'SUCCESS' || statusStr == 'PAID';

    final payableAmt = (item['payableAmount'] is num)
        ? (item['payableAmount'] as num).toDouble()
        : (double.tryParse((item['payableAmount'] ?? '').toString()) ??
            _toDouble(item['totalAmount']));

    final paidFromPayment = (paymentObj != null && paymentObj['amount'] is num)
        ? (paymentObj['amount'] as num).toDouble()
        : 0.0;

    final paidAmt = (item['paidAmount'] is num)
        ? (item['paidAmount'] as num).toDouble()
        : (paidFromPayment > 0
            ? paidFromPayment
            : (isPaid
                ? payableAmt
                : (double.tryParse((item['paidAmount'] ?? '').toString()) ??
                    0.0)));

    final totalAmt = payableAmt > 0 ? payableAmt : paidAmt;
    final dueAmt = isPaid
        ? 0.0
        : ((item['dueAmount'] is num)
            ? (item['dueAmount'] as num).toDouble()
            : (totalAmt - paidAmt));

    final dateStr = (item['paymentDate'] ??
            paymentObj?['paidAt'] ??
            item['createdAt'] ??
            item['startDate'] ??
            item['month'] ??
            '')
        .toString();

    final paymentType = paymentObj?['method']?.toString() ??
        item['paymentType']?.toString() ??
        item['method']?.toString() ??
        'RENT';

    final rentVal = (item['bookingAmount'] is num)
        ? (item['bookingAmount'] as num).toDouble()
        : ((item['rent'] is num)
            ? (item['rent'] as num).toDouble()
            : ((bookingObj != null && bookingObj['rent'] is num)
                ? (bookingObj['rent'] as num).toDouble()
                : double.tryParse((item['bookingAmount'] ?? item['rent'] ?? '').toString())));

    final depositVal = (item['deposit'] is num)
        ? (item['deposit'] as num).toDouble()
        : ((bookingObj != null && bookingObj['deposit'] is num)
            ? (bookingObj['deposit'] as num).toDouble()
            : double.tryParse((item['deposit'] ?? '').toString()));

    final maintenanceVal = (item['maintenance'] is num)
        ? (item['maintenance'] as num).toDouble()
        : ((bookingObj != null && bookingObj['maintenance'] is num)
            ? (bookingObj['maintenance'] as num).toDouble()
            : double.tryParse((item['maintenance'] ?? '').toString()));

    return TenantPaymentItemModel(
      id: id,
      month: dateStr,
      totalAmount: totalAmt,
      paidAmount: paidAmt,
      dueAmount: dueAmt > 0 ? dueAmt : 0.0,
      status: statusStr,
      paymentType: paymentType,
      paymentDate: dateStr.isNotEmpty ? dateStr : null,
      dueDate: item['dueDate']?.toString() ?? bookingObj?['endDate']?.toString(),
      rent: rentVal,
      deposit: depositVal,
      maintenance: maintenanceVal,
    );
  }
}

class GuardianMobileModel extends GuardianMobileEntity {
  const GuardianMobileModel({
    required super.name,
    required super.mobileNumber,
    required super.relation,
  });

  factory GuardianMobileModel.fromJson(Map<String, dynamic> json) {
    return GuardianMobileModel(
      name: json['name']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      relation: json['relation']?.toString() ?? '',
    );
  }
}

class DlKycModel extends DlKycEntity {
  const DlKycModel({
    required super.isAadharVerified,
    super.gender,
    super.maskedAadhaar,
    super.dob,
    super.dateTime,
    super.aadharFilename,
    super.aadharImgFilename,
    super.adharimg,
    super.aadharAddress,
    super.aadharNo,
    super.fatherName,
    super.name,
  });

  factory DlKycModel.fromJson(Map<String, dynamic> json) {
    return DlKycModel(
      isAadharVerified: json['is_aadhar_verified'] == true,
      gender: json['gender']?.toString(),
      maskedAadhaar: json['masked_aadhaar']?.toString(),
      dob: json['dob']?.toString(),
      dateTime: json['date_time']?.toString(),
      aadharFilename: json['aadhar_filename']?.toString(),
      aadharImgFilename: json['aadhar_img_filename']?.toString(),
      adharimg: json['adharimg']?.toString(),
      aadharAddress: json['aadhar_address']?.toString(),
      aadharNo: json['aadhar_no']?.toString(),
      fatherName: json['fathername']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
