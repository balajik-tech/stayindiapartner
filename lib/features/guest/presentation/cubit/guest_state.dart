import 'package:equatable/equatable.dart';
import '../../domain/entities/guest_request.dart';

abstract class GuestState extends Equatable {
  const GuestState();

  @override
  List<Object?> get props => [];
}

class GuestInitial extends GuestState {}

class GuestLoading extends GuestState {}

class GuestSuccess extends GuestState {
  final List<GuestRequest> requests;
  const GuestSuccess(this.requests);

  @override
  List<Object?> get props => [requests];
}

class GuestStatusUpdated extends GuestState {
  final GuestRequest request;
  const GuestStatusUpdated(this.request);

  @override
  List<Object?> get props => [request];
}

class GuestError extends GuestState {
  final String message;
  const GuestError(this.message);

  @override
  List<Object?> get props => [message];
}
