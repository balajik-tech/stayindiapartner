enum BookingStatus {
  confirmed,
  pending,
  checkedIn,
  checkedOut,
  cancelled,
  unknown,
}

class Booking {
  final String id;
  final String tenantName;
  final String tenantPhone;
  final String hostelName;
  final String roomTypeName;
  final String bedNumber;
  final BookingStatus status;
  final String? checkInDate;
  final bool isKycVerified;
  final String? sharingType;
  final String? hostelId;
  final String? tenantAvatar;
  final String? tenantId;
  final String? createdAt;
  final String? roomType;

  Booking({
    required this.id,
    required this.tenantName,
    required this.tenantPhone,
    required this.hostelName,
    required this.roomTypeName,
    required this.bedNumber,
    required this.status,
    this.checkInDate,
    this.isKycVerified = true,
    this.sharingType,
    this.hostelId,
    this.tenantAvatar,
    this.tenantId,
    this.createdAt,
    this.roomType,
  });

  Booking copyWith({
    String? id,
    String? tenantName,
    String? tenantPhone,
    String? hostelName,
    String? roomTypeName,
    String? bedNumber,
    BookingStatus? status,
    String? checkInDate,
    bool? isKycVerified,
    String? sharingType,
    String? hostelId,
    String? tenantAvatar,
    String? tenantId,
    String? createdAt,
    String? roomType,
  }) {
    return Booking(
      id: id ?? this.id,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      hostelName: hostelName ?? this.hostelName,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      bedNumber: bedNumber ?? this.bedNumber,
      status: status ?? this.status,
      checkInDate: checkInDate ?? this.checkInDate,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      sharingType: sharingType ?? this.sharingType,
      hostelId: hostelId ?? this.hostelId,
      tenantAvatar: tenantAvatar ?? this.tenantAvatar,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      roomType: roomType ?? this.roomType,
    );
  }
}

class PendingBooking {
  final String bookingId;
  final String tenantId;
  final String tenantName;
  final String phone;
  final String kycStatus;
  final String? checkInDate;
  final String sharingType;
  final String status;
  final String bookingStatus;
  final String hostelId;
  final String? roomType;

  PendingBooking({
    required this.bookingId,
    required this.tenantId,
    required this.tenantName,
    required this.phone,
    required this.kycStatus,
    this.checkInDate,
    required this.sharingType,
    required this.status,
    required this.bookingStatus,
    required this.hostelId,
    this.roomType,
  });
}

class ScanBookingResponse {
  final String bookingId;
  final String hostelId;
  final String tenantId;
  final String tenantName;
  final String tenantPhone;
  final String kycStatus;
  final String? checkInDate;
  final String sharingType;
  final String status;
  final String bookingStatus;
  final String? roomType;

  final String? roomId;
  final String? roomTypename;
  final String? bedNumber;
  final String? reservedRoomId;
  final String? reservedBed;

  ScanBookingResponse({
    required this.bookingId,
    required this.hostelId,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    required this.kycStatus,
    this.checkInDate,
    required this.sharingType,
    required this.status,
    required this.bookingStatus,
    this.roomType,
    this.roomId,
    this.roomTypename,
    this.bedNumber,
    this.reservedRoomId,
    this.reservedBed,
  });
}
