import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/data/models/occupancy_model.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/floor_filter.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/floor_accordion.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/room_card.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';

class RoomSelectionPage extends StatefulWidget {
  final String bookingId;
  final String hostelId;
  final String tenantName;
  final String? accessCode;
  final String? preAllocatedRoomId;
  final String? preAllocatedBedNumber;
  final bool isRoomChange;
  final String? bookedSharingType;
  final String? bookedRoomType;

  const RoomSelectionPage({
    super.key,
    required this.bookingId,
    required this.hostelId,
    required this.tenantName,
    this.accessCode,
    this.preAllocatedRoomId,
    this.preAllocatedBedNumber,
    this.isRoomChange = false,
    this.bookedSharingType,
    this.bookedRoomType,
  });

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  int _selectedFloorIndex = 0;

  String _getFloorDisplayName(FloorData floor) {
    if (floor.floorName == 'basement' ||
        (floor.floorNum != null && floor.floorNum! < 0)) {
      final absNum = floor.floorNum != null ? floor.floorNum!.abs() : 1;
      if (absNum > 1) {
        return '${StringUtils.translate('basement', context: context)} $absNum';
      }
      return StringUtils.translate('basement', context: context);
    }
    return StringUtils.translate(
      floor.floorName == 'ground_floor' ? 'ground_floor' : 'floor_n',
      context: context,
      namedArgs: {'n': '${floor.floorNum ?? 0}'},
    );
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });

    context.read<BookingsCubit>().fetchOccupancy(widget.hostelId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<BookingsCubit>().clearScannedBooking();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () {
              context.read<BookingsCubit>().clearScannedBooking();
              Navigator.pop(context);
            },
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.isRoomChange
                  ? 'Move ${widget.tenantName} to...'
                  : 'Select Bed for ${widget.tenantName}',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: BlocConsumer<BookingsCubit, BookingsState>(
          listener: (context, state) {
            if ((state.successMessage?.contains('successfully') ?? false) &&
                state.status == BookingsStatus.success) {
              ScaffoldMessenger.of(context).clearSnackBars();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            }

            if (state.errorMessage != null &&
                state.status == BookingsStatus.failure) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }


          },
          builder: (context, state) {
            if (state.status == BookingsStatus.loading &&
                state.occupancy == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == BookingsStatus.failure &&
                state.occupancy == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.errorMessage}'),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context
                          .read<BookingsCubit>()
                          .fetchOccupancy(widget.hostelId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.occupancy == null) {
              return const Center(child: Text('No occupancy data found'));
            }

            final occupancyModel = state.occupancy as OccupancyModel;
            final floorNames = [
              StringUtils.translate('all_floors', context: context),
              ...occupancyModel.floors.map((f) => _getFloorDisplayName(f)),
            ];

            return Stack(
              children: [
                Column(
                  children: [
                    FloorFilter(
                      floors: floorNames,
                      selectedIndex: _selectedFloorIndex,
                      onSelected: (index) {
                        setState(() {
                          _selectedFloorIndex = index;
                        });
                      },
                    ),
                    if (!widget.isRoomChange &&
                        ((widget.bookedSharingType != null && widget.bookedSharingType!.isNotEmpty) ||
                         (widget.bookedRoomType != null && widget.bookedRoomType!.isNotEmpty)))
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primaryBlue,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Showing rooms matching: ${[
                                  if (widget.bookedSharingType != null && widget.bookedSharingType!.isNotEmpty)
                                    StringUtils.formatSharingType(widget.bookedSharingType!, context),
                                  if (widget.bookedRoomType != null && widget.bookedRoomType!.isNotEmpty)
                                    widget.bookedRoomType!.toUpperCase(),
                                ].join(' • ')}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16.h),
                    Expanded(child: _buildFloorsList(occupancyModel)),
                  ],
                ),
                if (state.status == BookingsStatus.loading)
                  Container(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _normalizeToGroup(String type) {
    final clean = type.toUpperCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
    
    if (clean.contains('SINGLE') || clean == '1' || clean == '1SHARING' || clean == '1BED' || clean == 'SINGLESHARING') {
      return 'SINGLE';
    }
    if (clean.contains('DOUBLE') || clean == '2' || clean == '2SHARING' || clean == '2BED' || clean == 'DOUBLESHARING') {
      return 'DOUBLE';
    }
    if (clean.contains('TRIPLE') || clean == '3' || clean == '3SHARING' || clean == '3BED' || clean == 'TRIPLESHARING') {
      return 'TRIPLE';
    }
    if (clean.contains('QUADRUPLE') || clean == '4' || clean == '4SHARING' || clean == '4BED' || clean == 'QUADRUPLESHARING') {
      return 'QUADRUPLE';
    }
    if (clean.contains('QUINTUPLE') || clean == '5' || clean == '5SHARING' || clean == '5BED' || clean == 'QUINTUPLESHARING') {
      return 'QUINTUPLE';
    }
    
    final digitsMatch = RegExp(r'\d+').firstMatch(clean);
    if (digitsMatch != null) {
      final val = int.tryParse(digitsMatch.group(0)!) ?? 0;
      if (val >= 6) {
        return 'DORMITORY';
      }
    }
    
    if (clean.contains('DORMITORY') || clean.contains('DORM') || clean == '6SHARING' || clean == '6' || clean == 'DORMITORYSHARING') {
      return 'DORMITORY';
    }
    
    return clean;
  }

  bool _matchesSharing(String roomSharing, String bookedSharing) {
    return _normalizeToGroup(roomSharing) == _normalizeToGroup(bookedSharing);
  }

  bool _matchesRoomType(String roomType, String bookedRoomType) {
    final cleanRoom = roomType.toUpperCase().replaceAll('_', '').replaceAll('-', '');
    final cleanBooked = bookedRoomType.toUpperCase().replaceAll('_', '').replaceAll('-', '');
    
    if (cleanRoom == cleanBooked) return true;
    
    if (cleanRoom == 'AC' && cleanBooked != 'AC') return false;
    if (cleanRoom != 'AC' && cleanBooked == 'AC') return false;
    
    final isRoomNonAc = cleanRoom.contains('NONAC');
    final isBookedNonAc = cleanBooked.contains('NONAC');
    
    return isRoomNonAc == isBookedNonAc;
  }

  Widget _buildFloorsList(OccupancyModel occupancyModel) {
    final bookedSharing = widget.isRoomChange ? null : widget.bookedSharingType;
    final bookedAc = widget.isRoomChange ? null : widget.bookedRoomType;

    final List<FloorData> criteriaFilteredFloors = [];

    for (final floor in occupancyModel.floors) {
      final matchingRooms = floor.rooms.where((room) {
        bool matches = true;
        if (bookedSharing != null && bookedSharing.isNotEmpty) {
          matches = matches && _matchesSharing(room.sharingType, bookedSharing);
        }
        if (bookedAc != null && bookedAc.isNotEmpty) {
          matches = matches && _matchesRoomType(room.roomType ?? '', bookedAc);
        }
        return matches;
      }).toList();

      if (matchingRooms.isNotEmpty) {
        criteriaFilteredFloors.add(
          FloorData(
            floorName: floor.floorName,
            floorNum: floor.floorNum,
            bedInfo: floor.bedInfo,
            totalBeds: matchingRooms.fold<int>(0, (sum, r) => sum + r.beds.length),
            freeBeds: matchingRooms.fold<int>(0, (sum, r) => sum + r.beds.where((b) => b.status == 'FREE').length),
            rooms: matchingRooms,
          ),
        );
      }
    }

    if (criteriaFilteredFloors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hotel_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Rooms Available',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'There are no active rooms matching the booked criteria: ${[
                  if (widget.bookedSharingType != null && widget.bookedSharingType!.isNotEmpty)
                    StringUtils.formatSharingType(widget.bookedSharingType!, context),
                  if (widget.bookedRoomType != null && widget.bookedRoomType!.isNotEmpty)
                    widget.bookedRoomType!.toUpperCase(),
                ].join(' • ')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<FloorData> filteredFloors;
    if (_selectedFloorIndex == 0) {
      filteredFloors = criteriaFilteredFloors;
    } else {
      final selectedFloorData = occupancyModel.floors[_selectedFloorIndex - 1];
      final matches = criteriaFilteredFloors.where((f) => f.floorNum == selectedFloorData.floorNum).toList();
      if (matches.isNotEmpty) {
        filteredFloors = [matches.first];
      } else {
        filteredFloors = [];
      }
    }

    if (filteredFloors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'No rooms available on this floor for the booked criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.greyText,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: filteredFloors.length,
      itemBuilder: (context, index) {
        final floor = filteredFloors[index];
        return FloorAccordion(
          title: _getFloorDisplayName(floor),
          bedInfo: StringUtils.translate(
            'beds_free_count',
            context: context,
            namedArgs: {
              'free': '${floor.freeBeds ?? 0}',
              'total': '${floor.totalBeds ?? 0}',
            },
          ),
          isInitialExpanded: _selectedFloorIndex != 0 || criteriaFilteredFloors.length == 1,
          itemCount: floor.rooms.length,
          itemBuilder: (context, i) {
            final room = floor.rooms[i];
            final isPreAllocatedRoom = room.id == widget.preAllocatedRoomId;
            return RoomCard(
              room: room,
              id: room.id,
              roomNumber: room.roomNumber,
              sharingType: room.sharingType,
              occupancy: room.occupancy,
              beds: room.beds,
              rent: room.rent,
              dailyRent: room.dailyRent,
              onBedTap: (roomNumber, bedNumber) {
                _showConfirmationDialog(context, room, bedNumber);
              },
              isPreAllocated: isPreAllocatedRoom,
              preAllocatedBedNumber: isPreAllocatedRoom
                  ? widget.preAllocatedBedNumber
                  : null,
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    Room room,
    String bedNumber,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRoomChange
                      ? Icons.swap_horiz_rounded
                      : Icons.person_add_rounded,
                  color: AppColors.primaryBlue,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                widget.isRoomChange
                    ? 'Confirm Room Change'
                    : 'Confirm Check-in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Are you sure you want to allocate '),
                    TextSpan(
                      text: 'Room ${room.roomNumber}, Bed $bedNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const TextSpan(text: ' to '),
                    TextSpan(
                      text: widget.tenantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<BookingsCubit>().finalizeCheckin(
                          bookingId: widget.bookingId,
                          roomId: room.id,
                          bedNumber: bedNumber,
                          accessCode: widget.accessCode,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
