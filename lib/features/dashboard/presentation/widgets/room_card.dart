import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'occupied_bed_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class RoomCard extends StatefulWidget {
  final String roomNumber;
  final String sharingType;
  final String occupancy;
  final List<BedInfo> beds;
  final String? hostelId;
  final Function(String roomNumber, String bedNumber)? onBedTap;

  final bool isPreAllocated;
  final String? preAllocatedBedNumber;

  const RoomCard({
    super.key,
    required this.roomNumber,
    required this.sharingType,
    required this.occupancy,
    required this.beds,
    this.hostelId,
    this.onBedTap,
    this.isPreAllocated = false,
    this.preAllocatedBedNumber,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String cleanRoomNum = widget.roomNumber.toLowerCase().startsWith('room') 
        ? widget.roomNumber.substring(4).trim() 
        : widget.roomNumber;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.roomCardBorder.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFEFF4FF), const Color(0xFFF1F3FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cleanRoomNum,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room $cleanRoomNum',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${widget.sharingType}  ${widget.occupancy}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.greyText.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusIndicator(occupancy: widget.occupancy),
                ],
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: widget.beds.map((bed) => _buildBedIcon(context, bed)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBedIcon(BuildContext context, BedInfo bed) {
    bool isPreAllocatedBed = widget.isPreAllocated && bed.bedNumber == widget.preAllocatedBedNumber;
    bool isOccupied = bed.status == 'OCCUPIED';
    bool isReserved = bed.status == 'LOCKED' || bed.status == 'BOOKED';
    bool isAway = bed.status == 'AWAY';
    
    Widget content;
    if ((isOccupied || isReserved || isAway) && bed.tenantName != null) {
      content = Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isAway 
                ? Colors.orange.shade700 
                : (isOccupied ? AppColors.primaryBlue.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.4)),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isAway 
                  ? Colors.orange.withValues(alpha: 0.2) 
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CustomAvatar(
          imageUrl: ApiConstants.getImageUrl(bed.tenantAvatar),
          name: bed.tenantName!,
          size: 44.0,
          isCircle: true,
        ),
      );
    } else {
      String bedLabel = '';
      try {
        String cleanedNumber = bed.bedNumber.trim();
        int? num = int.tryParse(cleanedNumber);
        if (num != null && num >= 1 && num <= 26) {
          bedLabel = String.fromCharCode(64 + num);
        } else {
          bedLabel = cleanedNumber.toUpperCase();
        }
      } catch (e) {
        bedLabel = bed.bedNumber;
      }

      content = Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.greyText.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          bedLabel,
          style: TextStyle(
            color: AppColors.greyText.withValues(alpha: 0.6),
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GestureDetector(
      key: ValueKey('bed_${bed.bedNumber}'),
      onTap: () {
        if ((isOccupied || isReserved || isAway) && bed.tenantId != null) {
          final hId = widget.hostelId ?? _getHostelId(context);
          if (hId != null) {
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
        } else if (widget.onBedTap != null && (bed.status == 'FREE' || isPreAllocatedBed)) {
          widget.onBedTap!(widget.roomNumber, bed.bedNumber);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          if (isPreAllocatedBed)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
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
}

class _StatusIndicator extends StatelessWidget {
  final String occupancy;
  const _StatusIndicator({required this.occupancy});

  @override
  Widget build(BuildContext context) {
    
    bool isFull = false;
    try {
      final parts = occupancy.split('/');
      if (parts.length >= 2) {
        final occupied = int.tryParse(parts[0].trim()) ?? 0;
        final totalPart = parts[1].trim().split(' ')[0];
        final total = int.tryParse(totalPart) ?? 0;
        isFull = occupied >= total && total > 0;
      }
    } catch (_) {
      isFull = false;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isFull ? const Color(0xFFFFF5F5) : const Color(0xFFF3FEF7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isFull ? const Color(0xFFE03131) : const Color(0xFF099268),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            isFull ? 'Full' : 'Available',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: isFull ? const Color(0xFFE03131) : const Color(0xFF099268),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
