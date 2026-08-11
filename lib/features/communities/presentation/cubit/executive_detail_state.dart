import 'package:equatable/equatable.dart';
import '../../domain/entities/executive_structure_entity.dart';

abstract class ExecutiveDetailState extends Equatable {
  const ExecutiveDetailState();
  @override
  List<Object?> get props => [];
}

class ExecutiveDetailInitial extends ExecutiveDetailState {}

class ExecutiveDetailLoading extends ExecutiveDetailState {}

class ExecutiveDetailLoaded extends ExecutiveDetailState {
  final List<ExecutiveStructureLeaderEntity> leaders;
  const ExecutiveDetailLoaded(this.leaders);

  @override
  List<Object?> get props => [leaders];
}

class ExecutiveDetailError extends ExecutiveDetailState {
  final String message;
  const ExecutiveDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
