import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'bed_card.dart';
import 'bed_details_sheet.dart';


class RoomDetailsSheet extends StatefulWidget {
  final Room room;
  final String? initialBedNumber;
  final String hostelId;

  const RoomDetailsSheet({
    super.key,
    required this.room,
    required this.hostelId,
    this.initialBedNumber,
  });

  static void show(BuildContext context, {required Room room, String? bedNumber, required String hostelId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomDetailsSheet(room: room, initialBedNumber: bedNumber, hostelId: hostelId),
    );
  }

  @override
  State<RoomDetailsSheet> createState() => _RoomDetailsSheetState();
}

class _RoomDetailsSheetState extends State<RoomDetailsSheet> {
  late BedInfo selectedBed;

  @override
  void initState() {
    super.initState();
    if (widget.initialBedNumber != null) {
      selectedBed = widget.room.beds.firstWhere(
        (b) => b.bedNumber == widget.initialBedNumber,
        orElse: () => widget.room.beds.first,
      );
    } else {
      selectedBed = widget.room.beds.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 32.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Room Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.roomNumber.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${widget.room.floorName ?? "Property Room"} • ${widget.room.sharingType}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.room.roomType == 'AC' ? Icons.ac_unit_rounded : Icons.air_rounded,
                        size: 12.sp,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.room.roomType ?? 'NON-AC',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Features
          if (widget.room.features.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: widget.room.features.map((feature) => _buildFeatureChip(feature)).toList(),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Rent Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  _buildPriceItem('Monthly Rent', '₹${widget.room.rent?.toStringAsFixed(0) ?? "0"}'),
                  Container(width: 1, height: 24.h, color: const Color(0xFFE2E8F0)),
                  _buildPriceItem('Daily Rent', '₹${widget.room.dailyRent?.toStringAsFixed(0) ?? "0"}'),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Bed Selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  'Select Bed',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.room.occupancy,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: widget.room.beds.map((bed) {
                final isSelected = selectedBed.bedNumber == bed.bedNumber;
                return _buildBedChip(bed, isSelected);
              }).toList(),
            ),
          ),

          SizedBox(height: 24.h),

          // Bed Action Area
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBedActionArea(selectedBed),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    IconData icon;
    String label = feature;
    
    switch (feature.toLowerCase()) {
      case 'ac':
        icon = Icons.ac_unit_rounded;
        break;
      case 'geyser':
        icon = Icons.hot_tub_rounded;
        break;
      case 'balcony':
        icon = Icons.balcony_rounded;
        break;
      case 'washroom':
        icon = Icons.wc_rounded;
        break;
      case 'wifi':
        icon = Icons.wifi_rounded;
        break;
      default:
        icon = Icons.star_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: Colors.orange),
          SizedBox(width: 4.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedChip(BedInfo bed, bool isSelected) {
    return BedCard(
      bedNumber: bed.bedNumber,
      status: bed.status,
      tenantName: bed.tenantName,
      tenantAvatar: bed.tenantAvatar,
      isSelected: isSelected,
      onTap: () => setState(() => selectedBed = bed),
    );
  }

  Widget _buildBedActionArea(BedInfo bed) {
    final bool isOccupied = bed.status == 'OCCUPIED' || bed.status == 'AWAY' || bed.status == 'NOTICE';
    
    if (isOccupied) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CustomAvatar(
                  imageUrl: bed.tenantAvatar,
                  name: bed.tenantName ?? 'T',
                  size: 40.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bed.tenantName ?? 'Unknown Tenant',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Currently ${bed.status}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final bedStatus = _mapStatus(bed.status);
                  BedDetailsSheet.show(
                    context,
                    BedState(
                      status: bedStatus,
                      bedNumber: "${widget.room.roomNumber}-${bed.bedNumber}",
                      tenantName: bed.tenantName,
                      profileImage: bed.tenantAvatar,
                      joiningDate: "01 May 2024",
                      vacatingDate: bedStatus == BedStatus.notice ? "31 May 2024" : null,
                      tenantId: bed.tenantId,
                      hostelId: widget.hostelId,
                      roomNumber: widget.room.roomNumber,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                child: Text(
                  'VIEW PROFILE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (bed.status == 'FREE') {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Bed ${bed.bedNumber} is available.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final bedStatus = _mapStatus(bed.status);
                BedDetailsSheet.show(
                  context,
                  BedState(
                    status: bedStatus,
                    bedNumber: "${widget.room.roomNumber}-${bed.bedNumber}",
                    tenantName: bed.tenantName,
                    profileImage: bed.tenantAvatar,
                    joiningDate: "01 May 2024",
                    vacatingDate: bedStatus == BedStatus.notice ? "31 May 2024" : null,
                    tenantId: bed.tenantId,
                    hostelId: widget.hostelId,
                    roomNumber: widget.room.roomNumber,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              child: Text(
                'ADD TENANT',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            'Bed is ${bed.status}',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
          ),
        ),
      );
    }
  }

  BedStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return BedStatus.free;
      case 'NOTICE':
        return BedStatus.notice;
      default:
        return BedStatus.occupied;
    }
  }
}

