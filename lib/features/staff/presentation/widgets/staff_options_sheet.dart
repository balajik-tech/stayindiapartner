import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import '../../domain/entities/staff.dart';
import '../cubit/staff_cubit.dart';
import 'add_staff_sheet.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class StaffOptionsSheet extends StatelessWidget {
  final Staff staff;
  final VoidCallback onUpdated;

  const StaffOptionsSheet({
    super.key,
    required this.staff,
    required this.onUpdated,
  });

  static void show(
    BuildContext context, {
    required Staff staff,
    required VoidCallback onUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StaffOptionsSheet(staff: staff, onUpdated: onUpdated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        12.h,
        24.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.greyText.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryBlue,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      StringUtils.translate(
                        staff.role.toLowerCase().replaceAll(' ', '_'),
                        context: context,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          _buildOption(
            context,
            icon: Icons.edit_rounded,
            label: StringUtils.translate(
              'edit_details_option',
              context: context,
            ),
            color: AppColors.darkText,
            onTap: () {
              Navigator.pop(context);
              AddStaffSheet.show(
                context,
                hostelId: staff.hostelId,
                staff: staff,
                onAdded: onUpdated,
              );
            },
          ),
          _buildOption(
            context,
            icon: staff.isActive
                ? Icons.block_rounded
                : Icons.check_circle_outline_rounded,
            label: staff.isActive
                ? StringUtils.translate(
                    'deactivate_account_option',
                    context: context,
                  )
                : StringUtils.translate(
                    'activate_account_option',
                    context: context,
                  ),
            color: staff.isActive
                ? const Color(0xFFF04438)
                : const Color(0xFF099268),
            onTap: () {
              context.read<StaffCubit>().updateStaff(staff.id, {
                'isActive': !staff.isActive,
              });
              Navigator.pop(context);
              onUpdated();
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.greyText.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22.sp),
                SizedBox(width: 16.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.greyText.withValues(alpha: 0.2),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
