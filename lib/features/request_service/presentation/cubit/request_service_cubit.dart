import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import '../../domain/entities/service_request_entity.dart';
import '../../domain/usecases/request_service_usecases.dart';

part 'request_service_state.dart';

class RequestServiceCubit extends Cubit<RequestServiceState> {
  final CreateServiceRequestUseCase _createServiceRequest;
  final GetServiceRequestsUseCase _getServiceRequests;

  RequestServiceCubit({
    required CreateServiceRequestUseCase createServiceRequestUseCase,
    required GetServiceRequestsUseCase getServiceRequestsUseCase,
  })  : _createServiceRequest = createServiceRequestUseCase,
        _getServiceRequests = getServiceRequestsUseCase,
        super(RequestServiceInitial());

  Future<void> createRequest({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  }) async {
    emit(RequestServiceLoading());
    try {
      final request = await _createServiceRequest(
        hostelId: hostelId,
        serviceType: serviceType,
        date: date,
        slot: slot,
        details: details,
        tags: tags,
      );
      emit(RequestServiceSuccess(request));
    } catch (e) {
      emit(RequestServiceError(ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadRequests({required String hostelId}) async {
    emit(RequestServiceLoading());
    try {
      final requests = await _getServiceRequests(hostelId: hostelId);
      emit(RequestServiceListLoaded(requests));
    } catch (e) {
      emit(RequestServiceError(ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
