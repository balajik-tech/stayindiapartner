import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:flutter/services.dart';

class GlobalActionSheet extends StatelessWidget {
  const GlobalActionSheet({super.key});

  static Future<void> show(BuildContext context, {
    required VoidCallback onNewProperty,
    required VoidCallback onAddFloor,
    required VoidCallback onAddRoom,
    required VoidCallback onAddTenant,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlobalActionSheetContent(
        onNewProperty: onNewProperty,
        onAddFloor: onAddFloor,
        onAddRoom: onAddRoom,
        onAddTenant: onAddTenant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class GlobalActionSheetContent extends StatelessWidget {
  final VoidCallback onNewProperty;
  final VoidCallback onAddFloor;
  final VoidCallback onAddRoom;
  final VoidCallback onAddTenant;

  const GlobalActionSheetContent({
    super.key,
    required this.onNewProperty,
    required this.onAddFloor,
    required this.onAddRoom,
    required this.onAddTenant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 32.h),
          
          _buildActionItem(
            context,
            icon: Icons.add_business_rounded,
            title: 'New Property',
            subtitle: 'Onboard your new hostel/PG',
            onTap: () {
              Navigator.pop(context);
              onNewProperty();
            },
          ),
          SizedBox(height: 16.h),
          _buildActionItem(
            context,
            icon: Icons.layers_rounded,
            title: 'Add New Floor',
            subtitle: 'Expand your existing building',
            onTap: () {
              Navigator.pop(context);
              onAddFloor();
            },
          ),
          SizedBox(height: 16.h),
          _buildActionItem(
            context,
            icon: Icons.meeting_room_rounded,
            title: 'Add Room(s)',
            subtitle: 'Increase capacity instantly',
            onTap: () {
              Navigator.pop(context);
              onAddRoom();
            },
          ),
          SizedBox(height: 16.h),
          _buildActionItem(
            context,
            icon: Icons.person_add_rounded,
            title: 'Add Tenant',
            subtitle: 'Quick tenant check-in flow',
            onTap: () {
              Navigator.pop(context);
              onAddTenant();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7000).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFFF7000), size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.2), size: 14.sp),
          ],
        ),
      ),
    );
  }
}
