import 'package:equatable/equatable.dart';
import '../../domain/entities/kyc_result.dart';

abstract class DigiLockerState extends Equatable {
  const DigiLockerState();
  
  @override
  List<Object?> get props => [];
}

class DigiLockerInitial extends DigiLockerState {}

class DigiLockerLoading extends DigiLockerState {}

class DigiLockerLoaded extends DigiLockerState {
  final KycResult result;
  const DigiLockerLoaded(this.result);
  
  @override
  List<Object?> get props => [result];
}

class DigiLockerSaving extends DigiLockerState {}

class DigiLockerSaved extends DigiLockerState {
  final KycResult result;
  const DigiLockerSaved(this.result);
  
  @override
  List<Object?> get props => [result];
}

class DigiLockerError extends DigiLockerState {
  final String message;
  const DigiLockerError(this.message);
  
  @override
  List<Object?> get props => [message];
}
