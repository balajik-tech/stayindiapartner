import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

abstract class PropertySetupRepository {
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
  });
}
