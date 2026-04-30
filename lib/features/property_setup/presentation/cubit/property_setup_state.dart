import 'package:equatable/equatable.dart';

class PropertySetupState extends Equatable {
  final int currentStep;
  final String buildingName;
  final String address;
  final double? lat;
  final double? lng;
  final String area;
  final String city;
  final String state;
  final List<String> selectedFloors;
  final List<String> selectedAmenities;
  final bool isBulkMode;
  final String roomStartRange;
  final String roomEndRange;
  final int sharingType;
  final String roomType; 
  final Map<String, dynamic> masterPricing; 
  final List<Map<String, dynamic>> rooms;
  final String? hostelId;
  final bool isSaving;
  final String? error;

  const PropertySetupState({
    this.currentStep = 0,
    this.buildingName = '',
    this.address = '',
    this.lat,
    this.lng,
    this.area = '',
    this.city = '',
    this.state = '',
    this.selectedFloors = const [],
    this.selectedAmenities = const [],
    this.isBulkMode = true,
    this.roomStartRange = '',
    this.roomEndRange = '',
    this.sharingType = 2,
    this.roomType = 'Non-AC',
    this.masterPricing = const {
      'AC': {
        '2': 0.0,
        '3': 0.0,
        '4': 0.0,
      },
      'Non-AC': {
        '2': 0.0,
        '3': 0.0,
        '4': 0.0,
      },
    },
    this.rooms = const [],
    this.hostelId,
    this.isSaving = false,
    this.error,
  });

  PropertySetupState copyWith({
    int? currentStep,
    String? buildingName,
    String? address,
    double? lat,
    double? lng,
    String? area,
    String? city,
    String? state,
    List<String>? selectedFloors,
    List<String>? selectedAmenities,
    bool? isBulkMode,
    String? roomStartRange,
    String? roomEndRange,
    int? sharingType,
    String? roomType,
    Map<String, dynamic>? masterPricing,
    List<Map<String, dynamic>>? rooms,
    String? hostelId,
    bool? isSaving,
    String? error,
  }) {
    return PropertySetupState(
      currentStep: currentStep ?? this.currentStep,
      buildingName: buildingName ?? this.buildingName,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      selectedFloors: selectedFloors ?? this.selectedFloors,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      isBulkMode: isBulkMode ?? this.isBulkMode,
      roomStartRange: roomStartRange ?? this.roomStartRange,
      roomEndRange: roomEndRange ?? this.roomEndRange,
      sharingType: sharingType ?? this.sharingType,
      roomType: roomType ?? this.roomType,
      masterPricing: masterPricing ?? this.masterPricing,
      rooms: rooms ?? this.rooms,
      hostelId: hostelId ?? this.hostelId,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'buildingName': buildingName,
      'address': address,
      'lat': lat,
      'lng': lng,
      'area': area,
      'city': city,
      'state': state,
      'selectedFloors': selectedFloors,
      'selectedAmenities': selectedAmenities,
      'isBulkMode': isBulkMode,
      'roomStartRange': roomStartRange,
      'roomEndRange': roomEndRange,
      'sharingType': sharingType,
      'roomType': roomType,
      'masterPricing': masterPricing,
      'rooms': rooms,
      'hostelId': hostelId,
    };
  }

  factory PropertySetupState.fromJson(Map<String, dynamic> json) {
    return PropertySetupState(
      currentStep: json['currentStep'] ?? 0,
      buildingName: json['buildingName'] ?? '',
      address: json['address'] ?? '',
      lat: json['lat'],
      lng: json['lng'],
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      selectedFloors: List<String>.from(json['selectedFloors'] ?? []),
      selectedAmenities: List<String>.from(json['selectedAmenities'] ?? []),
      isBulkMode: json['isBulkMode'] ?? true,
      roomStartRange: json['roomStartRange'] ?? '',
      roomEndRange: json['roomEndRange'] ?? '',
      sharingType: json['sharingType'] ?? 2,
      roomType: json['roomType'] ?? 'Non-AC',
      masterPricing: Map<String, dynamic>.from(json['masterPricing'] ?? {}),
      rooms: List<Map<String, dynamic>>.from(json['rooms'] ?? []),
      hostelId: json['hostelId'],
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        buildingName,
        address,
        lat,
        lng,
        area,
        city,
        state,
        selectedFloors,
        selectedAmenities,
        isBulkMode,
        roomStartRange,
        roomEndRange,
        sharingType,
        roomType,
        masterPricing,
        rooms,
        hostelId,
        isSaving,
        error,
      ];
}
