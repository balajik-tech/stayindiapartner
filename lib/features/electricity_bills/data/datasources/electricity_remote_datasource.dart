import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/logger.dart';

abstract class ElectricityRemoteDataSource {
  Future<Map<String, dynamic>> createElectricityBill(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateElectricityBill(String billId, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateTenantBillStatus({
    required String billId,
    required String tenantId,
    required Map<String, dynamic> payload,
  });
  Future<Map<String, dynamic>> fetchElectricityBills({
    required String hostelId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 50,
  });
}

class ElectricityRemoteDataSourceImpl implements ElectricityRemoteDataSource {
  final Dio _dio;

  ElectricityRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, dynamic>> createElectricityBill(Map<String, dynamic> payload) async {
    try {
      AppLogger.info('Posting electricity bill payload to ${ApiConstants.electricityBills}: $payload');
      final response = await _dio.post(
        ApiConstants.electricityBills,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      throw Exception('Failed to create electricity bill');
    } on DioException catch (e) {
      AppLogger.error('Dio error in createElectricityBill: ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to create electricity bill';
      throw Exception(msg);
    } catch (e) {
      AppLogger.error('Error in createElectricityBill: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateElectricityBill(
    String billId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final url = '${ApiConstants.electricityBills}/$billId';
      AppLogger.info('Updating electricity bill via PUT to $url: $payload');
      final response = await _dio.put(
        url,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      throw Exception('Failed to update electricity bill');
    } on DioException catch (e) {
      AppLogger.error('Dio error in updateElectricityBill: ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to update electricity bill';
      throw Exception(msg);
    } catch (e) {
      AppLogger.error('Error in updateElectricityBill: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateTenantBillStatus({
    required String billId,
    required String tenantId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final url = '${ApiConstants.electricityBills}/$billId/tenants/$tenantId/status';
      AppLogger.info('Updating tenant electricity bill status via PATCH to $url: $payload');
      final response = await _dio.patch(
        url,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      throw Exception('Failed to update tenant bill status');
    } on DioException catch (e) {
      AppLogger.error('Dio error in updateTenantBillStatus: ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to update tenant bill status';
      throw Exception(msg);
    } catch (e) {
      AppLogger.error('Error in updateTenantBillStatus: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchElectricityBills({
    required String hostelId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'hostelId': hostelId,
        'page': page,
        'limit': limit,
      };
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['dateFrom'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['dateTo'] = dateTo;
      }

      AppLogger.info('Fetching electricity bills: $queryParams');
      final response = await _dio.get(
        ApiConstants.electricityBills,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      throw Exception('Failed to fetch electricity bills');
    } on DioException catch (e) {
      AppLogger.error('Dio error in fetchElectricityBills: ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to fetch electricity bills';
      throw Exception(msg);
    } catch (e) {
      AppLogger.error('Error in fetchElectricityBills: $e');
      rethrow;
    }
  }
}
