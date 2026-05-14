import 'package:equatable/equatable.dart';
import '../../domain/entities/offer_entity.dart';

abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<OfferEntity> offers;
  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OffersError extends OffersState {
  final String message;
  const OffersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OfferOperationSuccess extends OffersState {
  final String message;
  const OfferOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
