import 'dart:io';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/profile/data/models/profile_model.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  });
  Future<ProfileModel> uploadAvatar(File image);
  Future<void> deleteAccount();
  Future<String> generateReferralId();
  Future<String> getRateUsUrl();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await dio.get(ApiConstants.userProfile);
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return ProfileModel.fromJson(data);
    }
    throw Exception('Failed to load profile');
  }

  @override
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'dob': dob,
      'gender': gender,
      if (dlKyc != null) 'dlKyc': {
        'is_aadhar_verified': dlKyc.isAadharVerified,
        'gender': dlKyc.gender,
        'masked_aadhaar': dlKyc.maskedAadhaar,
        'dob': dlKyc.dob,
        'date_time': dlKyc.dateTime,
        'aadhar_filename': dlKyc.aadharFilename,
        'aadhar_img_filename': dlKyc.aadharImgFilename,
        'adharimg': dlKyc.adharImg,
        'aadhar_address': dlKyc.aadharAddress,
        'aadhar_no': dlKyc.aadharNo,
        // 'aadhar_xml': dlKyc.aadharXml,
        'fathername': dlKyc.fatherName,
        'name': dlKyc.name,
      },
    }..removeWhere((k, v) => v == null);
    final response = await dio.put(ApiConstants.userProfile, data: body);
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return ProfileModel.fromJson(data);
    }
    throw Exception('Failed to update profile');
  }

  @override
  Future<ProfileModel> uploadAvatar(File image) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(image.path),
    });
    final response = await dio.patch(ApiConstants.userProfile, data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return ProfileModel.fromJson(data);
    }
    throw Exception('Failed to upload image');
  }

  @override
  Future<void> deleteAccount() async {
    final response = await dio.delete(ApiConstants.userDeleteAccount);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }

  @override
  Future<String> generateReferralId() async {
    final response = await dio.post(ApiConstants.generateReferral);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'] as Map<String, dynamic>;
      return data['referralId'] as String;
    }
    throw Exception('Failed to generate referral ID');
  }

  @override
  Future<String> getRateUsUrl() async {
    final response = await dio.get(ApiConstants.rateUs);
    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return data['rateUsUrl'] as String;
    }
    throw Exception('Failed to fetch rate us URL');
  }
}
