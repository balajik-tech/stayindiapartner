import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'bed_card.dart';
import 'bed_details_sheet.dart';


class RoomCard extends StatefulWidget {
  final entity.Room room;
  final String id;
  final String roomNumber;
  final String sharingType;
  final String occupancy;
  final List<entity.BedInfo> beds;
  final String? hostelId;
  final Function(String roomNumber, String bedNumber)? onBedTap;

  final bool isPreAllocated;
  final String? preAllocatedBedNumber;
  final bool isGridView;
  final double? rent;
  final double? dailyRent;
  final String? roomType;

  const RoomCard({
    super.key,
    required this.room,
    required this.id,
    required this.roomNumber,
    required this.sharingType,
    required this.occupancy,
    required this.beds,
    this.hostelId,
    this.onBedTap,
    this.isPreAllocated = false,
    this.preAllocatedBedNumber,
    this.isGridView = true,
    this.rent,
    this.dailyRent,
    this.roomType,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isGridView ? EdgeInsets.zero : EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (widget.isGridView) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (() {
                          final fName = widget.room.floorName ?? '0';
                          final clean = fName.replaceAll('floor_', '');
                          final val = int.tryParse(clean);
                          if (fName == 'basement' || (val != null && val < 0)) {
                            final absNum = val != null ? val.abs() : 1;
                            if (absNum > 1) {
                              return '${StringUtils.translate('basement', context: context)} $absNum';
                            }
                            return StringUtils.translate('basement', context: context);
                          }
                          return StringUtils.translate(
                            fName == 'ground_floor' ? 'ground_floor' : 'floor_n',
                            context: context,
                            namedArgs: {'n': clean},
                          );
                        })(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.roomNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              StringUtils.translate(widget.roomType?.toLowerCase() ?? 'ac', context: context),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    StringUtils.formatSharingType(widget.sharingType, context, widget.beds.length),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            if ((widget.rent != null && widget.rent! > 0) || (widget.dailyRent != null && widget.dailyRent! > 0)) ...[
              SizedBox(height: 8.h),
              Text(
                widget.rent != null && widget.rent! > 0
                    ? '₹${widget.rent!.toInt()}${StringUtils.translate('price_per_month', context: context)}'
                    : '₹${widget.dailyRent!.toInt()}${StringUtils.translate('daily_rate', context: context)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (() {
                          final fName = widget.room.floorName ?? '0';
                          final clean = fName.replaceAll('floor_', '');
                          final val = int.tryParse(clean);
                          if (fName == 'basement' || (val != null && val < 0)) {
                            final absNum = val != null ? val.abs() : 1;
                            if (absNum > 1) {
                              return '${StringUtils.translate('basement', context: context)} $absNum';
                            }
                            return StringUtils.translate('basement', context: context);
                          }
                          return StringUtils.translate(
                            fName == 'ground_floor' ? 'ground_floor' : 'floor_n',
                            context: context,
                            namedArgs: {'n': clean},
                          );
                        })(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.roomNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              StringUtils.translate(widget.roomType?.toLowerCase() ?? 'ac', context: context),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.rent != null && widget.rent! > 0) ...[
                      Text(
                        '₹${widget.rent!.toInt()}${StringUtils.translate('per_month', context: context)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ] else if (widget.dailyRent != null && widget.dailyRent! > 0) ...[
                      Text(
                        '₹${widget.dailyRent!.toInt()}${StringUtils.translate('per_day', context: context)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        StringUtils.formatSharingType(widget.sharingType, null, widget.beds.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: const Color(0xFFF1F5F9), thickness: 1.5),
          ),
          

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.start,
            children: widget.beds.map((bed) => _buildBedItem(context, bed)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBedItem(BuildContext context, entity.BedInfo bed) {
    return BedCard(
      bedNumber: bed.bedNumber,
      status: bed.status,
      isAwayField: bed.isAway,
      tenantName: bed.tenantName,
      tenantAvatar: bed.tenantAvatar,
      isSelected: widget.isPreAllocated && bed.bedNumber == widget.preAllocatedBedNumber,
      isSmall: widget.isGridView,
      onTap: () {
        final bedStatus = _mapStatus(bed.status);
        
        if (widget.onBedTap != null && bedStatus == BedStatus.free) {
          widget.onBedTap!(widget.roomNumber, bed.bedNumber);
          return;
        }

        final hId = widget.hostelId ?? _getHostelId(context);
        BedDetailsSheet.show(
          context,
          BedState(
            status: bedStatus,
            bedNumber: "${widget.roomNumber}-${bed.bedNumber}",
            tenantName: bed.tenantName,
            profileImage: bed.tenantAvatar,
            joiningDate: "01 May 2024",
            vacatingDate: bedStatus == BedStatus.notice ? "31 May 2024" : null,
            tenantId: bed.tenantId,
            hostelId: hId,
            roomNumber: widget.roomNumber,
            rent: widget.rent,
            dailyRent: widget.dailyRent,
            maintenance: widget.room.maintenance,
            amenities: widget.room.features,
            awayReturnDate: bed.awayReturnDate,
          ),
        );
      },
    );
  }

  BedStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return BedStatus.free;
      case 'NOTICE':
        return BedStatus.notice;
      case 'AWAY':
        return BedStatus.away;
      default:
        return BedStatus.occupied;
    }
  }

  String? _getHostelId(BuildContext context) {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].id;
    }
    return null;
  }
}
