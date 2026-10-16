import 'dart:io';

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
  final BulkUploadTenantsUseCase _bulkUpload;

  AddTenantCubit({
    required GetFloorsUseCase getFloorsUseCase,
    required GetRoomsByFloorUseCase getRoomsByFloorUseCase,
    required GetFreeBedsUseCase getFreeBedsUseCase,
    required AddTenantUseCase addTenantUseCase,
    required BulkUploadTenantsUseCase bulkUploadTenantsUseCase,
  }) : _getFloors = getFloorsUseCase,
       _getRoomsByFloor = getRoomsByFloorUseCase,
       _getFreeBeds = getFreeBedsUseCase,
       _addTenant = addTenantUseCase,
       _bulkUpload = bulkUploadTenantsUseCase,
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

  Future<Map<String, dynamic>?> submit({
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
    String? aadharCardbackPath,
    String? employeeIdProofPath,
    List<Map<String, String>>? guardianMobiles,
    String? bookingType,
    String? maintenance,
    String? roomType,
    required DateTime endDate,
    String? email,
    String? aadhaarNumber,
    String? dob,
    String? gender,
    String? address,
    double? totalAmount,
    bool? isexistingTenant,
  }) async {
    emit(AddTenantSubmitting());
    try {
      final response = await _addTenant(
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
        aadharCardbackPath: aadharCardbackPath,
        employeeIdProofPath: employeeIdProofPath,
        guardianMobiles: guardianMobiles,
        bookingType: bookingType,
        maintenance: maintenance,
        roomType: roomType,
        endDate: "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        email: email,
        aadhaarNumber: aadhaarNumber,
        dob: dob,
        gender: gender,
        address: address,
        totalAmount: totalAmount,
        isexistingTenant: isexistingTenant,
    );
      emit(AddTenantSuccess(data: response));
      return response;
    } catch (e) {
      emit(AddTenantError(ErrorHelper.toFriendlyMessage(e)));
      return null;
    }
  }

  Future<void> bulkUpload(File file, String hostelId) async {
    emit(const AddTenantLoading(message: "Processing bulk upload..."));
    try {
      final response = await _bulkUpload(file, hostelId);
      final success = response['success'] == true || response['status'] == 'success';
      final message = response['message'] ?? 'Bulk upload processed';
      
      if (success) {
        emit(AddTenantSuccess(message: message));
      } else {
        emit(AddTenantError(message));
      }
    } catch (e) {
      emit(AddTenantError(ErrorHelper.toFriendlyMessage(e)));
    }
  }

  void reset() {
    emit(AddTenantInitial());
  }
}
