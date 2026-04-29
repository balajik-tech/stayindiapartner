import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/dashboard/data/models/occupancy_model.dart';
import 'package:stayindia_owner/features/dashboard/data/models/daily_operations_model.dart';
import 'package:stayindia_owner/features/dashboard/data/models/rent_due_model.dart';

abstract class DashboardRemoteDataSource {
  Future<OccupancyModel> getOccupancy(String hostelId);
  Future<DailyOperationsModel> getDailyOperations(String hostelId);
  Future<RentDueDetailsModel> getRentDueDetails(String hostelId);
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
    final response = await _dio.get('${ApiConstants.dashboardDailyOps}/$hostelId');
    
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return DailyOperationsModel.fromJson(data);
    }
    
    
    throw Exception('Failed to load daily operations: ${response.statusCode}');
  }

  @override
  Future<RentDueDetailsModel> getRentDueDetails(String hostelId) async {
    AppLogger.info('Fetching rent due details for hostel: $hostelId');
    final response = await _dio.get('${ApiConstants.dashboardRentDue}/$hostelId');
    
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return RentDueDetailsModel.fromJson(data);
    }
    
    throw Exception('Failed to load rent due details: ${response.statusCode}');
  }
}
