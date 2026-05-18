import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/dashboard/data/models/occupancy_model.dart';
import 'package:stayindia_owner/features/dashboard/data/models/daily_operations_model.dart';
import 'package:stayindia_owner/features/dashboard/data/models/rent_due_model.dart';

import 'package:stayindia_owner/features/dashboard/data/models/occupancy_status_model.dart';

abstract class DashboardRemoteDataSource {
  Future<OccupancyModel> getOccupancy(String hostelId);
  Future<DailyOperationsModel> getDailyOperations(String hostelId);
  Future<RentDueDetailsModel> getRentDueDetails(String hostelId);
  Future<OccupancyStatusModel> getOccupancyStatus(String hostelId);
  Future<List<dynamic>> getBulkDashboardData(String hostelIds);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<OccupancyModel> getOccupancy(String hostelId) async {
    AppLogger.info('Fetching occupancy for hostel: $hostelId');
    final response = await _dio.get('${ApiConstants.roomsOccupancy}/$hostelId');

    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return OccupancyModel.fromJson(data);
    }

    throw Exception('Failed to load occupancy data: ${response.statusCode}');
  }

  @override
  Future<DailyOperationsModel> getDailyOperations(String hostelId) async {
    AppLogger.info('Fetching daily operations for hostel: $hostelId');
    final response = await _dio.get(
      '${ApiConstants.dashboardDailyOps}/$hostelId',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return DailyOperationsModel.fromJson(data);
    }

    throw Exception('Failed to load daily operations: ${response.statusCode}');
  }

  @override
  Future<RentDueDetailsModel> getRentDueDetails(String hostelId) async {
    AppLogger.info('Fetching rent due details for hostel: $hostelId');
    final response = await _dio.get(
      '${ApiConstants.dashboardRentDue}/$hostelId',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return RentDueDetailsModel.fromJson(data);
    }

    throw Exception('Failed to load rent due details: ${response.statusCode}');
  }

  @override
  Future<OccupancyStatusModel> getOccupancyStatus(String hostelId) async {
    AppLogger.info(
      'Fetching occupancy status (Geo-Fence) for hostel: $hostelId',
    );

    final response = await _dio.get(
      '${ApiConstants.propertyOccupancyStatus}/$hostelId/occupancy-status',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return OccupancyStatusModel.fromJson(data);
    }

    throw Exception('Failed to load occupancy status: ${response.statusCode}');
  }

  @override
  Future<List<dynamic>> getBulkDashboardData(String hostelIds) async {
    try {
      AppLogger.info('Fetching bulk dashboard data for hostels: $hostelIds');
      final response = await _dio.get(
        ApiConstants.dashboardBulkData,
        queryParameters: {'hostelIds': hostelIds},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
        return [];
      }

      throw Exception('failed_to_load_dashboard_data'.tr());
    } on DioException catch (e) {
      AppLogger.error('Dio error in getBulkDashboardData: ${e.message}');
      String errorMessage = 'network_error_occurred'.tr();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'connection_timed_out'.tr();
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'endpoint_not_found'.tr();
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'server_side_error'.tr();
      }
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.error('Unexpected error in getBulkDashboardData: $e');
      throw Exception('unexpected_error_occurred'.tr());
    }
  }
}
