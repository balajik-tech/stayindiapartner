import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';

class BedCard extends StatelessWidget {
  final String bedNumber;
  final String status;
  final String? tenantName;
  final String? tenantAvatar;
  final bool isSelected;
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.tenantAvatar,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    final upperStatus = status.toUpperCase();
    final bool isOccupied = upperStatus == 'OCCUPIED' || upperStatus == 'AWAY';
    final bool isBooked = upperStatus == 'BOOKED';
    final bool isNotice = upperStatus == 'NOTICE';
    final bool isFree = upperStatus == 'FREE';

    if (isFree) {
      bgColor = const Color(0xFFE6F9EF);
      borderColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF15803D);
    } else if (isNotice) {
      bgColor = const Color(0xFFFEF9C3);
      borderColor = const Color(0xFFEAB308);
      textColor = const Color(0xFFA16207);
    } else if (isBooked) {
      bgColor = const Color(0xFFF3E8FF);
      borderColor = const Color(0xFF9333EA);
      textColor = const Color(0xFF7E22CE);
    } else {
      bgColor = const Color(0xFFFFF1E6);
      borderColor = const Color(0xFFF97316);
      textColor = const Color(0xFFC2410C);
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 68.w,
      height: 76.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tenantAvatar != null || tenantName != null)
                    CustomAvatar(
                      imageUrl: tenantAvatar,
                      name: tenantName ?? 'T',
                      size: 22.r,
                      fontSize: 9.sp,
                    )
                  else
                    Icon(
                      Icons.bed_rounded,
                      size: 18.sp,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    bedLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: 2.h),
                  
                  Text(
                    isFree ? 'FREE' : (tenantName?.split(' ')[0] ?? upperStatus),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7.5.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.8),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
