import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/payment_report_entity.dart';
import '../models/payment_report_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentReportData> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = ApiConstants.paginationLimit,
  });

  Future<void> recordPayment({
    required String tenantId,
    required double amount,
    required String category,
    required String mode,
    required String date,
    String? referenceNo,
    String? note,
    String? screenshotPath,
    bool sendWhatsapp = true,
  });

  Future<String> createCashOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  });

  Future<String> createUpiOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  });

  Future<void> recordCashPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  });

  Future<void> recordUpiPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentReportData> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = ApiConstants.paginationLimit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await dio.get(
        ApiConstants.tenantRentalPayments,
        queryParameters: queryParams,
      );
      final List results = response.data['data']['payments'] ?? [];
      final payments = results.map((e) => PaymentReportModel.fromTenantRentalJson(e)).toList();
      
      // Try to find the total count from various common field names
      final totalCount = response.data['data']['total'] ?? 
                         response.data['data']['totalCount'] ?? 
                         response.data['data']['count'] ?? 
                         0;
      
      final tenantCount = payments.map((e) => e.tenantName).toSet().length;
      final summary = PaymentReportModel.summaryFromJson(
        response.data['data']['summary'] ?? {},
        tenantCount,
      );

      return PaymentReportData(payments: payments, summary: summary, totalCount: totalCount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> recordPayment({
    required String tenantId,
    required double amount,
    required String category,
    required String mode,
    required String date,
    String? referenceNo,
    String? note,
    String? screenshotPath,
    bool sendWhatsapp = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'tenantId': tenantId,
        'amount': amount,
        'category': category,
        'mode': mode,
        'date': date,
        'referenceNo': ?referenceNo,
        'note': ?note,
        'sendWhatsapp': sendWhatsapp,
        if (screenshotPath != null)
          'screenshot': await MultipartFile.fromFile(screenshotPath),
      });

      await dio.post(ApiConstants.payments, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createCashOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "tenant": tenantId,
        "hostel": hostelId,
        "booking": bookingId,
        "amount": amount,
        "rent": rent,
        "deposit": deposit,
        "utilities": utilities,
        "others": others,
        "dueDate": dueDate,
        "receiptNumber": "",
        "notes": notes ?? "",
      };
      if (startDate != null && startDate.isNotEmpty) {
        data["startDate"] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        data["endDate"] = endDate;
      }
      if (forthePeriod != null && forthePeriod.isNotEmpty) {
        data["forthePeriod"] = forthePeriod;
      }

      final response = await dio.post(
        ApiConstants.tenantRentalOrderCash,
        data: data,
      );
      return response.data['data']['rentalId'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createUpiOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "tenant": tenantId,
        "hostel": hostelId,
        "booking": bookingId,
        "amount": amount,
        "rent": rent,
        "deposit": deposit,
        "utilities": utilities,
        "others": others,
        "dueDate": dueDate,
        "receiptNumber": "",
        "notes": notes ?? "",
      };
      if (startDate != null && startDate.isNotEmpty) {
        data["startDate"] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        data["endDate"] = endDate;
      }
      if (forthePeriod != null && forthePeriod.isNotEmpty) {
        data["forthePeriod"] = forthePeriod;
      }

      final response = await dio.post(
        ApiConstants.tenantRentalOrderUpi,
        data: data,
      );
      return response.data['data']['rentalId'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> recordCashPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  }) async {
    try {
      await dio.post(
        ApiConstants.tenantRentalPaymentCash(rentalId),
        data: {
          "amount": amount,
          "reference": reference,
          "notes": notes ?? "",
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> recordUpiPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  }) async {
    try {
      await dio.post(
        ApiConstants.tenantRentalPaymentUpi(rentalId),
        data: {
          "amount": amount,
          "reference": reference,
          "notes": notes ?? "",
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
