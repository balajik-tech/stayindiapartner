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
  final String pincode;
  final String hostelType;
  final String gstNumber;
  final List<String> images;
  final List<String> selectedFloors;
  final Map<String, int> floorRoomCounts; 
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
  final String? validationMessage;
  final String? foodLicense;
  final String? hostelLicense;
  final String? tradeLicense;
  final String? fireSafety;
  final String? policeNoc;
  final String? shopsEstablishment;
  final String? gstRegistration;
  final String? healthSanitation;
  final String? utilityBill;
  final String? pollutionNoc;
  final String? residentVerification;
  final String detailedAddress;
  final Map<String, List<String>> categorizedImages;
  final List<Map<String, dynamic>> roomMasters;
  final List<Map<String, dynamic>> roomCategories;

  const PropertySetupState({
    this.currentStep = 0,
    this.buildingName = '',
    this.address = '',
    this.lat,
    this.lng,
    this.area = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.hostelType = '',
    this.gstNumber = '',
    this.images = const [],
    this.selectedFloors = const [],
    this.floorRoomCounts = const {},
    this.selectedAmenities = const [],
    this.isBulkMode = true,
    this.roomStartRange = '',
    this.roomEndRange = '',
    this.sharingType = 2,
    this.roomType = 'Non-AC',
    this.masterPricing = const {
      'AC': {
        '2': {'rent': 0.0, 'deposit': 0.0},
        '3': {'rent': 0.0, 'deposit': 0.0},
        '4': {'rent': 0.0, 'deposit': 0.0},
      },
      'Non-AC': {
        '2': {'rent': 0.0, 'deposit': 0.0},
        '3': {'rent': 0.0, 'deposit': 0.0},
        '4': {'rent': 0.0, 'deposit': 0.0},
      },
    },
    this.rooms = const [],
    this.hostelId,
    this.isSaving = false,
    this.error,
    this.validationMessage,
    this.foodLicense,
    this.hostelLicense,
    this.tradeLicense,
    this.fireSafety,
    this.policeNoc,
    this.shopsEstablishment,
    this.gstRegistration,
    this.healthSanitation,
    this.utilityBill,
    this.pollutionNoc,
    this.residentVerification,
    this.detailedAddress = '',
    this.categorizedImages = const {
      'Exterior': [],
      'Reception': [],
      'Rooms': [],
      'Dining': [],
      'Kitchen': [],
      'Bathrooms': [],
      'Balcony': [],
    },
    this.roomMasters = const [],
    this.roomCategories = const [],
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
    String? pincode,
    String? hostelType,
    String? gstNumber,
    List<String>? images,
    List<String>? selectedFloors,
    Map<String, int>? floorRoomCounts,
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
    String? validationMessage,
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
    String? detailedAddress,
    Map<String, List<String>>? categorizedImages,
    List<Map<String, dynamic>>? roomMasters,
    List<Map<String, dynamic>>? roomCategories,
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
      pincode: pincode ?? this.pincode,
      hostelType: hostelType ?? this.hostelType,
      gstNumber: gstNumber ?? this.gstNumber,
      images: images ?? this.images,
      selectedFloors: selectedFloors ?? this.selectedFloors,
      floorRoomCounts: floorRoomCounts ?? this.floorRoomCounts,
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
      validationMessage: validationMessage ?? this.validationMessage,
      foodLicense: foodLicense ?? this.foodLicense,
      hostelLicense: hostelLicense ?? this.hostelLicense,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      fireSafety: fireSafety ?? this.fireSafety,
      policeNoc: policeNoc ?? this.policeNoc,
      shopsEstablishment: shopsEstablishment ?? this.shopsEstablishment,
      gstRegistration: gstRegistration ?? this.gstRegistration,
      healthSanitation: healthSanitation ?? this.healthSanitation,
      utilityBill: utilityBill ?? this.utilityBill,
      pollutionNoc: pollutionNoc ?? this.pollutionNoc,
      residentVerification: residentVerification ?? this.residentVerification,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      categorizedImages: categorizedImages ?? this.categorizedImages,
      roomMasters: roomMasters ?? this.roomMasters,
      roomCategories: roomCategories ?? this.roomCategories,
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
      'pincode': pincode,
      'hostelType': hostelType,
      'gstNumber': gstNumber,
      'images': images,
      'selectedFloors': selectedFloors,
      'floorRoomCounts': floorRoomCounts,
      'selectedAmenities': selectedAmenities,
      'isBulkMode': isBulkMode,
      'roomStartRange': roomStartRange,
      'roomEndRange': roomEndRange,
      'sharingType': sharingType,
      'roomType': roomType,
      'masterPricing': masterPricing,
      'rooms': rooms,
      'hostelId': hostelId,
      'foodLicense': foodLicense,
      'hostelLicense': hostelLicense,
      'tradeLicense': tradeLicense,
      'fireSafety': fireSafety,
      'policeNoc': policeNoc,
      'shopsEstablishment': shopsEstablishment,
      'gstRegistration': gstRegistration,
      'healthSanitation': healthSanitation,
      'utilityBill': utilityBill,
      'pollutionNoc': pollutionNoc,
      'residentVerification': residentVerification,
      'detailedAddress': detailedAddress,
      'categorizedImages': categorizedImages,
      'roomMasters': roomMasters,
      'roomCategories': roomCategories,
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
      pincode: json['pincode'] ?? '',
      hostelType: json['hostelType'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      selectedFloors: List<String>.from(json['selectedFloors'] ?? []),
      floorRoomCounts: Map<String, int>.from(json['floorRoomCounts'] ?? {}),
      selectedAmenities: List<String>.from(json['selectedAmenities'] ?? []),
      isBulkMode: json['isBulkMode'] ?? true,
      roomStartRange: json['roomStartRange'] ?? '',
      roomEndRange: json['roomEndRange'] ?? '',
      sharingType: json['sharingType'] ?? 2,
      roomType: json['roomType'] ?? 'Non-AC',
      masterPricing: Map<String, dynamic>.from(json['masterPricing'] ?? {}),
      rooms: List<Map<String, dynamic>>.from(json['rooms'] ?? []),
      hostelId: json['hostelId'],
      foodLicense: json['foodLicense'],
      hostelLicense: json['hostelLicense'],
      tradeLicense: json['tradeLicense'],
      fireSafety: json['fireSafety'],
      policeNoc: json['policeNoc'],
      shopsEstablishment: json['shopsEstablishment'],
      gstRegistration: json['gstRegistration'],
      healthSanitation: json['healthSanitation'],
      utilityBill: json['utilityBill'],
      pollutionNoc: json['pollutionNoc'],
      residentVerification: json['residentVerification'],
      detailedAddress: json['detailedAddress'] ?? '',
      categorizedImages: Map<String, List<String>>.from(
        (json['categorizedImages'] ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      ),
      roomMasters: List<Map<String, dynamic>>.from(json['roomMasters'] ?? []),
      roomCategories: List<Map<String, dynamic>>.from(json['roomCategories'] ?? []),
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
        pincode,
        hostelType,
        gstNumber,
        images,
        selectedFloors,
        floorRoomCounts,
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
        foodLicense,
        hostelLicense,
        tradeLicense,
        fireSafety,
        policeNoc,
        shopsEstablishment,
        gstRegistration,
        healthSanitation,
        utilityBill,
        pollutionNoc,
        residentVerification,
        detailedAddress,
        categorizedImages,
        roomMasters,
        roomCategories,
      ];
}
