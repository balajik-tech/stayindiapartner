import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../../models/booking_model.dart';

abstract class BookingsRemoteDataSource {
  Future<List<BookingModel>> getOwnerBookings({int page = 1, int limit = 10, String? kycStatus, String? roomType, String? hostelId});
  Future<List<PendingBookingModel>> getPendingBookings({int page = 1, int limit = 10});
  Future<List<PendingBookingModel>> getConfirmedBookings({int page = 1, int limit = 10});
  Future<ScanBookingResponseModel> scanBooking(String token, {String? hostelId});
  Future<ScanBookingResponseModel> manualCheckin(String accessCode, {String? hostelId});
  Future<ScanBookingResponseModel> getCheckinData({String? bookingId, String? accessCode, String? hostelId});
  Future<void> assignRoom(String bookingId, String roomId, String bedNumber);
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  });
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  });
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature);
  Future<BookingModel> getBookingById(String id);
  Future<void> checkoutBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final Dio dio;

  BookingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookingModel>> getOwnerBookings({int page = 1, int limit = 10, String? kycStatus, String? roomType, String? hostelId}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (kycStatus != null) queryParams['kycStatus'] = kycStatus;
      if (roomType != null) queryParams['sharingType'] = roomType;
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      final response = await dio.get(
        ApiConstants.ownerBookings,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List<dynamic> data = rawData is Map ? (rawData['results'] ?? []) : rawData;
        AppLogger.debug('[BOOKINGS] Fetched owner bookings: ${data.length}');
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch bookings');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error fetching owner bookings: $e');
      rethrow;
    }
  }

  @override
  Future<List<PendingBookingModel>> getConfirmedBookings({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        ApiConstants.bookingsConfirmed,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final raw = response.data['data'];
        final List<dynamic> list = raw is Map ? (raw['results'] ?? []) : (raw is List ? raw : []);
        AppLogger.debug('[BOOKINGS] Fetched confirmed bookings: ${list.length}');
        return list.map((j) => PendingBookingModel.fromJson(j)).toList();
      }
      throw Exception('Failed to fetch confirmed bookings');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error fetching confirmed bookings: $e');
      rethrow;
    }
  }

  @override
  Future<List<PendingBookingModel>> getPendingBookings({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        ApiConstants.pendingBookings,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final raw = response.data['data'];
        final List<dynamic> list = raw is Map ? (raw['results'] ?? []) : (raw is List ? raw : []);
        AppLogger.debug('[BOOKINGS] Fetched pending bookings: ${list.length}');
        return list.map((json) => PendingBookingModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch pending bookings');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error fetching pending bookings: $e');
      rethrow;
    }
  }

  @override
  Future<ScanBookingResponseModel> scanBooking(String token, {String? hostelId}) async {
    try {
      final response = await dio.post(
        ApiConstants.scanBooking,
        data: {'token': token, 'hostelId': hostelId},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      }
      throw Exception('Failed to scan booking');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error scanning booking: $e');
      rethrow;
    }
  }

  @override
  Future<ScanBookingResponseModel> manualCheckin(String accessCode, {String? hostelId}) async {
    try {
      final response = await dio.post(
        ApiConstants.manualCheckin,
        data: {'accessCode': accessCode, 'hostelId': hostelId},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      }
      throw Exception('Failed to check in');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error during manual check-in: $e');
      rethrow;
    }
  }

  @override
  Future<void> assignRoom(String bookingId, String roomId, String bedNumber) async {
    try {
      await dio.post(
        ApiConstants.assignRoom,
        data: {
          'bookingId': bookingId,
          'roomId': roomId,
          'bedNumber': bedNumber,
        },
      );
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error assigning room: $e');
      rethrow;
    }
  }

  @override
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) async {
    try {
      final body = <String, dynamic>{
        'bookingId': bookingId,
        'roomId': roomId,
        'bedNumber': bedNumber,
        if (accessCode?.isNotEmpty == true) 'accessCode': accessCode,
        'documents': documents,
      };
      await dio.post(ApiConstants.bookingsCheckin, data: body);
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error finalizing check-in: $e');
      rethrow;
    }
  }

  @override
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature) async {
    try {
      await dio.post(
        '${ApiConstants.confirmBooking}/$bookingId',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error confirming booking: $e');
      rethrow;
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.bookings}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to fetch booking');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error fetching booking by id: $e');
      rethrow;
    }
  }

  @override
  Future<void> checkoutBooking(String bookingId) async {
    try {
      await dio.post('${ApiConstants.checkoutBooking}/$bookingId');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error during check-out: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await dio.post('${ApiConstants.cancelBooking}/$bookingId');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error cancelling booking: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  }) async {
    try {
      final body = <String, dynamic>{
        'bookingId': bookingId,
        'hostelId': hostelId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'idempotencyKey': idempotencyKey,
        if (referenceId?.isNotEmpty == true) 'referenceId': referenceId,
      };
      final response = await dio.post(ApiConstants.transactions, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      throw Exception('Failed to process payment');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error creating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<ScanBookingResponseModel> getCheckinData({
    String? bookingId,
    String? accessCode,
    String? hostelId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (bookingId?.isNotEmpty == true) 'bookingId': bookingId,
        if (accessCode?.isNotEmpty == true) 'accessCode': accessCode,
        if (hostelId?.isNotEmpty == true) 'hostelId': hostelId,
      };
      final response = await dio.get(
        ApiConstants.bookingsCheckinData,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      }
      throw Exception('Failed to fetch check-in data');
    } catch (e) {
      AppLogger.error('[BOOKINGS] Error fetching check-in data: $e');
      rethrow;
    }
  }
}
