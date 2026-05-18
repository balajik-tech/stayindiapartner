import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:flutter/services.dart';

class GlobalActionSheet extends StatelessWidget {
  const GlobalActionSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onNewProperty,
    required VoidCallback onAddFloor,
    required VoidCallback onAddRoom,
    required VoidCallback onAddTenant,
    required VoidCallback onRoomMaster,
    required VoidCallback onGuestRequests,
    required VoidCallback onSpecialOffers,
    bool isMultiSelect = false,
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
        onRoomMaster: onRoomMaster,
        onGuestRequests: onGuestRequests,
        onSpecialOffers: onSpecialOffers,
        isMultiSelect: isMultiSelect,
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
  final VoidCallback onRoomMaster;
  final VoidCallback onGuestRequests;
  final VoidCallback onSpecialOffers;
  final bool isMultiSelect;

  const GlobalActionSheetContent({
    super.key,
    required this.onNewProperty,
    required this.onAddFloor,
    required this.onAddRoom,
    required this.onAddTenant,
    required this.onRoomMaster,
    required this.onGuestRequests,
    required this.onSpecialOffers,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          _buildActionItem(
            context,
            icon: Icons.store_rounded,
            title: 'new_property'.tr(),
            subtitle: 'new_property_sub'.tr(),
            onTap: () {
              Navigator.pop(context);
              onNewProperty();
            },
          ),
          if (!isMultiSelect) ...[
            SizedBox(height: 12.h),
            _buildActionItem(
              context,
              icon: Icons.layers_rounded,
              title: 'add_new_floor_rooms'.tr(),
              subtitle: 'add_new_floor_rooms_sub'.tr(),
              onTap: () {
                Navigator.pop(context);
                onAddFloor();
              },
            ),
            SizedBox(height: 12.h),
            _buildActionItem(
              context,
              icon: Icons.door_front_door_rounded,
              title: 'room_master'.tr(),
              subtitle: 'room_master_sub'.tr(),
              onTap: () {
                Navigator.pop(context);
                onRoomMaster();
              },
            ),
            SizedBox(height: 12.h),
            _buildActionItem(
              context,
              icon: Icons.person_add_rounded,
              title: 'add_tenant'.tr(),
              subtitle: 'add_tenant_sub'.tr(),
              onTap: () {
                Navigator.pop(context);
                onAddTenant();
              },
            ),
            SizedBox(height: 12.h),
            _buildActionItem(
              context,
              icon: Icons.assignment_ind_rounded,
              title: 'guest_requests'.tr(),
              subtitle: 'bookings_subtitle'.tr(),
              onTap: () {
                Navigator.pop(context);
                onGuestRequests();
              },
            ),
            SizedBox(height: 12.h),
            _buildActionItem(
              context,
              icon: Icons.local_offer_rounded,
              title: 'hostel_offers'.tr(),
              subtitle: 'hostel_offers_sub'.tr(),
              onTap: () {
                Navigator.pop(context);
                onSpecialOffers();
              },
            ),
          ],
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7000).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFFF7000), size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
