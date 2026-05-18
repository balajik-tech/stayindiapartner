import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_service.dart';
import 'location_state.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService;

  LocationCubit(this._locationService) : super(LocationInitial());

  Future<void> fetchCurrentLocation() async {
    emit(LocationFetching());

    try {
      final result = await _locationService.getCurrentLocation();

      emit(
        LocationFetched(
          address: "${result.street ?? ''}, ${result.subLocality ?? ''}"
              .trim()
              .replaceAll(RegExp(r'^,\s*'), ''),
          area: result.locality ?? result.subLocality ?? '',
          city: result.locality ?? '',
          state: result.administrativeArea ?? '',
          district: result.subAdministrativeArea ?? '',
          pincode: result.pincode ?? '',
          latitude: result.latitude,
          longitude: result.longitude,
        ),
      );
    } catch (e) {
      emit(LocationError(GlobalErrorMapper.map(e).message));
    }
  }
}
