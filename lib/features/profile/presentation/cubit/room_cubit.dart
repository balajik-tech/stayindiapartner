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
  final BulkCreateRoomsUseCase _bulkCreateRooms;

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
    required BulkCreateRoomsUseCase bulkCreateRoomsUseCase,
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
        _bulkCreateRooms = bulkCreateRoomsUseCase,
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
    List<int> floors = const [],
    required String sharingType,
    required String roomType,
    required double rent,
    double dailyRent = 0,
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
        floors: floors,
        sharingType: sharingType,
        roomType: roomType,
        rent: rent,
        dailyRent: dailyRent,
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
      default:
        final digits = RegExp(r'\d+').firstMatch(sharing)?.group(0);
        if (digits != null) {
          return int.tryParse(digits) ?? 1;
        }
        return 1;
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

  Future<void> bulkCreateRooms({
    required String hostelId,
    required String ownerId,
    required List<RoomDetail> rooms,
  }) async {
    if (state is RoomLoading) return;
    emit(RoomLoading());
    try {
      await _bulkCreateRooms(rooms, ownerId);
      emit(RoomOperationSuccess('${rooms.length} rooms created successfully'));
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> addFloor({
    required String hostelId,
    required String ownerId,
    required String floorName,
    required int roomCount,
    required int bedsPerRoom,
  }) async {
    if (state is RoomLoading) return;
    emit(RoomLoading());
    try {
      int floorNumber = 0;
      final nameUpper = floorName.toUpperCase().trim();
      if (nameUpper == 'GROUND_FLOOR' || nameUpper == 'GROUND FLOOR' || nameUpper == 'G' || nameUpper == '0') {
        floorNumber = 0;
      } else if (nameUpper == 'BASEMENT' || nameUpper == 'B') {
        floorNumber = -1;
      } else if (nameUpper.startsWith('BASEMENT') || nameUpper.startsWith('B')) {
        final numStr = nameUpper.replaceAll(RegExp(r'[^0-9]'), '');
        final parsed = int.tryParse(numStr);
        if (parsed != null) {
          floorNumber = -parsed;
        } else {
          floorNumber = -1;
        }
      } else {
        floorNumber = int.tryParse(floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      
      final List<RoomDetail> rooms = [];
      final isBasement = floorNumber < 0 || nameUpper.contains('BASEMENT') || nameUpper.startsWith('B');

      for (int i = 1; i <= roomCount; i++) {
        String roomNoStr;
        if (isBasement) {
          final absFloor = floorNumber.abs();
          final prefix = absFloor > 1 ? 'B$absFloor' : 'B';
          roomNoStr = '$prefix${i.toString().padLeft(2, '0')}';
        } else {
          final roomNo = (floorNumber * 100) + i;
          roomNoStr = roomNo.toString();
        }
        
        rooms.add(RoomDetail(
          id: '',
          hostelId: hostelId,
          roomTypename: roomNoStr,
          floor: floorNumber,
          sharingType: _mapCapacityToSharing(bedsPerRoom),
          roomType: 'NON-AC',
          rent: 0,
          deposit: 0,
          maintenance: 0,
          isActive: true,
          isMaster: false,
          capacity: bedsPerRoom,
        ));
      }
      
      await _bulkCreateRooms(rooms, ownerId);
      emit(RoomOperationSuccess('Floor $floorName added with $roomCount rooms'));
    } catch (e) {
      emit(RoomError(ErrorHandler.getErrorMessage(e)));
    }
  }

  String _mapCapacityToSharing(int capacity) {
    switch (capacity) {
      case 1: return 'SINGLE';
      case 2: return 'DOUBLE';
      case 3: return 'TRIPLE';
      case 4: return 'QUADRUPLE';
      case 5: return 'QUINTUPLE';
      default: return '$capacity Sharing';
    }
  }
}
