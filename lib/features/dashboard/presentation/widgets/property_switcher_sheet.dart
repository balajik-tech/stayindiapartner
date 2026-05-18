import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/property_setup_stepper_page.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class PropertySwitcherSheet extends StatelessWidget {
  final VoidCallback? onAddProperty;
  final Function(int)? onPropertySelected;

  const PropertySwitcherSheet({
    super.key,
    this.onAddProperty,
    this.onPropertySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Property',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Select a property to manage',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                BouncingWrapper(
                  onTap: () {
                    Navigator.pop(context);
                    if (onAddProperty != null) {
                      onAddProperty!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PropertySetupStepperPage(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.orange,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400.h),
            child: BlocBuilder<HostelCubit, HostelState>(
              builder: (context, state) {
                if (state is HostelLoaded) {
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: state.hostels.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = state.selectedHostelIndices.contains(
                        index,
                      );

                      return BouncingWrapper(
                        onTap: () {
                          if (onPropertySelected != null) {
                            onPropertySelected!(index);
                            Navigator.pop(context);
                          } else {
                            context.read<HostelCubit>().toggleHostelSelection(
                              index,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF1F5F9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50.r,
                                height: 50.r,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  image: hostel.coverImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            hostel.coverImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: hostel.coverImage == null
                                    ? Icon(
                                        Icons.apartment_rounded,
                                        color: Colors.orange,
                                        size: 24.sp,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hostel.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      hostel.city ?? 'Unknown Location',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 24.sp,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
