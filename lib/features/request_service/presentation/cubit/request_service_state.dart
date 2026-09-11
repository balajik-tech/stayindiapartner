part of 'request_service_cubit.dart';

abstract class RequestServiceState extends Equatable {
  const RequestServiceState();

  @override
  List<Object?> get props => [];
}

class RequestServiceInitial extends RequestServiceState {}

class RequestServiceLoading extends RequestServiceState {}

class RequestServiceSuccess extends RequestServiceState {
  final ServiceRequestEntity request;

  const RequestServiceSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestServiceListLoaded extends RequestServiceState {
  final List<ServiceRequestEntity> requests;

  const RequestServiceListLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestServiceError extends RequestServiceState {
  final String message;

  const RequestServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
