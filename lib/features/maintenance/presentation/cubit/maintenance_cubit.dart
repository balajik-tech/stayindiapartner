import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:stayindia_owner/features/maintenance/domain/usecases/maintenance_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

part 'maintenance_state.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final GetMaintenanceIssuesUseCase _getIssues;
  final CreateMaintenanceIssueUseCase _createIssue;
  final UpdateMaintenanceIssueUseCase _updateIssue;
  final GetMaintenanceIssueByIdUseCase _getIssueById;

  MaintenanceCubit({
    required GetMaintenanceIssuesUseCase getIssuesUseCase,
    required CreateMaintenanceIssueUseCase createIssueUseCase,
    required UpdateMaintenanceIssueUseCase updateIssueUseCase,
    required GetMaintenanceIssueByIdUseCase getIssueByIdUseCase,
  })  : _getIssues = getIssuesUseCase,
        _createIssue = createIssueUseCase,
        _updateIssue = updateIssueUseCase,
        _getIssueById = getIssueByIdUseCase,
        super(MaintenanceInitial());

  Future<void> loadIssues({
    String? hostelId,
    String? status,
    String? search,
  }) async {
    emit(MaintenanceLoading(summary: state.summary));
    try {
      final summary = await _getIssues(
        hostelId: hostelId,
        status: status,
        search: search,
      );
      emit(MaintenanceLoaded(summary: summary));
    } catch (e) {
      emit(MaintenanceError(message: ErrorHelper.toFriendlyMessage(e), summary: state.summary));
    }
  }

  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
  }) async {
    emit(MaintenanceSaving(summary: state.summary));
    try {
      await _createIssue(
        hostelId: hostelId,
        title: title,
        description: description,
        roomId: roomId,
        bedNumber: bedNumber,
        status: status,
      );
      emit(MaintenanceSuccess(summary: state.summary));
    } catch (e) {
      emit(MaintenanceError(message: ErrorHelper.toFriendlyMessage(e), summary: state.summary));
    }
  }

  Future<void> updateIssue(
    String id, {
    String? title,
    String? description,
    String? status,
    String? assignedStaffId,
  }) async {
    emit(MaintenanceSaving(summary: state.summary));
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status;
      if (assignedStaffId != null) data['assignedStaffId'] = assignedStaffId;

      await _updateIssue(id, data);
      emit(MaintenanceSuccess(summary: state.summary));
    } catch (e) {
      emit(MaintenanceError(message: ErrorHelper.toFriendlyMessage(e), summary: state.summary));
    }
  }

  Future<void> loadIssueById(String id) async {
    try {
      await _getIssueById(id);
    } catch (e) {
      emit(MaintenanceError(message: ErrorHelper.toFriendlyMessage(e), summary: state.summary));
    }
  }
}
