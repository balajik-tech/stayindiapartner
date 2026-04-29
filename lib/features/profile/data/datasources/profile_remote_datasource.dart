import 'dart:io';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
  });
  Future<ProfileModel> uploadAvatar(File image);
  Future<void> deleteAccount();
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
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'dob': dob,
      'gender': gender,
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
    final response = await dio.post(ApiConstants.userProfileImage, data: formData);
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
}
