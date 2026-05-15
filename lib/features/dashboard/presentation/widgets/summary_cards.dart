import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';

class SummaryCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData icon;
  final bool isSelected;
  final bool isBordered;

  const SummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    this.isBordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool useWhiteStyle = isBordered || color == Colors.white;
    final Color backgroundColor = useWhiteStyle ? Colors.white : color;
    
    final bool isLightBackground = useWhiteStyle || 
                                  ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.light;
    
    final Color contentColor = isLightBackground ? const Color(0xFF0F172A) : Colors.white;

    return Semantics(
      label: '$label: $count',
      selected: isSelected,
      button: true,
      child: BouncingWrapper(
        onTap: onTap,
        scaleFactor: 0.97,
        child: Container(
          width: 86.w,
          height: 68.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          margin: EdgeInsets.only(right: 10.w, bottom: 4.h, top: 2.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(11.r),
            border: useWhiteStyle ? Border.all(color: const Color(0xFF3B71CA), width: 1.2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: contentColor, size: 20.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        count,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: contentColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: contentColor.withValues(alpha: isLightBackground ? 0.75 : 0.95),
                        height: 1.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final totalProperties = hostelState is HostelLoaded ? hostelState.hostels.length : 0;
    final authState = context.watch<AuthCubit>().state;
    final owner = authState is AuthAuthenticated ? authState.owner : null;
    final role = owner?.role.toLowerCase() ?? 'owner';

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final bool isLoading = state is DashboardLoading;
        final data = state is DashboardLoaded ? state.data : null;
        final occupancy = data?.occupancy;
        final status = data?.occupancyStatus;
        final ops = data?.dailyOperations;

        return SizedBox(
          height: 80.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildCard(context, 'properties', '$totalProperties', 'total_properties'.tr(), Colors.white, Icons.apartment_rounded, state.selectedMetric, isBordered: true),
              _buildCard(context, 'total', isLoading ? '...' : (occupancy?.totalBeds.toString() ?? '0'), 'total_beds'.tr(), const Color(0xFF2C599D), Icons.bed_rounded, state.selectedMetric),
              if (role != 'warden')
                _buildCard(context, 'overdue', isLoading ? '...' : (ops?.overdueRent.count.toString() ?? '0'), 'payment_dues'.tr(), const Color(0xFF800000), Icons.payments_rounded, state.selectedMetric),
              _buildCard(context, 'occupied', isLoading ? '...' : (occupancy?.occupiedBeds.toString() ?? '0'), 'occupied'.tr(), const Color(0xFFFF8600), Icons.person_pin_rounded, state.selectedMetric),
              _buildCard(context, 'free', isLoading ? '...' : (occupancy?.freeBeds.toString() ?? '0'), 'vacant_beds'.tr(), const Color(0xFF87CEEB), Icons.add_box_rounded, state.selectedMetric),
              _buildCard(context, 'reserved', isLoading ? '...' : (occupancy?.reservedBeds.toString() ?? '0'), 'pre_booked'.tr(), const Color(0xFF9C27B0), Icons.event_available_rounded, state.selectedMetric),
              _buildCard(context, 'notice', isLoading ? '...' : (occupancy?.noticeBeds.toString() ?? '0'), 'move_out_notice'.tr(), const Color(0xFFFFB300), Icons.notifications_active_rounded, state.selectedMetric),
              _buildAttendanceCard(context, isLoading ? '...' : (status?.inside.toString() ?? '0'), isLoading ? '...' : (status?.outside.toString() ?? '0')),
              _buildCard(context, 'away', isLoading ? '...' : (status?.unknown.toString() ?? '0'), 'away'.tr(), const Color(0xFFE91E63), Icons.luggage_rounded, state.selectedMetric),
              _buildCard(context, 'repair', isLoading ? '...' : '0', 'minor_repair'.tr(), const Color(0xFFCBD5E1), Icons.handyman_rounded, state.selectedMetric),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(BuildContext context, String inCount, String outCount) {
    return BouncingWrapper(
      onTap: () {},
      scaleFactor: 0.97,
      child: Container(
        width: 110.w,
        height: 68.h,
        margin: EdgeInsets.only(right: 10.w, bottom: 4.h, top: 2.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [

            Container(
              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 7.w),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _BlinkingDot(),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'live_attendance'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [

                  Expanded(
                    child: Semantics(
                      label: '${'presence_in'.tr()}: $inCount',
                      child: Container(
                        color: const Color(0xFF34A853),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              inCount,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'presence_in'.tr().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Semantics(
                      label: '${'presence_out'.tr()}: $outCount',
                      child: Container(
                        color: const Color(0xFF94A3B8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              outCount,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'presence_out'.tr().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String id, String count, String label, Color color, IconData icon, String? selectedMetric, {bool isBordered = false}) {
    return SummaryCard(
      count: count,
      label: label,
      color: color,
      icon: icon,
      isBordered: isBordered,
      isSelected: selectedMetric == id,
      onTap: () => context.read<DashboardCubit>().toggleMetric(id),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6.r,
        height: 6.r,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  }
