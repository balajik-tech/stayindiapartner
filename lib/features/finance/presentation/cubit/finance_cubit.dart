import '../../../../core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/finance_usecases.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final GetFinancialStatsUseCase getFinancialStatsUseCase;
  final GetRevenueAnalyticsUseCase getRevenueAnalyticsUseCase;

  FinanceCubit({
    required this.getFinancialStatsUseCase,
    required this.getRevenueAnalyticsUseCase,
  }) : super(const FinanceState());

  Future<void> loadDashboard({String? hostelId}) async {
    final currentHostelId = hostelId ?? state.selectedHostelId;
    emit(state.copyWith(status: FinanceStatus.loading, selectedHostelId: currentHostelId));

    try {
      final stats = await getFinancialStatsUseCase(hostelId: currentHostelId);
      final trends = await getRevenueAnalyticsUseCase(
        hostelId: currentHostelId,
        interval: state.interval,
      );

      emit(state.copyWith(
        status: FinanceStatus.success,
        stats: stats,
        revenueTrends: trends,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: GlobalErrorMapper.map(e).message,
      ));
    }
  }

  void changeInterval(String interval) {
    emit(state.copyWith(interval: interval));
    loadDashboard();
  }

  void changeHostel(String? hostelId) {
    loadDashboard(hostelId: hostelId);
  }
}
