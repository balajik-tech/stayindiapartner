import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.email,
    required super.address,
    super.dob,
    super.gender,
    super.avatar,
    super.associationId,
    super.isVerifiedOwner = false,
    super.dlKyc,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse dlKyc if present
    DlKycEntity? dlKyc;
    if (json['dlKyc'] != null && json['dlKyc'] is Map) {
      final dlKycJson = json['dlKyc'] as Map<String, dynamic>;
      dlKyc = DlKycEntity(
        isAadharVerified: dlKycJson['is_aadhar_verified'] ?? false,
        gender: dlKycJson['gender']?.toString(),
        maskedAadhaar: dlKycJson['masked_aadhaar']?.toString(),
        dob: dlKycJson['dob']?.toString(),
        dateTime: dlKycJson['date_time']?.toString(),
        aadharFilename: dlKycJson['aadhar_filename']?.toString(),
        aadharImgFilename: dlKycJson['aadhar_img_filename']?.toString(),
        adharImg: dlKycJson['adharimg']?.toString(),
        aadharAddress: dlKycJson['aadhar_address']?.toString(),
        aadharNo: dlKycJson['aadhar_no']?.toString(),
        fatherName: dlKycJson['fathername']?.toString(),
        name: dlKycJson['name']?.toString(),
      );
    }

    return ProfileModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      avatar: json['avatar']?.toString(),
      associationId: json['associationId']?.toString(),
      isVerifiedOwner: json['isVerifiedOwner'] ?? false,
      dlKyc: dlKyc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'dob': dob,
      'gender': gender,
      'avatar': avatar,
    };
  }
}
