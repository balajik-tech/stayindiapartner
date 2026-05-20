import 'package:flutter_test/flutter_test.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/bed_allocation_service.dart';

void main() {
  group('BedAllocationService', () {
    test('allocates bed to partially filled room over empty room', () {
      final mockOccupancy = Occupancy(
        totalBeds: 4, freeBeds: 3, occupiedBeds: 1, noticeBeds: 0, awayBeds: 0, reservedBeds: 0, overdueBeds: 0, maintenanceBeds: 0,
        floors: [
          FloorData(
            floorName: 'Ground', floorNum: 0, bedInfo: '3 free',
            rooms: [
              Room(
                id: '1', roomNumber: 'G1', sharingType: '2 Sharing', roomType: 'AC', occupancy: '0/2',
                tenantImages: [], features: [],
                beds: [
                  BedInfo(bedNumber: 'A', status: 'FREE'),
                  BedInfo(bedNumber: 'B', status: 'FREE'),
                ]
              ),
              Room(
                id: '2', roomNumber: 'G2', sharingType: '2 Sharing', roomType: 'AC', occupancy: '1/2',
                tenantImages: [], features: [],
                beds: [
                  BedInfo(bedNumber: 'A', status: 'OCCUPIED', tenantName: 'Rahul'),
                  BedInfo(bedNumber: 'B', status: 'FREE'),
                ]
              )
            ]
          )
        ]
      );

      final result = BedAllocationService.allocateOptimalBed(
        occupancy: mockOccupancy,
        targetSharingType: '2 Sharing',
        targetRoomType: 'AC',
      );

      expect(result, isNotNull);
      expect(result!.room.roomNumber, equals('G2')); // Should pick partially filled room
      expect(result.bed.bedNumber, equals('B'));
    });
  });
}
