import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/staff/domain/entities/staff.dart';
import 'package:stayindia_owner/features/staff/domain/usecases/staff_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/staff/data/datasources/staff_remote_datasource.dart';

part 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  final GetStaffListUseCase _getStaffList;
  final CreateStaffUseCase _createStaff;
  final UpdateStaffUseCase _updateStaff;
  final LogStaffActivityUseCase _logActivity;
  final GetStaffByIdUseCase _getStaffById;

  StaffCubit({
    required GetStaffListUseCase getStaffListUseCase,
    required CreateStaffUseCase createStaffUseCase,
    required UpdateStaffUseCase updateStaffUseCase,
    required LogStaffActivityUseCase logStaffActivityUseCase,
    required GetStaffByIdUseCase getStaffByIdUseCase,
  }) : _getStaffList = getStaffListUseCase,
       _createStaff = createStaffUseCase,
       _updateStaff = updateStaffUseCase,
       _logActivity = logStaffActivityUseCase,
       _getStaffById = getStaffByIdUseCase,
       super(StaffInitial());

  Future<void> loadStaff(String? hostelId) async {
    emit(StaffLoading());
    try {
      final staffList = await _getStaffList(hostelId);
      emit(StaffLoaded(staffList: staffList));
    } catch (e) {
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    String? password,
    required String role,
    Map<String, dynamic>? permissions,
    double salary = 0.0,
    String? photo,
    Map<String, dynamic>? paymentDetails,
  }) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await _createStaff(
        hostelId: hostelId,
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
        permissions: permissions,
        salary: salary,
        photo: photo,
        paymentDetails: paymentDetails,
      );
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await _updateStaff(id, data);
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> logActivity(String id, String action, String? details) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await _logActivity(id, action, details);
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      return await sl<StaffRemoteDataSource>().uploadStaffPhoto(filePath);
    } catch (e) {
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
      return null;
    }
  }

  Future<void> loadStaffById(String id) async {
    try {
      await _getStaffById(id);
    } catch (e) {
      emit(StaffError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
