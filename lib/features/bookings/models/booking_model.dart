import 'package:stayindia_owner/features/bookings/domain/booking.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class BookingModel extends Booking {
  BookingModel({
    required super.id,
    required super.tenantName,
    required super.tenantPhone,
    required super.hostelName,
    required super.roomTypeName,
    required super.bedNumber,
    required super.status,
    super.checkInDate,
    super.isKycVerified,
    super.sharingType,
    super.hostelId,
    super.tenantAvatar,
    super.tenantId,
    super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      return {};
    }

    final tenant = safeMap(json['tenant']);
    final hostel = safeMap(json['hostel']);
    final room = safeMap(json['room']);

    final firstName = tenant['firstName'] as String? ?? '';
    final lastName = tenant['lastName'] as String? ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final statusStr =
        (json['status']?.toString() ?? json['paymentStatus']?.toString() ?? '')
            .toUpperCase();
    BookingStatus status;
    if (['CONFIRMED', 'IDLE'].contains(statusStr)) {
      status = BookingStatus.confirmed;
    } else if (['PENDING_PAYMENT', 'PENDING'].contains(statusStr)) {
      status = BookingStatus.pending;
    } else if (statusStr == 'CHECKED_IN') {
      status = BookingStatus.checkedIn;
    } else if (statusStr == 'CHECKED_OUT') {
      status = BookingStatus.checkedOut;
    } else if (['CANCELLED', 'REJECTED'].contains(statusStr)) {
      status = BookingStatus.cancelled;
    } else {
      status = BookingStatus.unknown;
    }

    return BookingModel(
      id: json['_id']?.toString() ?? '',
      tenantName: fullName.isNotEmpty ? fullName : 'Unknown',
      tenantPhone: tenant['mobile']?.toString() ?? '',
      hostelName: hostel['name']?.toString() ?? '',
      roomTypeName: StringUtils.formatRoomNumber(
        room['roomTypename']?.toString() ?? '',
      ),
      bedNumber: json['bedNumber']?.toString() ?? '',
      status: status,
      checkInDate:
          json['checkInDate']?.toString() ??
          json['startDate']?.toString() ??
          '',
      isKycVerified: safeMap(tenant['kyc'])['verified'] as bool? ?? false,
      sharingType: json['sharingType']?.toString(),
      hostelId: hostel['_id']?.toString() ?? json['hostel']?.toString(),
      tenantAvatar:
          tenant['avatar']?.toString() ??
          tenant['userProfile']?['avatar']?.toString(),
      tenantId: tenant['_id']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenant': {'firstName': tenantName, 'mobile': tenantPhone},
      'hostel': {'name': hostelName},
      'room': {'roomTypename': roomTypeName},
      'bedNumber': bedNumber,
      'status': status.name.toUpperCase(),
      'checkInDate': checkInDate,
      'isKycVerified': isKycVerified,
    };
  }
}

class PendingBookingModel extends PendingBooking {
  PendingBookingModel({
    required super.bookingId,
    required super.tenantId,
    required super.tenantName,
    required super.phone,
    required super.kycStatus,
    super.checkInDate,
    required super.sharingType,
    required super.status,
    required super.bookingStatus,
    required super.hostelId,
  });

  factory PendingBookingModel.fromJson(Map<String, dynamic> json) {
    return PendingBookingModel(
      bookingId: json['bookingId'] ?? json['_id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      tenantName: json['tenantName'] ?? '',
      phone: json['phone'] ?? '',
      kycStatus: json['kycStatus'] ?? 'KYC_PENDING',
      checkInDate: json['checkInDate'],
      sharingType: json['sharingType'] ?? '',
      status: json['status'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      hostelId: json['hostelId'] ?? '',
    );
  }
}

class ScanBookingResponseModel extends ScanBookingResponse {
  ScanBookingResponseModel({
    required super.bookingId,
    required super.hostelId,
    required super.tenantId,
    required super.tenantName,
    required super.tenantPhone,
    required super.kycStatus,
    super.checkInDate,
    required super.sharingType,
    required super.status,
    required super.bookingStatus,
    super.roomId,
    super.roomTypename,
    super.bedNumber,
  });

  factory ScanBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>? ?? {};
    return ScanBookingResponseModel(
      bookingId: json['bookingId'] ?? json['_id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      tenantId: tenant['id'] ?? json['tenantId'] ?? '',
      tenantName: tenant['name'] ?? json['tenantName'] ?? '',
      tenantPhone: tenant['phone'] ?? json['tenantPhone'] ?? '',
      kycStatus: tenant['kycStatus'] ?? json['kycStatus'] ?? 'KYC_PENDING',
      checkInDate: json['checkInDate'],
      sharingType: json['sharingType'] ?? '',
      status: json['status'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      roomId: json['roomId'],
      roomTypename: StringUtils.formatRoomNumber(
        json['roomTypename']?.toString() ?? '',
      ),
      bedNumber: json['bedNumber'],
    );
  }
}
