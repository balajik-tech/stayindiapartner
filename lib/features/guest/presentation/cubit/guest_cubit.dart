import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/guest_repository.dart';
import 'guest_state.dart';

class GuestCubit extends Cubit<GuestState> {
  final GuestRepository repository;

  GuestCubit({required this.repository}) : super(GuestInitial());

  Future<void> loadHostelRequests(String hostelId) async {
    emit(GuestLoading());
    try {
      final requests = await repository.getHostelGuestRequests(hostelId);
      emit(GuestSuccess(requests));
    } catch (e) {
      emit(GuestError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> updateStatus(String requestId, String status, String hostelId, {String? rejectionReason}) async {
    emit(GuestLoading());
    try {
      final request = await repository.updateGuestRequestStatus(requestId, status, rejectionReason: rejectionReason);
      emit(GuestStatusUpdated(request));

      await loadHostelRequests(hostelId);
    } catch (e) {
      emit(GuestError(GlobalErrorMapper.map(e).message));
    }
  }
}
