import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/payment_report_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentReportModel>> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
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
    required String dueDate,
    String? notes,
  });

  Future<void> recordCashPayment({
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
  Future<List<PaymentReportModel>> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await dio.get(
        ApiConstants.financeRevenueHistory,
        queryParameters: queryParams,
      );
      final List results = response.data['data'] ?? [];
      return results.map((e) => PaymentReportModel.fromJson(e)).toList();
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
        if (referenceNo != null) 'referenceNo': referenceNo,
        if (note != null) 'note': note,
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
    required String dueDate,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.tenantRentalOrderCash,
        data: {
          "tenant": tenantId,
          "hostel": hostelId,
          "booking": bookingId,
          "amount": amount,
          "dueDate": dueDate,
          "receiptNumber": "",
          "notes": notes ?? "",
        },
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
}
