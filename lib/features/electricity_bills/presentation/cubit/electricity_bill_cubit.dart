import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import '../../data/datasources/electricity_remote_datasource.dart';
import '../../data/models/electricity_bill_model.dart';
import 'electricity_bill_state.dart';

class ElectricityBillCubit extends Cubit<ElectricityBillState> {
  final GetDashboardDataUseCase? _getDashboardDataUseCase;
  final ElectricityRemoteDataSource? _remoteDataSource;

  ElectricityBillCubit({
    GetDashboardDataUseCase? getDashboardDataUseCase,
    ElectricityRemoteDataSource? remoteDataSource,
  })  : _getDashboardDataUseCase = getDashboardDataUseCase,
        _remoteDataSource = remoteDataSource,
        super(ElectricityBillState());

  Future<void> loadRoomsAndData({
    required String hostelId,
    String? defaultPgName,
  }) async {
    final updatedPgName =
        (state.pgName == 'My PG' && defaultPgName != null && defaultPgName.isNotEmpty)
            ? defaultPgName
            : state.pgName;

    emit(state.copyWith(
      isLoading: true,
      hostelId: hostelId,
      pgName: updatedPgName,
    ));

    if (hostelId.isEmpty || _getDashboardDataUseCase == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    try {
      final dashboardData = await _getDashboardDataUseCase.call(hostelId);
      final apiRooms = <ElectricityRoomModel>[];

      for (final floor in dashboardData.occupancy.floors) {
        for (final room in floor.rooms) {
          final hasOccupiedBed = room.beds.any((bed) {
            final s = bed.status.toUpperCase();
            return s == 'OCCUPIED' || s == 'NOTICE' || s == 'AWAY';
          });

          if (!hasOccupiedBed) continue;

          final code = StringUtils.formatRoomNumber(
            room.roomNumber,
            floor.floorNum ?? floor.floorName,
          );
          final name = room.roomNumber.contains('Room')
              ? room.roomNumber
              : 'Room $code';

          if (code.isNotEmpty && !apiRooms.any((r) => r.code == code)) {
            apiRooms.add(ElectricityRoomModel(
              id: room.id.isNotEmpty ? room.id : code,
              code: code,
              name: name,
              isCustom: false,
            ));
          }
        }
      }

      final mergedRooms = <ElectricityRoomModel>[];

      for (var apiRoom in apiRooms) {
        mergedRooms.add(apiRoom);
      }

      for (var existingRoom in state.rooms) {
        if (!mergedRooms.any((r) => r.code == existingRoom.code)) {
          mergedRooms.add(existingRoom);
        }
      }

      emit(state.copyWith(
        isLoading: false,
        rooms: mergedRooms,
      ));
      AppLogger.success('Electricity bills occupied rooms loaded successfully: ${mergedRooms.length}');

      await fetchBillsForHostel();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load bulk dashboard rooms for electricity bills', e, stackTrace);
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> fetchBillsForHostel({DateTime? fromDate, DateTime? toDate}) async {
    if (state.hostelId.isEmpty || _remoteDataSource == null) return;

    try {
      final start = fromDate ?? state.fromDate;
      final end = toDate ?? state.toDate;

      final dateFromStr = DateFormat('yyyy-MM-dd').format(start);
      final dateToStr = DateFormat('yyyy-MM-dd').format(end);

      final response = await _remoteDataSource.fetchElectricityBills(
        hostelId: state.hostelId,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      final dataObj = response['data'];
      final billsList = <ElectricityBillModel>[];

      if (dataObj is Map<String, dynamic> && dataObj['bills'] is List) {
        final list = dataObj['bills'] as List;
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            billsList.add(ElectricityBillModel.fromJson(item));
          }
        }
      }

      emit(state.copyWith(bills: billsList));
      // AppLogger.success('Fetched ${billsList.length} electricity bills from API for range $dateFromStr to $dateToStr');
    } catch (e) {
      AppLogger.error('Failed to fetch electricity bills from API', e);
    }
  }

  Future<bool> createElectricityBill(ElectricityBillModel bill) async {
    final payload = {
      "hostelId": bill.hostelId.isNotEmpty ? bill.hostelId : state.hostelId,
      "roomId": bill.roomId,
      "billAmount": bill.amount,
      "billStartDate": DateFormat('yyyy-MM-dd').format(bill.billStartDate),
      "billEndDate": DateFormat('yyyy-MM-dd').format(bill.billEndDate),
      "month": bill.month.isNotEmpty
          ? bill.month
          : DateFormat('MMMM yyyy').format(bill.billStartDate),
      "dueDate": DateFormat('yyyy-MM-dd').format(bill.dueDate),
      "notes": bill.note ?? "",
    };

    try {
      if (_remoteDataSource != null) {
        final responseData = await _remoteDataSource.createElectricityBill(payload);
        final data = responseData['data'];

        ElectricityBillModel createdBill = bill;
        if (data is Map<String, dynamic>) {
          createdBill = ElectricityBillModel.fromJson(data).copyWith(
            roomCode: bill.roomCode,
            roomName: bill.roomName,
            hostelId: bill.hostelId,
            roomId: bill.roomId,
            note: bill.note,
          );
        }

        addBill(createdBill);
        return true;
      }
    } catch (e) {
      AppLogger.error('Error calling createElectricityBill API', e);
      addBill(bill);
      rethrow;
    }

    addBill(bill);
    return true;
  }

  Future<bool> updateElectricityBillApi(ElectricityBillModel bill) async {
    final payload = {
      "billAmount": bill.amount,
      "dueDate": DateFormat('yyyy-MM-dd').format(bill.dueDate),
      "notes": bill.note ?? "",
    };

    try {
      if (_remoteDataSource != null) {
        final responseData = await _remoteDataSource.updateElectricityBill(bill.id, payload);
        final data = responseData['data'];

        ElectricityBillModel updatedBill = bill;
        if (data is Map<String, dynamic>) {
          updatedBill = ElectricityBillModel.fromJson(data).copyWith(
            roomCode: bill.roomCode,
            roomName: bill.roomName,
            hostelId: bill.hostelId,
            roomId: bill.roomId,
            note: bill.note,
          );
        }

        updateBill(updatedBill);
        return true;
      }
    } catch (e) {
      AppLogger.error('Error calling updateElectricityBill API', e);
      updateBill(bill);
      rethrow;
    }

    updateBill(bill);
    return true;
  }

  Future<bool> updateTenantBillStatusApi({
    required String billId,
    required String tenantId,
    required String paymentMethod,
    String? reference,
    String? notes,
  }) async {
    final payload = {
      "status": "PAID",
      "paymentMethod": paymentMethod,
      "reference": reference ?? "",
      "notes": notes ?? "",
    };

    try {
      if (_remoteDataSource != null) {
        await _remoteDataSource.updateTenantBillStatus(
          billId: billId,
          tenantId: tenantId,
          payload: payload,
        );

        await fetchBillsForHostel();
        return true;
      }
    } catch (e) {
      AppLogger.error('Error updating tenant bill status', e);
      rethrow;
    }

    return false;
  }

  void setFilterType(DateFilterType filterType) {
    final now = DateTime.now();
    DateTime fromDate;
    DateTime toDate;

    switch (filterType) {
      case DateFilterType.thisMonth:
        fromDate = DateTime(now.year, now.month, 1);
        toDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case DateFilterType.lastMonth:
        fromDate = DateTime(now.year, now.month - 1, 1);
        toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case DateFilterType.last30Days:
        fromDate = now.subtract(const Duration(days: 30));
        toDate = now;
        break;
      case DateFilterType.custom:
        fromDate = state.fromDate;
        toDate = state.toDate;
        break;
    }

    emit(state.copyWith(
      filterType: filterType,
      fromDate: fromDate,
      toDate: toDate,
    ));

    fetchBillsForHostel(fromDate: fromDate, toDate: toDate);
  }

  void setDateRange(DateTime from, DateTime to) {
    final adjustedFrom = DateTime(from.year, from.month, from.day, 0, 0, 0);
    final adjustedTo = DateTime(to.year, to.month, to.day, 23, 59, 59);

    emit(state.copyWith(
      filterType: DateFilterType.custom,
      fromDate: adjustedFrom,
      toDate: adjustedTo,
    ));

    fetchBillsForHostel(fromDate: adjustedFrom, toDate: adjustedTo);
  }

  void addBill(ElectricityBillModel bill) {
    final updatedBills = List<ElectricityBillModel>.from(state.bills);
    final existingIndex = updatedBills.indexWhere((b) => b.id == bill.id);

    if (existingIndex >= 0) {
      updatedBills[existingIndex] = bill;
    } else {
      updatedBills.add(bill);
    }

    emit(state.copyWith(bills: updatedBills));
  }

  void updateBill(ElectricityBillModel bill) {
    addBill(bill);
  }

  Future<bool> deleteBill(String billId) async {
    try {
      if (_remoteDataSource != null) {
        await _remoteDataSource.deleteElectricityBill(billId);
      }
      final updatedBills = state.bills.where((b) => b.id != billId).toList();
      emit(state.copyWith(bills: updatedBills));
      return true;
    } catch (e) {
      AppLogger.error('Error calling deleteElectricityBill API', e);
      rethrow;
    }
  }

  void updateSettings({
    required String pgName,
    required String subtitle,
    required List<ElectricityRoomModel> rooms,
  }) {
    emit(state.copyWith(
      pgName: pgName.trim().isNotEmpty ? pgName.trim() : state.pgName,
      subtitle: subtitle,
      rooms: rooms,
    ));
  }

  void addCustomRooms(String roomsInput) {
    if (roomsInput.trim().isEmpty) return;

    final parts = roomsInput.split(RegExp(r'[,;\n]'));
    final currentRooms = List<ElectricityRoomModel>.from(state.rooms);

    for (var part in parts) {
      final code = part.replaceAll(RegExp(r'^Room\s*', caseSensitive: false), '').trim();
      if (code.isNotEmpty && !currentRooms.any((r) => r.code.toLowerCase() == code.toLowerCase())) {
        currentRooms.add(ElectricityRoomModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + code,
          code: code,
          name: 'Room $code',
          isCustom: true,
        ));
      }
    }

    emit(state.copyWith(rooms: currentRooms));
  }

  void deleteRoom(String roomCode) {
    final updatedRooms = state.rooms.where((r) => r.code != roomCode).toList();
    emit(state.copyWith(rooms: updatedRooms));
  }
}
