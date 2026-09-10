import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';
import '../models/hostel_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<HostelSettingsModel> getSettings(String hostelId);
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data);
  Future<void> updateAmenities(String hostelId, List<String> enabledAmenities);
  Future<void> updateHouseRules(String hostelId, Map<String, dynamic> data);
  Future<void> updateNotifications(String hostelId, Map<String, dynamic> data);
  Future<void> updateRoomConfiguration(
    String hostelId,
    Map<String, dynamic> data,
  );
  Future<void> uploadHostelImages(String hostelId, List<String> filePaths);
  Future<String> uploadSingleImage(String filePath);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<HostelSettingsModel> getSettings(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.settings}/$hostelId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return HostelSettingsModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to load settings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/profile',
        data: data,
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateAmenities(
    String hostelId,
    List<String> enabledAmenities,
  ) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/amenities',
        data: {'amenities': enabledAmenities},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update amenities',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateHouseRules(
    String hostelId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/house-rules',
        data: data,
      );
      if (response.statusCode != 200) {
        final message =
            (response.data is Map && response.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to update house rules';
        throw ServerException(message: message, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateNotifications(
    String hostelId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/notifications',
        data: data,
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update notification settings',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateRoomConfiguration(
    String hostelId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/room-configuration',
        data: data,
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update room configuration',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> uploadHostelImages(
    String hostelId,
    List<String> filePaths,
  ) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(path)),
        );
      }
      formData.fields.add(const MapEntry('folder', 'hostels'));

      final response = await dio.post(
        '${ApiConstants.hostels}/$hostelId/images',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to upload images',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadSingleImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        ApiConstants.offerUploadImage,
        data: formData,
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['imageUrl'] as String;
      }
      throw ServerException(
        message: 'Failed to upload image',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw GlobalErrorMapper.map(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
