import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/side_view_bed_icon.dart';

class BedListHeader extends StatelessWidget {
  const BedListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              'BED',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'STATUS',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80.w,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'DETAILS',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BedListRow extends StatelessWidget {
  final String roomNumber;
  final String bedNumber;
  final String status;
  final String? tenantName;
  final VoidCallback? onTap;

  const BedListRow({
    super.key,
    required this.roomNumber,
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color pillBgColor;
    Color pillTextColor;
    String displayStatus = status.toUpperCase();

    final isFree = displayStatus == 'FREE';
    final isOccupied = displayStatus == 'OCCUPIED';
    final isReserved = displayStatus == 'RESERVED';
    final isBooked = displayStatus == 'BOOKED';
    final isNotice = displayStatus == 'NOTICE';
    final isMaintenance = displayStatus == 'MAINTENANCE';

    if (isFree) {
      pillBgColor = const Color(0xFFE0F2FE);
      pillTextColor = const Color(0xFF0284C7);
      displayStatus = 'AVAILABLE';
    } else if (isOccupied) {
      pillBgColor = const Color(0xFFFFEDD5);
      pillTextColor = const Color(0xFFEA580C);
    } else if (isReserved || isBooked) {
      pillBgColor = const Color(0xFFF3E8FF);
      pillTextColor = const Color(0xFF9333EA);
    } else if (isNotice) {
      pillBgColor = const Color(0xFFFEF3C7);
      pillTextColor = const Color(0xFFD97706);
    } else if (isMaintenance) {
      pillBgColor = const Color(0xFFF1F5F9);
      pillTextColor = const Color(0xFF475569);
    } else {
      pillBgColor = const Color(0xFFF1F5F9);
      pillTextColor = const Color(0xFF475569);
    }

    String bedLabel = bedNumber;
    try {
      int? num = int.tryParse(bedNumber);
      if (num != null && num >= 1 && num <= 26) {
        bedLabel = String.fromCharCode(64 + num);
      } else {
        bedLabel = bedNumber.toUpperCase();
      }
    } catch (_) {
      bedLabel = bedNumber;
    }

    final fullBedNumber = '$roomNumber-$bedLabel';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80.w,
              child: Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SideViewBedIcon(
                      size: 18.sp,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fullBedNumber,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        roomNumber,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      color: pillTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  (tenantName != null && tenantName!.trim().isNotEmpty) ? tenantName! : '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
