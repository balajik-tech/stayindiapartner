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

              SizedBox(height: 16.h),

              // Default Amenities Card
              _PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Room Amenities',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Applied to all generated rooms.',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                    ),
                    SizedBox(height: 12.h),
                    _buildAmenitiesChips(context, state),
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

  Widget _buildAmenitiesChips(BuildContext context, PropertySetupState state) {
    final amenities = [
      {'id': 'Car Parking', 'name': 'Car Parking', 'icon': Icons.directions_car_rounded},
      {'id': 'Two Wheeler Parking', 'name': 'Two Wheeler Parking', 'icon': Icons.two_wheeler_rounded},
      {'id': 'Lift', 'name': 'Lift', 'icon': Icons.elevator_rounded},
      {'id': 'Study Table & Chair', 'name': 'Study Table & Chair', 'icon': Icons.chair_alt_rounded},
      {'id': 'Single/Sharing Rooms', 'name': 'Single/Sharing Rooms', 'icon': Icons.room_preferences_rounded},
      {'id': 'AC / Cooler', 'name': 'AC / Cooler', 'icon': Icons.ac_unit_rounded},
      {'id': 'TV', 'name': 'TV', 'icon': Icons.tv_rounded},
      {'id': 'High-Speed Wi-Fi', 'name': 'High-Speed Wi-Fi', 'icon': Icons.wifi_rounded},
      {'id': 'Washing Machine', 'name': 'Washing Machine', 'icon': Icons.local_laundry_service_rounded},
      {'id': 'Purified Drinking Water (RO)', 'name': 'Purified Drinking Water (RO)', 'icon': Icons.water_drop_rounded},
      {'id': 'Geyser (Hot Water)', 'name': 'Geyser (Hot Water)', 'icon': Icons.hot_tub_rounded},
      {'id': 'Power Backup (Generator)', 'name': 'Power Backup (Generator)', 'icon': Icons.power_rounded},
      {'id': 'CCTV Security', 'name': 'CCTV Security', 'icon': Icons.videocam_rounded},
      {'id': 'Individual Lockers / Wardrobes', 'name': 'Individual Lockers / Wardrobes', 'icon': Icons.lock_rounded},
      {'id': 'Daily Housekeeping', 'name': 'Daily Housekeeping', 'icon': Icons.cleaning_services_rounded},
      {'id': '3 Tier Food Service', 'name': '3 Tier Food Service', 'icon': Icons.restaurant_rounded},
      {'id': 'Kitchen (Self-Cooking Area)', 'name': 'Kitchen (Self-Cooking Area)', 'icon': Icons.kitchen_rounded},
      {'id': 'Gym / Fitness Center', 'name': 'Gym / Fitness Center', 'icon': Icons.fitness_center_rounded},
      {'id': 'Professional Common Lounge / Lobby', 'name': 'Professional Common Lounge / Lobby', 'icon': Icons.weekend_rounded},
      {'id': 'Biometric / Smart Card Access', 'name': 'Biometric / Smart Card Access', 'icon': Icons.fingerprint_rounded},
      {'id': 'Attached Balcony', 'name': 'Attached Balcony', 'icon': Icons.balcony_rounded},
      {'id': 'Shoe Racks / Storage Area', 'name': 'Shoe Racks / Storage Area', 'icon': Icons.shelves},
      {'id': 'First Aid / Emergency Kit', 'name': 'First Aid / Emergency Kit', 'icon': Icons.medical_services_rounded},
      {'id': 'Fire Safety (Extinguishers)', 'name': 'Fire Safety (Extinguishers)', 'icon': Icons.fire_extinguisher_rounded},
      {'id': 'Guest Waiting Area', 'name': 'Guest Waiting Area', 'icon': Icons.event_seat_rounded},
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: amenities.map((amenity) {
        final isSelected = state.selectedAmenities.contains(amenity['id']);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<PropertySetupCubit>().toggleAmenity(amenity['id'] as String);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEDF2F7) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF2B5797) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  amenity['icon'] as IconData,
                  size: 16.sp,
                  color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF64748B),
                ),
                SizedBox(width: 6.w),
                Text(
                  amenity['name'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF2B5797) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
