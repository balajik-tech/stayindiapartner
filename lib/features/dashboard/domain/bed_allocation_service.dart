import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';

class BedAllocationResult {
  final FloorData floor;
  final Room room;
  final BedInfo bed;

  BedAllocationResult({required this.floor, required this.room, required this.bed});
}

class BedAllocationService {
  static BedAllocationResult? allocateOptimalBed({
    required Occupancy occupancy,
    required String targetSharingType,
    required String targetRoomType,
  }) {
    final List<BedAllocationResult> candidates = [];

    for (final floor in occupancy.floors) {
      for (final room in floor.rooms) {
        final isSharingMatch = room.sharingType.toLowerCase().replaceAll(' ', '') == 
                               targetSharingType.toLowerCase().replaceAll(' ', '');
        final isAcMatch = (room.roomType ?? '').toLowerCase().replaceAll('-', '') == 
                          targetRoomType.toLowerCase().replaceAll('-', '');
        
        if (isSharingMatch && isAcMatch) {
          final freeBeds = room.beds.where((b) => b.status.toUpperCase() == 'FREE').toList();
          if (freeBeds.isNotEmpty) {
            freeBeds.sort((a, b) => a.bedNumber.compareTo(b.bedNumber));
            candidates.add(BedAllocationResult(floor: floor, room: room, bed: freeBeds.first));
          }
        }
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      final aOccupied = a.room.beds.where((bed) => 
        bed.status.toUpperCase() == 'OCCUPIED' || bed.status.toUpperCase() == 'RESERVED'
      ).length;
      final bOccupied = b.room.beds.where((bed) => 
        bed.status.toUpperCase() == 'OCCUPIED' || bed.status.toUpperCase() == 'RESERVED'
      ).length;
      
      final aRatio = a.room.beds.isEmpty ? 0.0 : aOccupied / a.room.beds.length;
      final bRatio = b.room.beds.isEmpty ? 0.0 : bOccupied / b.room.beds.length;

      if (bRatio.compareTo(aRatio) != 0) {
        return bRatio.compareTo(aRatio);
      }

      final aFloorNum = a.floor.floorNum ?? 999;
      final bFloorNum = b.floor.floorNum ?? 999;
      if (aFloorNum.compareTo(bFloorNum) != 0) {
        return aFloorNum.compareTo(bFloorNum);
      }

      return a.room.roomNumber.compareTo(b.room.roomNumber);
    });

    return candidates.first;
  }
}
