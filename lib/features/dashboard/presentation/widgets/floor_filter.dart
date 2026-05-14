import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class FloorFilter extends StatelessWidget {
  final List<String> floors;
  final int selectedIndex;
  final Function(int) onSelected;

  const FloorFilter({
    super.key,
    required this.floors,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: floors.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: BouncingWrapper(
              onTap: () => onSelected(index),
              scaleFactor: 0.97,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2C5990) : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF2C5990).withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(4, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2C5990).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ] : [
                    // Embedded/Flat feel for secondary chips
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  floors[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
