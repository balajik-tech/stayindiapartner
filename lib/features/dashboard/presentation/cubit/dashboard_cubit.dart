import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardDataUseCase _getDashboardData;
  final DeleteRoomUseCase _deleteRoom;
  bool _isFetching = false;

  DashboardCubit({
    required GetDashboardDataUseCase getDashboardDataUseCase,
    required DeleteRoomUseCase deleteRoomUseCase,
  })  : _getDashboardData = getDashboardDataUseCase,
        _deleteRoom = deleteRoomUseCase,
        super(const DashboardInitial());

  Future<void> fetchDashboardData(String hostelId) async {
    if (isClosed) return;
    
    if (_isFetching) return;
    _isFetching = true;

    final currentIndex = state.selectedFloorIndex;
    final currentSearch = state.searchQuery;
    final currentView = state.isGridView;

    if (state is! DashboardLoaded) {
      emit(DashboardLoading(
        selectedFloorIndex: currentIndex,
        searchQuery: currentSearch,
        isGridView: currentView,
        selectedMetric: state.selectedMetric,
      ));
    }
    
    try {
      final data = await _getDashboardData(hostelId);
      if (isClosed) return;
      emit(DashboardLoaded(
        data: data,
        selectedFloorIndex: currentIndex,
        searchQuery: currentSearch,
        isGridView: currentView,
        selectedMetric: state.selectedMetric,
      ));
      AppLogger.success('Dashboard data loaded successfully');
    } catch (e) {
      AppLogger.error('fetchDashboardData failed', e);
      if (!isClosed) {
        emit(DashboardError(
          message: ErrorHelper.toFriendlyMessage(e),
          selectedFloorIndex: currentIndex,
          searchQuery: currentSearch,
          isGridView: currentView,
          selectedMetric: state.selectedMetric,
        ));
      }
    } finally {
      _isFetching = false;
    }
  }

  void selectFloor(int index) {
    if (isClosed) return;
    final s = state;
    if (s is DashboardLoaded) {
      emit(s.copyWith(selectedFloorIndex: index));
    } else if (s is DashboardLoading) {
      emit(DashboardLoading(selectedFloorIndex: index, searchQuery: s.searchQuery, isGridView: s.isGridView));
    } else if (s is DashboardError) {
      emit(DashboardError(message: s.message, selectedFloorIndex: index, searchQuery: s.searchQuery, isGridView: s.isGridView));
    } else if (s is DashboardInitial) {
      emit(DashboardInitial(selectedFloorIndex: index, searchQuery: s.searchQuery, isGridView: s.isGridView));
    }
  }

  void updateSearchQuery(String query) {
    if (isClosed) return;
    final s = state;
    if (s is DashboardLoaded) {
      emit(s.copyWith(searchQuery: query));
    } else if (s is DashboardLoading) {
      emit(DashboardLoading(selectedFloorIndex: s.selectedFloorIndex, searchQuery: query, isGridView: s.isGridView));
    } else if (s is DashboardError) {
      emit(DashboardError(message: s.message, selectedFloorIndex: s.selectedFloorIndex, searchQuery: query, isGridView: s.isGridView));
    } else if (s is DashboardInitial) {
      emit(DashboardInitial(selectedFloorIndex: s.selectedFloorIndex, searchQuery: query, isGridView: s.isGridView));
    }
  }

  void toggleViewType(bool isGrid) {
    if (isClosed) return;
    final s = state;
    if (s is DashboardLoaded) {
      emit(s.copyWith(isGridView: isGrid));
    } else if (s is DashboardLoading) {
      emit(DashboardLoading(selectedFloorIndex: s.selectedFloorIndex, searchQuery: s.searchQuery, isGridView: isGrid));
    } else if (s is DashboardError) {
      emit(DashboardError(message: s.message, selectedFloorIndex: s.selectedFloorIndex, searchQuery: s.searchQuery, isGridView: isGrid));
    } else if (s is DashboardInitial) {
      emit(DashboardInitial(selectedFloorIndex: s.selectedFloorIndex, searchQuery: s.searchQuery, isGridView: isGrid));
    }
  }

  Future<void> deleteRoom(String roomId, String hostelId) async {
    try {
      await _deleteRoom(roomId);
      await fetchDashboardData(hostelId);
      AppLogger.success('Room deleted successfully');
    } catch (e) {
      AppLogger.error('deleteRoom failed', e);
      
      
      
      rethrow;
    }
  }

  Future<void> deleteRoomsBulk(List<String> roomIds, String hostelId) async {
    try {
      
      for (final roomId in roomIds) {
        await _deleteRoom(roomId);
      }
      await fetchDashboardData(hostelId);
      AppLogger.success('Floor/Rooms deleted successfully');
    } catch (e) {
      AppLogger.error('deleteRoomsBulk failed', e);
      rethrow;
    }
  }

  void toggleMetric(String metric) {
    if (isClosed) return;
    final s = state;
    if (s is DashboardLoaded) {
      if (s.selectedMetric == metric) {
        emit(s.copyWith(clearMetric: true));
      } else {
        emit(s.copyWith(selectedMetric: metric));
      }
    }
  }
}
