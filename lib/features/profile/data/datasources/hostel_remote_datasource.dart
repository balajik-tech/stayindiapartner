import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import '../models/hostel_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:stayindia_owner/core/utils/logger.dart';

abstract class HostelRemoteDataSource {
  Future<List<HostelModel>> getHostels({int page = 1, int limit = 10});
  Future<HostelModel> createHostel(HostelModel hostel);
  Future<HostelModel> updateHostel(HostelModel hostel);
  Future<void> deleteHostel(String id);
  Future<HostelModel> uploadHostelImages(String id, List<String> filePaths);
  Future<HostelModel> uploadHostelLicenses(
    String id, {
    String? foodLicense,
    String? hostelLicense,
    String? tradeLicense,
    String? fireSafety,
    String? policeNoc,
    String? shopsEstablishment,
    String? gstRegistration,
    String? healthSanitation,
    String? utilityBill,
    String? pollutionNoc,
    String? residentVerification,
  });
  Future<void> updateHostelLocation(String id, double lat, double lng);
}

class HostelRemoteDataSourceImpl implements HostelRemoteDataSource {
  final Dio dio;

  HostelRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HostelModel>> getHostels({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        ApiConstants.hostels,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'];
        final dynamic data = rawData is Map
            ? (rawData['results'] ?? [])
            : rawData;
        if (data is List) {
          return data.map((json) => HostelModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch hostels');
      }
    } catch (e) {
      throw Exception('Error fetching hostels: $e');
    }
  }

  @override
  Future<HostelModel> createHostel(HostelModel hostel) async {
    try {
      final Map<String, dynamic> data = hostel.toJson();
      data.remove('amenities');
      data.remove('houseRules');
      data.remove('foodMenu');

      final response = await dio.post(
        ApiConstants.hostels,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      } else {
        throw Exception('Failed to create hostel');
      }
    } catch (e) {
      throw Exception('Error creating hostel: $e');
    }
  }

  @override
  Future<HostelModel> updateHostel(HostelModel hostel) async {
    try {
      final response = await dio.put(
        '${ApiConstants.hostels}/${hostel.id}',
        data: hostel.toJson(),
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      } else {
        throw Exception('Failed to update hostel');
      }
    } catch (e) {
      throw Exception('Error updating hostel: $e');
    }
  }

  @override
  Future<void> deleteHostel(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.hostels}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete hostel');
      }
    } catch (e) {
      throw Exception('Error deleting hostel: $e');
    }
  }

  @override
  Future<HostelModel> uploadHostelImages(
    String id,
    List<String> filePaths,
  ) async {
    try {
      final formData = FormData();
      final tempDir = await getTemporaryDirectory();

      for (final path in filePaths) {
        String uploadPath = path;

        try {
          final File file = File(path);
          final String targetPath = p.join(
            tempDir.path,
            "temp_hostel_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(path)}.jpg",
          );

          AppLogger.info('Compressing hostel image: $path -> $targetPath');

          final XFile? compressedFile =
              await FlutterImageCompress.compressAndGetFile(
                file.absolute.path,
                targetPath,
                quality: 50,
                minWidth: 1024,
                minHeight: 1024,
              );

          if (compressedFile != null) {
            uploadPath = compressedFile.path;
          }
        } catch (e) {
          AppLogger.error(
            'Hostel image compression failed, using original: $e',
          );
        }

        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              uploadPath,
              contentType: DioMediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      debugPrint('========== FORM DATA FIELDS ==========');

      final Map<String, dynamic> formDataJson = {
        for (final field in formData.fields) field.key: field.value,
      };

      for (final file in formData.files) {
        formDataJson.putIfAbsent(file.key, () => []);

        if (formDataJson[file.key] is List) {
          formDataJson[file.key].add({
            'filename': file.value.filename,
            'contentType': file.value.contentType.toString(),
            'length': file.value.length,
          });
        }
      }

      debugPrint(
        const JsonEncoder.withIndent('  ').convert(formDataJson),
      );

      debugPrint('======================================');


      final response = await dio.post(
        '${ApiConstants.hostels}/$id/images',
        data: formData,
        options: Options(headers: {'x-upload-folder': 'hostels'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      }
      throw Exception('Failed to upload hostel images');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<HostelModel> uploadHostelLicenses(
    String id, {
    String? foodLicense,
    String? hostelLicense,
    String? tradeLicense,
    String? fireSafety,
    String? policeNoc,
    String? shopsEstablishment,
    String? gstRegistration,
    String? healthSanitation,
    String? utilityBill,
    String? pollutionNoc,
    String? residentVerification,
  }) async {
    try {
      final formData = FormData();

      Future<void> addFiles(String? fieldVal, String fieldName) async {
        if (fieldVal != null && fieldVal.isNotEmpty) {
          final paths = fieldVal.split(',').where((p) => p.isNotEmpty).toList();
          for (final path in paths) {
            if (!path.startsWith('http')) {
              formData.files.add(
                MapEntry(fieldName, await MultipartFile.fromFile(path)),
              );
            }
          }
        }
      }

      await addFiles(foodLicense, 'foodLicense');
      await addFiles(hostelLicense, 'hostelLicense');
      await addFiles(tradeLicense, 'tradeLicense');
      await addFiles(fireSafety, 'fireSafety');
      await addFiles(policeNoc, 'policeNoc');
      await addFiles(shopsEstablishment, 'shopsEstablishment');
      await addFiles(gstRegistration, 'gstRegistration');
      await addFiles(healthSanitation, 'healthSanitation');
      await addFiles(utilityBill, 'utilityBill');
      await addFiles(pollutionNoc, 'pollutionNoc');
      await addFiles(residentVerification, 'residentVerification');

      if (formData.files.isEmpty) {
        return HostelModel(
          id: id,
          name: '',
          address: '',
          floors: 1,
          hostelType: 'men',
          lat: 0,
          lng: 0,
          area: '',
          city: '',
          state: '',
        );
      }

      final response = await dio.post(
        '${ApiConstants.hostels}/$id/licenses',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      }
      throw Exception('Failed to upload hostel licenses');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateHostelLocation(String id, double lat, double lng) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.propertyOccupancyStatus}/$id/location',
        data: {'lat': lat, 'lng': lng},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update property location');
      }
    } catch (e) {
      throw Exception('Error updating property location: $e');
    }
  }
}
