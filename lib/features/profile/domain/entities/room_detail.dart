class RoomDetail {
  final String id;
  final String hostelId;
  final String roomTypename;
  final int floor;
  final List<int> floors;
  final String sharingType;
  final String roomType;
  final double rent;
  final double dailyRent;
  final double deposit;
  final double maintenance;
  final bool isActive;
  final bool isMaster;
  final int capacity;
  final List<String> features;
  final List<BedInfo> beds;

  RoomDetail({
    required this.id,
    required this.hostelId,
    required this.roomTypename,
    required this.floor,
    this.floors = const [],
    required this.sharingType,
    required this.roomType,
    required this.rent,
    this.dailyRent = 0,
    required this.deposit,
    required this.maintenance,
    required this.isActive,
    required this.isMaster,
    required this.capacity,
    this.features = const [],
    this.beds = const [],
  });
}

class BedInfo {
  final String bedNumber;
  final String status;

  BedInfo({required this.bedNumber, required this.status});
}
