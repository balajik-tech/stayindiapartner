import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel_settings.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/settings_usecases.dart';
import 'package:stayindia_owner/core/utils/image_utils.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final HostelSettings settings;
  const SettingsLoaded({required this.settings});
  @override
  List<Object?> get props => [settings];
}

class SettingsSaving extends SettingsState {
  const SettingsSaving();
}

class SettingsSaveSuccess extends SettingsState {
  final String message;
  const SettingsSaveSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SettingsCubit extends Cubit<SettingsState> {
  final GetHostelSettingsUseCase _getSettings;
  final UpdateHostelProfileUseCase _updateProfile;
  final UpdateHostelAmenitiesUseCase _updateAmenities;
  final UpdateHostelHouseRulesUseCase _updateHouseRules;
  final UpdateHostelNotificationsUseCase _updateNotifications;
  final UpdateHostelRoomConfigUseCase _updateRoomConfig;
  final UploadHostelSettingsImagesUseCase _uploadImages;
  final UploadSingleImageUseCase _uploadSingleImage;

  SettingsCubit({
    required GetHostelSettingsUseCase getHostelSettingsUseCase,
    required UpdateHostelProfileUseCase updateHostelProfileUseCase,
    required UpdateHostelAmenitiesUseCase updateHostelAmenitiesUseCase,
    required UpdateHostelHouseRulesUseCase updateHostelHouseRulesUseCase,
    required UpdateHostelNotificationsUseCase updateHostelNotificationsUseCase,
    required UpdateHostelRoomConfigUseCase updateHostelRoomConfigUseCase,
    required UploadHostelSettingsImagesUseCase
    uploadHostelSettingsImagesUseCase,
    required UploadSingleImageUseCase uploadSingleImageUseCase,
  }) : _getSettings = getHostelSettingsUseCase,
       _updateProfile = updateHostelProfileUseCase,
       _updateAmenities = updateHostelAmenitiesUseCase,
       _updateHouseRules = updateHostelHouseRulesUseCase,
       _updateNotifications = updateHostelNotificationsUseCase,
       _updateRoomConfig = updateHostelRoomConfigUseCase,
       _uploadImages = uploadHostelSettingsImagesUseCase,
       _uploadSingleImage = uploadSingleImageUseCase,
       super(SettingsInitial());

  Future<void> loadSettings(String hostelId) async {
    emit(SettingsLoading());
    try {
      final settings = await _getSettings(hostelId);
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateProfile(
    String hostelId, {
    required String name,
    required String address,
    required String city,
    required String village,
    required String district,
    required String area,
    required String state,
    required String pincode,
    required String contactNumber,
    required String contactEmail,
    required String description,
    String? propertyTag,
    String? hostelType,
    double? lat,
    double? lng,
  }) async {
    emit(SettingsSaving());
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'address': address,
        'city': city,
        'village': village,
        'district': district,
        'area': area,
        'state': state,
        'pincode': pincode,
        'contactNumber': contactNumber,
        'contactEmail': contactEmail,
        'description': description,
      };
      if (propertyTag != null) data['propertyTag'] = propertyTag;
      if (hostelType != null) data['hostel_type'] = hostelType;
      if (lat != null && lng != null) {
        data['location'] = {
          'type': 'Point',
          'coordinates': [lng, lat],
        };
      }
      await _updateProfile(hostelId, data);
      emit(SettingsSaveSuccess(message: 'Profile updated successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateAmenities(
    String hostelId,
    List<String> enabledAmenities,
  ) async {
    emit(SettingsSaving());
    try {
      await _updateAmenities(hostelId, enabledAmenities);
      emit(SettingsSaveSuccess(message: 'Amenities updated successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateHouseRules(
    String hostelId, {
    required String entryTime,
    required String visitorPolicy,
    required String otherRules,
    required int penaltyDate,
    required List<CustomRule> customRules,
  }) async {
    emit(SettingsSaving());
    try {
      final List<Map<String, dynamic>> customRulesData = customRules
          .map((e) => {'text': e.text, 'photo': e.photo})
          .toList();

      await _updateHouseRules(hostelId, {
        'entryTime': entryTime,
        'visitorPolicy': visitorPolicy,
        'otherRules': otherRules,
        'penaltyDate': penaltyDate,
        'customRules': customRulesData,
      });
      emit(SettingsSaveSuccess(message: 'House rules saved successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateNotifications(
    String hostelId,
    Map<String, dynamic> data,
  ) async {
    emit(SettingsSaving());
    try {
      await _updateNotifications(hostelId, data);
      emit(SettingsSaveSuccess(message: 'Notification settings saved'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateRoomConfiguration(
    String hostelId,
    Map<String, dynamic> data,
  ) async {
    emit(SettingsSaving());
    try {
      await _updateRoomConfig(hostelId, data);
      emit(SettingsSaveSuccess(message: 'Room configuration saved'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateFullProfile(
    String hostelId, {
    required String name,
    required String address,
    required String city,
    required String village,
    required String district,
    required String area,
    required String state,
    required String pincode,
    required String contactNumber,
    required String contactEmail,
    required String description,
    String? propertyTag,
    String? hostelType,
    double? lat,
    double? lng,
    List<String>? newImagePaths,
    List<String>? existingImages,
  }) async {
    emit(SettingsSaving());
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'address': address,
        'city': city,
        'village': village,
        'district': district,
        'area': area,
        'state': state,
        'pincode': pincode,
        'contactNumber': contactNumber,
        'contactEmail': contactEmail,
        'description': description,
      };
      if (propertyTag != null) data['propertyTag'] = propertyTag;
      if (hostelType != null) data['hostel_type'] = hostelType;
      if (existingImages != null) data['images'] = existingImages;
      if (lat != null && lng != null) {
        data['location'] = {
          'type': 'Point',
          'coordinates': [lng, lat],
        };
      }

      await _updateProfile(hostelId, data);

      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        final compressedPaths = await ImageUtils.compressImages(newImagePaths);
        await _uploadImages(hostelId, compressedPaths);
      }

      emit(
        SettingsSaveSuccess(message: 'Profile and images updated successfully'),
      );
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> uploadHostelImages(
    String hostelId,
    List<String> filePaths,
  ) async {
    emit(SettingsSaving());
    try {
      final compressedPaths = await ImageUtils.compressImages(filePaths);
      await _uploadImages(hostelId, compressedPaths);
      emit(SettingsSaveSuccess(message: 'Images uploaded successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<String> uploadImage(String filePath) async {
    try {
      return await _uploadSingleImage(filePath);
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
