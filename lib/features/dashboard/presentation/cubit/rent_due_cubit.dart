import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';
import 'package:stayindia_owner/features/dashboard/domain/usecases/get_rent_due_details_usecase.dart';

abstract class RentDueState extends Equatable {
  const RentDueState();
  @override
  List<Object?> get props => [];
}

class RentDueInitial extends RentDueState {}
class RentDueLoading extends RentDueState {}
class RentDueLoaded extends RentDueState {
  final RentDueDetails details;
  const RentDueLoaded({required this.details});
  @override
  List<Object?> get props => [details];
}
class RentDueError extends RentDueState {
  final String message;
  const RentDueError({required this.message});
  @override
  List<Object?> get props => [message];
}

class RentDueCubit extends Cubit<RentDueState> {
  final GetRentDueDetailsUseCase _getRentDueDetails;

  RentDueCubit({required GetRentDueDetailsUseCase getRentDueDetails})
      : _getRentDueDetails = getRentDueDetails,
        super(RentDueInitial());

  Future<void> fetchRentDueDetails(String hostelId) async {
    emit(RentDueLoading());
    try {
      final details = await _getRentDueDetails(hostelId);
      emit(RentDueLoaded(details: details));
    } catch (e) {
      emit(RentDueError(message: e.toString()));
    }
  }
}
