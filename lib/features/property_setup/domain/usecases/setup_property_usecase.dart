import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/property_setup/domain/repositories/property_setup_repository.dart';

class SetupPropertyUseCase {
  final PropertySetupRepository repository;

  SetupPropertyUseCase(this.repository);

  Future<Hostel> execute({
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
  }) {
    return repository.setupCompleteProperty(
      hostelId: hostelId,
      name: name,
      address: address,
      floors: floors,
      amenities: amenities,
      rooms: rooms,
      masterPricing: masterPricing,
      lat: lat,
      lng: lng,
      area: area,
      city: city,
      state: state,
      hostelType: hostelType,
      images: images,
      foodLicense: foodLicense,
      hostelLicense: hostelLicense,
      tradeLicense: tradeLicense,
    );
  }
}
