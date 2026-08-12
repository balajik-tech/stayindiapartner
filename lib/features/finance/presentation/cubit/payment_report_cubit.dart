import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';
import '../../domain/entities/revenue_summary.dart';
import '../../domain/usecases/get_payment_report_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'payment_report_state.dart';

class PaymentReportCubit extends Cubit<PaymentReportState> {
  final GetPaymentReportUseCase _getPaymentReport;
  final RecordPaymentUseCase _recordPayment;
  final GetTenantsUseCase _getTenants;

  PaymentReportCubit({
    required GetPaymentReportUseCase getPaymentReport,
    required RecordPaymentUseCase recordPayment,
    required GetTenantsUseCase getTenants,
  })  : _getPaymentReport = getPaymentReport,
        _recordPayment = recordPayment,
        _getTenants = getTenants,
        super(PaymentReportInitial());

  Future<void> fetchReport({String? hostelId}) async {
    emit(PaymentReportLoading());
    try {
      final items = await _getPaymentReport(hostelId: hostelId);
      final tenants = await _getTenants(hostelId: hostelId, limit: 100);

      final now = DateTime.now();
      final summary = RevenueSummary(
        totalCollected: items.fold(0, (sum, item) => sum + item.totalPaid),
        paymentCount: items.length,
        tenantCount: items.map((e) => e.tenantName).toSet().length,
        viaStayIndia: items
            .where((e) => e.paymentMethod?.toLowerCase() == 'stayindia')
            .fold(0, (sum, item) => sum + item.totalPaid),
        direct: items
            .where((e) => e.paymentMethod?.toLowerCase() == 'direct')
            .fold(0, (sum, item) => sum + item.totalPaid),
        settlingAmount: 18000,
        period: DateFormat('MMMM').format(now),
      );

      emit(PaymentReportLoaded(items: items, summary: summary, tenants: tenants));
    } catch (e) {
      emit(PaymentReportError(message: GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> submitPayment({
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
      fetchReport();
    } catch (e) {
      rethrow;
    }
  }
}
