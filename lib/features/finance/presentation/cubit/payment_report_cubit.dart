import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';
import '../../domain/entities/payment_report_entity.dart';
import '../../domain/entities/revenue_summary.dart';
import '../../domain/usecases/get_payment_report_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../domain/usecases/record_cash_payment_usecase.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'payment_report_state.dart';

class PaymentReportCubit extends Cubit<PaymentReportState> {
  final GetPaymentReportUseCase _getPaymentReport;
  final RecordPaymentUseCase _recordPayment;
  final GetTenantsUseCase _getTenants;
  final CreateCashOrderUseCase _createCashOrder;
  final RecordCashPaymentUseCase _recordCashPayment;
  final CreateUpiOrderUseCase _createUpiOrder;
  final RecordUpiPaymentUseCase _recordUpiPayment;

  PaymentReportCubit({
    required GetPaymentReportUseCase getPaymentReport,
    required RecordPaymentUseCase recordPayment,
    required GetTenantsUseCase getTenants,
    required CreateCashOrderUseCase createCashOrder,
    required RecordCashPaymentUseCase recordCashPayment,
    required CreateUpiOrderUseCase createUpiOrder,
    required RecordUpiPaymentUseCase recordUpiPayment,
  })  : _getPaymentReport = getPaymentReport,
        _recordPayment = recordPayment,
        _getTenants = getTenants,
        _createCashOrder = createCashOrder,
        _recordCashPayment = recordCashPayment,
        _createUpiOrder = createUpiOrder,
        _recordUpiPayment = recordUpiPayment,
        super(PaymentReportInitial());

  Future<void> fetchReport({
    String? hostelId,
    String? startDate,
    String? endDate,
  }) async {
    emit(PaymentReportLoading());
    try {
      final reportData = await _getPaymentReport(
        hostelId: hostelId,
        startDate: startDate,
        endDate: endDate,
        page: 1,
        limit: ApiConstants.paginationLimit,
      );
      final tenants = await _getTenants(hostelId: hostelId, limit: 100);

      emit(PaymentReportLoaded(
        items: reportData.payments,
        summary: reportData.summary,
        tenants: tenants,
        page: 1,
        hasMore: reportData.payments.length < reportData.totalCount,
      ));
    } catch (e) {
      emit(PaymentReportError(message: GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> fetchMoreReport({
    String? hostelId,
    String? startDate,
    String? endDate,
  }) async {
    final currentState = state;
    if (currentState is! PaymentReportLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) return;

    final int nextPage = currentState.page + 1;
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final reportData = await _getPaymentReport(
        hostelId: hostelId,
        startDate: startDate,
        endDate: endDate,
        page: nextPage,
        limit: ApiConstants.paginationLimit,
      );

      if (reportData.payments.isEmpty) {
        emit(currentState.copyWith(
          hasMore: false,
          isLoadingMore: false,
        ));
        return;
      }

      final List<PaymentReportItem> updatedItems = [
        ...currentState.items,
        ...reportData.payments
      ];

      emit(currentState.copyWith(
        items: updatedItems,
        page: nextPage,
        hasMore: reportData.payments.length >= ApiConstants.paginationLimit &&
            updatedItems.length < reportData.totalCount,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> submitPayment({
    required String tenantId,
    String? hostelId,
    String? bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String category,
    required String mode,
    required String date,
    String? referenceNo,
    String? note,
    String? screenshotPath,
    bool sendWhatsapp = true,
  }) async {
    try {
      if (mode == 'Cash' && hostelId != null && bookingId != null) {
        // Step 1: Create Cash Order
        final rentalId = await _createCashOrder(
          tenantId: tenantId,
          hostelId: hostelId,
          bookingId: bookingId,
          amount: amount,
          rent: rent,
          deposit: deposit,
          utilities: utilities,
          others: others,
          dueDate: date,
          notes: note,
        );

        // Step 2: Record Cash Payment immediately
        await _recordCashPayment(
          rentalId: rentalId,
          amount: amount,
          reference: referenceNo ?? "CASH-$tenantId",
          notes: note ?? "Cash received from tenant",
        );
      } else if (mode == 'UPI' && hostelId != null && bookingId != null) {
        // Step 1: Create UPI Order
        final rentalId = await _createUpiOrder(
          tenantId: tenantId,
          hostelId: hostelId,
          bookingId: bookingId,
          amount: amount,
          rent: rent,
          deposit: deposit,
          utilities: utilities,
          others: others,
          dueDate: date,
          notes: note,
        );

        // Step 2: Record UPI Payment immediately with UTR number
        await _recordUpiPayment(
          rentalId: rentalId,
          amount: amount,
          reference: referenceNo ?? "UPI-$tenantId",
          notes: note ?? "UPI received from tenant",
        );
      } else {
        await _recordPayment(
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
      fetchReport(hostelId: hostelId);
    } catch (e) {
      rethrow;
    }
  }
}
