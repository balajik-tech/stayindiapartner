import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? street;
  final String? subLocality;
  final String? locality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? pincode;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.street,
    this.subLocality,
    this.locality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.pincode,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? street, subLocality, locality, administrativeArea, subAdministrativeArea, pincode;

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      street = place.street;
      subLocality = place.subLocality;
      locality = place.locality;
      administrativeArea = place.administrativeArea;
      subAdministrativeArea = place.subAdministrativeArea;
      pincode = place.postalCode;
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      street: street,
      subLocality: subLocality,
      locality: locality,
      administrativeArea: administrativeArea,
      subAdministrativeArea: subAdministrativeArea,
      pincode: pincode,
    );
  }
}
