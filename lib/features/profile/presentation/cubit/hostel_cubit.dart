import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/hostel_usecases.dart';
import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'hostel_state.dart';

class HostelCubit extends Cubit<HostelState> {
  final GetHostelsUseCase _getHostels;
  final CreateHostelUseCase _createHostel;
  final UpdateHostelUseCase _updateHostel;
  final DeleteHostelUseCase _deleteHostel;
  final UploadHostelImagesUseCase _uploadHostelImages;
  final UpdateHostelLocationUseCase _updateHostelLocation;

  HostelCubit({
    required GetHostelsUseCase getHostelsUseCase,
    required CreateHostelUseCase createHostelUseCase,
    required UpdateHostelUseCase updateHostelUseCase,
    required DeleteHostelUseCase deleteHostelUseCase,
    required UploadHostelImagesUseCase uploadHostelImagesUseCase,
    required UpdateHostelLocationUseCase updateHostelLocationUseCase,
  })  : _getHostels = getHostelsUseCase,
        _createHostel = createHostelUseCase,
        _updateHostel = updateHostelUseCase,
        _deleteHostel = deleteHostelUseCase,
        _uploadHostelImages = uploadHostelImagesUseCase,
        _updateHostelLocation = updateHostelLocationUseCase,
        super(HostelInitial());

  Future<void> getHostels({bool forceRefresh = false}) async {
    if (isClosed) return;
    if (!state.isStale && !forceRefresh && state is HostelLoaded) {
      return;
    }

    final int currentIndex = state is HostelLoaded ? (state as HostelLoaded).selectedHostelIndex : 0;
    
    if (state is! HostelLoaded) {
      emit(HostelLoading(lastFetched: state.lastFetched));
    }
    
    try {
      final hostels = await _getHostels();
      if (isClosed) return;
      emit(HostelLoaded(
        hostels: hostels,
        selectedHostelIndex: currentIndex < hostels.length ? currentIndex : 0,
        lastFetched: DateTime.now(),
      ));
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  void selectHostel(int index) {
    if (state is HostelLoaded) {
      final loadedState = state as HostelLoaded;
      if (index >= 0 && index < loadedState.hostels.length) {
        emit(HostelLoaded(
          hostels: loadedState.hostels,
          selectedHostelIndex: index,
        ));
      }
    }
  }

  Future<void> createHostel({
    required String name,
    required String address,
    required int floors,
    required String hostelType,
    required String city,
    required String state,
    String area = '',
    String district = '',
    String village = '',
    String pincode = '',
    String contactNumber = '',
    String description = '',
    String propertyTag = 'PG',
    double? lat,
    double? lng,
  }) async {
    if (isClosed) return;
    emit(HostelLoading());
    try {
      final hostel = Hostel(
        id: '',
        name: name,
        address: address,
        floors: floors,
        hostelType: hostelType,
        city: city,
        state: state,
        area: area,
        district: district,
        village: village,
        pincode: pincode,
        contactNumber: contactNumber,
        description: description,
        propertyTag: propertyTag,
        lat: lat,
        lng: lng,
      );
      final createdHostel = await _createHostel(hostel);
      if (isClosed) return;
      emit(HostelOperationSuccess(
        message: 'Hostel created successfully',
        hostelId: createdHostel.id,
      ));
      await getHostels();
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateHostel(Hostel hostel) async {
    if (isClosed) return;
    emit(HostelLoading());
    try {
      await _updateHostel(hostel);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Hostel updated successfully'));
      await getHostels();
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> uploadHostelImages({
    required String id,
    required List<String> filePaths,
  }) async {
    if (isClosed) return;
    emit(HostelLoading());
    try {
      await _uploadHostelImages(id, filePaths);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Images uploaded successfully'));
      await getHostels();
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> deleteHostel(String id) async {
    if (isClosed) return;
    emit(HostelLoading());
    try {
      await _deleteHostel(id);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Hostel deleted successfully'));
      await getHostels();
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateHostelLocation({
    required String id,
    required double lat,
    required double lng,
  }) async {
    if (isClosed) return;
    emit(HostelLoading());
    try {
      await _updateHostelLocation(id, lat, lng);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Property location updated successfully'));
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
    }
  }
}
