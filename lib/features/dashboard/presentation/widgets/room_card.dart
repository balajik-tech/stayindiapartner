import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'occupied_bed_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class RoomCard extends StatefulWidget {
  final String id;
  final String roomNumber;
  final String sharingType;
  final String occupancy;
  final List<BedInfo> beds;
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
    return GestureDetector(
      onLongPress: () => _showDeleteConfirmation(context),
      child: Container(
        margin: widget.isGridView ? EdgeInsets.zero : EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(widget.isGridView ? 8.w : 12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.roomNumber.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp, 
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E325C),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    widget.roomType ?? (widget.sharingType.contains('AC') ? 'AC' : 'NON-AC'),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9EA3B0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Rent: ₹${widget.rent?.toStringAsFixed(0) ?? "0"}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: widget.isGridView ? 2.w : 8.w,
              runSpacing: widget.isGridView ? 8.h : 10.h,
              alignment: WrapAlignment.start,
              children: widget.beds.map((bed) => SizedBox(
                width: widget.isGridView ? 48.w : 64.w, 
                child: _buildBedItem(context, bed),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedItem(BuildContext context, BedInfo bed) {
    final status = bed.status;
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon = Icons.hotel_rounded;
    String label = '';
    String bedLetter = '';
    
    try {
      int? num = int.tryParse(bed.bedNumber);
      if (num != null && num >= 1 && num <= 26) {
        bedLetter = String.fromCharCode(64 + num);
      } else {
        bedLetter = bed.bedNumber.toUpperCase();
      }
    } catch (_) {
      bedLetter = bed.bedNumber;
    }

    switch (status) {
      case 'OCCUPIED':
        bgColor = const Color(0xFFFFEBEE); 
        borderColor = const Color(0xFFEF9A9A);
        textColor = const Color(0xFFC62828);
        label = bed.tenantName ?? '';
        break;
      case 'FREE':
        bgColor = const Color(0xFFE8F5E9); 
        borderColor = const Color(0xFFA5D6A7);
        textColor = const Color(0xFF2E7D32);
        label = 'FREE';
        break;
      case 'NOTICE':
        bgColor = const Color(0xFFFFF3E0); 
        borderColor = const Color(0xFFFFCC80);
        textColor = const Color(0xFFE65100);
        label = 'NOTICE';
        break;
      case 'LOCKED':
      case 'MAINTENANCE':
        bgColor = const Color(0xFFF5F5F5);
        borderColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF616161);
        icon = Icons.build_rounded;
        label = 'MAINT';
        break;
      case 'BOOKED':
        bgColor = const Color(0xFFF3E5F5); 
        borderColor = const Color(0xFFCE93D8);
        textColor = const Color(0xFF6A1B9A);
        label = 'BOOKED';
        break;
      default:
        bgColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
        textColor = Colors.grey;
        label = 'UNK';
    }

    return GestureDetector(
      onTap: () {
        if (status != 'FREE') {
          final hId = widget.hostelId ?? _getHostelId(context);
          if (hId != null && bed.tenantId != null) {
            OccupiedBedSheet.show(
              context,
              roomNumber: widget.roomNumber,
              bedNumber: bed.bedNumber,
              tenantName: bed.tenantName ?? 'Tenant',
              tenantAvatar: bed.tenantAvatar,
              tenantId: bed.tenantId!,
              hostelId: hId,
            );
          }
        }
      },
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor.withValues(alpha: 0.6), size: 16.sp),
            Text(
              bedLetter,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 7.sp,
                fontWeight: FontWeight.w800,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getHostelId(BuildContext context) {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].id;
    }
    return null;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text(
            'Delete Room?',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E325C)),
          ),
          content: Text(
            'Are you sure you want to delete ${widget.roomNumber}? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final hId = widget.hostelId ?? _getHostelId(context);
                if (hId == null) return;

                Navigator.pop(context); 

                try {
                  await context.read<DashboardCubit>().deleteRoom(widget.id, hId);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room ${widget.roomNumber} deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete room: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}


