import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/complaint.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/complaint_usecases.dart';

abstract class ComplaintsState {}

class ComplaintsInitial extends ComplaintsState {}

class ComplaintsLoading extends ComplaintsState {}

class ComplaintsLoaded extends ComplaintsState {
  final List<Complaint> complaints;
  ComplaintsLoaded({required this.complaints});
}

class ComplaintUpdating extends ComplaintsState {}

class ComplaintUpdateSuccess extends ComplaintsState {
  final String message;
  ComplaintUpdateSuccess({this.message = 'Complaint updated'});
}

class ComplaintsError extends ComplaintsState {
  final String message;
  ComplaintsError({required this.message});
}

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final GetComplaintsUseCase _getComplaints;
  final UpdateComplaintStatusUseCase _updateStatus;

  ComplaintsCubit({
    required GetComplaintsUseCase getComplaintsUseCase,
    required UpdateComplaintStatusUseCase updateStatusUseCase,
  }) : _getComplaints = getComplaintsUseCase,
       _updateStatus = updateStatusUseCase,
       super(ComplaintsInitial());

  Future<void> loadComplaints(String hostelId) async {
    emit(ComplaintsLoading());
    try {
      final complaints = await _getComplaints(hostelId);
      emit(ComplaintsLoaded(complaints: complaints));
    } catch (e) {
      emit(ComplaintsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateStatus(String id, String status, String hostelId) async {
    emit(ComplaintUpdating());
    try {
      await _updateStatus(id, status);
      emit(ComplaintUpdateSuccess());
      await loadComplaints(hostelId);
    } catch (e) {
      emit(ComplaintsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }
}
