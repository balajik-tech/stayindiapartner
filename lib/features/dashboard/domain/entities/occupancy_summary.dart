class Occupancy {
  final int totalBeds;
  final int freeBeds;
  final int occupiedBeds;
  final int noticeBeds;
  final int awayBeds;
  final int reservedBeds;
  final int overdueBeds;
  final List<FloorData> floors;

  Occupancy({
    required this.totalBeds,
    required this.freeBeds,
    required this.occupiedBeds,
    required this.noticeBeds,
    required this.awayBeds,
    required this.reservedBeds,
    required this.overdueBeds,
    required this.floors,
  });
}

class FloorData {
  final String floorName;
  final String bedInfo; 
  final List<Room> rooms;

  FloorData({
    required this.floorName,
    required this.bedInfo,
    required this.rooms,
  });
}

class Room {
  final String id;
  final String roomNumber;
  final String sharingType;
  final String? roomType;
  final String occupancy; 
  final List<String> tenantImages;
  final List<BedInfo> beds;
  final double? rent;
  final double? dailyRent;
  final double? maintenance;
  final List<String> features;
  final String? floorName;

  Room({
    required this.id,
    required this.roomNumber,
    required this.sharingType,
    this.roomType,
    required this.occupancy,
    required this.tenantImages,
    required this.beds,
    this.rent,
    this.dailyRent,
    this.maintenance,
    this.features = const [],
    this.floorName,
  });
}

class BedInfo {
  final String bedNumber;
  final String status; 
  final String? tenantName;
  final String? tenantAvatar;
  final String? tenantId;
  final bool isAway;

  BedInfo({
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.tenantAvatar,
    this.tenantId,
    this.isAway = false,
  });
}
