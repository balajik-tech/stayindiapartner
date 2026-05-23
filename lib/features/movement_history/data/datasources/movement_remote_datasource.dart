import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/movement_history/domain/entities/movement_history_entity.dart';

class MovementRemoteDataSource {
  final Dio _dio;

  MovementRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  Future<List<MovementHistoryEntity>> getLocationHistory(String tenantId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/users/$tenantId/location-history',
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> historyData = response.data['data'];
        return historyData.map((e) => MovementHistoryEntity.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
