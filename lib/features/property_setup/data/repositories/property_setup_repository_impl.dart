import 'package:stayindia_owner/features/profile/data/datasources/hostel_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/datasources/room_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/models/hostel_model.dart';
import 'package:stayindia_owner/features/profile/data/models/room_detail_model.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/property_setup/domain/repositories/property_setup_repository.dart';
import 'package:stayindia_owner/core/utils/logger.dart';

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
    List<Map<String, dynamic>>? roomCategories,
    required Map<String, dynamic> masterPricing,
    double? lat,
    double? lng,
    required String area,
    required String city,
    required String state,
    required String hostelType,
    required List<String> images,
    String? pincode,
    String? contactNumber,
    String? contactEmail,
    String? description,
    String? propertyTag,
    String? district,
    String? village,
    String? foodLicense,
    String? hostelLicense,
    String? tradeLicense,
    String? fireSafety,
    String? policeNoc,
    String? shopsEstablishment,
    String? gstRegistration,
    String? healthSanitation,
    String? utilityBill,
    String? pollutionNoc,
    String? residentVerification,
  }) async {
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
        pincode: pincode,
        contactNumber: contactNumber,
        description: description,
        propertyTag: propertyTag,
        district: district,
        village: village,
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
        pincode: pincode,
        contactNumber: contactNumber,
        description: description,
        propertyTag: propertyTag,
        district: district,
        village: village,
      );

      createdHostel = await hostelRemoteDataSource.createHostel(hostelModel);
    }

    if (images.isNotEmpty) {
      final localPaths = images.where((path) => !path.startsWith('http')).toList();
      if (localPaths.isNotEmpty) {
        createdHostel = await hostelRemoteDataSource.uploadHostelImages(createdHostel.id, localPaths);
      }
    }

    if (foodLicense != null ||
        hostelLicense != null ||
        tradeLicense != null ||
        fireSafety != null ||
        policeNoc != null ||
        shopsEstablishment != null ||
        gstRegistration != null ||
        healthSanitation != null ||
        utilityBill != null ||
        pollutionNoc != null ||
        residentVerification != null) {
      createdHostel = await hostelRemoteDataSource.uploadHostelLicenses(
        createdHostel.id,
        foodLicense: foodLicense,
        hostelLicense: hostelLicense,
        tradeLicense: tradeLicense,
        fireSafety: fireSafety,
        policeNoc: policeNoc,
        shopsEstablishment: shopsEstablishment,
        gstRegistration: gstRegistration,
        healthSanitation: healthSanitation,
        utilityBill: utilityBill,
        pollutionNoc: pollutionNoc,
        residentVerification: residentVerification,
      );
    }

    final List<RoomDetailModel> roomModels = [];
    
    for (var roomData in rooms) {
      final features = roomData['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] == true;
      
      String type = isAC ? 'AC' : 'NON-AC';
      
      final sharing = (roomData['sharingType'] ?? 2).toString();
      
      final typePricing = masterPricing[type] as Map<String, dynamic>? ?? {};
      final config = typePricing[sharing] as Map<String, dynamic>?;
      
      if (config == null) {
        AppLogger.error("Missing pricing for type=$type sharing=$sharing");
      }

      final rent = ((double.tryParse(roomData['rent']?.toString() ?? '0') ?? 0.0) > 0)
          ? (double.tryParse(roomData['rent']?.toString() ?? '0') ?? 0.0)
          : (config?['rent'] ?? 0.0).toDouble();

      final deposit = ((double.tryParse(roomData['deposit']?.toString() ?? '0') ?? 0.0) > 0)
          ? (double.tryParse(roomData['deposit']?.toString() ?? '0') ?? 0.0)
          : (config?['deposit'] ?? 0.0).toDouble();

      final maintenance = ((double.tryParse(roomData['maintenance']?.toString() ?? '0') ?? 0.0) > 0)
          ? (double.tryParse(roomData['maintenance']?.toString() ?? '0') ?? 0.0)
          : (config?['maintenance'] ?? 0.0).toDouble();

      final dailyRent = ((double.tryParse(roomData['dailyRent']?.toString() ?? '0') ?? 0.0) > 0)
          ? (double.tryParse(roomData['dailyRent']?.toString() ?? '0') ?? 0.0)
          : (config?['dailyRent'] ?? 0.0).toDouble();
      
      AppLogger.debug("FINAL_SAVE:\nRoom: ${roomData['roomNumber']}\nType: $type\nSharing: $sharing\nPricing: $config");

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

    if (roomCategories != null) {
      for (var cat in roomCategories) {
        final isAC = cat['isAC'] == true;
        final sharing = (cat['sharingType'] ?? 2).toString();
        final rent = double.tryParse(cat['monthlyRent']?.toString() ?? '0') ?? 0.0;
        final deposit = double.tryParse(cat['securityDeposit']?.toString() ?? '0') ?? 0.0;
        final maintenance = double.tryParse(cat['maintenance']?.toString() ?? '0') ?? 0.0;
        final dailyRent = double.tryParse(cat['dailyRent']?.toString() ?? '0') ?? 0.0;

        roomModels.add(RoomDetailModel(
          id: '',
          hostelId: createdHostel.id,
          roomTypename: cat['name']?.toString().isNotEmpty == true ? cat['name'].toString() : '$sharing Sharing ${isAC ? "AC" : "NON-AC"}',
          floor: 0,
          sharingType: sharing == '1' ? 'SINGLE' : sharing == '2' ? 'DOUBLE' : sharing == '3' ? 'TRIPLE' : sharing == '4' ? 'QUADRUPLE' : sharing == '5' ? 'QUINTUPLE' : 'DORMITORY',
          roomType: isAC ? 'AC' : 'NON-AC',
          rent: rent,
          deposit: deposit,
          maintenance: maintenance,
          dailyRent: dailyRent,
          isActive: true,
          isMaster: true,
          capacity: int.tryParse(sharing) ?? 2,
          beds: [],
        ));
      }
    }

    if (roomModels.isNotEmpty) {
      await roomRemoteDataSource.bulkUpsertRooms(roomModels, ownerId);
    }

    return createdHostel;
  }
}
