import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';

class BedCard extends StatelessWidget {
  final String bedNumber;
  final String status;
  final String? tenantName;
  final String? tenantAvatar;
  final bool isSelected;
  final bool isAway;
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.tenantAvatar,
    this.isAway = false,
    this.isSelected = false,
    required this.onTap,
  });

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 6.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    final upperStatus = status.toUpperCase();
    final bool isBooked = upperStatus == 'BOOKED';
    final bool isNotice = upperStatus == 'NOTICE';
    final bool isFree = upperStatus == 'FREE';

    if (isFree) {
      bgColor = const Color(0xFFE0F7FA);
      borderColor = const Color(0xFF0891B2);
      textColor = const Color(0xFF0E7490);
    } else if (isNotice) {
      bgColor = const Color(0xFFFEF9C3);
      borderColor = const Color(0xFFFACC15);
      textColor = const Color(0xFF854D0E);
    } else if (isAway) {
      bgColor = const Color(0xFFFFF4E5);
      borderColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFD97706);
    } else if (isBooked) {
      bgColor = const Color(0xFFF3E8FF);
      borderColor = const Color(0xFF9333EA);
      textColor = const Color(0xFF7E22CE);
    } else {
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFF97316);
      textColor = const Color(0xFF9A3412);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68.w,
              height: 86.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18.r),
                border: isFree
                    ? null
                    : Border.all(
                        color: borderColor,
                        width: 1.5,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: CustomPaint(
                painter: isFree ? _DottedBorderPainter(color: borderColor, radius: 18.r) : null,
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
                                size: 28.r,
                                fontSize: 11.sp,
                              )
                            else
                              Icon(
                                Icons.bed_rounded,
                                size: 30.sp,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            SizedBox(height: 6.h),
                            Text(
                              isFree ? 'FREE' : (tenantName?.split(' ')[0] ?? (isAway ? 'AWAY' : upperStatus)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: textColor.withValues(alpha: 0.8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isAway || isNotice)
              Positioned(
                top: -4.h,
                right: -4.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAway)
                      _buildBadge('AWAY', const Color(0xFFF59E0B)),
                    if (isAway && isNotice) SizedBox(width: 2.w),
                    if (isNotice)
                      _buildBadge('NOTICE', const Color(0xFFFACC15)),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "BED $bedLabel",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DottedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dottedPath = Path();

    const double dashWidth = 4;
    const double dashSpace = 3;
    double distance = 0;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dottedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0;
    }

    canvas.drawPath(dottedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
