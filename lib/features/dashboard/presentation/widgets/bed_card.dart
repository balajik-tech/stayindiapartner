import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/widgets/side_view_bed_icon.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BedCard extends StatelessWidget {
  final String bedNumber;
  final String status;
  final String? tenantName;
  final String? tenantAvatar;
  final bool isSelected;
  final bool isSmall;
  final bool? isAwayField;
  final Color? labelColor;
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.tenantAvatar,
    this.isSelected = false,
    this.isSmall = false,
    this.isAwayField,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    final upperStatus = status.toUpperCase();
    final bool isAway = isAwayField ?? (upperStatus == 'AWAY');
    final bool isBooked = upperStatus == 'BOOKED';
    final bool isReserved = upperStatus == 'RESERVED';
    final bool isNotice = upperStatus == 'NOTICE';
    final bool isFree = upperStatus == 'FREE';
    final bool isMaintenance = upperStatus == 'MAINTENANCE';

    if (isFree) {
      bgColor = const Color(0xFFD6EEF8);
      borderColor = const Color(0xFF87CEEB);
      textColor = const Color(0xFF1A6F8A);
    } else if (isMaintenance) {
      bgColor = const Color(0xFFF1F5F9);
      borderColor = const Color(0xFFCBD5E1);
      textColor = const Color(0xFF475569);
    } else if (isNotice) {
      bgColor = const Color(0xFFFFF3CD);
      borderColor = const Color(0xFFFFB300);
      textColor = const Color(0xFF7A5800);
    } else if (isBooked || isReserved) {
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
      label:
          '${'bed'.tr()} $bedNumber, ${'status'.tr()}: $status${tenantName != null ? ', ${'tenant'.tr()}: $tenantName' : ''}',
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
                  width: isSmall ? 52.w : 72.w,
                  height: isSmall ? 76.h : 106.h,
                  child: CustomPaint(
                    foregroundPainter: _DottedBorderPainter(
                      color: borderColor,
                      strokeWidth: 3.0,
                      dashWidth: 4,
                      dashSpace: 3,
                      borderRadius: isSmall ? 14.r : 18.r,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(
                          isSmall ? 14.r : 18.r,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: borderColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: tenantAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(isSmall ? 14.r : 18.r),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: ApiConstants.getImageUrl(tenantAvatar) ?? '',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(color: bgColor),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: isSmall ? 8.h : 12.h),
                                      child: FittedBox(
                                        child: Text(
                                          bedLabel,
                                          style: TextStyle(
                                            fontSize: isSmall ? 11.sp : 14.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 8.h : 12.h,
                                horizontal: 4.w,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (tenantName != null)
                                    CustomAvatar(
                                      imageUrl: null,
                                      name: tenantName ?? 'T',
                                      size: isSmall ? 30.r : 42.r,
                                      fontSize: isSmall ? 14.sp : 18.sp,
                                      isCircle: true,
                                    )
                                  else
                                    isMaintenance
                                        ? Icon(
                                            Icons.build_rounded,
                                            size: isSmall ? 22.sp : 34.sp,
                                            color: textColor.withValues(alpha: 0.8),
                                          )
                                        : SideViewBedIcon(
                                            size: isSmall ? 22.sp : 34.sp,
                                            color: textColor.withValues(alpha: 0.8),
                                          ),
                                  SizedBox(height: isSmall ? 4.h : 8.h),
                                  FittedBox(
                                    child: Text(
                                      bedLabel,
                                      style: TextStyle(
                                        fontSize: isSmall ? 11.sp : 14.sp,
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
                if (isAway && isNotice) ...[
                  Positioned(
                    top: isSmall ? -4.h : -6.h,
                    left: isSmall ? 2.w : 4.w,
                    child: _BouncingBadge(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 3.w : 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'away'.tr(),
                          style: TextStyle(
                            fontSize: isSmall ? 7.sp : 9.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: isSmall ? -4.h : -6.h,
                    right: isSmall ? 2.w : 4.w,
                    child: _BouncingBadge(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 3.w : 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'notice_status'.tr(),
                          style: TextStyle(
                            fontSize: isSmall ? 7.sp : 9.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else if (isAway || isNotice || isBooked || isReserved)
                  Positioned(
                    top: isSmall ? -4.h : -6.h,
                    right: isSmall ? 2.w : 4.w,
                    child: _BouncingBadge(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 3.w : 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          isAway ? 'away'.tr() : (isNotice ? 'notice_status'.tr() : (isReserved ? 'reserved'.tr() : 'booked'.tr())),
                          style: TextStyle(
                            fontSize: isSmall ? 7.sp : 9.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmall ? 4.h : 6.h),
            Text(
              isFree
                  ? StringUtils.translate('available', context: context)
                  : isMaintenance
                  ? 'Maintenance'
                  : (tenantName?.split(' ')[0] ?? upperStatus),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmall ? 9.sp : 13.sp,
                fontWeight: FontWeight.w700,
                color: labelColor ?? textColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingBadge extends StatefulWidget {
  final Widget child;

  const _BouncingBadge({required this.child});

  @override
  State<_BouncingBadge> createState() => _BouncingBadgeState();
}

class _BouncingBadgeState extends State<_BouncingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -4).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
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
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final remaining = metric.length - distance;
        final currentDash = dashWidth < remaining ? dashWidth : remaining;
        canvas.drawPath(
          metric.extractPath(distance, distance + currentDash),
          paint,
        );
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
