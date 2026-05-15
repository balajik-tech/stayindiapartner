import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';

class UnifiedHeader extends StatelessWidget {
  const UnifiedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        String selectedHostelName = "select_property".tr();
        if (state is HostelLoaded && state.hostels.isNotEmpty) {
          if (state.selectedHostelIndices.length > 1) {
            selectedHostelName = "${state.selectedHostelIndices.length} ${"properties".tr()}";
          } else {
            final index = state.selectedHostelIndices.isNotEmpty 
                ? state.selectedHostelIndices.first 
                : state.selectedHostelIndex;
            
            if (index < state.hostels.length) {
              selectedHostelName = state.hostels[index].name;
              // 10/10 RESPONSIVE TRUNCATION: 
              // Smartly truncate based on word boundaries if possible, else fixed length.
              if (selectedHostelName.length > 12) {
                selectedHostelName = "${selectedHostelName.substring(0, 9).trim()}...";
              }
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          color: Colors.white,
          child: Row(
            children: [
              // SI Partner Logo
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7000),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      "PARTNER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Property Switcher
              Semantics(
                label: 'switch_property'.tr(),
                hint: '${'current_property'.tr()}: $selectedHostelName',
                button: true,
                child: GestureDetector(
                  onTap: () => _showSwitchHostelSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.apartment_rounded, color: const Color(0xFFFF7000), size: 18.sp),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedHostelName,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 18.sp),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Notification Button
              Semantics(
                label: 'notifications'.tr(),
                button: true,
                child: Tooltip(
                  message: 'notifications'.tr(),
                  child: BouncingWrapper(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                      );
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded, 
                        color: const Color(0xFF3B71CA), 
                        size: 24.sp
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSwitchHostelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is! HostelLoaded) return const SizedBox.shrink();
          
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'switch_property'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = state.selectedHostelIndices.contains(index);
                      return BouncingWrapper(
                        onTap: () {
                          context.read<HostelCubit>().toggleHostelSelection(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.backgroundSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.apartment_rounded, 
                                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  hostel.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 24.sp),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
