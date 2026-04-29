import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/room_repository.dart';

class GetOccupancyUseCase {
  final RoomRepository repository;
  GetOccupancyUseCase(this.repository);

  Future<Occupancy> call(String hostelId) {
    return repository.getOccupancy(hostelId);
  }
}

class GetFloorWiseRoomsUseCase {
  final RoomRepository repository;
  GetFloorWiseRoomsUseCase(this.repository);

  Future<List<FloorData>> call(String hostelId) {
    return repository.getFloorWiseRooms(hostelId);
  }
}

class GetRoomsUseCase {
  final RoomRepository repository;
  GetRoomsUseCase(this.repository);

  Future<List<RoomDetail>> call({bool? isMaster}) {
    return repository.getRooms(isMaster: isMaster);
  }
}

class GetFloorsUseCase {
  final RoomRepository repository;
  GetFloorsUseCase(this.repository);

  Future<List<int>> call(String hostelId) {
    return repository.getFloors(hostelId);
  }
}

class GetRoomsByFloorUseCase {
  final RoomRepository repository;
  GetRoomsByFloorUseCase(this.repository);

  Future<List<RoomDetail>> call(String hostelId, int floor) {
    return repository.getRoomsByFloor(hostelId, floor);
  }
}

class GetFreeBedsUseCase {
  final RoomRepository repository;
  GetFreeBedsUseCase(this.repository);

  Future<List<String>> call(String roomId) {
    return repository.getFreeBeds(roomId);
  }
}

class CreateRoomUseCase {
  final RoomRepository repository;
  CreateRoomUseCase(this.repository);

  Future<RoomDetail> call(RoomDetail room, String ownerId) {
    return repository.createRoom(room, ownerId);
  }
}

class UpdateRoomUseCase {
  final RoomRepository repository;
  UpdateRoomUseCase(this.repository);

  Future<RoomDetail> call(RoomDetail room) {
    return repository.updateRoom(room);
  }
}

class DeleteRoomUseCase {
  final RoomRepository repository;
  DeleteRoomUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteRoom(id);
  }
}

class GetBedDetailUseCase {
  final RoomRepository repository;
  GetBedDetailUseCase(this.repository);

  Future<Map<String, dynamic>> call(String roomId, String bedNumber) {
    return repository.getBedDetail(roomId, bedNumber);
  }
}

class GetBedHistoryUseCase {
  final RoomRepository repository;
  GetBedHistoryUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(String roomId, String bedNumber) {
    return repository.getBedHistory(roomId, bedNumber);
  }
}
