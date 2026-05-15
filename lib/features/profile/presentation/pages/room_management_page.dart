import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/room_pricing_page.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';


class RoomManagementPage extends StatefulWidget {
  final Hostel hostel;
  final String floorName;
  final bool isSetupMode;
  final bool isDraftMode;
  final int? draftRoomCount;

  const RoomManagementPage({
    super.key,
    required this.hostel,
    required this.floorName,
    this.isSetupMode = false,
    this.isDraftMode = false,
    this.draftRoomCount,
  });

  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  DashboardData? _lastData;
  Timer? _refreshTimer;

  void _requestRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.read<DashboardCubit>().fetchDashboardData(widget.hostel.id);
      }
    });
  }
  List<RoomDetail>? _draftRooms;
  final Map<String, RoomDetail> _modifiedRooms = {};


  @override
  void initState() {
    super.initState();
    if (widget.isDraftMode && widget.draftRoomCount != null) {
      _initDraftRooms();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initDraftRooms() {
    final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    _draftRooms = List.generate(widget.draftRoomCount!, (index) {
      final roomNo = (floorNum * 100) + (index + 1);
      return RoomDetail(
        id: 'draft_$index',
        hostelId: widget.hostel.id,
        roomTypename: roomNo.toString(),
        floor: floorNum,
        sharingType: 'SINGLE',
        roomType: 'NON-AC',
        rent: 0,
        deposit: 0,
        maintenance: 0,
        isActive: true,
        isMaster: false,
        capacity: 1,
        features: [],
        beds: [],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomCubit, RoomState>(
      listener: (context, state) {
        if (state is RoomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        } else if (state is RoomOperationSuccess && !widget.isDraftMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            widget.isSetupMode ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.isSetupMode ? 'Setup Property' : 'Room Config',
              style: TextStyle(
                color: const Color(0xFF2C5990),
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (widget.isSetupMode)
              Text(
                'Step 3 of 4',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(widget.isSetupMode ? 6.h : 1.h),
          child: Column(
            children: [
              if (widget.isSetupMode)
                LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF98125)),
                  minHeight: 4.h,
                ),
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
            ],
          ),
        ),
      ),
      body: widget.isSetupMode
          ? BlocBuilder<PropertySetupCubit, PropertySetupState>(
              builder: (context, state) {
                final filteredRooms = state.rooms.where((r) {
                  final roomFloor = r['floor']?.toString().toLowerCase() ?? '';
                  final targetFloor = widget.floorName.toLowerCase();
                  return roomFloor == targetFloor ||
                      roomFloor.contains(targetFloor) ||
                      targetFloor.contains(roomFloor);
                }).toList();

                return _buildMainContent(context, null, filteredRooms, state.isSaving);
              },
            )
          : (widget.isDraftMode
              ? _buildMainContent(context, null, _draftRooms ?? [], false)
              : BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoaded) {
                      _lastData = state.data;
                    }

                    final currentData = state is DashboardLoaded ? state.data : _lastData;

                    if (currentData == null) {
                      if (state is DashboardLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                      }
                      return const Center(child: Text('No data available'));
                    }

                    final floor = currentData.occupancy.floors.cast<entity.FloorData>().firstWhere(
                      (f) {
                        final fName = f.floorName.toLowerCase();
                        final targetName = widget.floorName.toLowerCase();
                        return fName == targetName ||
                            fName.contains(targetName) ||
                            targetName.contains(fName) ||
                            (targetName.replaceAll(RegExp(r'[^0-9]'), '') == fName.replaceAll(RegExp(r'[^0-9]'), '') && targetName.replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty);
                      },
                      orElse: () => entity.FloorData(floorName: widget.floorName, bedInfo: '', rooms: []),
                    );

                    final allRooms = [...floor.rooms, ...?_draftRooms];
                    return _buildMainContent(context, state, allRooms, false);
                  },
                )),
      floatingActionButton: null,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState? dashboardState, List<dynamic> rooms, bool isSaving) {
    if (rooms.isEmpty && (dashboardState == null || dashboardState is! DashboardLoading)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.meeting_room_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
            ),
            SizedBox(height: 24.h),
            Text(
              'No rooms found',
              style: TextStyle(color: const Color(0xFF1E293B), fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
            if (!widget.isSetupMode) ...[
              SizedBox(height: 24.h),
              BouncingWrapper(
                onTap: () => context.read<DashboardCubit>().fetchDashboardData(widget.hostel.id),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Refresh Data',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        if (dashboardState is DashboardLoading || isSaving)
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            minHeight: 2.h,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSectionHeader('Room Config', 'Customize features for each room.'),
              ),
              SizedBox(width: 8.w),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                alignment: WrapAlignment.end,
                children: [
                  BouncingWrapper(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _addQuickRoom();
                    },
                    onLongPress: () {
                      HapticFeedback.heavyImpact();
                      _showBulkAddDialog();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF98125).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF98125).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: const Color(0xFFF98125), size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'ADD',
                            style: TextStyle(color: const Color(0xFFF98125), fontSize: 10.sp, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!widget.isSetupMode && !widget.isDraftMode) _buildCloneButton(context, rooms.map((r) {
                    if (r is entity.Room) return r;
                    final rd = r as RoomDetail;
                    return entity.Room(
                      id: rd.id,
                      roomNumber: rd.roomTypename,
                      sharingType: rd.sharingType,
                      roomType: rd.roomType,
                      occupancy: '0/${rd.beds.length} beds',
                      tenantImages: [],
                      beds: rd.beds.map((b) => entity.BedInfo(bedNumber: b.bedNumber, status: b.status)).toList(),
                      rent: rd.rent,
                      dailyRent: rd.dailyRent,
                      maintenance: rd.maintenance,
                      features: rd.features,
                      floorName: widget.floorName,
                    );
                  }).toList()),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(20.r),
            physics: const BouncingScrollPhysics(),
            itemCount: rooms.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final room = rooms[index];
              if (widget.isSetupMode) {
                return _RoomManageCard(
                  key: ValueKey('setup_${widget.floorName}_$index'),
                  roomMap: room as Map<String, dynamic>,
                  roomIndex: index,
                  hostel: widget.hostel,
                  floorName: widget.floorName,
                  isSetupMode: true,
                  onSaveComplete: _requestRefresh,
                );
              } else if (widget.isDraftMode) {
                return _RoomManageCard(
                  key: ValueKey((room as RoomDetail).id),
                  draftRoom: room,
                  roomIndex: index,
                  hostel: widget.hostel,
                  floorName: widget.floorName,
                  isDraftMode: true,
                  onDraftUpdate: (updatedRoom) {
                    setState(() {
                      _draftRooms![index] = updatedRoom;
                    });
                  },
                );
              } else {
                if (room is entity.Room) {
                  final RoomDetail currentDraft = _modifiedRooms[room.id] ?? RoomDetail(
                    id: room.id,
                    hostelId: widget.hostel.id,
                    roomTypename: room.roomNumber,
                    floor: int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                    sharingType: room.sharingType,
                    roomType: room.roomType ?? 'NON-AC',
                    rent: room.rent ?? 0,
                    deposit: 0,
                    maintenance: room.maintenance ?? 0,
                    isActive: true,
                    isMaster: false,
                    capacity: room.beds.length,
                    features: List<String>.from(room.features),
                    beds: room.beds.map((b) => BedInfo(bedNumber: b.bedNumber, status: b.status)).toList(),
                  );

                  return _RoomManageCard(
                    key: ValueKey(room.id),
                    draftRoom: currentDraft,
                    hostel: widget.hostel,
                    floorName: widget.floorName,
                    isDraftMode: true,
                    onDraftUpdate: (updatedRoom) {
                      setState(() {
                        _modifiedRooms[room.id] = updatedRoom;
                      });
                    },
                    onSaveComplete: _requestRefresh,
                  );
                } else {
                  final draftRoom = room as RoomDetail;
                  return _RoomManageCard(
                    key: ValueKey(draftRoom.id),
                    draftRoom: draftRoom,
                    roomIndex: index,
                    hostel: widget.hostel,
                    floorName: widget.floorName,
                    isDraftMode: true,
                    onSaveComplete: _requestRefresh,
                    onDraftUpdate: (updatedRoom) {
                      setState(() {
                        final draftIdx = _draftRooms?.indexWhere((dr) => dr.id == draftRoom.id) ?? -1;
                        if (draftIdx != -1) {
                           _draftRooms![draftIdx] = updatedRoom;
                        }
                      });
                    },
                  );
                }
              }
            },
          ),
        ),
        if (widget.isDraftMode) _buildDraftActions(context) else _buildBottomActions(context, rooms),
      ],
    );
  }

  Widget _buildDraftActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: const BorderSide(color: Color(0xFF2C5990), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF2C5990), fontWeight: FontWeight.w800)),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _proceedToPricing(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5990),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                shadowColor: const Color(0xFF2C5990).withValues(alpha: 0.3),
              ),
              child: const Text('Set Pricing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPricing() {
    final List<RoomDetail> allRooms = [];
    
    if (_lastData != null) {
      for (var floor in _lastData!.occupancy.floors) {
        for (var r in floor.rooms) {
          allRooms.add(RoomDetail(
            id: r.id,
            hostelId: widget.hostel.id,
            roomTypename: r.roomNumber,
            floor: int.tryParse(floor.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
            sharingType: r.sharingType,
            roomType: r.roomType ?? 'NON-AC',
            rent: r.rent ?? 0,
            deposit: 0,
            maintenance: r.maintenance ?? 0,
            isActive: true,
            isMaster: false,
            capacity: r.beds.length,
            features: List<String>.from(r.features),
            beds: r.beds.map((b) => BedInfo(bedNumber: b.bedNumber, status: b.status)).toList(),
          ));
        }
      }
    }
    
    if (_draftRooms != null) {
      for (var dr in _draftRooms!) {
        if (!allRooms.any((r) => r.roomTypename == dr.roomTypename)) {
          allRooms.add(dr);
        }
      }
    }

    final roomCubit = context.read<RoomCubit>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: roomCubit),
          ],
          child: RoomPricingPage(
            hostel: widget.hostel,
            rooms: allRooms.isNotEmpty ? allRooms : _draftRooms,
          ),
        ),
      ),
    );
  }



  void _showAddRoomDialog(BuildContext context) {
    final roomNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('Add Room to ${widget.floorName}', style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Number', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: roomNoController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'e.g. 305',
                  hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              final roomNo = roomNoController.text.trim();
              if (roomNo.isEmpty) return;

              if (widget.isSetupMode) {
                final setupState = context.read<PropertySetupCubit>().state;
                context.read<PropertySetupCubit>().addManualRoom({
                  'roomNumber': roomNo,
                  'floor': widget.floorName,
                  'sharingType': setupState.sharingType,
                  'roomType': setupState.roomType,
                  'features': {
                    'isAC': setupState.roomType == 'AC',
                    'hasGeyser': false,
                    'hasBalcony': false,
                    'hasAttachedWashroom': false,
                  },
                  'beds': List.generate(setupState.sharingType, (index) => {
                    'bedNumber': String.fromCharCode(65 + index), 
                    'status': 'FREE',
                  }),
                });
              } else if (widget.isDraftMode) {
                final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final newRoom = RoomDetail(
                  id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
                  hostelId: widget.hostel.id,
                  roomTypename: roomNo,
                  floor: floorNum,
                  sharingType: 'SINGLE',
                  roomType: 'NON-AC',
                  rent: 0,
                  deposit: 0,
                  maintenance: 0,
                  isActive: true,
                  isMaster: false,
                  capacity: 1,
                  features: [],
                  beds: [],
                );
                setState(() {
                  _draftRooms ??= [];
                  _draftRooms!.add(newRoom);
                });
              } else {
                final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final newRoom = RoomDetail(
                  id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
                  hostelId: widget.hostel.id,
                  roomTypename: roomNo,
                  floor: floorNum,
                  sharingType: 'DOUBLE',
                  roomType: 'NON-AC',
                  rent: 0,
                  deposit: 0,
                  maintenance: 0,
                  isActive: true,
                  isMaster: false,
                  capacity: 2,
                  features: [],
                  beds: [],
                );
                setState(() {
                  _draftRooms ??= [];
                  _draftRooms!.add(newRoom);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Room $roomNo added (Pending save)')),
                );
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5990),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Add Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showBulkAddDialog() {
    final controller = TextEditingController(text: '5');
    final countNotifier = ValueNotifier<int>(5);
    
    controller.addListener(() {
      countNotifier.value = int.tryParse(controller.text) ?? 0;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Bulk Add Rooms', style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many rooms would you like to add sequentially?', style: TextStyle(color: const Color(0xFF64748B))),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Rooms',
                  labelStyle: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp),
                  prefixIcon: Icon(Icons.numbers_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ValueListenableBuilder<int>(
            valueListenable: countNotifier,
            builder: (context, count, _) {
              return ElevatedButton(
                onPressed: count > 0 ? () {
                  Navigator.pop(context);
                  _addQuickRoom(count: count);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5990),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('Add $count Rooms', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addQuickRoom({int count = 1}) async {
    for (int i = 0; i < count; i++) {
      final List<dynamic> currentRooms = [];
      if (widget.isSetupMode) {
        currentRooms.addAll(context.read<PropertySetupCubit>().state.rooms.where((r) {
          final roomFloor = r['floor']?.toString().toLowerCase() ?? '';
          final targetFloor = widget.floorName.toLowerCase();
          return roomFloor == targetFloor || roomFloor.contains(targetFloor);
        }));
      } else if (widget.isDraftMode) {
        currentRooms.addAll(_draftRooms ?? []);
      } else if (_lastData != null) {
        final floor = _lastData!.occupancy.floors.cast<entity.FloorData>().firstWhere(
          (f) => f.floorName.toLowerCase().contains(widget.floorName.toLowerCase()),
          orElse: () => entity.FloorData(floorName: widget.floorName, bedInfo: '', rooms: []),
        );
        currentRooms.addAll(floor.rooms);
      }
      
      if (!widget.isSetupMode && !widget.isDraftMode && _draftRooms != null) {
        currentRooms.addAll(_draftRooms!);
      }
  
      if (currentRooms.isEmpty) {
        _showAddRoomDialog(context);
        break;
      }
  
      final dynamic lastRoom = currentRooms.last;
      String lastRoomNumber = '';
      if (widget.isSetupMode) {
        lastRoomNumber = lastRoom['roomNumber'] ?? '';
      } else if (lastRoom is RoomDetail) {
        lastRoomNumber = lastRoom.roomTypename;
      } else if (lastRoom is entity.Room) {
        lastRoomNumber = lastRoom.roomNumber;
      }
      
      final match = RegExp(r'^([A-Z]*)([0-9]+)$').firstMatch(lastRoomNumber);
      if (match != null) {
        final prefix = match.group(1) ?? '';
        final numberStr = match.group(2) ?? '0';
        final int number = int.tryParse(numberStr) ?? 0;
        final int nextNumber = number + 1;
        final String nextRoomNumber = '$prefix${nextNumber.toString().padLeft(numberStr.length, '0')}';
  
        if (widget.isSetupMode) {
          final setupState = context.read<PropertySetupCubit>().state;
          context.read<PropertySetupCubit>().addManualRoom({
            'roomNumber': nextRoomNumber,
            'floor': widget.floorName,
            'sharingType': setupState.sharingType,
            'roomType': setupState.roomType,
            'features': {
              'isAC': setupState.roomType == 'AC',
              'hasGeyser': false,
              'hasBalcony': false,
              'hasAttachedWashroom': false,
            },
            'beds': List.generate(setupState.sharingType, (index) => {
              'bedNumber': String.fromCharCode(65 + index), 
              'status': 'FREE',
            }),
          });
        } else if (widget.isDraftMode) {
          final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final newRoom = RoomDetail(
            id: 'draft_${DateTime.now().millisecondsSinceEpoch}_$i',
            hostelId: widget.hostel.id,
            roomTypename: nextRoomNumber,
            floor: floorNum,
            sharingType: 'SINGLE',
            roomType: 'NON-AC',
            rent: 0,
            deposit: 0,
            maintenance: 0,
            isActive: true,
            isMaster: false,
            capacity: 1,
            features: [],
            beds: [],
          );
          setState(() {
            _draftRooms ??= [];
            _draftRooms!.add(newRoom);
          });
        } else {
          final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final newRoom = RoomDetail(
            id: 'draft_${DateTime.now().millisecondsSinceEpoch}_$i',
            hostelId: widget.hostel.id,
            roomTypename: nextRoomNumber,
            floor: floorNum,
            sharingType: 'DOUBLE',
            roomType: 'NON-AC',
            rent: 0,
            deposit: 0,
            maintenance: 0,
            isActive: true,
            isMaster: false,
            capacity: 2,
            features: [],
            beds: [],
          );
          setState(() {
            _draftRooms ??= [];
            _draftRooms!.add(newRoom);
          });
        }
      } else {
        break;
      }
    }
    
    if (count > 1) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully added $count rooms sequentially')),
      );
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C5990),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCloneButton(BuildContext context, List<entity.Room> rooms) {
    return BouncingWrapper(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCloneDialog(context, rooms);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2C5990).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF2C5990).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2C5990).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.copy_all_rounded, color: const Color(0xFF2C5990), size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              'CLONE',
              style: TextStyle(color: const Color(0xFF2C5990), fontSize: 10.sp, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloneDialog(BuildContext context, List<entity.Room> rooms) {
    if (rooms.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: const Text('Clone Settings', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        content: Text('Apply current settings of Room ${rooms[0].roomNumber} to all other rooms on this floor?',
            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: EdgeInsets.only(left: 8.w),
            child: OutlinedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                _cloneSettings(context, rooms);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2C5990), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Clone to All', style: TextStyle(color: Color(0xFF2C5990), fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cloneSettings(BuildContext context, List<entity.Room> rooms) async {
    if (rooms.length < 2) return;
    final source = rooms[0];
    
    final sourceFeatures = List<String>.from(source.features);
    final sourceRoomType = source.roomType ?? 'NON-AC';
    final sourceSharing = source.sharingType;
    final sourceCapacity = source.beds.length;

    setState(() {
      for (int i = 1; i < rooms.length; i++) {
        final target = rooms[i];
        final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        
        _modifiedRooms[target.id] = RoomDetail(
          id: target.id,
          hostelId: widget.hostel.id,
          roomTypename: target.roomNumber,
          floor: floorNum,
          sharingType: sourceSharing,
          roomType: sourceRoomType,
          rent: source.rent ?? 0,
          dailyRent: source.dailyRent ?? 0,
          deposit: 0, 
          maintenance: source.maintenance ?? 0,
          isActive: true,
          isMaster: false,
          capacity: sourceCapacity,
          features: sourceFeatures,
          beds: target.beds.map((b) => BedInfo(bedNumber: b.bedNumber, status: b.status)).toList(), 
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings cloned locally! Click Continue to proceed.')),
    );
  }

  Widget _buildBottomActions(BuildContext context, List<dynamic> rooms) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: const BorderSide(color: Color(0xFF2C5990), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Back', style: TextStyle(color: Color(0xFF2C5990), fontWeight: FontWeight.w800)),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                final List<RoomDetail> allRooms = [];
                
                if (_lastData != null) {
                  for (var floor in _lastData!.occupancy.floors) {
                    for (var r in floor.rooms) {
                      if (_modifiedRooms.containsKey(r.id)) {
                        allRooms.add(_modifiedRooms[r.id]!);
                      } else {
                        allRooms.add(RoomDetail(
                          id: r.id,
                          hostelId: widget.hostel.id,
                          roomTypename: r.roomNumber,
                          floor: int.tryParse(floor.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                          sharingType: r.sharingType,
                          roomType: r.roomType ?? 'NON-AC',
                          rent: r.rent ?? 0,
                          deposit: 0,
                          maintenance: r.maintenance ?? 0,
                          isActive: true,
                          isMaster: false,
                          capacity: r.beds.length,
                          features: List<String>.from(r.features),
                          beds: r.beds.map((b) => BedInfo(bedNumber: b.bedNumber, status: b.status)).toList(),
                        ));
                      }
                    }
                  }
                }

                if (_draftRooms != null) {
                  for (var dr in _draftRooms!) {
                    if (!allRooms.any((r) => r.roomTypename == dr.roomTypename)) {
                      allRooms.add(dr);
                    }
                  }
                }

                if (!context.mounted) return;
                
                final roomCubit = context.read<RoomCubit>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: roomCubit),
                      ],
                      child: RoomPricingPage(
                        hostel: widget.hostel,
                        rooms: allRooms.isNotEmpty ? allRooms : null,
                      ),
                    ),
                  ),
                ).then((_) {
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5990),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                shadowColor: const Color(0xFF2C5990).withValues(alpha: 0.3),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomManageCard extends StatefulWidget {
  final Map<String, dynamic>? roomMap;
  final int? roomIndex;
  final Hostel hostel;
  final String floorName;
  final bool isSetupMode;
  final bool isDraftMode;
  final RoomDetail? draftRoom;
  final Function(RoomDetail)? onDraftUpdate;

  const _RoomManageCard({
    super.key,
    this.roomMap,
    this.roomIndex,
    required this.hostel,
    required this.floorName,
    this.isSetupMode = false,
    this.isDraftMode = false,
    this.draftRoom,
    this.onDraftUpdate,
    this.onSaveComplete,
  });

  final VoidCallback? onSaveComplete;

  @override
  State<_RoomManageCard> createState() => _RoomManageCardState();
}

class _RoomManageCardState extends State<_RoomManageCard> {
  Timer? _debounceTimer;
  late int _localCapacity;
  late List<String> _localFeatures;
  late String _localRoomType;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initLocalState();
  }

  void _initLocalState() {
    if (widget.isSetupMode && widget.roomMap != null) {
      final features = widget.roomMap!['features'] as Map<String, dynamic>? ?? {};
      _localCapacity = widget.roomMap!['sharingType'] ?? 2;
      _localFeatures = [];
      if (features['hasStudyRoom'] == true) _localFeatures.add('STUDY_ROOM');
      if (features['hasBalcony'] == true) _localFeatures.add('BALCONY');
      if (features['hasAttachedWashroom'] == true) _localFeatures.add('WASHROOM');
      _localRoomType = features['isAC'] == true ? 'AC' : 'NON-AC';
    } else if (widget.isDraftMode && widget.draftRoom != null) {
      _localCapacity = widget.draftRoom!.capacity;
      _localFeatures = List<String>.from(widget.draftRoom!.features);
      _localRoomType = widget.draftRoom!.roomType;
    } else {
      _localCapacity = 1;
      _localFeatures = [];
      _localRoomType = 'NON-AC';
    }
  }

  @override
  void didUpdateWidget(_RoomManageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDraftMode && oldWidget.draftRoom != widget.draftRoom && !_isUpdating) {
      _initLocalState();
    } else if (!widget.isSetupMode && !widget.isDraftMode && !_isUpdating) {
      _initLocalState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: const Color(0xFF2C5990).withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.door_front_door_rounded, size: 18.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Room ${widget.isSetupMode ? (widget.roomMap?['roomNumber'] ?? '') : (widget.draftRoom?.roomTypename ?? '')}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                  ),
                  if (_isUpdating) ...[
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                    ),
                  ],
                ],
              ),
              _buildFloorBadge(),
            ],
          ),
          SizedBox(height: 20.h),
              Text(
                'SHARING TYPE',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
              SizedBox(height: 12.h),
              _buildSharingSelector(context, _localCapacity),
              SizedBox(height: 24.h),
              Text(
                'AMENITIES',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureIcon(
                    icon: Icons.ac_unit_rounded,
                    label: 'AC',
                    isSelected: _localRoomType == 'AC',
                    onTap: () => _toggleFeature(context, 'roomType', _localRoomType == 'AC' ? 'NON-AC' : 'AC'),
                  ),
                  _buildFeatureIcon(
                    icon: Icons.menu_book_rounded,
                    label: 'Study Table',
                    isSelected: _localFeatures.contains('STUDY_ROOM'),
                    onTap: () => _toggleFeature(context, 'feature', 'STUDY_ROOM'),
                  ),
                  _buildFeatureIcon(
                    icon: Icons.balcony_rounded,
                    label: 'Balcony',
                    isSelected: _localFeatures.contains('BALCONY'),
                    onTap: () => _toggleFeature(context, 'feature', 'BALCONY'),
                  ),
                  _buildFeatureIcon(
                    icon: Icons.wc_rounded,
                    label: 'Washroom',
                    isSelected: _localFeatures.contains('WASHROOM'),
                    onTap: () => _toggleFeature(context, 'feature', 'WASHROOM'),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'BEDS CONFIGURATION',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(_localCapacity, (index) {
                  final bedLabel = String.fromCharCode(65 + index); 
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF98125).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFF98125).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.single_bed_rounded, size: 16.sp, color: const Color(0xFFF98125)),
                        SizedBox(width: 6.w),
                        Text(
                          'Bed $bedLabel',
                          style: TextStyle(
                            color: const Color(0xFFF98125),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }

  void _toggleFeature(BuildContext context, String type, String value) {
    HapticFeedback.lightImpact();

    setState(() {
      _isUpdating = true;
      if (type == 'roomType') {
        _localRoomType = value;
      } else {
        if (_localFeatures.contains(value)) {
          _localFeatures.remove(value);
        } else {
          _localFeatures.add(value);
        }
      }
    });

    if (widget.isSetupMode && widget.roomIndex != null) {
      final cubit = context.read<PropertySetupCubit>();
      if (type == 'roomType') {
        cubit.updateRoomFeature(widget.roomIndex!, 'isAC', value == 'AC');
      } else {
        final cubitFeatureKey = value == 'STUDY_ROOM'
            ? 'hasStudyRoom'
            : value == 'BALCONY'
                ? 'hasBalcony'
                : value == 'WASHROOM'
                    ? 'hasAttachedWashroom'
                    : value;
        cubit.updateRoomFeature(widget.roomIndex!, cubitFeatureKey, _localFeatures.contains(value));
      }
      if (mounted) setState(() => _isUpdating = false);
    }
    
    _debounceSave();
  }

  void _debounceSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!context.mounted) return;
      
      if (widget.isSetupMode) return;

      if (widget.isDraftMode && widget.draftRoom != null) {
        final updatedRoom = RoomDetail(
          id: widget.draftRoom!.id,
          hostelId: widget.hostel.id,
          roomTypename: widget.draftRoom!.roomTypename,
          floor: widget.draftRoom!.floor,
          floors: const [],
          sharingType: StringUtils.mapCapacityToSharing(_localCapacity),
          roomType: _localRoomType,
          rent: 0,
          deposit: 0,
          maintenance: 0,
          isActive: true,
          isMaster: false,
          capacity: _localCapacity,
          features: _localFeatures,
          beds: [],
        );
        widget.onDraftUpdate?.call(updatedRoom);
        if (mounted) setState(() => _isUpdating = false);
        return;
      }

      final floorNum = int.tryParse(widget.floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      if (!mounted) return;
      if (!_isUpdating) setState(() => _isUpdating = true);
      
      try {
        if (widget.draftRoom == null) return;
        
        await context.read<RoomCubit>().updateRoom(RoomDetail(
              id: widget.draftRoom!.id,
              hostelId: widget.hostel.id,
              roomTypename: widget.draftRoom!.roomTypename,
              floor: floorNum,
              floors: const [],
              sharingType: StringUtils.mapCapacityToSharing(_localCapacity),
              roomType: _localRoomType,
              rent: widget.draftRoom!.rent,
              dailyRent: widget.draftRoom!.dailyRent,
              deposit: widget.draftRoom!.deposit,
              maintenance: widget.draftRoom!.maintenance,
              isActive: true,
              isMaster: false,
              capacity: _localCapacity,
              features: _localFeatures,
              beds: [],
            ));

        if (!mounted) return;
        
        if (widget.onSaveComplete != null) {
          widget.onSaveComplete!();
        } else {
          await context.read<DashboardCubit>().fetchDashboardData(widget.hostel.id);
        }
      } catch (e) {
        debugPrint('Error saving room: $e');
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    });
  }

  void _updateCapacity(BuildContext context, int capacity) {
    HapticFeedback.selectionClick();
    setState(() {
      _isUpdating = true;
      _localCapacity = capacity;
    });

    if (widget.isSetupMode) {
      if (widget.roomIndex != null) {
        context.read<PropertySetupCubit>().updateRoomSharing(widget.roomIndex!, capacity);
      }
      if (mounted) setState(() => _isUpdating = false);
      return;
    }
    
    _debounceSave();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildFloorBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        widget.floorName.toUpperCase(),
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildSharingSelector(BuildContext context, int capacity) {
    final sharingList = ['1 Sharing', '2 Sharing', '3 Sharing', '4 Sharing', '5 Sharing'];
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: List.generate(5, (index) {
          final isSelected = (index + 1) == capacity;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _updateCapacity(context, index + 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF98125).withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected ? Border.all(color: const Color(0xFFF98125), width: 1.5) : null,
                ),
                child: Text(
                  sharingList[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFF98125) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp, 
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeatureIcon({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF98125).withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? const Color(0xFFF98125) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFFF98125) : const Color(0xFF94A3B8), size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
