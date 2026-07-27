import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_state.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

class AddTenantCubit extends Cubit<AddTenantState> {
  final GetFloorsUseCase _getFloors;
  final GetRoomsByFloorUseCase _getRoomsByFloor;
  final GetFreeBedsUseCase _getFreeBeds;
  final AddTenantUseCase _addTenant;

  AddTenantCubit({
    required GetFloorsUseCase getFloorsUseCase,
    required GetRoomsByFloorUseCase getRoomsByFloorUseCase,
    required GetFreeBedsUseCase getFreeBedsUseCase,
    required AddTenantUseCase addTenantUseCase,
  }) : _getFloors = getFloorsUseCase,
       _getRoomsByFloor = getRoomsByFloorUseCase,
       _getFreeBeds = getFreeBedsUseCase,
       _addTenant = addTenantUseCase,
       super(AddTenantInitial());

  void selectHostel(Hostel hostel) async {
    emit(const AddTenantLoading(message: "Loading floors..."));
    try {
      final floors = await _getFloors(hostel.id);
      emit(AddTenantFloorsLoaded(hostel: hostel, floors: floors));
    } catch (e) {
      emit(AddTenantError(ErrorHandler.getErrorMessage(e)));
    }
  }

  void selectFloor(Hostel hostel, int floor, List<int> floors) async {
    emit(const AddTenantLoading(message: "Loading rooms..."));
    try {
      final rooms = await _getRoomsByFloor(hostel.id, floor);
      emit(
        AddTenantRoomsLoaded(
          hostel: hostel,
          floors: floors,
          selectedFloor: floor,
          rooms: rooms,
        ),
      );
    } catch (e) {
      emit(AddTenantError(ErrorHandler.getErrorMessage(e)));
    }
  }

  void selectRoom(
    Hostel hostel,
    int floor,
    List<int> floors,
    RoomDetail room,
    List<RoomDetail> rooms,
  ) async {
    emit(const AddTenantLoading(message: "Loading beds..."));
    try {
      final beds = await _getFreeBeds(room.id);
      emit(
        AddTenantBedsLoaded(
          hostel: hostel,
          floors: floors,
          selectedFloor: floor,
          rooms: rooms,
          selectedRoom: room,
          beds: beds,
        ),
      );
    } catch (e) {
      emit(AddTenantError(ErrorHandler.getErrorMessage(e)));
    }
  }

  void selectBed(
    Hostel hostel,
    int floor,
    List<int> floors,
    RoomDetail room,
    List<RoomDetail> rooms,
    String bed,
    List<String> beds,
  ) {
    emit(
      AddTenantReady(
        hostel: hostel,
        floors: floors,
        selectedFloor: floor,
        rooms: rooms,
        selectedRoom: room,
        beds: beds,
        selectedBed: bed,
      ),
    );
  }

  Future<void> submit({
    required Hostel hostel,
    required RoomDetail room,
    required String bed,
    required String phone,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    double? deposit,
    required DateTime startDate,
    String? userPhotoPath,
    String? aadharPhotoPath,
    String? bookingType,
    String? maintenance,
    String? roomType,
    required DateTime endDate
  }) async {
    emit(AddTenantSubmitting());
    try {
      await _addTenant(
        phone: phone,
        hostelId: hostel.id,
        roomId: room.id,
        bedNumber: bed,
        rent: rent,
        firstName: firstName,
        lastName: lastName,
        sharingType: sharingType,
        startDate:
            "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        deposit: deposit,
        userPhotoPath: userPhotoPath,
        aadharPhotoPath: aadharPhotoPath,
        bookingType:bookingType,
        maintenance:maintenance,
        roomType:roomType,
        endDate: "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",

    );
      emit(AddTenantSuccess());
    } catch (e) {
      emit(AddTenantError(ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
