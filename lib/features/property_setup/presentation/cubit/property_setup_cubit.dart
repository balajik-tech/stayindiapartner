import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart' as cropper;
import '../../domain/usecases/setup_property_usecase.dart';
import 'property_setup_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/services/quality_checker_service.dart';

class PropertySetupCubit extends HydratedCubit<PropertySetupState> {
  final SetupPropertyUseCase setupPropertyUseCase;
  final ImagePicker _picker = ImagePicker();

  PropertySetupCubit(this.setupPropertyUseCase)
    : super(const PropertySetupState());

  void prefillFromHostel(Hostel hostel, {List<RoomDetail>? rooms}) {
    final List<Map<String, dynamic>> mappedRooms = [];
    if (rooms != null) {
      for (var room in rooms) {
        mappedRooms.add({
          'id': room.id,
          'roomNumber': room.roomTypename,
          'floor': room.floor.toString(),
          'sharingType': room.capacity,
          'roomType': room.roomType,
          'rent': room.rent,
          'deposit': room.deposit,
          'maintenance': room.maintenance,
          'dailyRent': room.dailyRent,
          'features': {
            'isAC': room.roomType == 'AC',
            'hasGeyser': room.features.contains('GEYSER'),
            'hasBalcony': room.features.contains('BALCONY'),
            'hasAttachedWashroom': room.features.contains('WASHROOM'),
          },
          'beds': room.beds
              .map((b) => {'bedNumber': b.bedNumber, 'status': b.status})
              .toList(),
        });
      }
    }

    emit(
      state.copyWith(
        hostelId: hostel.id,
        buildingName: hostel.name,
        address: hostel.address,
        lat: hostel.lat,
        lng: hostel.lng,
        city: hostel.city ?? '',
        state: hostel.state ?? '',
        pincode: hostel.pincode ?? '',
        area: hostel.area ?? '',
        hostelType: hostel.hostelType,
        gstNumber: '',
        selectedFloors: List.generate(
          hostel.floors,
          (i) => i == 0 ? 'G' : i.toString(),
        ),
        rooms: rooms != null ? mappedRooms : state.rooms,
        roomCategories: rooms != null ? const [] : state.roomCategories,
        currentStep: rooms != null ? 3 : 0,
      ),
    );
    syncRoomCategories();
  }

  void updateGstNumber(String gst) {
    emit(state.copyWith(gstNumber: gst));
  }

  void nextStep() {
    final int targetStep = state.currentStep + 1;

    if (state.currentStep == 1) {
      if (state.roomCategories.isEmpty) {
        addRoomCategory();
      }

      final List<Map<String, dynamic>> updatedCategories =
          List<Map<String, dynamic>>.from(
            state.roomCategories.map((c) {
              final cat = Map<String, dynamic>.from(c);
              final String rent = cat['monthlyRent']?.toString().trim() ?? '';
              cat['monthlyRentLocked'] =
                  rent.isNotEmpty && rent != '0' && rent != '0.0';

              final String deposit =
                  cat['securityDeposit']?.toString().trim() ?? '';
              cat['securityDepositLocked'] =
                  deposit.isNotEmpty && deposit != '0' && deposit != '0.0';

              final String daily = cat['dailyRent']?.toString().trim() ?? '';
              cat['dailyRentLocked'] =
                  daily.isNotEmpty && daily != '0' && daily != '0.0';

              final String maint = cat['maintenance']?.toString().trim() ?? '';
              cat['maintenanceLocked'] =
                  maint.isNotEmpty && maint != '0' && maint != '0.0';

              return cat;
            }),
          );

      if (state.currentStep < 5) {
        emit(
          state.copyWith(
            roomCategories: updatedCategories,
            currentStep: targetStep,
          ),
        );
      } else {
        emit(state.copyWith(roomCategories: updatedCategories));
      }
      return;
    }

    if (state.currentStep == 2) {
      autoGenerateRooms();
      syncPricingFromCategories();
    }

    if (state.currentStep == 3) {
      syncRoomCategoriesAndPricing();
    }

    if (state.currentStep < 5) {
      emit(state.copyWith(currentStep: targetStep));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      final int targetStep = state.currentStep - 1;

      if (state.currentStep == 4 || state.currentStep == 3) {
        syncRoomCategoriesAndPricing();
      }

      emit(state.copyWith(currentStep: targetStep));
    }
  }

  void setStep(int step) {
    emit(state.copyWith(currentStep: step));
  }

  void updateBuildingName(String name) {
    emit(state.copyWith(buildingName: name));
  }

  void updateHostelType(String type) {
    emit(state.copyWith(hostelType: type));
  }

  void updateLocation(String address, double? lat, double? lng) {
    emit(state.copyWith(address: address, lat: lat, lng: lng));
  }

  void updateDetailedAddress(String address) {
    emit(state.copyWith(detailedAddress: address));
  }

  Future<void> updateCoordinates(double lat, double lng) async {
    emit(state.copyWith(lat: lat, lng: lng));
    await fetchAddressFromCoordinates(lat, lng);
  }

  Future<void> fetchAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final detailedAddress = [
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality,
        ].join(', ');

        emit(
          state.copyWith(
            address: detailedAddress,
            detailedAddress: detailedAddress,
            area: place.subLocality ?? '',
            city: place.locality ?? '',
            state: place.administrativeArea ?? '',
            pincode: place.postalCode ?? '',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error fetching address: $e');
    }
  }

  void updateArea(String area) {
    emit(state.copyWith(area: area));
  }

  void updateCity(String city) {
    emit(state.copyWith(city: city));
  }

  void updateState(String stateName) {
    emit(state.copyWith(state: stateName));
  }

  void updatePincode(String pincode) {
    emit(state.copyWith(pincode: pincode));
  }

  Future<void> pickCategoryImage(
    String category, {
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final currentMap = Map<String, List<String>>.from(
        state.categorizedImages,
      );
      final currentImages = List<String>.from(currentMap[category] ?? []);
      if (currentImages.length >= 5) {
        emit(state.copyWith(error: 'Maximum 5 images allowed per category.'));
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        emit(state.copyWith(isSaving: true));
        final qualityError = await QualityCheckerService.checkImageQuality(
          pickedFile.path,
        );
        emit(state.copyWith(isSaving: false));

        if (qualityError != null) {
          emit(state.copyWith(error: qualityError));
          return;
        }

        final croppedPath = await _cropImage(pickedFile.path);
        if (croppedPath != null) {
          currentImages.add(croppedPath);
          currentMap[category] = currentImages;
          emit(state.copyWith(categorizedImages: currentMap, error: null));
        }
      }
    } catch (e) {
      AppLogger.error('Error picking category image: $e');
      emit(state.copyWith(isSaving: false));
    }
  }

  void removeCategoryImage(String category, int index) {
    final currentMap = Map<String, List<String>>.from(state.categorizedImages);
    final currentImages = List<String>.from(currentMap[category] ?? []);
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      currentMap[category] = currentImages;
      emit(state.copyWith(categorizedImages: currentMap));
    }
  }

  Future<void> cropImageAtIndex(int index) async {
    if (index < 0 || index >= state.images.length) return;

    final path = state.images[index];
    final croppedPath = await _cropImage(path);

    if (croppedPath != null) {
      final currentImages = List<String>.from(state.images);
      currentImages[index] = croppedPath;
      emit(state.copyWith(images: currentImages));
    }
  }

  Future<String?> _cropImage(String path) async {
    try {
      final croppedFile = await cropper.ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          cropper.AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF1E3A8A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: cropper.CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              cropper.CropAspectRatioPreset.square,
              cropper.CropAspectRatioPreset.ratio3x2,
              cropper.CropAspectRatioPreset.original,
              cropper.CropAspectRatioPreset.ratio4x3,
              cropper.CropAspectRatioPreset.ratio16x9,
            ],
          ),
          cropper.IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              cropper.CropAspectRatioPreset.square,
              cropper.CropAspectRatioPreset.ratio3x2,
              cropper.CropAspectRatioPreset.original,
              cropper.CropAspectRatioPreset.ratio4x3,
              cropper.CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return croppedFile?.path;
    } catch (e) {
      AppLogger.error('Error cropping image: $e');
      return null;
    }
  }

  void removeImage(int index) {
    final currentImages = List<String>.from(state.images);
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      emit(state.copyWith(images: currentImages));
    }
  }

  String? _getLicensePath(String type) {
    if (type == 'food') return state.foodLicense;
    if (type == 'hostel') return state.hostelLicense;
    if (type == 'trade') return state.tradeLicense;
    if (type == 'fire') return state.fireSafety;
    if (type == 'police') return state.policeNoc;
    if (type == 'shops') return state.shopsEstablishment;
    if (type == 'gst') return state.gstRegistration;
    if (type == 'health') return state.healthSanitation;
    if (type == 'utility') return state.utilityBill;
    if (type == 'pollution') return state.pollutionNoc;
    if (type == 'resident') return state.residentVerification;
    return null;
  }

  void _updateLicensePath(String type, String path) {
    if (type == 'food') emit(state.copyWith(foodLicense: path));
    if (type == 'hostel') emit(state.copyWith(hostelLicense: path));
    if (type == 'trade') emit(state.copyWith(tradeLicense: path));
    if (type == 'fire') emit(state.copyWith(fireSafety: path));
    if (type == 'police') emit(state.copyWith(policeNoc: path));
    if (type == 'shops') emit(state.copyWith(shopsEstablishment: path));
    if (type == 'gst') emit(state.copyWith(gstRegistration: path));
    if (type == 'health') emit(state.copyWith(healthSanitation: path));
    if (type == 'utility') emit(state.copyWith(utilityBill: path));
    if (type == 'pollution') emit(state.copyWith(pollutionNoc: path));
    if (type == 'resident') emit(state.copyWith(residentVerification: path));
  }

  void removeLicenseAtIndex(String type, int index) {
    final currentPath = _getLicensePath(type) ?? '';
    final List<String> files = currentPath
        .split(',')
        .where((f) => f.isNotEmpty)
        .toList();
    if (index >= 0 && index < files.length) {
      files.removeAt(index);
      _updateLicensePath(type, files.join(','));
    }
  }

  Future<void> pickLicense(String type) async {
    try {
      final currentPath = _getLicensePath(type) ?? '';
      final List<String> files = currentPath
          .split(',')
          .where((f) => f.isNotEmpty)
          .toList();
      if (files.length >= 5) {
        emit(state.copyWith(error: 'Maximum 5 files allowed per license.'));
        return;
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        final extension = path.split('.').last.toLowerCase();

        if (['jpg', 'jpeg', 'png'].contains(extension)) {
          final croppedPath = await _cropImage(path);
          if (croppedPath == null) return;
          path = croppedPath;
        }

        files.add(path);
        _updateLicensePath(type, files.join(','));
      }
    } catch (e) {
      AppLogger.error('Error picking license: $e');
    }
  }

  void removeLicense(String type) {
    _updateLicensePath(type, '');
  }

  void setTotalFloors(int count) {
    final hasB = state.selectedFloors.contains('B');
    final floors = List.generate(count, (i) => i == 0 ? 'G' : i.toString());
    if (hasB) {
      floors.insert(0, 'B');
    }
    emit(state.copyWith(selectedFloors: floors));
  }

  void toggleBasement(bool include) {
    final floors = List<String>.from(state.selectedFloors);
    final counts = Map<String, int>.from(state.floorRoomCounts);

    if (include) {
      if (!floors.contains('B')) {
        floors.insert(0, 'B');
        counts['B'] = counts['B'] ?? 0;
      }
    } else {
      floors.remove('B');
      counts.remove('B');
    }

    emit(state.copyWith(selectedFloors: floors, floorRoomCounts: counts));
  }

  void updateFloorRoomCount(String floor, int count) {
    final counts = Map<String, int>.from(state.floorRoomCounts);
    counts[floor] = count;
    emit(state.copyWith(floorRoomCounts: counts));
  }

  int get totalRooms {
    return state.floorRoomCounts.values.fold(0, (sum, count) => sum + count);
  }

  void updateAllFloorsRoomCount(int count) {
    final counts = {for (var f in state.selectedFloors) f: count};
    emit(state.copyWith(floorRoomCounts: counts));
  }

  void autoGenerateRooms() {
    final List<Map<String, dynamic>> newRooms = [];
    final existingRooms = {for (var r in state.rooms) r['roomNumber']: r};

    for (var floor in state.selectedFloors) {
      final roomCount = state.floorRoomCounts[floor] ?? 0;
      final floorPrefix = floor == 'G' ? 'G' : floor;

      for (int i = 1; i <= roomCount; i++) {
        final roomNumber = '$floorPrefix${i.toString().padLeft(2, '0')}';

        if (existingRooms.containsKey(roomNumber)) {
          newRooms.add(existingRooms[roomNumber]!);
          continue;
        }

        newRooms.add(_createNewRoom(roomNumber, floor, 2, 'NON-AC', 'Medium'));
      }
    }

    emit(state.copyWith(rooms: newRooms));
  }

  Map<String, dynamic> _createNewRoom(
    String roomNumber,
    String floor,
    int sharing,
    String type,
    String size,
  ) {
    final isAC = state.selectedAmenities.contains('ac');
    return {
      'roomNumber': roomNumber,
      'floor': floor,
      'sharingType': sharing,
      'roomType': isAC ? 'AC' : 'NON-AC',
      'roomSize': size,
      'features': {
        'isAC': isAC,
        'hasGeyser': state.selectedAmenities.contains('geyser'),
        'hasBalcony': state.selectedAmenities.contains('balcony'),
        'hasAttachedWashroom': state.selectedAmenities.contains('washroom'),
      },
      'beds': List.generate(
        sharing,
        (index) => {
          'bedNumber': String.fromCharCode(65 + index),
          'status': 'FREE',
        },
      ),
    };
  }

  void addFloorLocally({required String floorName, required int roomCount}) {
    final floors = List<String>.from(state.selectedFloors);
    if (!floors.contains(floorName)) {
      floors.add(floorName);
    }

    final counts = Map<String, int>.from(state.floorRoomCounts);
    counts[floorName] = roomCount;

    emit(state.copyWith(selectedFloors: floors, floorRoomCounts: counts));

    autoGenerateRooms();
  }

  void updateRoomFeature(int index, String feature, bool value) {
    final rooms = List<Map<String, dynamic>>.from(
      state.rooms.map((r) => Map<String, dynamic>.from(r)),
    );
    final room = Map<String, dynamic>.from(rooms[index]);
    final features = Map<String, dynamic>.from(room['features'] ?? {});

    features[feature] = value;

    if (feature == 'isAC') {
      room['roomType'] = value ? 'AC' : 'NON-AC';
    }

    room['features'] = features;

    _autoAssignCategory(room);

    rooms[index] = room;

    emit(state.copyWith(rooms: rooms));
    syncRoomCategoriesAndPricing();
  }

  void updateRoomSharing(int index, int sharing) {
    final rooms = List<Map<String, dynamic>>.from(
      state.rooms.map((r) => Map<String, dynamic>.from(r)),
    );
    final room = Map<String, dynamic>.from(rooms[index]);

    room['sharingType'] = sharing;
    room['beds'] = List.generate(
      sharing,
      (i) => {'bedNumber': String.fromCharCode(65 + i), 'status': 'FREE'},
    );

    _autoAssignCategory(room);

    rooms[index] = room;

    emit(state.copyWith(rooms: rooms));
    syncRoomCategoriesAndPricing();
  }

  void _autoAssignCategory(Map<String, dynamic> room) {
    final isAC = room['features']?['isAC'] == true;
    final sharing = room['sharingType'] ?? 2;

    final matches = state.roomCategories.where(
      (cat) => cat['sharingType'] == sharing && cat['isAC'] == isAC,
    );
    final Map<String, dynamic> matchingCategory = matches.isNotEmpty
        ? matches.first
        : <String, dynamic>{};

    if (matchingCategory.isNotEmpty) {
      room['categoryId'] = matchingCategory['id'];
      room['roomSize'] = matchingCategory['roomSize'];
    } else {
      room['categoryId'] = null;
    }
  }

  void cloneRoomSettings(int sourceIndex) {
    final currentRooms = state.rooms;
    if (sourceIndex < 0 || sourceIndex >= currentRooms.length) return;

    final sourceRoom = Map<String, dynamic>.from(currentRooms[sourceIndex]);
    final sourceFeatures = Map<String, dynamic>.from(
      sourceRoom['features'] ?? {},
    );
    final isAC = sourceFeatures['isAC'] == true;
    final sourceSharing = sourceRoom['sharingType'] ?? 2;

    final updatedRooms = currentRooms.map((room) {
      final newRoom = Map<String, dynamic>.from(room);

      newRoom['features'] = Map<String, dynamic>.from(sourceFeatures);
      newRoom['sharingType'] = sourceSharing;
      newRoom['roomType'] = isAC ? 'AC' : 'NON-AC';
      newRoom['beds'] = List.generate(
        sourceSharing,
        (idx) => {'bedNumber': String.fromCharCode(65 + idx), 'status': 'FREE'},
      );
      return newRoom;
    }).toList();

    emit(state.copyWith(rooms: updatedRooms));
  }

  void updatePricing(
    String roomType,
    String sharing,
    String field,
    double value,
  ) {
    final pricing = Map<String, dynamic>.from(state.masterPricing);
    final typeMap = Map<String, dynamic>.from(pricing[roomType] ?? {});
    final sharingMap = Map<String, dynamic>.from(
      typeMap[sharing] ??
          {
            'rent': 0.0,
            'monthlyRent': 0.0,
            'deposit': 0.0,
            'securityDeposit': 0.0,
            'maintenance': 0.0,
            'dailyRent': 0.0,
            'dailyRentThresholdDays': 5.0,
          },
    );

    sharingMap[field] = value;
    if (field == 'rent') {
      sharingMap['monthlyRent'] = value;
    } else if (field == 'monthlyRent') {
      sharingMap['rent'] = value;
    }
    if (field == 'deposit') {
      sharingMap['securityDeposit'] = value;
    } else if (field == 'securityDeposit') {
      sharingMap['deposit'] = value;
    }

    typeMap[sharing] = sharingMap;
    pricing[roomType] = typeMap;

    final isAC = roomType == 'AC';
    final sharingInt = int.tryParse(sharing) ?? 2;
    final List<Map<String, dynamic>> categories =
        List<Map<String, dynamic>>.from(
          state.roomCategories.map((c) => Map<String, dynamic>.from(c)),
        );
    final catIndex = categories.indexWhere(
      (c) => c['sharingType'] == sharingInt && c['isAC'] == isAC,
    );
    if (catIndex != -1) {
      final updatedCat = Map<String, dynamic>.from(categories[catIndex]);
      if (field == 'rent' || field == 'monthlyRent') {
        updatedCat['monthlyRent'] = value.toString();
      } else if (field == 'deposit' || field == 'securityDeposit') {
        updatedCat['securityDeposit'] = value.toString();
      } else if (field == 'dailyRent') {
        updatedCat['dailyRent'] = value.toString();
      } else if (field == 'maintenance') {
        updatedCat['maintenance'] = value.toString();
      } else if (field == 'dailyRentThresholdDays') {
        updatedCat['dailyRentThresholdDays'] = value.round().toString();
      }
      categories[catIndex] = updatedCat;
    }

    emit(state.copyWith(masterPricing: pricing, roomCategories: categories));
  }

  void applyPricingToAllRooms(String field, double value) {
    final pricing = Map<String, dynamic>.from(state.masterPricing);

    final roomTypes = ['AC', 'NON-AC'];
    final sharingTypes = {
      '1',
      '2',
      '3',
      '4',
      '5',
      ...state.roomCategories.map((c) => (c['sharingType'] ?? 2).toString()),
    }.toList();

    for (var type in roomTypes) {
      final typeMap = Map<String, dynamic>.from(pricing[type] ?? {});
      for (var sharing in sharingTypes) {
        final sharingMap = Map<String, dynamic>.from(
          typeMap[sharing] ??
              {
                'rent': 0.0,
                'monthlyRent': 0.0,
                'deposit': 0.0,
                'securityDeposit': 0.0,
                'maintenance': 0.0,
                'dailyRent': 0.0,
              },
        );

        final sharingInt = int.tryParse(sharing) ?? 2;
        final isAC = type == 'AC';
        final isFromRoomMaster = state.roomMasters.any(
          (m) => m['sharingType'] == sharingInt && m['isAC'] == isAC,
        );

        if (!isFromRoomMaster) {
          sharingMap[field] = value;
          if (field == 'rent') {
            sharingMap['monthlyRent'] = value;
          } else if (field == 'deposit') {
            sharingMap['securityDeposit'] = value;
          }
        }
        typeMap[sharing] = sharingMap;
      }
      pricing[type] = typeMap;
    }

    final updatedCategories = state.roomCategories.map((cat) {
      final newCat = Map<String, dynamic>.from(cat);
      final sharing = cat['sharingType'] ?? 2;
      final isAC = cat['isAC'] == true;
      final isFromRoomMaster = state.roomMasters.any(
        (m) => m['sharingType'] == sharing && m['isAC'] == isAC,
      );

      if (!isFromRoomMaster) {
        if (field == 'rent') newCat['monthlyRent'] = value.toString();
        if (field == 'deposit') newCat['securityDeposit'] = value.toString();
        if (field == 'maintenance') newCat['maintenance'] = value.toString();
        if (field == 'dailyRent') newCat['dailyRent'] = value.toString();
      }
      return newCat;
    }).toList();

    emit(
      state.copyWith(masterPricing: pricing, roomCategories: updatedCategories),
    );
  }

  bool get isStepValid {
    if (state.currentStep == 0) {
      return state.hostelType.isNotEmpty &&
          state.buildingName.trim().isNotEmpty &&
          state.lat != null &&
          state.lng != null &&
          state.detailedAddress.trim().isNotEmpty &&
          state.area.trim().isNotEmpty &&
          state.city.trim().isNotEmpty &&
          state.state.trim().isNotEmpty &&
          state.pincode.trim().isNotEmpty;
    }
    if (state.currentStep == 1) {
      if (state.roomCategories.isEmpty) return false;
      for (final cat in state.roomCategories) {
        final monthlyRent = cat['monthlyRent']?.toString().trim() ?? '';
        final securityDeposit = cat['securityDeposit']?.toString().trim() ?? '';
        final dailyRent = cat['dailyRent']?.toString().trim() ?? '';
        final maintenance = cat['maintenance']?.toString().trim() ?? '';

        if (monthlyRent.isEmpty ||
            securityDeposit.isEmpty ||
            dailyRent.isEmpty ||
            maintenance.isEmpty) {
          return false;
        }
      }
      return true;
    }
    if (state.currentStep == 2) {
      if (state.selectedFloors.isEmpty) return false;
      for (final floor in state.selectedFloors) {
        if ((state.floorRoomCounts[floor] ?? 0) <= 0) return false;
      }
      return true;
    }
    return true;
  }

  bool get isValidToFinish {
    if (state.buildingName.trim().isEmpty) {
      emit(state.copyWith(validationMessage: 'Please enter a property name'));
      return false;
    }
    if (state.address.trim().isEmpty) {
      emit(
        state.copyWith(validationMessage: 'Please enter the property address'),
      );
      return false;
    }
    if (state.lat == null || state.lng == null) {
      emit(
        state.copyWith(
          validationMessage: 'Please select the property location on map',
        ),
      );
      return false;
    }
    if (state.rooms.isEmpty) {
      emit(state.copyWith(validationMessage: 'Please add at least one room'));
      return false;
    }

    final List<String> missingPricing = [];
    for (int i = 0; i < state.roomCategories.length; i++) {
      final cat = state.roomCategories[i];
      final sharing = cat['sharingType'] ?? 2;
      final isAC = cat['isAC'] == true;
      final type = isAC ? 'AC' : 'NON-AC';

      final hasRooms = state.rooms.any((room) {
        final roomIsAC = (room['features'] as Map?)?['isAC'] == true;
        final roomSharing = room['sharingType'] ?? 2;
        return roomSharing == sharing && roomIsAC == isAC;
      });
      if (!hasRooms) continue;

      final label = 'Category ${i + 1} ($sharing Sharing - $type)';

      final monthlyRent = cat['monthlyRent']?.toString().trim() ?? '';
      final securityDeposit = cat['securityDeposit']?.toString().trim() ?? '';

      final List<String> missing = [];
      if (monthlyRent.isEmpty || (double.tryParse(monthlyRent) ?? 0) <= 0) {
        missing.add('Monthly Rent');
      }
      if (securityDeposit.isEmpty) {
        missing.add('Security Deposit');
      }

      if (missing.isNotEmpty) {
        missingPricing.add('$label: ${missing.join(", ")}');
      }
    }

    if (missingPricing.isNotEmpty) {
      emit(
        state.copyWith(
          validationMessage:
              'Missing pricing for:\n${missingPricing.join("\n")}',
        ),
      );
      return false;
    }

    emit(state.copyWith(validationMessage: null));
    return true;
  }

  Future<void> saveProperty() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, error: null));
    try {
      final roomsWithPricing = state.rooms.map((room) {
        final r = Map<String, dynamic>.from(room);
        final catId = r['categoryId'];
        final matches = state.roomCategories.where((c) => c['id'] == catId);
        Map<String, dynamic> cat = matches.isNotEmpty
            ? matches.first
            : <String, dynamic>{};

        if (cat.isEmpty && state.roomCategories.isNotEmpty) {
          final isAC = (r['features'] as Map?)?['isAC'] == true;
          final sharing = r['sharingType'] ?? 2;
          final matches2 = state.roomCategories.where(
            (c) => c['sharingType'] == sharing && c['isAC'] == isAC,
          );
          cat = matches2.isNotEmpty ? matches2.first : <String, dynamic>{};
          if (cat.isEmpty) {
            cat = state.roomCategories.first;
          }
        }

        final isAC = (r['features'] as Map?)?['isAC'] == true;
        final type = isAC ? 'AC' : 'NON-AC';
        final sharingStr = (r['sharingType'] ?? 2).toString();

        final pricing = state.masterPricing[type] ?? {};
        final config = pricing[sharingStr];

        double rent = 0.0;
        double deposit = 0.0;
        double maintenance = 0.0;
        double dailyRent = 0.0;

        if (config is Map) {
          rent =
              double.tryParse(
                config['rent']?.toString() ??
                    config['monthlyRent']?.toString() ??
                    '0',
              ) ??
              0.0;
          deposit =
              double.tryParse(
                config['deposit']?.toString() ??
                    config['securityDeposit']?.toString() ??
                    '0',
              ) ??
              0.0;
          maintenance =
              double.tryParse(config['maintenance']?.toString() ?? '0') ?? 0.0;
          dailyRent =
              double.tryParse(config['dailyRent']?.toString() ?? '0') ?? 0.0;
        }

        if (cat.isNotEmpty) {
          final catRent =
              double.tryParse(cat['monthlyRent']?.toString() ?? '0') ?? 0.0;
          if (catRent > 0) rent = catRent;

          final catDeposit =
              double.tryParse(cat['securityDeposit']?.toString() ?? '0') ?? 0.0;
          if (catDeposit > 0) deposit = catDeposit;

          final catMaintenance =
              double.tryParse(cat['maintenance']?.toString() ?? '0') ?? 0.0;
          if (catMaintenance > 0) maintenance = catMaintenance;

          final catDailyRent =
              double.tryParse(cat['dailyRent']?.toString() ?? '0') ?? 0.0;
          if (catDailyRent > 0) dailyRent = catDailyRent;
        }

        r['rent'] = rent;
        r['deposit'] = deposit;
        r['maintenance'] = maintenance;
        r['dailyRent'] = dailyRent;
        return r;
      }).toList();

      final allImages = [
        ...state.images,
        ...state.categorizedImages.values.expand((e) => e),
      ];

      final activeRoomCategories = state.roomCategories.where((cat) {
        final rentStr = cat['monthlyRent']?.toString().trim() ?? '';
        final hasRent =
            rentStr.isNotEmpty && rentStr != '0' && rentStr != '0.0';

        final isAC = cat['isAC'] == true;
        final sharing = cat['sharingType'] ?? 2;
        final hasRooms = state.rooms.any((room) {
          final roomIsAC = (room['features'] as Map?)?['isAC'] == true;
          final roomSharing = room['sharingType'] ?? 2;
          return roomSharing == sharing && roomIsAC == isAC;
        });

        return hasRent || hasRooms;
      }).toList();

      final hostel = await setupPropertyUseCase.execute(
        hostelId: state.hostelId,
        name: state.buildingName,
        address: state.address,
        floors: state.selectedFloors.length,
        amenities: state.selectedAmenities,
        rooms: roomsWithPricing,
        roomCategories: activeRoomCategories,
        masterPricing: state.masterPricing,
        lat: state.lat,
        lng: state.lng,
        area: state.area,
        city: state.city,
        state: state.state,
        hostelType: state.hostelType,
        images: allImages,
        pincode: state.pincode,
        foodLicense: state.foodLicense,
        hostelLicense: state.hostelLicense,
        tradeLicense: state.tradeLicense,
        fireSafety: state.fireSafety,
        policeNoc: state.policeNoc,
        shopsEstablishment: state.shopsEstablishment,
        gstRegistration: state.gstRegistration,
        healthSanitation: state.healthSanitation,
        utilityBill: state.utilityBill,
        pollutionNoc: state.pollutionNoc,
        residentVerification: state.residentVerification,
      );
      emit(
        state.copyWith(isSaving: false, currentStep: 5, hostelId: hostel.id),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: GlobalErrorMapper.map(e).message,
        ),
      );
    }
  }

  void syncRoomCategoriesAndPricing() {
    final List<Map<String, dynamic>> rooms = List<Map<String, dynamic>>.from(
      state.rooms.map((r) => Map<String, dynamic>.from(r)),
    );
    final List<Map<String, dynamic>> categories =
        List<Map<String, dynamic>>.from(
          state.roomCategories.map((c) => Map<String, dynamic>.from(c)),
        );
    bool changed = false;

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final features = room['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] == true;
      final sharing = room['sharingType'] ?? 2;

      int existingCatIndex = categories.indexWhere(
        (cat) => cat['sharingType'] == sharing && cat['isAC'] == isAC,
      );

      if (existingCatIndex == -1) {
        final newCatId = 'cat_${DateTime.now().millisecondsSinceEpoch}_$i';

        final newCat = {
          'id': newCatId,
          'sharingType': sharing,
          'isAC': isAC,
          'roomSize': room['roomSize'] ?? 'Medium',
          'roomCount': 0,
          'monthlyRent': '',
          'dailyRent': '',
          'securityDeposit': '',
          'maintenance': '',
          'dailyRentThresholdDays': '5',
        };
        categories.add(newCat);
        existingCatIndex = categories.length - 1;
        changed = true;
      }

      if (room['categoryId'] != categories[existingCatIndex]['id']) {
        rooms[i]['categoryId'] = categories[existingCatIndex]['id'];
        changed = true;
      }
    }

    for (var i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final count = rooms.where((r) => r['categoryId'] == cat['id']).length;
      if (cat['roomCount'] != count) {
        cat['roomCount'] = count;
        changed = true;
      }

      final sharing = cat['sharingType'] ?? 2;
      final isAC = cat['isAC'] == true;
      final matches3 = state.roomMasters.where(
        (m) => m['sharingType'] == sharing && m['isAC'] == isAC,
      );
      final Map<String, dynamic> matchingMaster = matches3.isNotEmpty
          ? matches3.first
          : <String, dynamic>{};

      if (matchingMaster.isNotEmpty) {
        final double rentVal =
            double.tryParse(matchingMaster['rent']?.toString() ?? '') ?? 0.0;
        if (rentVal > 0) {
          final String rentStr = rentVal.toStringAsFixed(0);
          final currentRent = cat['monthlyRent']?.toString() ?? '';
          final isLocked = cat['monthlyRentLocked'] == true;
          if (!isLocked && (currentRent.isEmpty || currentRent == '0' || currentRent == '0.0')) {
            if (cat['monthlyRent']?.toString() != rentStr) {
              cat['monthlyRent'] = rentStr;
              changed = true;
            }
          }
        }

        final double depositVal =
            double.tryParse(matchingMaster['deposit']?.toString() ?? '') ?? 0.0;
        if (depositVal > 0) {
          final String depositStr = depositVal.toStringAsFixed(0);
          final currentDeposit = cat['securityDeposit']?.toString() ?? '';
          final isLocked = cat['securityDepositLocked'] == true;
          if (!isLocked && (currentDeposit.isEmpty || currentDeposit == '0' || currentDeposit == '0.0')) {
            if (cat['securityDeposit']?.toString() != depositStr) {
              cat['securityDeposit'] = depositStr;
              changed = true;
            }
          }
        }

        final double dailyVal =
            double.tryParse(matchingMaster['dailyRent']?.toString() ?? '') ??
            0.0;
        if (dailyVal > 0) {
          final String dailyStr = dailyVal.toStringAsFixed(0);
          final currentDaily = cat['dailyRent']?.toString() ?? '';
          final isLocked = cat['dailyRentLocked'] == true;
          if (!isLocked && (currentDaily.isEmpty || currentDaily == '0' || currentDaily == '0.0')) {
            if (cat['dailyRent']?.toString() != dailyStr) {
              cat['dailyRent'] = dailyStr;
              changed = true;
            }
          }
        }

        final double maintVal =
            double.tryParse(matchingMaster['maintenance']?.toString() ?? '') ??
            0.0;
        if (maintVal > 0) {
          final String maintStr = maintVal.toStringAsFixed(0);
          final currentMaint = cat['maintenance']?.toString() ?? '';
          final isLocked = cat['maintenanceLocked'] == true;
          if (!isLocked && (currentMaint.isEmpty || currentMaint == '0' || currentMaint == '0.0')) {
            if (cat['maintenance']?.toString() != maintStr) {
              cat['maintenance'] = maintStr;
              changed = true;
            }
          }
        }
      }
    }

    final Map<String, dynamic> currentPricing = {};
    state.masterPricing.forEach((key, value) {
      if (value is Map) {
        currentPricing[key] = Map<String, dynamic>.from(value);
      } else {
        currentPricing[key] = value;
      }
    });

    for (var category in categories) {
      final type = category['isAC'] == true ? 'AC' : 'NON-AC';
      final sharing = category['sharingType'].toString();

      if (currentPricing[type] == null) {
        currentPricing[type] = <String, dynamic>{};
      }

      final Map<String, dynamic> typeMap = Map<String, dynamic>.from(
        currentPricing[type] as Map,
      );

      typeMap[sharing] = <String, dynamic>{
        'rent':
            double.tryParse(category['monthlyRent']?.toString() ?? '0') ?? 0.0,
        'monthlyRent':
            double.tryParse(category['monthlyRent']?.toString() ?? '0') ?? 0.0,
        'dailyRent':
            double.tryParse(category['dailyRent']?.toString() ?? '0') ?? 0.0,
        'deposit':
            double.tryParse(category['securityDeposit']?.toString() ?? '0') ??
            0.0,
        'securityDeposit':
            double.tryParse(category['securityDeposit']?.toString() ?? '0') ??
            0.0,
        'maintenance':
            double.tryParse(category['maintenance']?.toString() ?? '0') ?? 0.0,
        'dailyRentThresholdDays':
            int.tryParse(
              category['dailyRentThresholdDays']?.toString() ?? '0',
            ) ??
            0,
      };
      currentPricing[type] = typeMap;
    }

    if (changed) {
      AppLogger.info(
        'syncRoomCategoriesAndPricing detected category setup changes',
      );
    }

    emit(
      state.copyWith(
        roomCategories: categories,
        rooms: rooms,
        masterPricing: currentPricing,
      ),
    );
  }

  void syncRoomCategories() {
    syncRoomCategoriesAndPricing();
  }

  void syncPricingFromCategories() {
    syncRoomCategoriesAndPricing();
  }

  void resetState() {
    emit(const PropertySetupState());
  }

  void addManualRoom(Map<String, dynamic> room) {
    final currentRooms = List<Map<String, dynamic>>.from(state.rooms);
    currentRooms.add(room);
    emit(state.copyWith(rooms: currentRooms));
  }

  void setRoomMasters(List<RoomDetail> masters) {
    final List<Map<String, dynamic>> mapped = masters
        .map(
          (m) => {
            'id': m.id,
            'sharingType': m.capacity,
            'isAC': m.roomType == 'AC',
            'rent': m.rent,
            'dailyRent': m.dailyRent,
            'deposit': m.deposit,
            'maintenance': m.maintenance,
          },
        )
        .toList();
    emit(state.copyWith(roomMasters: mapped));

    updatePricingFromMasters();
    syncRoomCategoriesAndPricing();
  }

  void updatePricingFromMasters() {
    final List<Map<String, dynamic>> categories =
        List<Map<String, dynamic>>.from(
          state.roomCategories.map((c) => Map<String, dynamic>.from(c)),
        );

    bool changed = false;
    for (var i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final sharing = cat['sharingType'] ?? 2;
      final isAC = cat['isAC'] == true;

      final matches = state.roomMasters.where(
        (m) => m['sharingType'] == sharing && m['isAC'] == isAC,
      );
      final Map<String, dynamic> matchingMaster = matches.isNotEmpty
          ? matches.first
          : <String, dynamic>{};

      if (matchingMaster.isNotEmpty) {
        final double rentVal =
            double.tryParse(matchingMaster['rent']?.toString() ?? '') ?? 0.0;
        if (rentVal > 0) {
          final String rentStr = rentVal.toStringAsFixed(0);
          final currentRent = cat['monthlyRent']?.toString() ?? '';
          final isLocked = cat['monthlyRentLocked'] == true;
          if (!isLocked && (currentRent.isEmpty || currentRent == '0' || currentRent == '0.0')) {
            if (cat['monthlyRent']?.toString() != rentStr) {
              cat['monthlyRent'] = rentStr;
              changed = true;
            }
          }
        }

        final double depositVal =
            double.tryParse(matchingMaster['deposit']?.toString() ?? '') ?? 0.0;
        if (depositVal > 0) {
          final String depositStr = depositVal.toStringAsFixed(0);
          final currentDeposit = cat['securityDeposit']?.toString() ?? '';
          final isLocked = cat['securityDepositLocked'] == true;
          if (!isLocked && (currentDeposit.isEmpty || currentDeposit == '0' || currentDeposit == '0.0')) {
            if (cat['securityDeposit']?.toString() != depositStr) {
              cat['securityDeposit'] = depositStr;
              changed = true;
            }
          }
        }

        final double dailyVal =
            double.tryParse(matchingMaster['dailyRent']?.toString() ?? '') ??
            0.0;
        if (dailyVal > 0) {
          final String dailyStr = dailyVal.toStringAsFixed(0);
          final currentDaily = cat['dailyRent']?.toString() ?? '';
          final isLocked = cat['dailyRentLocked'] == true;
          if (!isLocked && (currentDaily.isEmpty || currentDaily == '0' || currentDaily == '0.0')) {
            if (cat['dailyRent']?.toString() != dailyStr) {
              cat['dailyRent'] = dailyStr;
              changed = true;
            }
          }
        }

        final double maintVal =
            double.tryParse(matchingMaster['maintenance']?.toString() ?? '') ??
            0.0;
        if (maintVal > 0) {
          final String maintStr = maintVal.toStringAsFixed(0);
          final currentMaint = cat['maintenance']?.toString() ?? '';
          final isLocked = cat['maintenanceLocked'] == true;
          if (!isLocked && (currentMaint.isEmpty || currentMaint == '0' || currentMaint == '0.0')) {
            if (cat['maintenance']?.toString() != maintStr) {
              cat['maintenance'] = maintStr;
              changed = true;
            }
          }
        }
      }
    }

    final rooms = List<Map<String, dynamic>>.from(
      state.rooms.map((r) => Map<String, dynamic>.from(r)),
    );
    final updatedRooms = rooms.map((room) {
      final features = room['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] ?? false;
      final type = isAC ? 'AC' : 'NON-AC';
      final sharing = (room['sharingType'] ?? 2).toString();

      final pricing = state.masterPricing[type] ?? {};
      final config = pricing[sharing];

      if (config is Map) {
        room['rent'] =
            double.tryParse(
              config['rent']?.toString() ??
                  config['monthlyRent']?.toString() ??
                  '0.0',
            ) ??
            0.0;
        room['deposit'] =
            double.tryParse(
              config['deposit']?.toString() ??
                  config['securityDeposit']?.toString() ??
                  '0.0',
            ) ??
            0.0;
      }
      return room;
    }).toList();

    emit(
      state.copyWith(
        rooms: updatedRooms,
        roomCategories: changed ? categories : state.roomCategories,
      ),
    );

    syncRoomCategoriesAndPricing();
  }

  void toggleFloor(String floor) {
    final floors = List<String>.from(state.selectedFloors);
    if (floors.contains(floor)) {
      floors.remove(floor);
    } else {
      floors.add(floor);
    }
    emit(state.copyWith(selectedFloors: floors));
  }

  void toggleAmenity(String amenity) {
    final amenities = List<String>.from(state.selectedAmenities);
    if (amenities.contains(amenity)) {
      amenities.remove(amenity);
    } else {
      amenities.add(amenity);
    }

    final updatedRooms = state.rooms.map((room) {
      final r = Map<String, dynamic>.from(room);
      final features = Map<String, dynamic>.from(r['features'] ?? {});
      if (amenity == 'AC / Cooler') {
        features['isAC'] = amenities.contains('AC / Cooler');
        r['roomType'] = amenities.contains('AC / Cooler') ? 'AC' : 'NON-AC';
      } else if (amenity == 'Attached Balcony') {
        features['hasBalcony'] = amenities.contains('Attached Balcony');
      } else if (amenity == 'Geyser (Hot Water)') {
        features['hasGeyser'] = amenities.contains('Geyser (Hot Water)');
      }
      r['features'] = features;
      return r;
    }).toList();

    emit(state.copyWith(selectedAmenities: amenities, rooms: updatedRooms));
    syncRoomCategoriesAndPricing();
  }

  void removeRoomMaster(int index) {
    final masters = List<Map<String, dynamic>>.from(state.roomMasters);
    if (index >= 0 && index < masters.length) {
      masters.removeAt(index);
      emit(state.copyWith(roomMasters: masters));
    }
  }

  void addRoomMaster(Map<String, dynamic> master) {
    final masters = List<Map<String, dynamic>>.from(state.roomMasters);
    masters.add(master);
    emit(state.copyWith(roomMasters: masters));
  }

  void addRoomCategory() {
    final categories = List<Map<String, dynamic>>.from(state.roomCategories);

    int defaultSharing = 2;
    bool defaultIsAC = false;

    final existingPairs = categories
        .map((c) => '${c['sharingType']}_${c['isAC']}')
        .toSet();

    final candidates = [
      {'sharing': 1, 'isAC': false},
      {'sharing': 1, 'isAC': true},
      {'sharing': 2, 'isAC': false},
      {'sharing': 2, 'isAC': true},
      {'sharing': 3, 'isAC': false},
      {'sharing': 3, 'isAC': true},
      {'sharing': 4, 'isAC': false},
      {'sharing': 4, 'isAC': true},
      {'sharing': 5, 'isAC': false},
      {'sharing': 5, 'isAC': true},
    ];

    for (final cand in candidates) {
      final key = '${cand['sharing']}_${cand['isAC']}';
      if (!existingPairs.contains(key)) {
        defaultSharing = cand['sharing'] as int;
        defaultIsAC = cand['isAC'] as bool;
        break;
      }
    }

    if (existingPairs.contains('${defaultSharing}_$defaultIsAC')) {
      int sharing = 6;
      while (existingPairs.contains('${sharing}_false')) {
        sharing++;
      }
      defaultSharing = sharing;
      defaultIsAC = false;
    }

    final String existingDeposit =
        categories
            .firstWhere(
              (c) => (c['securityDeposit']?.toString().trim() ?? '').isNotEmpty,
              orElse: () => <String, dynamic>{},
            )['securityDeposit']
            ?.toString() ??
        '';

    final String existingMaint =
        categories
            .firstWhere(
              (c) => (c['maintenance']?.toString().trim() ?? '').isNotEmpty,
              orElse: () => <String, dynamic>{},
            )['maintenance']
            ?.toString() ??
        '';

    categories.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sharingType': defaultSharing,
      'isAC': defaultIsAC,
      'roomSize': '',
      'roomCount': 0,
      'monthlyRent': '',
      'dailyRent': '',
      'securityDeposit': existingDeposit,
      'maintenance': existingMaint,
      'securityDepositCustomized': existingDeposit.isNotEmpty,
      'maintenanceCustomized': existingMaint.isNotEmpty,
      'dailyRentThresholdDays': '5',
    });
    emit(state.copyWith(roomCategories: categories));
  }

  void addCustomRoomCategory({
    required int sharingType,
    required bool isAC,
    required String monthlyRent,
    required String dailyRent,
    required String securityDeposit,
    required String maintenance,
    required String dailyRentThresholdDays,
  }) {
    final categories = List<Map<String, dynamic>>.from(state.roomCategories);
    categories.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sharingType': sharingType,
      'isAC': isAC,
      'roomSize': '',
      'roomCount': 0,
      'monthlyRent': monthlyRent,
      'dailyRent': dailyRent,
      'securityDeposit': securityDeposit,
      'maintenance': maintenance,
      'securityDepositCustomized': true,
      'maintenanceCustomized': true,
      'dailyRentThresholdDays': dailyRentThresholdDays,
    });
    emit(state.copyWith(roomCategories: categories));
  }

  void setRoomCategories(List<Map<String, dynamic>> categories) {
    emit(state.copyWith(roomCategories: categories));
  }

  void updateRoomCategory(int index, Map<String, dynamic> data) {
    final categories = List<Map<String, dynamic>>.from(state.roomCategories);
    if (index >= 0 && index < categories.length) {
      var cat = Map<String, dynamic>.from(categories[index]);

      if (data.containsKey('securityDeposit')) {
        final newVal = data['securityDeposit']?.toString() ?? '';
        cat['securityDepositCustomized'] = true;

        for (int i = 0; i < categories.length; i++) {
          if (i == index) continue;
          final otherCat = Map<String, dynamic>.from(categories[i]);
          if (otherCat['securityDepositCustomized'] != true) {
            otherCat['securityDeposit'] = newVal;
            categories[i] = otherCat;
          }
        }
      }

      if (data.containsKey('maintenance')) {
        final newVal = data['maintenance']?.toString() ?? '';
        cat['maintenanceCustomized'] = true;

        for (int i = 0; i < categories.length; i++) {
          if (i == index) continue;
          final otherCat = Map<String, dynamic>.from(categories[i]);
          if (otherCat['maintenanceCustomized'] != true) {
            otherCat['maintenance'] = newVal;
            categories[i] = otherCat;
          }
        }
      }

      cat.addAll(data);
      categories[index] = cat;
      emit(state.copyWith(roomCategories: categories));
    }
  }

  void removeRoomCategory(int index) {
    final categories = List<Map<String, dynamic>>.from(state.roomCategories);
    if (index >= 0 && index < categories.length) {
      categories.removeAt(index);
      emit(state.copyWith(roomCategories: categories));
    }
  }

  int get assignedCategoryRooms {
    return state.roomCategories.fold<int>(
      0,
      (sum, cat) => sum + (cat['roomCount'] as int? ?? 0),
    );
  }

  Map<String, dynamic>? getCategoryPricing(String? categoryId) {
    if (categoryId == null) return null;
    final matches = state.roomCategories.where(
      (cat) => cat['id'] == categoryId,
    );
    final Map<String, dynamic> category = matches.isNotEmpty
        ? matches.first
        : <String, dynamic>{};
    if (category.isEmpty) return null;

    final type = (category['isAC'] == true) ? 'AC' : 'NON-AC';
    final sharing = (category['sharingType'] ?? 2).toString();

    final pricing = state.masterPricing[type] ?? {};
    final config = pricing[sharing];

    if (config is Map<String, dynamic>) return config;
    return null;
  }

  void assignCategoryToRoom(int roomIndex, String categoryId) {
    final categories = state.roomCategories;
    final matches = categories.where((c) => c['id'] == categoryId);
    final Map<String, dynamic> category = matches.isNotEmpty
        ? matches.first
        : <String, dynamic>{};
    if (category.isEmpty) return;

    final rooms = List<Map<String, dynamic>>.from(
      state.rooms.map((r) => Map<String, dynamic>.from(r)),
    );
    final room = Map<String, dynamic>.from(rooms[roomIndex]);

    room['categoryId'] = categoryId;
    room['sharingType'] = category['sharingType'];
    room['roomType'] = (category['isAC'] as bool) ? 'AC' : 'NON-AC';
    room['roomSize'] = category['roomSize'];

    final features = Map<String, dynamic>.from(room['features'] ?? {});
    features['isAC'] = category['isAC'];
    room['features'] = features;

    room['beds'] = List.generate(
      category['sharingType'] as int,
      (i) => {'bedNumber': String.fromCharCode(65 + i), 'status': 'FREE'},
    );

    rooms[roomIndex] = room;
    emit(state.copyWith(rooms: rooms));
  }

  @override
  PropertySetupState? fromJson(Map<String, dynamic> json) {
    return PropertySetupState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PropertySetupState state) {
    return state.toJson();
  }

  @override
  String get id {
    try {
      final authCubit = GetIt.instance<AuthCubit>();
      final ownerId = authCubit.currentOwner?.id;
      if (ownerId != null && ownerId.isNotEmpty) {
        return '_$ownerId';
      }
    } catch (_) {}
    return '';
  }
}
