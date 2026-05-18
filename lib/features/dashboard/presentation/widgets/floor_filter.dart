import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2C599D) : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  floors[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 14.sp,
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
