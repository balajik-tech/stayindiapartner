import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: floors.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  floors[index].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
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
