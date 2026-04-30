import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../domain/usecases/setup_property_usecase.dart';
import 'property_setup_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class PropertySetupCubit extends HydratedCubit<PropertySetupState> {
  final SetupPropertyUseCase setupPropertyUseCase;

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
      area: hostel.area ?? '',
      selectedFloors: List.generate(hostel.floors, (i) => i == 0 ? 'G' : i.toString()),
      currentStep: 0, 
    ));
  }

  void updateRoomRange(String start, String end) {
    emit(state.copyWith(roomStartRange: start, roomEndRange: end));
  }

  void nextStep() {
    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void updateBuildingName(String name) {
    emit(state.copyWith(buildingName: name));
  }

  void updateLocation(String address, double? lat, double? lng) {
    emit(state.copyWith(address: address, lat: lat, lng: lng));
  }

  void updateAddress(String address) {
    emit(state.copyWith(address: address));
  }

  void updateCoordinates(double lat, double lng) {
    emit(state.copyWith(lat: lat, lng: lng));
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
    emit(state.copyWith(selectedAmenities: amenities));
  }

  void toggleBulkMode(bool isBulk) {
    emit(state.copyWith(isBulkMode: isBulk));
  }

  void updateSharingType(int sharing) {
    emit(state.copyWith(sharingType: sharing));
  }

  void updateRoomType(String type) {
    emit(state.copyWith(roomType: type));
  }

  void addRoomBatch() {
    if (state.roomStartRange.isEmpty || state.roomEndRange.isEmpty) return;
    
    final start = int.tryParse(state.roomStartRange);
    final end = int.tryParse(state.roomEndRange);
    
    if (start != null && end != null && start <= end) {
      final List<Map<String, dynamic>> currentRooms = List<Map<String, dynamic>>.from(state.rooms);
      
      for (int i = start; i <= end; i++) {
        final roomNumber = i.toString();
        
        if (currentRooms.any((r) => r['roomNumber'] == roomNumber)) continue;

        currentRooms.add({
          'roomNumber': roomNumber,
          'sharingType': state.sharingType,
          'roomType': state.roomType,
          'beds': List.generate(state.sharingType, (index) => {
            'bedNumber': String.fromCharCode(65 + index), 
            'status': 'FREE',
          }),
        });
      }
      
      
      currentRooms.sort((a, b) => int.parse(a['roomNumber']).compareTo(int.parse(b['roomNumber'])));
      
      emit(state.copyWith(
        rooms: currentRooms,
        roomStartRange: '',
        roomEndRange: '',
      ));
    }
  }

  void removeRoom(String roomNumber) {
    final rooms = List<Map<String, dynamic>>.from(state.rooms);
    rooms.removeWhere((r) => r['roomNumber'] == roomNumber);
    emit(state.copyWith(rooms: rooms));
  }

  void clearRooms() {
    emit(state.copyWith(rooms: []));
  }

  void updatePricing(String type, String sharing, String field, double value) {
    final pricing = Map<String, dynamic>.from(state.masterPricing);
    final typeMap = Map<String, dynamic>.from(pricing[type] ?? {});
    final existing = typeMap[sharing];
    final sharingMap = Map<String, dynamic>.from(existing is Map ? existing : {
      'rent': existing is num ? existing.toDouble() : 0.0,
      'deposit': 0.0,
      'maintenance': 0.0,
    });
    
    sharingMap[field] = value;
    typeMap[sharing] = sharingMap;
    pricing[type] = typeMap;
    emit(state.copyWith(masterPricing: pricing));
  }

  bool get isValidToFinish {
    if (state.buildingName.isEmpty || state.address.isEmpty || state.lat == null || state.lng == null) return false;
    if (state.area.isEmpty || state.city.isEmpty || state.state.isEmpty) return false;
    if (state.rooms.isEmpty) return false;

    
    for (final room in state.rooms) {
      final type = room['roomType'] ?? 'Non-AC';
      final sharing = room['sharingType'].toString();
      final pricing = state.masterPricing[type] ?? {};
      final config = pricing[sharing];
      double rent = 0.0;
      
      if (config is Map) {
        rent = (config['rent'] ?? 0.0).toDouble();
      } else if (config is num) {
        rent = config.toDouble();
      }

      if (rent <= 0) return false;
    }

    return true;
  }

  Future<void> saveProperty() async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await setupPropertyUseCase.execute(
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
      );
      final successStep = state.hostelId != null ? 2 : 3;
      emit(state.copyWith(isSaving: false, currentStep: successStep)); 
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
