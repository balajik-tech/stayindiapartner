import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';

class TenantCubit extends Cubit<TenantState> {
  final GetTenantsUseCase _getTenants;
  Timer? _searchDebounce;
  
  TenantCubit({
    required GetTenantsUseCase getTenantsUseCase,
  })  : _getTenants = getTenantsUseCase,
        super(TenantInitial());

  Future<void> loadTenants(String hostelId, {String? search, String status = 'CHECKED_IN'}) async {
    if (isClosed) return;
    emit(TenantLoading());
    try {
      final tenants = await _getTenants(search: search, status: status, page: 1, limit: 10, hostelId: hostelId);
      if (isClosed) return;
      if (tenants.isEmpty) {
        emit(TenantEmpty(message: status == 'CHECKED_OUT' ? 'No history found' : 'No active tenants found'));
      } else {
        emit(TenantLoaded(
          tenants: tenants,
          searchQuery: search,
          page: 1,
          hasMore: tenants.length >= 10,
        ));
      }
    } catch (e) {
      AppLogger.error('loadTenants failed', e);
      if (!isClosed) emit(TenantError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadMoreTenants(String hostelId, {String? search, String status = 'CHECKED_IN'}) async {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! TenantLoaded) return;
    if (currentState.isLoadMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadMore: true));
    try {
      final nextPage = currentState.page + 1;
      final newTenants = await _getTenants(search: search, status: status, page: nextPage, limit: 10, hostelId: hostelId);
      if (isClosed) return;

      emit(currentState.copyWith(
        tenants: [...currentState.tenants, ...newTenants],
        page: nextPage,
        hasMore: newTenants.length >= 10,
        isLoadMore: false,
      ));
    } catch (e) {
      AppLogger.error('loadMoreTenants failed', e);
      if (!isClosed) {
        emit(currentState.copyWith(
          isLoadMore: false,
          errorMessage: ErrorHelper.toFriendlyMessage(e),
        ));
      }
    }
  }

  
  void searchTenants(String hostelId, String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      loadTenants(hostelId, search: query.isEmpty ? null : query);
    });
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

class TenantDetailCubit extends Cubit<TenantDetailState> {
  final GetTenantDetailUseCase _getDetail;

  TenantDetailCubit({
    required GetTenantDetailUseCase getTenantDetailUseCase,
  })  : _getDetail = getTenantDetailUseCase,
        super(TenantDetailInitial());

  Future<void> loadDetail(String tenantId, String hostelId) async {
    emit(TenantDetailLoading());
    try {
      final detail = await _getDetail(tenantId, hostelId);
      emit(TenantDetailLoaded(detail));
    } catch (e) {
      AppLogger.error('loadDetail failed', e);
      emit(TenantDetailError(ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
