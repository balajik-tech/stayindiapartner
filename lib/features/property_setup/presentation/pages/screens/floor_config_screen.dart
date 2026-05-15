import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';

class FloorConfigScreen extends StatelessWidget {
  const FloorConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Floor Configuration', 'Define the total floors and rooms in your property.'),
              SizedBox(height: 12.h),
              
              // Total Floors Card
              _PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Floors',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 12.h),
                    _buildFloorCounter(context, state),
                  ],
                ),
              ),


              if (state.selectedFloors.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rooms per Floor',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2B5797)),
                        ),
                        Text(
                          'Set room count for each floor.',
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B5797),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Total: ${context.read<PropertySetupCubit>().totalRooms}',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.read<PropertySetupCubit>().updateAllFloorsRoomCount(10);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 12.sp, color: const Color(0xFF2B5797)),
                          SizedBox(width: 4.w),
                          Text(
                            'APPLY 10 TO ALL',
                            style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2B5797)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.selectedFloors.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final floor = state.selectedFloors[index];
                    return _buildFloorRoomItem(context, floor, state.floorRoomCounts[floor] ?? 0);
                  },
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E3A8A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloorCounter(BuildContext context, PropertySetupState state) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCounterButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (state.selectedFloors.length > 1) {
                HapticFeedback.lightImpact();
                context.read<PropertySetupCubit>().setTotalFloors(state.selectedFloors.length - 1);
              }
            },
          ),
          Column(
            children: [
              Text(
                state.selectedFloors.length.toString(),
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), height: 1.1),
              ),
              Text(
                'FLOORS',
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
            ],
          ),
          _buildCounterButton(
            icon: Icons.add_rounded,
            onTap: () {
              if (state.selectedFloors.length < 15) {
                HapticFeedback.mediumImpact();
                context.read<PropertySetupCubit>().setTotalFloors(state.selectedFloors.length + 1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: const Color(0xFF2B5797),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2B5797).withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }



  Widget _buildFloorRoomItem(BuildContext context, String floor, int currentCount) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2B5797),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              floor,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floor $floor',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                Text(
                  '$currentCount rooms planned',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildSmallCounterButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (currentCount > 0) {
                      HapticFeedback.lightImpact();
                      context.read<PropertySetupCubit>().updateFloorRoomCount(floor, currentCount - 1);
                    }
                  },
                ),
                SizedBox(
                  width: 24.w,
                  child: Text(
                    currentCount.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
                  ),
                ),
                _buildSmallCounterButton(
                  icon: Icons.add_rounded,
                  isPrimary: true,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.read<PropertySetupCubit>().updateFloorRoomCount(floor, currentCount + 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCounterButton({required IconData icon, required VoidCallback onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        margin: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          color: const Color(0xFF2B5797),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 16.sp),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
