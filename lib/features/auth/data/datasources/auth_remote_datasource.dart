import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../models/owner_model.dart';

abstract class AuthRemoteDataSource {
  Future<String?> requestOtp(String phone);

  Future<({OwnerModel owner, bool isNewUser})> verifyOtp(
    String phone,
    String otp, {
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  });

  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String name,
    required String avatar,
    required String role,
  });

  Future<OwnerModel> getCurrentOwner();

  Future<OwnerModel> completeProfile(Map<String, dynamic> data);

  Future<OwnerModel> updateProfile(Map<String, dynamic> data);

  Future<void> logout();

  Future<void> deleteAccount();
  Future<void> updateDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceId,
  });
  Future<OwnerModel> acceptPolicy({String version = '1.0'});
  Future<OwnerModel> staffLogin(String phone, String password);
  Future<OwnerModel> linkPhone(String phone);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required TokenStorage tokenStorage,
  }) : _dio = dio,
       _tokenStorage = tokenStorage;

  String _sanitizePhone(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^91'), '');

  Map<String, dynamic> _extractOwnerJson(dynamic responseData) {
    if (responseData is! Map) {
      throw ServerException(message: 'Unexpected response format from server.');
    }
    final data = responseData.containsKey('data') && responseData['data'] is Map
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;

    if (data.containsKey('user') && data['user'] is Map) {
      return data['user'] as Map<String, dynamic>;
    }
    return data;
  }

  @override
  Future<String?> requestOtp(String phone) async {
    final sanitized = _sanitizePhone(phone);
    AppLogger.info('Requesting OTP for: $sanitized');

    final response = await _dio.post(
      ApiConstants.requestOtp,
      data: {'phone': sanitized, 'role': 'OWNER'},
    );

    if (response.statusCode == 200) {
      AppLogger.success('OTP dispatched for $sanitized');
      final data = response.data;
      if (data is Map && data['data'] is Map && data['data']['otp'] != null) {
        return data['data']['otp'].toString();
      }
      return null;
    }

    final message = (response.data is Map && response.data['message'] != null)
        ? response.data['message'].toString()
        : 'Failed to send OTP. Please try again.';
    throw ServerException(message: message, statusCode: response.statusCode);
  }

  @override
  Future<({OwnerModel owner, bool isNewUser})> verifyOtp(
    String phone,
    String otp, {
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    final sanitized = _sanitizePhone(phone);
    AppLogger.info('Verifying OTP for: $sanitized');

    final Map<String, dynamic> payload = {
      'phone': sanitized,
      'otp': otp,
      'role': 'OWNER',
    };
    if (email != null) payload['email'] = email;
    if (firstName != null) payload['firstName'] = firstName;
    if (lastName != null) payload['lastName'] = lastName;
    if (avatar != null) payload['avatar'] = avatar;

    final response = await _dio.post(ApiConstants.verifyOtp, data: payload);

    if (response.statusCode != 200) {
      final message = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'OTP verification failed.';
      throw AuthException(message: message);
    }

    final raw = response.data is Map && response.data.containsKey('data')
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    final token = raw['token'] as String? ?? raw['accessToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
      await _tokenStorage.savePhone(sanitized);
      AppLogger.success('Token saved securely.');
    }

    final isNewUser = raw['isNewUser'] == true;
    final userJson = raw['user'] is Map
        ? raw['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    OwnerModel owner;
    if (userJson.isNotEmpty) {
      owner = OwnerModel.fromJson(
        userJson['phone'] == null || (userJson['phone'] as String).isEmpty
            ? {...userJson, 'phone': sanitized}
            : userJson,
      );
    } else {
      owner = await getCurrentOwner();
    }

    AppLogger.success('OTP verified. isNewUser=$isNewUser');
    return (owner: owner, isNewUser: isNewUser);
  }

  @override
  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String name,
    required String avatar,
    required String role,
  }) async {
    AppLogger.info('Sending Google login for: $email, role: $role');
    final response = await _dio.post(
      ApiConstants.googleLogin,
      data: {'email': email, 'name': name, 'avatar': avatar, 'role': role},
    );

    if (response.statusCode != 200) {
      final message = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'Google login failed.';
      throw AuthException(message: message);
    }

    final raw = response.data is Map && response.data.containsKey('data')
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    final token = raw['token'] as String? ?? raw['accessToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
      if (raw['user'] != null && raw['user']['phone'] != null) {
        await _tokenStorage.savePhone(raw['user']['phone'].toString());
      }
      AppLogger.success('Google Login: Token saved securely.');
    }

    return raw;
  }

  @override
  Future<OwnerModel> getCurrentOwner() async {
    AppLogger.info('Fetching owner profile (/auth/me)');
    final response = await _dio.get(ApiConstants.getMe);

    if (response.statusCode == 200) {
      final ownerJson = _extractOwnerJson(response.data);
      return OwnerModel.fromJson(ownerJson);
    }
    throw ServerException(
      message: 'Failed to fetch profile. Please try again.',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<OwnerModel> completeProfile(Map<String, dynamic> data) async {
    AppLogger.info('Completing owner profile');

    final payload = Map<String, dynamic>.from(data);
    final avatarPath = payload.remove('avatar') as String?;

    Response response;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final formData = FormData.fromMap(payload);
      final compressedPath = await _compressImage(avatarPath);
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(compressedPath ?? avatarPath),
        ),
      );
      response = await _dio.post(
        ApiConstants.userCompleteProfile,
        data: formData,
        options: Options(headers: {'x-upload-folder': 'profiles'}),
      );
    } else {
      response = await _dio.post(
        ApiConstants.userCompleteProfile,
        data: payload,
      );
    }

    final isSuccess =
        response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 409;

    if (!isSuccess) {
      throw ServerException(
        message: 'Profile completion failed. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return getCurrentOwner();
  }

  @override
  Future<OwnerModel> updateProfile(Map<String, dynamic> data) async {
    AppLogger.info('Updating owner profile');
    final response = await _dio.put(ApiConstants.userProfile, data: data);
    if (response.statusCode == 200) {
      return getCurrentOwner();
    }
    throw ServerException(
      message: 'Profile update failed.',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> logout() async {
    AppLogger.info('Logging out owner');
    await _tokenStorage.deleteToken();
  }

  @override
  Future<void> deleteAccount() async {
    AppLogger.info('Deleting owner account');
    final response = await _dio.delete(ApiConstants.userDeleteAccount);
    if (response.statusCode == 200) {
      await _tokenStorage.deleteToken();
      return;
    }
    throw ServerException(
      message: 'Account deletion failed. Please try again.',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> updateDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceId,
  }) async {
    AppLogger.info('Updating device token: $platform');
    final response = await _dio.post(
      ApiConstants.deviceToken,
      data: {
        'pushToken': pushToken,
        'platform': platform,
        'deviceId': deviceId,
        'appType': 'OWNER_APP',
      },
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to update device token');
    }
  }

  @override
  Future<OwnerModel> acceptPolicy({String version = '1.0'}) async {
    AppLogger.info('Accepting policy: $version');
    final response = await _dio.post(
      ApiConstants.userAcceptPolicy,
      data: {'version': version},
    );
    if (response.statusCode == 200) {
      final ownerJson = _extractOwnerJson(response.data);
      return OwnerModel.fromJson(ownerJson);
    }
    throw ServerException(
      message: 'Failed to accept policy.',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<OwnerModel> staffLogin(String phone, String password) async {
    final sanitized = _sanitizePhone(phone);
    AppLogger.info('Logging in staff: $sanitized');

    final response = await _dio.post(
      ApiConstants.staffLogin,
      data: {'phone': sanitized, 'password': password},
    );

    if (response.statusCode != 200) {
      final message = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'Staff login failed.';
      throw AuthException(message: message);
    }

    final raw = response.data is Map && response.data.containsKey('data')
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    final token = raw['token'] as String? ?? raw['accessToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
      await _tokenStorage.savePhone(sanitized);
      AppLogger.success('Staff token saved securely.');
    }

    final userJson = raw['user'] is Map
        ? raw['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    OwnerModel owner;
    if (userJson.isNotEmpty) {
      owner = OwnerModel.fromJson(
        userJson['phone'] == null || (userJson['phone'] as String).isEmpty
            ? {...userJson, 'phone': sanitized}
            : userJson,
      );
    } else {
      owner = await getCurrentOwner();
    }

    AppLogger.success('Staff login verified.');
    return owner;
  }

  @override
  Future<OwnerModel> linkPhone(String phone) async {
    final sanitized = _sanitizePhone(phone);
    AppLogger.info('Linking phone number: $sanitized');

    final response = await _dio.post(
      '/auth/link-phone',
      data: {'phone': sanitized},
    );

    if (response.statusCode != 200) {
      final message = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'Failed to link phone number.';
      throw AuthException(message: message);
    }

    final raw = response.data is Map && response.data.containsKey('data')
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    final userJson = raw['user'] is Map
        ? raw['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    if (userJson.isNotEmpty) {
      await _tokenStorage.savePhone(sanitized);
      return OwnerModel.fromJson(userJson);
    }

    return getCurrentOwner();
  }

  Future<String?> _compressImage(String imagePath) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final target = p.join(
        tmpDir.path,
        'compressed_${p.basenameWithoutExtension(imagePath)}.jpg',
      );
      final result = await FlutterImageCompress.compressAndGetFile(
        File(imagePath).absolute.path,
        target,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );
      return result?.path;
    } catch (e) {
      AppLogger.error('Image compression failed, using original: $e');
      return null;
    }
  }
}
