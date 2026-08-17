import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';

abstract class AddTenantState extends Equatable {
  const AddTenantState();
  @override
  List<Object?> get props => [];
}

class AddTenantInitial extends AddTenantState {}

class AddTenantLoading extends AddTenantState {
  final String message;
  const AddTenantLoading({required this.message});
  @override
  List<Object?> get props => [message];
}

class AddTenantFloorsLoaded extends AddTenantState {
  final Hostel hostel;
  final List<int> floors;
  const AddTenantFloorsLoaded({required this.hostel, required this.floors});
  @override
  List<Object?> get props => [hostel, floors];
}

class AddTenantRoomsLoaded extends AddTenantState {
  final Hostel hostel;
  final List<int> floors;
  final int selectedFloor;
  final List<RoomDetail> rooms;

  const AddTenantRoomsLoaded({
    required this.hostel,
    required this.floors,
    required this.selectedFloor,
    required this.rooms,
  });

  @override
  List<Object?> get props => [hostel, floors, selectedFloor, rooms];
}

class AddTenantBedsLoaded extends AddTenantState {
  final Hostel hostel;
  final List<int> floors;
  final int selectedFloor;
  final List<RoomDetail> rooms;
  final RoomDetail selectedRoom;
  final List<String> beds;

  const AddTenantBedsLoaded({
    required this.hostel,
    required this.floors,
    required this.selectedFloor,
    required this.rooms,
    required this.selectedRoom,
    required this.beds,
  });

  @override
  List<Object?> get props => [
    hostel,
    floors,
    selectedFloor,
    rooms,
    selectedRoom,
    beds,
  ];
}

class AddTenantReady extends AddTenantState {
  final Hostel hostel;
  final List<int> floors;
  final int selectedFloor;
  final List<RoomDetail> rooms;
  final RoomDetail selectedRoom;
  final List<String> beds;
  final String selectedBed;

  const AddTenantReady({
    required this.hostel,
    required this.floors,
    required this.selectedFloor,
    required this.rooms,
    required this.selectedRoom,
    required this.beds,
    required this.selectedBed,
  });

  @override
  List<Object?> get props => [
    hostel,
    floors,
    selectedFloor,
    rooms,
    selectedRoom,
    beds,
    selectedBed,
  ];
}

class AddTenantSubmitting extends AddTenantState {}

class AddTenantSuccess extends AddTenantState {
  final String? message;
  const AddTenantSuccess({this.message});
  @override
  List<Object?> get props => [message];
}

class AddTenantError extends AddTenantState {
  final String message;
  const AddTenantError(this.message);
  @override
  List<Object?> get props => [message];
}
