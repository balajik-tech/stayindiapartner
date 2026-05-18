import 'package:stayindia_owner/features/profile/domain/entities/hostel_settings.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/settings_repository.dart';

class GetHostelSettingsUseCase {
  final SettingsRepository repository;
  GetHostelSettingsUseCase(this.repository);

  Future<HostelSettings> call(String hostelId) {
    return repository.getSettings(hostelId);
  }
}

class UpdateHostelProfileUseCase {
  final SettingsRepository repository;
  UpdateHostelProfileUseCase(this.repository);

  Future<void> call(String hostelId, Map<String, dynamic> data) {
    return repository.updateProfile(hostelId, data);
  }
}

class UpdateHostelAmenitiesUseCase {
  final SettingsRepository repository;
  UpdateHostelAmenitiesUseCase(this.repository);

  Future<void> call(String hostelId, List<String> enabledAmenities) {
    return repository.updateAmenities(hostelId, enabledAmenities);
  }
}

class UpdateHostelHouseRulesUseCase {
  final SettingsRepository repository;
  UpdateHostelHouseRulesUseCase(this.repository);

  Future<void> call(String hostelId, Map<String, dynamic> data) {
    return repository.updateHouseRules(hostelId, data);
  }
}

class UpdateHostelNotificationsUseCase {
  final SettingsRepository repository;
  UpdateHostelNotificationsUseCase(this.repository);

  Future<void> call(String hostelId, Map<String, dynamic> data) {
    return repository.updateNotifications(hostelId, data);
  }
}

class UpdateHostelRoomConfigUseCase {
  final SettingsRepository repository;
  UpdateHostelRoomConfigUseCase(this.repository);

  Future<void> call(String hostelId, Map<String, dynamic> data) {
    return repository.updateRoomConfiguration(hostelId, data);
  }
}

class UploadHostelSettingsImagesUseCase {
  final SettingsRepository repository;
  UploadHostelSettingsImagesUseCase(this.repository);

  Future<void> call(String hostelId, List<String> filePaths) {
    return repository.uploadHostelImages(hostelId, filePaths);
  }
}

class UploadSingleImageUseCase {
  final SettingsRepository repository;
  UploadSingleImageUseCase(this.repository);

  Future<String> call(String filePath) {
    return repository.uploadSingleImage(filePath);
  }
}
