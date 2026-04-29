import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardDataUseCase _getDashboardData;
  bool _isFetching = false;

  DashboardCubit({
    required GetDashboardDataUseCase getDashboardDataUseCase,
  })  : _getDashboardData = getDashboardDataUseCase,
        super(const DashboardInitial());

  Future<void> fetchDashboardData(String hostelId) async {
    if (isClosed) return;
    
    if (_isFetching) return;
    _isFetching = true;

    final currentIndex = state.selectedFloorIndex;
    emit(DashboardLoading(selectedFloorIndex: currentIndex));
    try {
      final data = await _getDashboardData(hostelId);
      if (isClosed) return;
      emit(DashboardLoaded(data: data, selectedFloorIndex: currentIndex));
      AppLogger.success('Dashboard data loaded successfully');
    } catch (e) {
      AppLogger.error('fetchDashboardData failed', e);
      if (!isClosed) emit(DashboardError(message: ErrorHelper.toFriendlyMessage(e), selectedFloorIndex: currentIndex));
    } finally {
      _isFetching = false;
    }
  }

  void selectFloor(int index) {
    if (isClosed) return;
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(selectedFloorIndex: index));
    } else {
      
      if (state is DashboardLoading) {
        emit(DashboardLoading(selectedFloorIndex: index));
      } else if (state is DashboardError) {
        emit(DashboardError(message: (state as DashboardError).message, selectedFloorIndex: index));
      } else if (state is DashboardInitial) {
        emit(DashboardInitial(selectedFloorIndex: index));
      }
    }
  }
}
