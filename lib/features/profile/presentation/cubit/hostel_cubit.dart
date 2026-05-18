import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/hostel_usecases.dart';
import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'hostel_state.dart';
import '../../data/models/hostel_model.dart';

class HostelCubit extends HydratedCubit<HostelState> {
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
  }) : _getHostels = getHostelsUseCase,
       _createHostel = createHostelUseCase,
       _updateHostel = updateHostelUseCase,
       _deleteHostel = deleteHostelUseCase,
       _uploadHostelImages = uploadHostelImagesUseCase,
       _updateHostelLocation = updateHostelLocationUseCase,
       super(const HostelInitial());

  Future<void> getHostels({bool forceRefresh = false}) async {
    if (isClosed) return;
    if (!state.isStale && !forceRefresh && state is HostelLoaded) {
      return;
    }

    final int currentIndex = state is HostelLoaded
        ? (state as HostelLoaded).selectedHostelIndex
        : 0;

    if (state is! HostelLoaded) {
      emit(HostelLoading(lastFetched: state.lastFetched));
    }

    try {
      final hostels = await _getHostels();
      if (isClosed) return;

      List<int> indices = state is HostelLoaded
          ? (state as HostelLoaded).selectedHostelIndices
          : [0];
      indices = indices.where((i) => i < hostels.length).toList();
      if (indices.isEmpty && hostels.isNotEmpty) indices = [0];

      emit(
        HostelLoaded(
          hostels: hostels,
          selectedHostelIndex: currentIndex < hostels.length ? currentIndex : 0,
          selectedHostelIndices: indices,
          lastFetched: DateTime.now(),
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  void selectHostel(int index) {
    if (state is HostelLoaded) {
      final loadedState = state as HostelLoaded;
      if (index >= 0 && index < loadedState.hostels.length) {
        emit(
          HostelLoaded(
            hostels: loadedState.hostels,
            selectedHostelIndex: index,
            selectedHostelIndices: [index],
            lastFetched: loadedState.lastFetched,
          ),
        );
      }
    }
  }

  void toggleHostelSelection(int index) {
    if (state is HostelLoaded) {
      final loadedState = state as HostelLoaded;
      if (index >= 0 && index < loadedState.hostels.length) {
        List<int> newIndices = List.from(loadedState.selectedHostelIndices);
        if (newIndices.contains(index)) {
          if (newIndices.length > 1) {
            newIndices.remove(index);
          }
        } else {
          newIndices.add(index);
        }

        emit(
          HostelLoaded(
            hostels: loadedState.hostels,
            selectedHostelIndex: newIndices.first,
            selectedHostelIndices: newIndices,
            lastFetched: loadedState.lastFetched,
          ),
        );
      }
    }
  }

  void reset() {
    emit(const HostelInitial());
  }

  Future<void> createHostel({
    required String name,
    required String address,
    required int floors,
    required String hostelType,
    required String city,
    required String stateName,
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
    emit(HostelLoading(lastFetched: state.lastFetched));
    try {
      final hostel = Hostel(
        id: '',
        name: name,
        address: address,
        floors: floors,
        hostelType: hostelType,
        city: city,
        state: stateName,
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
      emit(
        HostelOperationSuccess(
          message: 'Hostel created successfully',
          hostelId: createdHostel.id,
        ),
      );
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  Future<void> updateHostel(Hostel hostel) async {
    if (isClosed) return;
    emit(HostelLoading(lastFetched: state.lastFetched));
    try {
      await _updateHostel(hostel);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Hostel updated successfully'));
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  Future<void> uploadHostelImages({
    required String id,
    required List<String> filePaths,
  }) async {
    if (isClosed) return;
    emit(HostelLoading(lastFetched: state.lastFetched));
    try {
      await _uploadHostelImages(id, filePaths);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Images uploaded successfully'));
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  Future<void> deleteHostel(String id) async {
    if (isClosed) return;
    emit(HostelLoading(lastFetched: state.lastFetched));
    try {
      await _deleteHostel(id);
      if (isClosed) return;
      emit(HostelOperationSuccess(message: 'Hostel deleted successfully'));
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  Future<void> updateHostelLocation({
    required String id,
    required double lat,
    required double lng,
  }) async {
    if (isClosed) return;
    emit(HostelLoading(lastFetched: state.lastFetched));
    try {
      await _updateHostelLocation(id, lat, lng);
      if (isClosed) return;
      emit(
        HostelOperationSuccess(
          message: 'Property location updated successfully',
        ),
      );
      await getHostels(forceRefresh: true);
    } catch (e) {
      if (!isClosed) {
        emit(HostelError(message: ErrorHandler.getErrorMessage(e)));
      }
    }
  }

  @override
  HostelState? fromJson(Map<String, dynamic> json) {
    try {
      final lastFetchedStr = json['lastFetched'] as String?;
      final lastFetched = lastFetchedStr != null
          ? DateTime.parse(lastFetchedStr)
          : null;

      final hostelsJson = json['hostels'] as List<dynamic>?;
      final hostels = hostelsJson?.map((e) => HostelModel.fromJson(e)).toList();

      if (hostels != null && hostels.isNotEmpty) {
        final selectedHostelIndex = json['selectedHostelIndex'] as int? ?? 0;
        final selectedHostelIndices =
            (json['selectedHostelIndices'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [0];

        return HostelLoaded(
          hostels: hostels,
          selectedHostelIndex: selectedHostelIndex < hostels.length
              ? selectedHostelIndex
              : 0,
          selectedHostelIndices: selectedHostelIndices
              .where((i) => i < hostels.length)
              .toList(),
          lastFetched: lastFetched,
        );
      }

      return HostelInitial(lastFetched: lastFetched);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(HostelState state) {
    if (state is HostelLoaded) {
      return {
        'lastFetched': state.lastFetched?.toIso8601String(),
        'hostels': state.hostels
            .map((e) => (e as HostelModel).toJson())
            .toList(),
        'selectedHostelIndex': state.selectedHostelIndex,
        'selectedHostelIndices': state.selectedHostelIndices,
      };
    }
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
