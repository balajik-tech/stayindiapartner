import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationFetching extends LocationState {}

class LocationFetched extends LocationState {
  final String address;
  final String area;
  final String city;
  final String state;
  final String district;
  final String pincode;
  final double latitude;
  final double longitude;

  const LocationFetched({
    required this.address,
    required this.area,
    required this.city,
    required this.state,
    required this.district,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, area, city, state, district, pincode, latitude, longitude];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
