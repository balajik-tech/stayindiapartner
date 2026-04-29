import 'package:stayindia_owner/features/payments/domain/entities/payment.dart';
import 'package:stayindia_owner/features/payments/domain/entities/hostel_payment_summary.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository repository;
  GetPaymentsUseCase(this.repository);

  Future<HostelPaymentSummary> call({String? hostelId, String? month, String? status}) {
    return repository.getPayments(hostelId: hostelId, month: month, status: status);
  }
}

class CreatePaymentUseCase {
  final PaymentRepository repository;
  CreatePaymentUseCase(this.repository);

  Future<Payment> call({
    required String tenantId,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required String month,
    required double rent,
    required String dueDate,
    double? maintenance,
    double? paidAmount,
    String? paymentType,
    String? transactionId,
    String? notes,
  }) {
    return repository.createPayment(
      tenantId: tenantId,
      hostelId: hostelId,
      roomId: roomId,
      bedNumber: bedNumber,
      month: month,
      rent: rent,
      dueDate: dueDate,
      maintenance: maintenance,
      paidAmount: paidAmount,
      paymentType: paymentType,
      transactionId: transactionId,
      notes: notes,
    );
  }
}

class MarkPaymentPaidUseCase {
  final PaymentRepository repository;
  MarkPaymentPaidUseCase(this.repository);

  Future<void> call({
    required String id,
    required double amount,
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  }) {
    return repository.markPaid(
      id: id,
      amount: amount,
      paymentType: paymentType,
      transactionId: transactionId,
      paymentDate: paymentDate,
      notes: notes,
    );
  }
}

class SendPaymentReminderUseCase {
  final PaymentRepository repository;
  SendPaymentReminderUseCase(this.repository);

  Future<void> call({required String id, String? channel, String? message}) {
    return repository.sendReminder(id: id, channel: channel, message: message);
  }
}

class SendBulkPaymentReminderUseCase {
  final PaymentRepository repository;
  SendBulkPaymentReminderUseCase(this.repository);

  Future<void> call({
    required String hostelId,
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  }) {
    return repository.sendBulkReminder(
      hostelId: hostelId,
      bucket: bucket,
      paymentIds: paymentIds,
      channel: channel,
      message: message,
    );
  }
}

class GetReminderHistoryUseCase {
  final PaymentRepository repository;
  GetReminderHistoryUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({String? hostelId}) {
    return repository.getReminderHistory(hostelId: hostelId);
  }
}

class GetBillsUseCase {
  final PaymentRepository repository;
  GetBillsUseCase(this.repository);

  Future<Map<String, dynamic>> call({required String tenantId, required String hostelId}) {
    return repository.getBills(tenantId: tenantId, hostelId: hostelId);
  }
}
