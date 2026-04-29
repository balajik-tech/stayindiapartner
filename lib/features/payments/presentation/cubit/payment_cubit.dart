import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/payments/domain/entities/hostel_payment_summary.dart';
import 'package:stayindia_owner/features/payments/domain/usecases/payment_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetPaymentsUseCase _getPayments;
  final CreatePaymentUseCase _createPayment;
  final MarkPaymentPaidUseCase _markPaid;
  final SendPaymentReminderUseCase _sendReminder;
  final SendBulkPaymentReminderUseCase _sendBulkReminder;
  final GetReminderHistoryUseCase _getReminderHistory;
  final GetBillsUseCase _getBills;

  PaymentCubit({
    required GetPaymentsUseCase getPaymentsUseCase,
    required CreatePaymentUseCase createPaymentUseCase,
    required MarkPaymentPaidUseCase markPaymentPaidUseCase,
    required SendPaymentReminderUseCase sendPaymentReminderUseCase,
    required SendBulkPaymentReminderUseCase sendBulkPaymentReminderUseCase,
    required GetReminderHistoryUseCase getReminderHistoryUseCase,
    required GetBillsUseCase getBillsUseCase,
  })  : _getPayments = getPaymentsUseCase,
        _createPayment = createPaymentUseCase,
        _markPaid = markPaymentPaidUseCase,
        _sendReminder = sendPaymentReminderUseCase,
        _sendBulkReminder = sendBulkPaymentReminderUseCase,
        _getReminderHistory = getReminderHistoryUseCase,
        _getBills = getBillsUseCase,
        super(PaymentInitial());

  Future<void> loadPayments(
    String hostelId, {
    String? month,
    String? status,
  }) async {
    emit(PaymentLoading());
    try {
      final summary = await _getPayments(
        hostelId: hostelId,
        month: month,
        status: status,
      );
      emit(PaymentLoaded(summary: summary));
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> createPayment({
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
  }) async {
    emit(PaymentLoading());
    try {
      await _createPayment(
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
      emit(PaymentSuccess(message: 'Payment created successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> markPaid(
    String id,
    double amount, {
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  }) async {
    emit(PaymentPaying());
    try {
      await _markPaid(
        id: id,
        amount: amount,
        paymentType: paymentType,
        transactionId: transactionId,
        paymentDate: paymentDate,
        notes: notes,
      );
      emit(PaymentSuccess(message: 'Payment recorded successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> sendReminder(
    String id, {
    String? channel,
    String? message,
  }) async {
    emit(PaymentReminding());
    try {
      await _sendReminder(
        id: id,
        channel: channel,
        message: message,
      );
      emit(PaymentSuccess(message: 'Reminder sent successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> sendBulkReminder(
    String hostelId, {
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  }) async {
    emit(PaymentReminding());
    try {
      await _sendBulkReminder(
        hostelId: hostelId,
        bucket: bucket,
        paymentIds: paymentIds,
        channel: channel,
        message: message,
      );
      emit(PaymentSuccess(message: 'Bulk reminders sent successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadReminderHistory(String hostelId) async {
    try {
      await _getReminderHistory(hostelId: hostelId);
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadBills(String tenantId, String hostelId) async {
    try {
      await _getBills(tenantId: tenantId, hostelId: hostelId);
    } catch (e) {
      emit(PaymentError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
