import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/pages/map_picker_page.dart';
import 'package:latlong2/latlong.dart';

class BuildingIdentityScreen extends StatelessWidget {
  const BuildingIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Building Identity',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by giving your property a name and location.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 32.h),
          
          _buildTextField(
            label: 'Building Name',
            hint: 'e.g. Royal Heritage Hostel',
            icon: Icons.business_rounded,
            onChanged: (val) => context.read<PropertySetupCubit>().updateBuildingName(val),
            initialValue: context.read<PropertySetupCubit>().state.buildingName,
          ),
          
          SizedBox(height: 24.h),
          
          _buildTextField(
            label: 'Property Coordinates',
            hint: 'Tap to pin location on map',
            icon: Icons.map_rounded,
            readOnly: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPickerPage(
                    initialLocation: context.read<PropertySetupCubit>().state.lat != null 
                        ? LatLng(context.read<PropertySetupCubit>().state.lat!, context.read<PropertySetupCubit>().state.lng!)
                        : null,
                    onLocationSelected: (location) {
                      context.read<PropertySetupCubit>().updateCoordinates(location.latitude, location.longitude);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            initialValue: context.watch<PropertySetupCubit>().state.lat != null 
                ? '${context.watch<PropertySetupCubit>().state.lat!.toStringAsFixed(4)}, ${context.watch<PropertySetupCubit>().state.lng!.toStringAsFixed(4)}'
                : '',
          ),
          
          SizedBox(height: 24.h),
          
          _buildTextField(
            label: 'Full Property Address',
            hint: 'Enter detailed address',
            icon: Icons.location_on_rounded,
            onChanged: (val) => context.read<PropertySetupCubit>().updateAddress(val),
            initialValue: context.read<PropertySetupCubit>().state.address,
          ),

          SizedBox(height: 24.h),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Area',
                  hint: 'e.g. HSR Layout',
                  icon: Icons.map_outlined,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateArea(val),
                  initialValue: context.read<PropertySetupCubit>().state.area,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  hint: 'e.g. Bangalore',
                  icon: Icons.location_city_rounded,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateCity(val),
                  initialValue: context.read<PropertySetupCubit>().state.city,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          _buildTextField(
            label: 'State',
            hint: 'e.g. Karnataka',
            icon: Icons.public_rounded,
            onChanged: (val) => context.read<PropertySetupCubit>().updateState(val),
            initialValue: context.read<PropertySetupCubit>().state.state,
          ),

          SizedBox(height: 32.h),
          Text(
            'Floor Selection',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
          ),
          SizedBox(height: 16.h),
          _buildFloorSelection(context),

          SizedBox(height: 32.h),
          Text(
            'Amenities (Icon Only UI)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
          ),
          SizedBox(height: 16.h),
          _buildAmenitiesSelection(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: readOnly 
                    ? Text(
                        initialValue?.isNotEmpty == true ? initialValue! : hint,
                        style: TextStyle(
                          fontSize: 14.sp, 
                          color: initialValue?.isNotEmpty == true ? AppColors.darkText : Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : TextFormField(
                        initialValue: initialValue,
                        onChanged: onChanged,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorSelection(BuildContext context) {
    final List<String> floors = ['G', '1', '2', '3', '4', '5'];
    final selectedFloors = context.watch<PropertySetupCubit>().state.selectedFloors;

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: floors.map((floor) {
        final isSelected = selectedFloors.contains(floor);
        return GestureDetector(
          onTap: () => context.read<PropertySetupCubit>().toggleFloor(floor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50.w,
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
              ] : null,
            ),
            child: Text(
              floor,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : AppColors.darkText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesSelection(BuildContext context) {
    final List<Map<String, dynamic>> amenities = [
      {'id': 'wifi', 'icon': Icons.wifi_rounded},
      {'id': 'cctv', 'icon': Icons.videocam_rounded},
      {'id': 'ro', 'icon': Icons.water_drop_rounded},
      {'id': 'geyser', 'icon': Icons.hot_tub_rounded},
      {'id': 'parking', 'icon': Icons.directions_car_rounded},
    ];
    final selectedAmenities = context.watch<PropertySetupCubit>().state.selectedAmenities;

    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: amenities.map((amenity) {
        final isSelected = selectedAmenities.contains(amenity['id']);
        return GestureDetector(
          onTap: () => context.read<PropertySetupCubit>().toggleAmenity(amenity['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Icon(
              amenity['icon'],
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade400,
              size: 28.sp,
            ),
          ),
        );
      }).toList(),
    );
  }
}
