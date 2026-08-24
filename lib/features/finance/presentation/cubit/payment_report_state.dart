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
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const PaymentReportLoaded({
    required this.items,
    this.summary,
    this.tenants = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaymentReportLoaded copyWith({
    List<PaymentReportItem>? items,
    RevenueSummary? summary,
    List<TenantEntity>? tenants,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaymentReportLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      tenants: tenants ?? this.tenants,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        items,
        summary,
        tenants,
        page,
        hasMore,
        isLoadingMore,
      ];
}

class PaymentReportError extends PaymentReportState {
  final String message;
  const PaymentReportError({required this.message});
  @override
  List<Object?> get props => [message];
}
