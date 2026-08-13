import '../repositories/payment_repository.dart';

class CreateCashOrderUseCase {
  final PaymentRepository repository;

  CreateCashOrderUseCase({required this.repository});

  Future<String> call({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    required String dueDate,
    String? notes,
  }) {
    return repository.createCashOrder(
      tenantId: tenantId,
      hostelId: hostelId,
      bookingId: bookingId,
      amount: amount,
      dueDate: dueDate,
      notes: notes,
    );
  }
}

class RecordCashPaymentUseCase {
  final PaymentRepository repository;

  RecordCashPaymentUseCase({required this.repository});

  Future<void> call({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  }) {
    return repository.recordCashPayment(
      rentalId: rentalId,
      amount: amount,
      reference: reference,
      notes: notes,
    );
  }
}
