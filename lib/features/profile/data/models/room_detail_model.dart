import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';

class RoomDetailModel extends RoomDetail {
  RoomDetailModel({
    required super.id,
    required super.hostelId,
    required super.roomTypename,
    required super.floor,
    super.floors = const [],
    required super.sharingType,
    required super.roomType,
    required super.rent,
    super.dailyRent = 0,
    required super.deposit,
    required super.maintenance,
    required super.isActive,
    required super.isMaster,
    required super.capacity,
    required super.beds,
  });

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) {
    final bedsJson = json['beds'] as List<dynamic>? ?? [];
    return RoomDetailModel(
      id: json['_id'] ?? json['roomId'] ?? '',
      hostelId: json['hostel'] is Map ? json['hostel']['_id'] ?? '' : json['hostel'] ?? '',
      roomTypename: json['roomTypename'] ?? '',
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      floors: json['floors'] is List
          ? (json['floors'] as List).map((e) => (e as num).toInt()).toList()
          : [],
      sharingType: json['sharingType'] ?? '',
      roomType: json['roomType'] ?? '',
      rent: (json['rent'] as num?)?.toDouble() ?? 0,
      dailyRent: (json['dailyRent'] as num? ?? json['daily_rent'] as num?)?.toDouble() ?? 0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      maintenance: (json['maintenance'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] ?? true,
      isMaster: json['isMaster'] ?? false,
      capacity: (json['capacity'] as num?)?.toInt() ?? _inferCapacity(json['sharingType'] ?? ''),
      beds: bedsJson.map((b) => BedInfo(
        bedNumber: b['bedNumber']?.toString() ?? '',
        status: b['status'] ?? 'FREE',
      )).toList(),
    );
  }

  static int _inferCapacity(String sharingType) {
    switch (sharingType.toUpperCase()) {
      case 'SINGLE': return 1;
      case 'DOUBLE': return 2;
      case 'TRIPLE': return 3;
      case 'QUADRUPLE': return 4;
      case 'QUINTUPLE': return 5;
      default: return 1;
    }
  }

  Map<String, dynamic> toCreateJson(String ownerId) {
    assert(hostelId.isNotEmpty, 'toCreateJson: hostelId must not be empty!');
    assert(ownerId.isNotEmpty, 'toCreateJson: ownerId must not be empty!');
    
    return {
      'hostelId': hostelId,
      'roomTypename': roomTypename,
      'floor': floor,
      'floors': floors,
      'sharingType': sharingType,
      'roomType': roomType,
      'rent': rent,
      'dailyRent': dailyRent,
      'deposit': deposit,
      'maintenance': maintenance,
      'capacity': capacity,
      'isMaster': isMaster,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'roomTypename': roomTypename,
      'floor': floor,
      'floors': floors,
      'sharingType': sharingType,
      'roomType': roomType,
      'rent': rent,
      'dailyRent': dailyRent,
      'deposit': deposit,
      'maintenance': maintenance,
      'isActive': isActive,
      'isMaster': isMaster,
      'capacity': capacity,
    };
  }
}
