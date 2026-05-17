import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/bed_card.dart';

class RoomConfigScreen extends StatefulWidget {
  const RoomConfigScreen({super.key});

  @override
  State<RoomConfigScreen> createState() => _RoomConfigScreenState();
}

class _RoomConfigScreenState extends State<RoomConfigScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PropertySetupCubit>();
    if (cubit.state.rooms.isEmpty) {
      cubit.autoGenerateRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('room_config'.tr(), 'room_config_desc'.tr()),
                  BouncingWrapper(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showCloneDialog(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF2B5797).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF2B5797).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.copy_all_rounded, color: const Color(0xFF2B5797), size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'btn_clone'.tr().toUpperCase(),
                            style: TextStyle(color: const Color(0xFF2B5797), fontSize: 10.sp, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.rooms.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.rooms.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final room = state.rooms[index];
                        return _buildRoomCard(context, index, room, key: ValueKey('room_${room['roomNumber']}'));
                      },
                    ),
            ),
          ],
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
            color: const Color(0xFF2B5797),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.meeting_room_rounded, size: 48.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 24.h),
          Text(
            'no_rooms_found'.tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 8.h),
          Text(
            'no_rooms_found_sub'.tr(),
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, int index, Map<String, dynamic> room, {Key? key}) {
    final state = context.watch<PropertySetupCubit>().state;
    final categories = state.roomCategories;
    final features = room['features'] as Map<String, dynamic>? ?? {};

    return _PremiumCard(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoomHeader(context, index, room, categories),
          SizedBox(height: 20.h),
          Text(
            'sharing_type_label'.tr().toUpperCase(),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          SizedBox(height: 12.h),
          _buildSharingSelector(context, index, room['sharingType'] ?? 2),
          SizedBox(height: 24.h),
          Text(
            'amenities_label'.tr().toUpperCase(),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureIcon(
                icon: Icons.ac_unit_rounded,
                label: 'amenity_ac'.tr(),
                isSelected: features['isAC'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'isAC', !(features['isAC'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.hot_tub_rounded,
                label: 'amenity_geyser'.tr(),
                isSelected: features['hasGeyser'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasGeyser', !(features['hasGeyser'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.balcony_rounded,
                label: 'amenity_balcony'.tr(),
                isSelected: features['hasBalcony'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasBalcony', !(features['hasBalcony'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.wc_rounded,
                label: 'amenity_washroom'.tr(),
                isSelected: features['hasAttachedWashroom'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasAttachedWashroom', !(features['hasAttachedWashroom'] ?? false)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'beds_config'.tr().toUpperCase(),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: (room['beds'] as List).map((bed) {
              return BedCard(
                bedNumber: bed['bedNumber']?.toString() ?? '1',
                status: 'FREE',
                onTap: () {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomHeader(BuildContext context, int index, Map<String, dynamic> room, List<Map<String, dynamic>> categories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.door_front_door_rounded, size: 18.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(width: 12.w),
            Text(
              'room_number_label'.tr(namedArgs: {'number': room['roomNumber'].toString()}),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            'floor_label'.tr(namedArgs: {'floor': room['floor'].toString()}),
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSelector(BuildContext context, int index, int selected) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Sliding Background Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            alignment: Alignment(
              -1.0 + ((selected - 1) * (2.0 / 4.0)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
              ),
            ),
          ),
          // Interactive Labels
          Row(
            children: [1, 2, 3, 4, 5].map((s) {
              final isSelected = selected == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      HapticFeedback.mediumImpact();
                      context.read<PropertySetupCubit>().updateRoomSharing(index, s);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'sharing_count'.tr(namedArgs: {'count': s.toString()}),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5.sp, // Reduced slightly to prevent tight UI issues
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEDF2F7) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF2B5797) : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2B5797).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF94A3B8), size: 28.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showCloneDialog(BuildContext context) {
    final state = context.read<PropertySetupCubit>().state;
    if (state.rooms.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('clone_settings'.tr(), style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: Text('clone_confirm_msg'.tr(namedArgs: {'room': state.rooms[0]['roomNumber'].toString()}),
            style: TextStyle(fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(), style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: EdgeInsets.only(left: 8.w),
            child: ElevatedButton(
              onPressed: () {
                context.read<PropertySetupCubit>().cloneRoomSettings(0);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('settings_cloned_success'.tr()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5797),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('btn_clone_to_all'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({super.key, required this.child});

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
