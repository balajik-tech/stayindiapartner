import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_report_entity.dart';
import '../../domain/entities/revenue_summary.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';

abstract class PaymentReportState extends Equatable {
  const PaymentReportState();
  @override
  List<Object?> get props => [];
}

class PaymentReportInitial extends PaymentReportState {}

class PaymentReportLoading extends PaymentReportState {}

class PaymentReportLoaded extends PaymentReportState {
  final List<PaymentReportItem> items;
  final RevenueSummary? summary;
  final List<TenantEntity> tenants;

  const PaymentReportLoaded({
    required this.items,
    this.summary,
    this.tenants = const [],
  });

  @override
  List<Object?> get props => [items, summary, tenants];
}

class PaymentReportError extends PaymentReportState {
  final String message;
  const PaymentReportError({required this.message});
  @override
  List<Object?> get props => [message];
}
