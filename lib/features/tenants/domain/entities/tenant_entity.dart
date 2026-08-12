import 'package:equatable/equatable.dart';

class TenantEntity extends Equatable {
  final String id;
  final String bookingId;
  final String hostelId;
  final String roomId;
  final String roomTypename;
  final int floor;
  final String bedNumber;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? email;
  final String? avatar;
  final bool kycVerified;
  final String? checkInDate;
  final String? checkOutDate;
  final String? parentMobile;
  final bool isAway;
  final String? awayMessage;

  const TenantEntity({
    required this.id,
    required this.bookingId,
    required this.hostelId,
    required this.roomId,
    required this.roomTypename,
    required this.floor,
    required this.bedNumber,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.email,
    this.avatar,
    required this.kycVerified,
    this.checkInDate,
    this.checkOutDate,
    this.parentMobile,
    this.isAway = false,
    this.awayMessage,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    bookingId,
    hostelId,
    roomId,
    roomTypename,
    floor,
    bedNumber,
    firstName,
    lastName,
    mobile,
    email,
    avatar,
    kycVerified,
    checkInDate,
    checkOutDate,
    parentMobile,
    isAway,
    awayMessage,
  ];
}

class TenantDetailEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String? avatar;
  final bool kycVerified;
  final String? aadharCardPhoto;
  final String? idPhotoBack;
  final String? aadhaarNumber;
  final TenantStayDetailEntity? stay;
  final List<TenantPaymentItemEntity> payments;
  final double outstandingAmount;
  final String? parentMobile;
  final bool isAway;
  final String? awayMessage;

  const TenantDetailEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.avatar,
    required this.kycVerified,
    this.aadharCardPhoto,
    this.idPhotoBack,
    this.aadhaarNumber,
    this.stay,
    required this.payments,
    required this.outstandingAmount,
    this.parentMobile,
    this.isAway = false,
    this.awayMessage,
  });

  TenantEntity toTenantEntity(String hostelId) {
    return TenantEntity(
      id: id,
      bookingId: stay?.bookingId ?? '',
      hostelId: hostelId,
      roomId: stay?.roomId ?? '',
      roomTypename: stay?.roomTypename ?? '',
      floor: stay?.floor ?? 0,
      bedNumber: stay?.bedNumber ?? '',
      firstName: name.split(' ').first,
      lastName: name.split(' ').length > 1
          ? name.split(' ').sublist(1).join(' ')
          : '',
      mobile: mobile,
      email: email,
      avatar: avatar,
      kycVerified: kycVerified,
      checkInDate: stay?.checkInDate,
      parentMobile: parentMobile,
      isAway: isAway,
      awayMessage: awayMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    mobile,
    email,
    avatar,
    kycVerified,
    aadharCardPhoto,
    idPhotoBack,
    stay,
    payments,
    outstandingAmount,
    parentMobile,
    isAway,
    awayMessage,
  ];
}

class TenantStayDetailEntity extends Equatable {
  final String bookingId;
  final String roomId;
  final String roomTypename;
  final int floor;
  final String bedNumber;
  final double rent;
  final double deposit;
  final String? checkInDate;
  final String? accessCode;
  final String? qrToken;
  final String? status;
  final double? electricityBill;
  final double? parkingBill;
  final String? sharingType;
  final String? acType;

  const TenantStayDetailEntity({
    required this.bookingId,
    required this.roomId,
    required this.roomTypename,
    required this.floor,
    required this.bedNumber,
    required this.rent,
    required this.deposit,
    this.checkInDate,
    this.accessCode,
    this.qrToken,
    this.status,
    this.electricityBill,
    this.parkingBill,
    this.sharingType,
    this.acType,
  });

  @override
  List<Object?> get props => [
    bookingId,
    roomId,
    roomTypename,
    floor,
    bedNumber,
    rent,
    deposit,
    checkInDate,
    accessCode,
    qrToken,
    status,
    electricityBill,
    parkingBill,
    sharingType,
    acType,
  ];
}

class TenantPaymentItemEntity extends Equatable {
  final String id;
  final String month;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String paymentType;
  final String? paymentDate;
  final String? dueDate;

  const TenantPaymentItemEntity({
    required this.id,
    required this.month,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    required this.paymentType,
    this.paymentDate,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
    id,
    month,
    totalAmount,
    paidAmount,
    dueAmount,
    status,
    paymentType,
    paymentDate,
    dueDate,
  ];
}
