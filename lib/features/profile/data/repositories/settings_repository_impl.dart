import 'package:stayindia_owner/features/profile/domain/entities/hostel_settings.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HostelSettings> getSettings(String hostelId) {
    return remoteDataSource.getSettings(hostelId);
  }

  @override
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data) {
    return remoteDataSource.updateProfile(hostelId, data);
  }

  @override
  Future<void> updateAmenities(
      String hostelId, List<String> enabledAmenities) {
    return remoteDataSource.updateAmenities(hostelId, enabledAmenities);
  }

  @override
  Future<void> updateHouseRules(String hostelId, Map<String, dynamic> data) {
    return remoteDataSource.updateHouseRules(hostelId, data);
  }

  @override
  Future<void> updateNotifications(
      String hostelId, Map<String, dynamic> data) {
    return remoteDataSource.updateNotifications(hostelId, data);
  }

  @override
  Future<void> updateRoomConfiguration(
      String hostelId, Map<String, dynamic> data) {
    return remoteDataSource.updateRoomConfiguration(hostelId, data);
  }

  @override
  Future<void> uploadHostelImages(String hostelId, List<String> filePaths) {
    return remoteDataSource.uploadHostelImages(hostelId, filePaths);
  }
}
