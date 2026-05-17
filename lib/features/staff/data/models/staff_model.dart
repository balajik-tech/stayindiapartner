import 'package:stayindia_owner/features/staff/domain/entities/staff.dart';

class StaffModel extends Staff {
  const StaffModel({
    required super.id,
    required super.hostelId,
    required super.name,
    required super.phone,
    super.email,
    required super.role,
    super.permissions,
    required super.isActive,
    required super.createdAt,
    super.photo,
    super.paymentDetails,
    super.salary,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: (json['_id'] ?? '').toString(),
      hostelId: (json['hostel'] ?? json['hostelId'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? '',
      permissions: json['permissions'] is Map ? Map<String, dynamic>.from(json['permissions']) : null,
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      photo: json['photo']?.toString(),
      paymentDetails: json['paymentDetails'] != null 
          ? StaffPaymentDetailsModel.fromJson(Map<String, dynamic>.from(json['paymentDetails']))
          : null,
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'permissions': permissions,
      'photo': photo,
      'salary': salary,
      if (paymentDetails != null) 'paymentDetails': (paymentDetails as StaffPaymentDetailsModel).toJson(),
    };
  }
}

class StaffPaymentDetailsModel extends StaffPaymentDetails {
  const StaffPaymentDetailsModel({
    super.upiId,
    super.bankName,
    super.accountNumber,
    super.ifscCode,
    super.beneficiaryName,
  });

  factory StaffPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return StaffPaymentDetailsModel(
      upiId: json['upiId']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      beneficiaryName: json['beneficiaryName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upiId': upiId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'beneficiaryName': beneficiaryName,
    };
  }
}
