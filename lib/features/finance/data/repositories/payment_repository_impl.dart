import '../../domain/entities/payment_report_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentReportItem>> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
  }) {
    return remoteDataSource.getPaymentReport(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
    );
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
  }) {
    return remoteDataSource.recordPayment(
      tenantId: tenantId,
      amount: amount,
      category: category,
      mode: mode,
      date: date,
      referenceNo: referenceNo,
      note: note,
      screenshotPath: screenshotPath,
      sendWhatsapp: sendWhatsapp,
    );
  }

  @override
  Future<String> createCashOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    required String dueDate,
    String? notes,
  }) {
    return remoteDataSource.createCashOrder(
      tenantId: tenantId,
      hostelId: hostelId,
      bookingId: bookingId,
      amount: amount,
      dueDate: dueDate,
      notes: notes,
    );
  }

  @override
  Future<void> recordCashPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  }) {
    return remoteDataSource.recordCashPayment(
      rentalId: rentalId,
      amount: amount,
      reference: reference,
      notes: notes,
    );
  }
}
