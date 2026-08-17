import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AssociationMembershipRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMyApplications(String portalId);
  Future<List<Map<String, dynamic>>> getEligibleProperties();
  Future<Map<String, dynamic>> submitApplication({
    required String portalId,
    required List<String> propertyIds,
  });
}

class AssociationMembershipRemoteDataSourceImpl
    implements AssociationMembershipRemoteDataSource {
  final Dio dio;

  AssociationMembershipRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getMyApplications(String portalId) async {
    final response = await dio.get(
      ApiConstants.associationMyApplications,
      queryParameters: {'portalId': portalId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final resData = response.data;
      List<dynamic> list = [];
      if (resData is Map) {
        if (resData['data'] is Map && resData['data']['memberships'] is List) {
          list = resData['data']['memberships'] as List;
        } else if (resData['memberships'] is List) {
          list = resData['memberships'] as List;
        } else if (resData['data'] is List) {
          list = resData['data'] as List;
        }
      }
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to fetch membership applications');
  }

  @override
  Future<List<Map<String, dynamic>>> getEligibleProperties() async {
    final response = await dio.get(ApiConstants.associationEligibleProperties);
    if (response.statusCode == 200 && response.data != null) {
      final resData = response.data;
      List<dynamic> rawList = [];
      if (resData is Map) {
        if (resData['data'] is Map && resData['data']['properties'] is List) {
          rawList = resData['data']['properties'] as List;
        } else if (resData['properties'] is List) {
          rawList = resData['properties'] as List;
        } else if (resData['data'] is List) {
          rawList = resData['data'] as List;
        }
      }
      return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to fetch eligible properties');
  }

  @override
  Future<Map<String, dynamic>> submitApplication({
    required String portalId,
    required List<String> propertyIds,
  }) async {
    final response = await dio.post(
      ApiConstants.associationMembershipApplications,
      data: {
        'portalId': portalId,
        'propertyIds': propertyIds,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = response.data;
      Map<String, dynamic>? membership;
      if (resData is Map &&
          resData['data'] is Map &&
          resData['data']['membership'] is Map) {
        membership = Map<String, dynamic>.from(resData['data']['membership'] as Map);
      } else if (resData is Map && resData['data'] is Map) {
        membership = Map<String, dynamic>.from(resData['data'] as Map);
      } else if (resData is Map && resData['membership'] is Map) {
        membership = Map<String, dynamic>.from(resData['membership'] as Map);
      }
      if (membership != null) return membership;
    }
    throw Exception(response.data?['message'] ?? 'Failed to submit application');
  }
}
