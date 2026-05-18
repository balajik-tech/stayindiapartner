import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_status_entity.dart';

class GeoFenceStatusRow extends StatelessWidget {
  final OccupancyStatus? occupancyStatus;

  const GeoFenceStatusRow({super.key, this.occupancyStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              "LIVE OCCUPANCY STATUS",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey[800],
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  label: "In House",
                  value: occupancyStatus?.inside.toString() ?? "0",
                  icon: Icons.person_pin_circle_rounded,
                  color: const Color(0xFF008B8B),
                  backgroundColor: const Color(0xFFE0F7F7),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatusCard(
                  label: "Out House",
                  value: occupancyStatus?.outside.toString() ?? "0",
                  icon: Icons.hail_rounded,
                  color: const Color(0xFFE67E22),
                  backgroundColor: const Color(0xFFFDF2E9),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatusCard(
                  label: "Unknown",
                  value: occupancyStatus?.unknown.toString() ?? "0",
                  icon: Icons.help_outline_rounded,
                  color: Colors.blueGrey,
                  backgroundColor: Colors.blueGrey.shade50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: backgroundColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[400],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
