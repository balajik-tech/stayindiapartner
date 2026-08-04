import 'package:equatable/equatable.dart';

class PanVerificationResult extends Equatable {
  final String pan;
  final String panType;
  final String fullname;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String aadhaarNumber;
  final bool aadhaarLinked;
  final String dob;
  final PanAddress address;
  final String mobile;
  final String email;
  final String panStatus;
  final String panAllotmentDate;

  const PanVerificationResult({
    required this.pan,
    required this.panType,
    required this.fullname,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.aadhaarNumber,
    required this.aadhaarLinked,
    required this.dob,
    required this.address,
    required this.mobile,
    required this.email,
    required this.panStatus,
    required this.panAllotmentDate,
  });

  factory PanVerificationResult.fromJson(Map<String, dynamic> json) {
    final fullNameValue = (json['full_name'] ?? json['fullname'] ?? '').toString().trim();
    final splitValue = json['full_name_split'];
    final fullNameSplit = splitValue is List ? splitValue.map((e) => e.toString()).toList() : <String>[];

    final firstNameValue = (json['first_name'] ?? (fullNameSplit.isNotEmpty ? fullNameSplit[0] : '')).toString().trim();
    final middleNameValue = (json['middle_name'] ?? (fullNameSplit.length > 1 ? fullNameSplit[1] : '')).toString().trim();
    final lastNameValue = (json['last_name'] ?? (fullNameSplit.length > 2 ? fullNameSplit[2] : '')).toString().trim();
    final fullName = fullNameValue.isNotEmpty
        ? fullNameValue
        : [firstNameValue, middleNameValue, lastNameValue].where((value) => value.isNotEmpty).join(' ');

    return PanVerificationResult(
      pan: (json['pan_number'] ?? json['pan'] ?? '').toString().trim(),
      panType: (json['category'] ?? json['pan_type'] ?? '').toString().trim(),
      fullname: fullName,
      firstName: firstNameValue,
      middleName: middleNameValue,
      lastName: lastNameValue,
      gender: (json['gender'] ?? '').toString().trim(),
      aadhaarNumber: (json['masked_aadhaar'] ?? json['aadhaar_number'] ?? '').toString().trim(),
      aadhaarLinked: json['aadhaar_linked'] ?? false,
      dob: (json['dob'] ?? '').toString().trim(),
      address: PanAddress.fromJson(Map<String, dynamic>.from(json['address'] ?? {})),
      mobile: (json['phone_number'] ?? json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      panStatus: (json['status'] ?? json['pan_status'] ?? '').toString().trim(),
      panAllotmentDate: (json['pan_allotment_date'] ?? '').toString().trim(),
    );
  }

  @override
  List<Object?> get props => [
        pan,
        panType,
        fullname,
        firstName,
        middleName,
        lastName,
        gender,
        aadhaarNumber,
        aadhaarLinked,
        dob,
        address,
        mobile,
        email,
        panStatus,
        panAllotmentDate,
      ];
}

class PanAddress extends Equatable {
  final String buildingName;
  final String locality;
  final String streetName;
  final String pincode;
  final String city;
  final String state;
  final String country;

  const PanAddress({
    required this.buildingName,
    required this.locality,
    required this.streetName,
    required this.pincode,
    required this.city,
    required this.state,
    required this.country,
  });

  factory PanAddress.fromJson(Map<String, dynamic> json) {
    return PanAddress(
      buildingName: (json['line_1'] ?? json['building_name'] ?? '').toString().trim(),
      locality: (json['line_2'] ?? json['locality'] ?? '').toString().trim(),
      streetName: (json['street_name'] ?? '').toString().trim(),
      pincode: (json['zip'] ?? json['pincode'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      country: (json['country'] ?? 'India').toString().trim(),
    );
  }

  @override
  List<Object?> get props => [
        buildingName,
        locality,
        streetName,
        pincode,
        city,
        state,
        country,
      ];
}
