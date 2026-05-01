import 'package:file_picker/file_picker.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/setup_property_usecase.dart';
import 'property_setup_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class PropertySetupCubit extends HydratedCubit<PropertySetupState> {
  final SetupPropertyUseCase setupPropertyUseCase;
  final ImagePicker _picker = ImagePicker();

  PropertySetupCubit(this.setupPropertyUseCase) : super(const PropertySetupState());

  void prefillFromHostel(Hostel hostel) {
    emit(state.copyWith(
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
      selectedFloors: List.generate(hostel.floors, (i) => i == 0 ? 'G' : i.toString()),
      currentStep: 0, 
    ));
  }

  void updateGstNumber(String gst) {
    emit(state.copyWith(gstNumber: gst));
  }

  void nextStep() {
    final int targetStep = state.currentStep + 1;
    
    // Auto-generate rooms when moving from Step 2 (Floor Config) to Step 3 (Room Config)
    if (state.currentStep == 1) {
      autoGenerateRooms();
    }
    
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: targetStep));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
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

  void updateAddress(String address) {
    emit(state.copyWith(address: address));
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
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
        ].join(', ');

        emit(state.copyWith(
          address: detailedAddress,
          area: place.subLocality ?? '',
          city: place.locality ?? '',
          state: place.administrativeArea ?? '',
          pincode: place.postalCode ?? '',
        ));
      }
    } catch (e) {
      // Keep existing values on error
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

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final currentImages = List<String>.from(state.images);
        currentImages.addAll(pickedFiles.map((file) => file.path));
        emit(state.copyWith(images: currentImages));
      }
    } catch (e) {
      // Handle error
    }
  }

  void removeImage(int index) {
    final currentImages = List<String>.from(state.images);
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      emit(state.copyWith(images: currentImages));
    }
  }

  Future<void> pickLicense(String type) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        if (type == 'food') emit(state.copyWith(foodLicense: path));
        if (type == 'hostel') emit(state.copyWith(hostelLicense: path));
        if (type == 'trade') emit(state.copyWith(tradeLicense: path));
      }
    } catch (e) {
      // Handle error
    }
  }

  void removeLicense(String type) {
    if (type == 'food') emit(state.copyWith(foodLicense: ''));
    if (type == 'hostel') emit(state.copyWith(hostelLicense: ''));
    if (type == 'trade') emit(state.copyWith(tradeLicense: ''));
  }

  void setTotalFloors(int count) {
    final floors = List.generate(count, (i) => i == 0 ? 'G' : i.toString());
    emit(state.copyWith(selectedFloors: floors));
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
    
    for (var floor in state.selectedFloors) {
      final roomCount = state.floorRoomCounts[floor] ?? 0;
      final floorPrefix = floor == 'G' ? '0' : floor;
      
      for (int i = 1; i <= roomCount; i++) {
        final roomNumber = '$floorPrefix${i.toString().padLeft(2, '0')}';
        // ALWAYS create a fresh Map instance for each room
        newRooms.add({
          'roomNumber': roomNumber,
          'floor': floor,
          'sharingType': state.sharingType,
          'roomType': state.roomType,
          'features': {
            'isAC': state.roomType == 'AC',
            'hasGeyser': false,
            'hasBalcony': false,
            'hasAttachedWashroom': false,
          },
          'beds': List.generate(state.sharingType, (index) => {
            'bedNumber': String.fromCharCode(65 + index), 
            'status': 'FREE',
          }),
        });
      }
    }
    
    emit(state.copyWith(rooms: newRooms));
  }

  void updateRoomFeature(int index, String feature, bool value) {
    final rooms = List<Map<String, dynamic>>.from(state.rooms.map((r) => Map<String, dynamic>.from(r)));
    final room = Map<String, dynamic>.from(rooms[index]);
    final features = Map<String, dynamic>.from(room['features'] ?? {});
    
    features[feature] = value;
    // Keep roomType in sync with isAC feature
    if (feature == 'isAC') {
      room['roomType'] = value ? 'AC' : 'Non-AC';
    }
    
    room['features'] = features;
    rooms[index] = room;
    
    emit(state.copyWith(rooms: rooms));
  }

  void updateRoomSharing(int index, int sharing) {
    final rooms = List<Map<String, dynamic>>.from(state.rooms.map((r) => Map<String, dynamic>.from(r)));
    final room = Map<String, dynamic>.from(rooms[index]);
    
    room['sharingType'] = sharing;
    room['beds'] = List.generate(sharing, (i) => {
      'bedNumber': String.fromCharCode(65 + i),
      'status': 'FREE',
    });
    rooms[index] = room;
    
    emit(state.copyWith(rooms: rooms));
  }

  void cloneRoomSettings(int sourceIndex) {
    final currentRooms = state.rooms;
    if (sourceIndex < 0 || sourceIndex >= currentRooms.length) return;
    
    final sourceRoom = Map<String, dynamic>.from(currentRooms[sourceIndex]);
    final sourceFeatures = Map<String, dynamic>.from(sourceRoom['features'] ?? {});
    final isAC = sourceFeatures['isAC'] == true;
    final sourceSharing = sourceRoom['sharingType'] ?? 2;

    final updatedRooms = currentRooms.map((room) {
      final newRoom = Map<String, dynamic>.from(room);
      // Deep copy features and sharing
      newRoom['features'] = Map<String, dynamic>.from(sourceFeatures);
      newRoom['sharingType'] = sourceSharing;
      newRoom['roomType'] = isAC ? 'AC' : 'Non-AC'; // Sync roomType
      newRoom['beds'] = List.generate(sourceSharing, (idx) => {
        'bedNumber': String.fromCharCode(65 + idx),
        'status': 'FREE',
      });
      return newRoom;
    }).toList();
    
    emit(state.copyWith(rooms: updatedRooms));
  }

  void updatePricing(String roomType, String sharing, String field, double value) {
    final pricing = Map<String, dynamic>.from(state.masterPricing);
    final typeMap = Map<String, dynamic>.from(pricing[roomType] ?? {});
    final sharingMap = Map<String, dynamic>.from(typeMap[sharing] ?? {'rent': 0.0, 'deposit': 0.0, 'maintenance': 0.0, 'dailyRent': 0.0});
    
    sharingMap[field] = value;
    typeMap[sharing] = sharingMap;
    pricing[roomType] = typeMap;
    emit(state.copyWith(masterPricing: pricing));
  }

  void applyPricingToAllRooms(String field, double value) {
    final pricing = Map<String, dynamic>.from(state.masterPricing);
    // Apply to ALL possible room types and sharing types (1-5) to ensure coverage
    final roomTypes = ['AC', 'Non-AC'];
    final sharingTypes = ['1', '2', '3', '4', '5'];
    
    for (var type in roomTypes) {
      final typeMap = Map<String, dynamic>.from(pricing[type] ?? {});
      for (var sharing in sharingTypes) {
        final sharingMap = Map<String, dynamic>.from(typeMap[sharing] ?? {
          'rent': 0.0, 
          'deposit': 0.0, 
          'maintenance': 0.0, 
          'dailyRent': 0.0
        });
        sharingMap[field] = value;
        typeMap[sharing] = sharingMap;
      }
      pricing[type] = typeMap;
    }
    emit(state.copyWith(masterPricing: pricing));
  }

  bool get isValidToFinish {
    // Basic validation
    if (state.buildingName.trim().isEmpty) {
      emit(state.copyWith(validationMessage: 'Please enter a property name'));
      return false;
    }
    if (state.address.trim().isEmpty) {
      emit(state.copyWith(validationMessage: 'Please enter the property address'));
      return false;
    }
    if (state.lat == null || state.lng == null) {
      emit(state.copyWith(validationMessage: 'Please select the property location on map'));
      return false;
    }
    if (state.rooms.isEmpty) {
      emit(state.copyWith(validationMessage: 'Please add at least one room'));
      return false;
    }

    // Check pricing for every room category present in the rooms list
    final Set<String> categoriesMissingPrice = {};
    for (final room in state.rooms) {
      final features = room['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] ?? false;
      final type = isAC ? 'AC' : 'Non-AC';
      
      final sharing = (room['sharingType'] ?? 2).toString();
      final pricing = state.masterPricing[type] ?? {};
      final config = pricing[sharing];
      
      double rent = 0.0;
      double deposit = 0.0;
      
      if (config is Map) {
        rent = double.tryParse(config['rent']?.toString() ?? '0.0') ?? 0.0;
        deposit = double.tryParse(config['deposit']?.toString() ?? '0.0') ?? 0.0;
      }
      
      // Strict validation: must have rent AND pricing config must exist
      if (config == null || rent <= 0 || deposit < 0) {
        categoriesMissingPrice.add('$sharing Sharing $type');
      }
    }

    if (categoriesMissingPrice.isNotEmpty) {
      emit(state.copyWith(
        validationMessage: 'Missing or invalid pricing for: ${categoriesMissingPrice.join(", ")}'
      ));
      return false;
    }

    emit(state.copyWith(validationMessage: null));
    return true;
  }

  Future<void> saveProperty() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, error: null));
    try {
      final hostel = await setupPropertyUseCase.execute(
        hostelId: state.hostelId,
        name: state.buildingName,
        address: state.address,
        floors: state.selectedFloors.length,
        amenities: state.selectedAmenities,
        rooms: state.rooms,
        masterPricing: state.masterPricing,
        lat: state.lat,
        lng: state.lng,
        area: state.area,
        city: state.city,
        state: state.state,
        hostelType: state.hostelType,
        images: state.images,
        foodLicense: state.foodLicense,
        hostelLicense: state.hostelLicense,
        tradeLicense: state.tradeLicense,
      );
      emit(state.copyWith(isSaving: false, currentStep: 4, hostelId: hostel.id)); 
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  void resetState() {
    emit(const PropertySetupState());
  }

  @override
  PropertySetupState? fromJson(Map<String, dynamic> json) {
    return PropertySetupState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PropertySetupState state) {
    return state.toJson();
  }
}
