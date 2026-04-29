import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';

abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<RoomDetail> rooms;
  RoomLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class RoomOperationSuccess extends RoomState {
  final String message;
  RoomOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class RoomError extends RoomState {
  final String message;
  RoomError(this.message);
  @override
  List<Object?> get props => [message];
}

class RoomCubit extends Cubit<RoomState> {
  final GetOccupancyUseCase _getOccupancy;
  final GetFloorWiseRoomsUseCase _getFloorWiseRooms;
  final GetRoomsUseCase _getRooms;
  final GetFloorsUseCase _getFloors;
  final GetRoomsByFloorUseCase _getRoomsByFloor;
  final GetFreeBedsUseCase _getFreeBeds;
  final CreateRoomUseCase _createRoom;
  final UpdateRoomUseCase _updateRoom;
  final DeleteRoomUseCase _deleteRoom;
  final GetBedDetailUseCase _getBedDetail;
  final GetBedHistoryUseCase _getBedHistory;

  RoomCubit({
    required GetOccupancyUseCase getOccupancyUseCase,
    required GetFloorWiseRoomsUseCase getFloorWiseRoomsUseCase,
    required GetRoomsUseCase getRoomsUseCase,
    required GetFloorsUseCase getFloorsUseCase,
    required GetRoomsByFloorUseCase getRoomsByFloorUseCase,
    required GetFreeBedsUseCase getFreeBedsUseCase,
    required CreateRoomUseCase createRoomUseCase,
    required UpdateRoomUseCase updateRoomUseCase,
    required DeleteRoomUseCase deleteRoomUseCase,
    required GetBedDetailUseCase getBedDetailUseCase,
    required GetBedHistoryUseCase getBedHistoryUseCase,
  })  : _getOccupancy = getOccupancyUseCase,
        _getFloorWiseRooms = getFloorWiseRoomsUseCase,
        _getRooms = getRoomsUseCase,
        _getFloors = getFloorsUseCase,
        _getRoomsByFloor = getRoomsByFloorUseCase,
        _getFreeBeds = getFreeBedsUseCase,
        _createRoom = createRoomUseCase,
        _updateRoom = updateRoomUseCase,
        _deleteRoom = deleteRoomUseCase,
        _getBedDetail = getBedDetailUseCase,
        _getBedHistory = getBedHistoryUseCase,
        super(RoomInitial());

  Future<void> getRooms({bool? isMaster}) async {
    emit(RoomLoading());
    try {
      final rooms = await _getRooms(isMaster: isMaster);
      emit(RoomLoaded(rooms));
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> createRoom({
    required String hostelId,
    required String ownerId,
    required String roomTypename,
    required int floor,
    required String sharingType,
    required String roomType,
    required double rent,
    required double deposit,
    required double maintenance,
    bool isMaster = false,
  }) async {
    if (state is RoomLoading) return;

    
    if (hostelId.isEmpty) {
      emit(RoomError('No hostel selected. Please select a hostel first.'));
      throw Exception('hostelId is empty');
    }
    if (ownerId.isEmpty) {
      emit(RoomError('Owner session expired. Please login again.'));
      throw Exception('ownerId is empty');
    }
    
    if (hostelId.length != 24) {
      emit(RoomError('Invalid hostel ID. Please try logging out and in again.'));
      throw Exception('hostelId is invalid: $hostelId');
    }

    emit(RoomLoading());
    try {
      final capacity = _mapSharingToCapacity(sharingType);
      final room = RoomDetail(
        id: '',
        hostelId: hostelId,
        roomTypename: roomTypename,
        floor: floor,
        sharingType: sharingType,
        roomType: roomType,
        rent: rent,
        deposit: deposit,
        maintenance: maintenance,
        isActive: true,
        isMaster: isMaster,
        capacity: capacity,
      );
      await _createRoom(room, ownerId);
      emit(RoomOperationSuccess('Room created successfully'));
      await getRooms(isMaster: isMaster);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
      rethrow;
    }
  }

  int _mapSharingToCapacity(String sharing) {
    switch (sharing.toUpperCase()) {
      case 'SINGLE': return 1;
      case 'DOUBLE': return 2;
      case 'TRIPLE': return 3;
      case 'QUADRUPLE': return 4;
      case 'QUINTUPLE': return 5;
      default: return 1;
    }
  }

  Future<void> updateRoom(RoomDetail room) async {
    if (state is RoomLoading) return;
    
    emit(RoomLoading());
    try {
      await _updateRoom(room);
      emit(RoomOperationSuccess('Room updated successfully'));
      await getRooms(isMaster: room.isMaster);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
      rethrow;
    }
  }

  Future<void> deleteRoom(String id, {bool? isMaster}) async {
    try {
      await _deleteRoom(id);
      emit(RoomOperationSuccess('Room deleted successfully'));
      await getRooms(isMaster: isMaster);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadOccupancy(String hostelId) async {
    try {
      await _getOccupancy(hostelId);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadFloorWiseRooms(String hostelId) async {
    try {
      await _getFloorWiseRooms(hostelId);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadFloors(String hostelId) async {
    try {
      await _getFloors(hostelId);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadRoomsByFloor(String hostelId, int floor) async {
    try {
      await _getRoomsByFloor(hostelId, floor);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadFreeBeds(String roomId) async {
    try {
      await _getFreeBeds(roomId);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadBedDetail(String roomId, String bedNumber) async {
    try {
      await _getBedDetail(roomId, bedNumber);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> loadBedHistory(String roomId, String bedNumber) async {
    try {
      await _getBedHistory(roomId, bedNumber);
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
