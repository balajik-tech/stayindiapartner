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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Floor Configuration', 'Define the total floors and rooms in your property.'),
              SizedBox(height: 16.h),
              _PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Floors',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 16.h),
                    _buildFloorCounter(context, state),
                  ],
                ),
              ),
              
              if (state.selectedFloors.isNotEmpty) ...[
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Rooms per Floor', 'Set the room count for each floor.'),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Text(
                        'Total: ${context.read<PropertySetupCubit>().totalRooms}',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.read<PropertySetupCubit>().updateAllFloorsRoomCount(10);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFFFE4C4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 16.sp, color: const Color(0xFFFF7A00)),
                          SizedBox(width: 4.w),
                          Text(
                            'APPLY 10 TO ALL',
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFFFF7A00)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.selectedFloors.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final floor = state.selectedFloors[index];
                    return _buildFloorRoomInput(context, floor, state.floorRoomCounts[floor] ?? 0);
                  },
                ),
              ],
              SizedBox(height: 40.h),
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
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
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
        borderRadius: BorderRadius.circular(20.r),
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
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), height: 1.1),
              ),
              Text(
                'FLOORS',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1),
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
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFFF7A00), size: 24.sp),
      ),
    );
  }

  Widget _buildFloorRoomInput(BuildContext context, String floor, int currentCount) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF7A00).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Text(
              floor,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floor $floor',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
                Text(
                  '$currentCount rooms planned',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildSmallIconButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (currentCount > 0) {
                      HapticFeedback.lightImpact();
                      context.read<PropertySetupCubit>().updateFloorRoomCount(floor, currentCount - 1);
                    }
                  },
                ),
                Container(
                  width: 36.w,
                  alignment: Alignment.center,
                  child: Text(
                    currentCount.toString(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                  ),
                ),
                _buildSmallIconButton(
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

  Widget _buildSmallIconButton({required IconData icon, required VoidCallback onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        margin: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF7A00) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))
                ]
              : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFFFF7A00), size: 18.sp),
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFFF7A00).withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
