import 'package:flutter/material.dart';
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
                  _buildSectionHeader('Room Master', 'Customize features for each room.'),
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
                            'CLONE FIRST',
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
                        return _buildRoomCard(context, index, room);
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
            'No Rooms Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Go back to Step 2 to add rooms.',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, int index, Map<String, dynamic> room) {
    final state = context.watch<PropertySetupCubit>().state;
    final categories = state.roomCategories;
    final features = room['features'] as Map<String, dynamic>? ?? {};

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoomHeader(context, index, room, categories),
          SizedBox(height: 20.h),
          Text(
            'SHARING TYPE',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          SizedBox(height: 12.h),
          _buildSharingSelector(context, index, room['sharingType'] ?? 2),
          SizedBox(height: 24.h),
          Text(
            'AMENITIES',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureIcon(
                icon: Icons.ac_unit_rounded,
                label: 'AC',
                isSelected: features['isAC'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'isAC', !(features['isAC'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.hot_tub_rounded,
                label: 'Geyser',
                isSelected: features['hasGeyser'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasGeyser', !(features['hasGeyser'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.balcony_rounded,
                label: 'Balcony',
                isSelected: features['hasBalcony'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasBalcony', !(features['hasBalcony'] ?? false)),
              ),
              _buildFeatureIcon(
                icon: Icons.wc_rounded,
                label: 'Washroom',
                isSelected: features['hasAttachedWashroom'] ?? false,
                onTap: () => context.read<PropertySetupCubit>().updateRoomFeature(index, 'hasAttachedWashroom', !(features['hasAttachedWashroom'] ?? false)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'BEDS CONFIGURATION',
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
              'Room ${room['roomNumber']}',
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
            'FLOOR ${room['floor']}',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSelector(BuildContext context, int index, int selected) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [1, 2, 3, 4, 5].map((s) {
          final isSelected = selected == s;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<PropertySetupCubit>().updateRoomSharing(index, s);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  s == 1 ? 'Single' : (s == 2 ? 'Double' : (s == 3 ? 'Triple' : (s == 4 ? 'Quad' : 'Penta'))),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            padding: EdgeInsets.all(12.r),
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
            child: Icon(icon, color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF94A3B8), size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
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
        title: Text('Clone Settings', style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: Text('Apply current settings of Room ${state.rooms[0]['roomNumber']} to all other rooms?',
            style: TextStyle(fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: EdgeInsets.only(left: 8.w),
            child: ElevatedButton(
              onPressed: () {
                context.read<PropertySetupCubit>().cloneRoomSettings(0);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings cloned to all rooms!'), backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5797),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('Clone to All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
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
