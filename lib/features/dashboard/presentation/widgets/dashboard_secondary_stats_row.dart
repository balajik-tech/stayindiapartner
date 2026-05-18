import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class DashboardSecondaryStatsRow extends StatelessWidget {
  const DashboardSecondaryStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'INSIDE',
            icon: Icons.home_rounded,
            themeColor: const Color(0xFF22C55E),
            backgroundColor: const Color(0xFFE8F8F0),
            textColor: const Color(0xFF16A34A),
            selector: (state) => state is DashboardLoaded
                ? state.data.occupancyStatus.inside
                : 0,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            label: 'OUTSIDE',
            icon: Icons.person_remove_rounded,
            themeColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFFFEAEA),
            textColor: const Color(0xFFDC2626),
            selector: (state) => state is DashboardLoaded
                ? state.data.occupancyStatus.outside
                : 0,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            label: 'AWAY',
            icon: Icons.nights_stay_rounded,
            themeColor: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFFFFF4E5),
            textColor: const Color(0xFFD97706),
            selector: (state) =>
                state is DashboardLoaded ? state.data.occupancy.awayBeds : 0,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            label: 'BOOKINGS',
            icon: Icons.calendar_today_rounded,
            themeColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFEAF3FF),
            textColor: const Color(0xFF2563EB),
            selector: (state) => state is DashboardLoaded
                ? state.data.dailyOperations.todayCheckIns
                : 0,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color themeColor;
  final Color backgroundColor;
  final Color textColor;
  final int Function(DashboardState) selector;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.themeColor,
    required this.backgroundColor,
    required this.textColor,
    required this.selector,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: themeColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeColor, size: 22.sp),
            ),
            SizedBox(height: 8.h),
            BlocSelector<DashboardCubit, DashboardState, int>(
              selector: selector,
              builder: (context, count) {
                return Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
