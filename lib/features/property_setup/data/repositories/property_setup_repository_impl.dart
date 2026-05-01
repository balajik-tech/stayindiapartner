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
    required String hostelType,
    required List<String> images,
    String? foodLicense,
    String? hostelLicense,
    String? tradeLicense,
  }) async {
    // Map UI labels to backend values
    String normalizedHostelType = hostelType.toLowerCase();
    if (hostelType == 'Boys') {
      normalizedHostelType = 'men';
    } else if (hostelType == 'Girls') {
      normalizedHostelType = 'women';
    } else if (hostelType == 'Co-Living' || hostelType == 'Co-ed') {
      normalizedHostelType = 'co-ed';
    }

    HostelModel createdHostel;

    if (hostelId != null && hostelId.isNotEmpty) {
      final hostelModel = HostelModel(
        id: hostelId,
        name: name,
        address: address,
        floors: floors,
        hostelType: normalizedHostelType,
        lat: lat,
        lng: lng,
        area: area,
        city: city,
        state: state,
      );
      createdHostel = await hostelRemoteDataSource.updateHostel(hostelModel);
    } else {
      final hostelModel = HostelModel(
        id: '',
        name: name,
        address: address,
        floors: floors,
        hostelType: normalizedHostelType,
        lat: lat,
        lng: lng,
        area: area,
        city: city,
        state: state,
      );

      createdHostel = await hostelRemoteDataSource.createHostel(hostelModel);
    }

    if (images.isNotEmpty) {
      final localPaths = images.where((path) => !path.startsWith('http')).toList();
      if (localPaths.isNotEmpty) {
        createdHostel = await hostelRemoteDataSource.uploadHostelImages(createdHostel.id, localPaths);
      }
    }

    if (foodLicense != null || hostelLicense != null || tradeLicense != null) {
      createdHostel = await hostelRemoteDataSource.uploadHostelLicenses(
        createdHostel.id,
        foodLicense: foodLicense,
        hostelLicense: hostelLicense,
        tradeLicense: tradeLicense,
      );
    }

    final List<RoomDetailModel> roomModels = [];
    
    for (var roomData in rooms) {
      final features = roomData['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] == true;
      
      // FIX 1: Room Type source of truth is features['isAC']
      // Ignore stale roomData['roomType']
      String type = isAC ? 'AC' : 'Non-AC';
      
      // FIX 2: Normalize sharingType as String for consistent lookup
      final sharing = (roomData['sharingType'] ?? 2).toString();
      
      // FIX 4: Safe pricing lookup with fallback and logging
      final typePricing = masterPricing[type] as Map<String, dynamic>? ?? {};
      final config = (typePricing[sharing] ?? typePricing[int.tryParse(sharing)?.toString()] ?? typePricing[int.tryParse(sharing)]) as Map<String, dynamic>?;
      
      if (config == null) {
        print("ERROR: Missing pricing for type=$type sharing=$sharing");
      }

      final rent = (config?['rent'] ?? 0.0).toDouble();
      final deposit = (config?['deposit'] ?? 0.0).toDouble();
      final maintenance = (config?['maintenance'] ?? 0.0).toDouble();
      final dailyRent = (config?['dailyRent'] ?? 0.0).toDouble();
      
      // TEMP DEBUG LOGGING
      print("FINAL_SAVE:");
      print("Room: ${roomData['roomNumber']}");
      print("Type: $type");
      print("Sharing: $sharing");
      print("Pricing: $config");

      // Handle floor logic correctly for G, 1, 2, etc.
      int floorNum = 1;
      final roomNo = roomData['roomNumber']?.toString() ?? '';
      if (roomNo.startsWith('G') || roomNo.startsWith('0')) {
        floorNum = 0;
      } else {
        floorNum = int.tryParse(roomNo.substring(0, 1)) ?? 1;
      }

      roomModels.add(RoomDetailModel(
        id: '',
        hostelId: createdHostel.id,
        roomTypename: 'Room $roomNo',
        floor: floorNum,
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
        dailyRent: dailyRent,
        isActive: true,
        isMaster: false,
        capacity: int.tryParse(sharing) ?? 2,
        beds: (roomData['beds'] as List? ?? []).map((b) => BedInfo(
          bedNumber: b['bedNumber']?.toString() ?? '',
          status: 'FREE',
        )).toList(),
      ));
    }

    if (roomModels.isNotEmpty) {
      // FIX 5: Use bulkUpsertRooms to avoid duplicates
      await roomRemoteDataSource.bulkUpsertRooms(roomModels, ownerId);
    }

    return createdHostel;
  }
}
