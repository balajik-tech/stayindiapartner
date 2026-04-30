import 'package:stayindia_owner/features/profile/data/datasources/hostel_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/datasources/room_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/models/hostel_model.dart';
import 'package:stayindia_owner/features/profile/data/models/room_detail_model.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/property_setup/domain/repositories/property_setup_repository.dart';

class PropertySetupRepositoryImpl implements PropertySetupRepository {
  final HostelRemoteDataSource hostelRemoteDataSource;
  final RoomRemoteDataSource roomRemoteDataSource;
  final String ownerId;

  PropertySetupRepositoryImpl({
    required this.hostelRemoteDataSource,
    required this.roomRemoteDataSource,
    required this.ownerId,
  });

  @override
  Future<Hostel> setupCompleteProperty({
    String? hostelId,
    required String name,
    required String address,
    required int floors,
    required List<String> amenities,
    required List<Map<String, dynamic>> rooms,
    required Map<String, dynamic> masterPricing,
    double? lat,
    double? lng,
    required String area,
    required String city,
    required String state,
  }) async {
    Hostel createdHostel;

    if (hostelId != null && hostelId.isNotEmpty) {
      
      createdHostel = Hostel(
        id: hostelId,
        name: name,
        address: address,
        floors: floors,
        hostelType: 'co-ed', 
        lat: lat,
        lng: lng,
        area: area,
        city: city,
        state: state,
      );
    } else {
      
      final hostelModel = HostelModel(
        id: '',
        name: name,
        address: address,
        floors: floors,
        hostelType: 'co-ed', 
        lat: lat,
        lng: lng,
        area: area,
        city: city,
        state: state,
      );

      createdHostel = await hostelRemoteDataSource.createHostel(hostelModel);
    }

    
    for (var roomData in rooms) {
      final sharing = roomData['sharingType'].toString();
      
      final type = roomData['roomType'] ?? 'Non-AC';
      final config = masterPricing[type]?[sharing] ?? {};
      
      final rent = (config['rent'] ?? 0.0).toDouble();
      final deposit = (config['deposit'] ?? 0.0).toDouble();
      final maintenance = (config['maintenance'] ?? 0.0).toDouble();
      
      final roomModel = RoomDetailModel(
        id: '',
        hostelId: createdHostel.id,
        roomTypename: 'Room ${roomData['roomNumber']}',
        floor: int.tryParse(roomData['roomNumber'].toString().substring(0, 1)) ?? 1,
        sharingType: sharing == '1'
            ? 'SINGLE'
            : sharing == '2'
                ? 'DOUBLE'
                : sharing == '3'
                    ? 'TRIPLE'
                    : sharing == '4'
                        ? 'QUADRUPLE'
                        : sharing == '5'
                            ? 'QUINTUPLE'
                            : 'DORMITORY',
        roomType: type.toUpperCase(),
        rent: rent,
        deposit: deposit,
        maintenance: maintenance,
        isActive: true,
        isMaster: false,
        capacity: int.parse(sharing),
        beds: (roomData['beds'] as List).map((b) => BedInfo(
          bedNumber: b['bedNumber'],
          status: 'FREE',
        )).toList(),
      );

      await roomRemoteDataSource.createRoom(roomModel, ownerId);
    }

    return createdHostel;
  }
}
