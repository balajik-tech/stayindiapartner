import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/finance/domain/entities/revenue_history_item.dart';
import 'package:stayindia_owner/features/finance/domain/usecases/get_revenue_history_usecase.dart';

abstract class RevenueHistoryState extends Equatable {
  const RevenueHistoryState();
  @override
  List<Object?> get props => [];
}

class RevenueHistoryInitial extends RevenueHistoryState {}

class RevenueHistoryLoading extends RevenueHistoryState {}

class RevenueHistoryLoaded extends RevenueHistoryState {
  final List<RevenueHistoryItem> items;
  const RevenueHistoryLoaded({required this.items});
  @override
  List<Object?> get props => [items];
}

class RevenueHistoryError extends RevenueHistoryState {
  final String message;
  const RevenueHistoryError({required this.message});
  @override
  List<Object?> get props => [message];
}

class RevenueHistoryCubit extends Cubit<RevenueHistoryState> {
  final GetRevenueHistoryUseCase _getRevenueHistory;

  RevenueHistoryCubit({required GetRevenueHistoryUseCase getRevenueHistory})
    : _getRevenueHistory = getRevenueHistory,
      super(RevenueHistoryInitial());

  Future<void> fetchRevenueHistory({
    String? hostelId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    emit(RevenueHistoryLoading());
    try {
      final items = await _getRevenueHistory(
        hostelId: hostelId,
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
        type: type,
      );
      emit(RevenueHistoryLoaded(items: items));
    } catch (e) {
      emit(RevenueHistoryError(message: GlobalErrorMapper.map(e).message));
    }
  }
}
