import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class SummaryCard extends StatelessWidget {
  final String count;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isSelected;

  const SummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
    this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 22.sp,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor.withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) {
        return prev.selectedMetric != curr.selectedMetric || 
               prev.runtimeType != curr.runtimeType ||
               (prev is DashboardLoaded && curr is DashboardLoaded && 
                (prev.data.occupancy != curr.data.occupancy || 
                 prev.data.occupancyStatus != curr.data.occupancyStatus ||
                 prev.data.dailyOperations != curr.data.dailyOperations));
      },
      builder: (context, state) {
        final bool isLoading = state is DashboardLoading;
        final data = state is DashboardLoaded ? state.data : null;
        final occupancy = data?.occupancy;
        final status = data?.occupancyStatus;
        final ops = data?.dailyOperations;

        return SizedBox(
          height: 64.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildCard(context, 'total', isLoading ? '...' : (occupancy?.totalBeds.toString() ?? '0'), 'TOTAL', const Color(0xFF0F172A), Colors.white, Icons.bed_rounded, state.selectedMetric),
              _buildCard(context, 'free', isLoading ? '...' : (occupancy?.freeBeds.toString() ?? '0'), 'FREE', const Color(0xFF0891B2), Colors.white, Icons.bed_outlined, state.selectedMetric),
              _buildCard(context, 'occupied', isLoading ? '...' : (occupancy?.occupiedBeds.toString() ?? '0'), 'OCCUPIED', const Color(0xFFF97316), Colors.white, Icons.person_rounded, state.selectedMetric),
              _buildCard(context, 'notice', isLoading ? '...' : (occupancy?.noticeBeds.toString() ?? '0'), 'NOTICE', const Color(0xFFFACC15), const Color(0xFF1E293B), Icons.notifications_rounded, state.selectedMetric),
              _buildCard(context, 'overdue', isLoading ? '...' : (ops?.overdueRent.count.toString() ?? '0'), 'OVERDUE', const Color(0xFFEF4444), Colors.white, Icons.error_outline_rounded, state.selectedMetric),
              _buildCard(context, 'inside', isLoading ? '...' : (status?.inside.toString() ?? '0'), 'INSIDE', const Color(0xFF22C55E), Colors.white, Icons.home_rounded, state.selectedMetric),
              _buildCard(context, 'outside', isLoading ? '...' : (status?.outside.toString() ?? '0'), 'OUTSIDE', const Color(0xFF64748B), Colors.white, Icons.logout_rounded, state.selectedMetric),
              _buildCard(context, 'away', isLoading ? '...' : (status?.unknown.toString() ?? '0'), 'AWAY', const Color(0xFF8B5CF6), Colors.white, Icons.schedule_rounded, state.selectedMetric),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String id, String count, String label, Color color, Color textColor, IconData icon, String? selectedMetric) {
    return SummaryCard(
      count: count,
      label: label,
      backgroundColor: color,
      textColor: textColor,
      icon: icon,
      isSelected: selectedMetric == id,
      onTap: () => context.read<DashboardCubit>().toggleMetric(id),
    );
  }
}
