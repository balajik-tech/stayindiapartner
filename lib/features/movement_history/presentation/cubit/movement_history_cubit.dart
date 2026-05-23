import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/movement_history/domain/entities/movement_history_entity.dart';
import 'package:stayindia_owner/features/movement_history/domain/repositories/movement_repository.dart';

abstract class MovementHistoryState extends Equatable {
  const MovementHistoryState();

  @override
  List<Object?> get props => [];
}

class MovementHistoryInitial extends MovementHistoryState {}

class MovementHistoryLoading extends MovementHistoryState {}

class MovementHistoryLoaded extends MovementHistoryState {
  final List<MovementHistoryEntity> history;

  const MovementHistoryLoaded({
    required this.history,
  });

  @override
  List<Object?> get props => [history];
}

class MovementHistoryError extends MovementHistoryState {
  final String message;

  const MovementHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class MovementHistoryCubit extends Cubit<MovementHistoryState> {
  final MovementRepository _repository;

  MovementHistoryCubit({required MovementRepository repository})
      : _repository = repository,
        super(MovementHistoryInitial());

  Future<void> loadHistory(String tenantId) async {
    try {
      emit(MovementHistoryLoading());
      final history = await _repository.getLocationHistory(tenantId);
      
      emit(MovementHistoryLoaded(
        history: history,
      ));
    } catch (e) {
      emit(MovementHistoryError(e.toString()));
    }
  }
}
