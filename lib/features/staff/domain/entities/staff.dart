class Staff {
  final String id;
  final String hostelId;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final Map<String, dynamic>? permissions;
  final bool isActive;
  final String createdAt;
  final String? photo;
  final StaffPaymentDetails? paymentDetails;
  final double salary;

  const Staff({
    required this.id,
    required this.hostelId,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.permissions,
    required this.isActive,
    required this.createdAt,
    this.photo,
    this.paymentDetails,
    this.salary = 0.0,
  });
}

class StaffPaymentDetails {
  final String upiId;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String beneficiaryName;

  const StaffPaymentDetails({
    this.upiId = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.beneficiaryName = '',
  });

  bool get isEmpty =>
      upiId.isEmpty &&
      bankName.isEmpty &&
      accountNumber.isEmpty &&
      ifscCode.isEmpty &&
      beneficiaryName.isEmpty;
}
