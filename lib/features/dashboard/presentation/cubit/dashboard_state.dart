part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  final int selectedFloorIndex;

  const DashboardState({this.selectedFloorIndex = -1});

  @override
  List<Object?> get props => [selectedFloorIndex];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial({super.selectedFloorIndex});
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({super.selectedFloorIndex});
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded({
    required this.data,
    super.selectedFloorIndex,
  });

  @override
  List<Object?> get props => [data, selectedFloorIndex];

  DashboardLoaded copyWith({
    DashboardData? data,
    int? selectedFloorIndex,
  }) {
    return DashboardLoaded(
      data: data ?? this.data,
      selectedFloorIndex: selectedFloorIndex ?? this.selectedFloorIndex,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({
    required this.message,
    super.selectedFloorIndex,
  });

  @override
  List<Object?> get props => [message, selectedFloorIndex];
}
