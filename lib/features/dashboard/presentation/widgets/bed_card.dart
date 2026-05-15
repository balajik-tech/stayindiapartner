import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

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
    final bool isAway = upperStatus == 'AWAY';
    final bool isBooked = upperStatus == 'BOOKED';
    final bool isNotice = upperStatus == 'NOTICE';
    final bool isFree = upperStatus == 'FREE';

    if (isFree) {

      bgColor = const Color(0xFFD6EEF8);
      borderColor = const Color(0xFF87CEEB);
      textColor = const Color(0xFF1A6F8A);
    } else if (isNotice) {

      bgColor = const Color(0xFFFFF3CD);
      borderColor = const Color(0xFFFFB300);
      textColor = const Color(0xFF7A5800);
    } else if (isBooked) {

      bgColor = const Color(0xFFF3E8FF);
      borderColor = const Color(0xFF9C27B0);
      textColor = const Color(0xFF6A0080);
    } else if (isAway) {

      bgColor = const Color(0xFFFFE4EE);
      borderColor = const Color(0xFFE91E63);
      textColor = const Color(0xFF9C0040);
    } else {

      bgColor = const Color(0xFFFFEDD5);
      borderColor = const Color(0xFFFF8600);
      textColor = const Color(0xFF8B4000);
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

    return Semantics(
      label: '${'bed'.tr()} $bedNumber, ${'status'.tr()}: $status${tenantName != null ? ', ${'tenant'.tr()}: $tenantName' : ''}',
      button: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56.w,
                  height: 80.h,
                  child: CustomPaint(
                    foregroundPainter: _DottedBorderPainter(
                      color: borderColor,
                      strokeWidth: 3.0,
                      dashWidth: 4,
                      dashSpace: 3,
                      borderRadius: 18.r,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: borderColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (tenantAvatar != null || tenantName != null)
                              CustomAvatar(
                                imageUrl: ApiConstants.getImageUrl(tenantAvatar),
                                name: tenantName ?? 'T',
                                size: 32.r,
                                fontSize: 14.sp,
                                isCircle: true,
                              )
                            else
                              Icon(
                                Icons.bed_rounded,
                                size: 24.sp,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            SizedBox(height: 6.h),
                             FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  bedLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    color: textColor.withValues(alpha: 0.6),
                                    height: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isAway || isNotice)
                  Positioned(
                    top: -6.h,
                    right: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        isAway ? 'AWAY' : 'NOTICE',
                        style: TextStyle(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              isFree ? 'Available' : (tenantName?.split(' ')[0] ?? upperStatus),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final remaining = metric.length - distance;
        final currentDash = dashWidth < remaining ? dashWidth : remaining;
        canvas.drawPath(metric.extractPath(distance, distance + currentDash), paint);
        distance += currentDash + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.borderRadius != borderRadius;
}
