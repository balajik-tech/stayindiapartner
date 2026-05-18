part of 'maintenance_cubit.dart';

abstract class MaintenanceState extends Equatable {
  final TicketSummary? summary;
  const MaintenanceState({this.summary});
  @override
  List<Object?> get props => [summary];
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {
  const MaintenanceLoading({super.summary});
}

class MaintenanceLoaded extends MaintenanceState {
  const MaintenanceLoaded({required TicketSummary summary})
    : super(summary: summary);
}

class MaintenanceSaving extends MaintenanceState {
  const MaintenanceSaving({super.summary});
}

class MaintenanceSuccess extends MaintenanceState {
  const MaintenanceSuccess({super.summary});
}

class MaintenanceError extends MaintenanceState {
  final String message;
  const MaintenanceError({required this.message, super.summary});
  @override
  List<Object?> get props => [message, summary];
}
