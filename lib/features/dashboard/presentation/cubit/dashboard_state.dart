part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  final int selectedFloorIndex;
  final String searchQuery;
  final bool isGridView;

  const DashboardState({
    this.selectedFloorIndex = -1,
    this.searchQuery = '',
    this.isGridView = false,
  });

  @override
  List<Object?> get props => [selectedFloorIndex, searchQuery, isGridView];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial({
    super.selectedFloorIndex,
    super.searchQuery,
    super.isGridView,
  });
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({
    super.selectedFloorIndex,
    super.searchQuery,
    super.isGridView,
  });
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded({
    required this.data,
    super.selectedFloorIndex,
    super.searchQuery,
    super.isGridView,
  });

  @override
  List<Object?> get props => [data, selectedFloorIndex, searchQuery, isGridView];

  DashboardLoaded copyWith({
    DashboardData? data,
    int? selectedFloorIndex,
    String? searchQuery,
    bool? isGridView,
  }) {
    return DashboardLoaded(
      data: data ?? this.data,
      selectedFloorIndex: selectedFloorIndex ?? this.selectedFloorIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({
    required this.message,
    super.selectedFloorIndex,
    super.searchQuery,
    super.isGridView,
  });

  @override
  List<Object?> get props => [message, selectedFloorIndex, searchQuery, isGridView];
}
