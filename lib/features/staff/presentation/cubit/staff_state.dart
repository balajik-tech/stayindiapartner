part of 'staff_cubit.dart';

abstract class StaffState extends Equatable {
  const StaffState();
  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<Staff> staffList;
  const StaffLoaded({required this.staffList});
  @override
  List<Object?> get props => [staffList];
}

class StaffSaving extends StaffState {
  final List<Staff> staffList;
  const StaffSaving({required this.staffList});
  @override
  List<Object?> get props => [staffList];
}

class StaffSuccess extends StaffState {}

class StaffError extends StaffState {
  final String message;
  const StaffError({required this.message});
  @override
  List<Object?> get props => [message];
}
