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
    return PanVerificationResult(
      pan: json['pan'] ?? '',
      panType: json['pan_type'] ?? '',
      fullname: json['fullname'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      aadhaarNumber: json['aadhaar_number'] ?? '',
      aadhaarLinked: json['aadhaar_linked'] ?? false,
      dob: json['dob'] ?? '',
      address: PanAddress.fromJson(json['address'] ?? {}),
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      panStatus: json['pan_status'] ?? '',
      panAllotmentDate: json['pan_allotment_date'] ?? '',
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
      buildingName: json['building_name'] ?? '',
      locality: json['locality'] ?? '',
      streetName: json['street_name'] ?? '',
      pincode: json['pincode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
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
