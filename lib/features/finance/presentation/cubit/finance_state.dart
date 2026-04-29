import 'package:equatable/equatable.dart';
import '../../domain/entities/financial_entities.dart';

enum FinanceStatus { initial, loading, success, failure }

class FinanceState extends Equatable {
  final FinanceStatus status;
  final FinancialStats? stats;
  final List<RevenueTrend> revenueTrends;
  final String? errorMessage;
  final String? selectedHostelId;
  final String interval;

  const FinanceState({
    this.status = FinanceStatus.initial,
    this.stats,
    this.revenueTrends = const [],
    this.errorMessage,
    this.selectedHostelId,
    this.interval = 'day',
  });

  FinanceState copyWith({
    FinanceStatus? status,
    FinancialStats? stats,
    List<RevenueTrend>? revenueTrends,
    String? errorMessage,
    String? selectedHostelId,
    String? interval,
  }) {
    return FinanceState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      revenueTrends: revenueTrends ?? this.revenueTrends,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedHostelId: selectedHostelId ?? this.selectedHostelId,
      interval: interval ?? this.interval,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stats,
        revenueTrends,
        errorMessage,
        selectedHostelId,
        interval,
      ];
}
