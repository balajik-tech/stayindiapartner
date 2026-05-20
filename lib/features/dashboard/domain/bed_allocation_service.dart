import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';

class BedAllocationResult {
  final FloorData floor;
  final Room room;
  final BedInfo bed;

  BedAllocationResult({required this.floor, required this.room, required this.bed});
}

class BedAllocationService {
  /// Allocates the optimal bed based on:
  /// 1. sharingType (e.g. "1Sharing", "2Sharing", etc.)
  /// 2. roomType (AC vs Non-AC)
  /// 3. Packing rooms: prioritizes rooms that already have occupants but aren't full.
  /// 4. Packing floors: prioritizes lower floors (or sequentially fills them).
  static BedAllocationResult? allocateOptimalBed({
    required Occupancy occupancy,
    required String targetSharingType,
    required String targetRoomType,
  }) {
    final List<BedAllocationResult> candidates = [];

    // Flatten and filter matching beds
    for (final floor in occupancy.floors) {
      for (final room in floor.rooms) {
        final isSharingMatch = room.sharingType.toLowerCase().replaceAll(' ', '') == 
                               targetSharingType.toLowerCase().replaceAll(' ', '');
        final isAcMatch = (room.roomType ?? '').toLowerCase().replaceAll('-', '') == 
                          targetRoomType.toLowerCase().replaceAll('-', '');
        
        if (isSharingMatch && isAcMatch) {
          final freeBeds = room.beds.where((b) => b.status.toUpperCase() == 'FREE').toList();
          if (freeBeds.isNotEmpty) {
            // Sort beds alphabetically
            freeBeds.sort((a, b) => a.bedNumber.compareTo(b.bedNumber));
            candidates.add(BedAllocationResult(floor: floor, room: room, bed: freeBeds.first));
          }
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Sort candidates to enforce packing rules
    candidates.sort((a, b) {
      // Rule A: Priority to rooms that are ALREADY partially occupied.
      final aOccupied = a.room.beds.where((bed) => 
        bed.status.toUpperCase() == 'OCCUPIED' || bed.status.toUpperCase() == 'RESERVED'
      ).length;
      final bOccupied = b.room.beds.where((bed) => 
        bed.status.toUpperCase() == 'OCCUPIED' || bed.status.toUpperCase() == 'RESERVED'
      ).length;
      
      final aRatio = a.room.beds.isEmpty ? 0.0 : aOccupied / a.room.beds.length;
      final bRatio = b.room.beds.isEmpty ? 0.0 : bOccupied / b.room.beds.length;

      // Higher ratio means more full. We want to fill the most-full room first.
      if (bRatio.compareTo(aRatio) != 0) {
        return bRatio.compareTo(aRatio); // Descending order
      }

      // Rule B: Sequential Floor Packing. E.g. fill basement -> ground -> 1 -> 2
      final aFloorNum = a.floor.floorNum ?? 999;
      final bFloorNum = b.floor.floorNum ?? 999;
      if (aFloorNum.compareTo(bFloorNum) != 0) {
        return aFloorNum.compareTo(bFloorNum); // Ascending order
      }

      // Rule C: Sort by room number deterministically
      return a.room.roomNumber.compareTo(b.room.roomNumber);
    });

    return candidates.first;
  }
}
