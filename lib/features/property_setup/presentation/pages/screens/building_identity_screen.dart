import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/features/dashboard/presentation/pages/map_picker_page.dart';
import 'package:latlong2/latlong.dart';

class BuildingIdentityScreen extends StatelessWidget {
  const BuildingIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PropertySetupCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Details', 'Start by giving your property a name and identifying its type.'),
          SizedBox(height: 16.h),
          _PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyTypeSelector(context, state),
                SizedBox(height: 24.h),
                _PremiumTextField(
                  label: 'Property Name',
                  hint: 'e.g. Royal Heritage Hostel',
                  icon: Icons.business_rounded,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateBuildingName(val),
                  initialValue: state.buildingName,
                ),
                SizedBox(height: 24.h),
                _PremiumTextField(
                  label: 'GST Number (Optional)',
                  hint: 'Enter GSTIN',
                  icon: Icons.description_rounded,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateGstNumber(val),
                  initialValue: state.gstNumber,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          _buildSectionHeader('Location Details', 'Pin your property on the map for accurate guest navigation.'),
          SizedBox(height: 16.h),
          _PremiumCard(
            child: Column(
              children: [
                _PremiumTextField(
                  label: 'Location on Map',
                  hint: 'Tap to pin location',
                  icon: Icons.map_rounded,
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPickerPage(
                          initialLocation: state.lat != null ? LatLng(state.lat!, state.lng!) : null,
                          onLocationSelected: (location) {
                            context.read<PropertySetupCubit>().updateCoordinates(location.latitude, location.longitude);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  initialValue: state.lat != null ? '${state.lat!.toStringAsFixed(4)}, ${state.lng!.toStringAsFixed(4)}' : '',
                ),
                SizedBox(height: 24.h),
                _PremiumTextField(
                  key: ValueKey('addr_${state.address}'),
                  label: 'Detailed Address',
                  hint: 'Street, Landmark, etc.',
                  icon: Icons.location_on_rounded,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateAddress(val),
                  initialValue: state.address,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _PremiumTextField(
                        key: ValueKey('area_${state.area}'),
                        label: 'Area',
                        hint: 'e.g. HSR Layout',
                        icon: Icons.map_outlined,
                        onChanged: (val) => context.read<PropertySetupCubit>().updateArea(val),
                        initialValue: state.area,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _PremiumTextField(
                        key: ValueKey('city_${state.city}'),
                        label: 'City',
                        hint: 'e.g. Bangalore',
                        icon: Icons.location_city_rounded,
                        onChanged: (val) => context.read<PropertySetupCubit>().updateCity(val),
                        initialValue: state.city,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PremiumTextField(
                        key: ValueKey('state_${state.state}'),
                        label: 'State',
                        hint: 'e.g. Karnataka',
                        icon: Icons.public_rounded,
                        onChanged: (val) => context.read<PropertySetupCubit>().updateState(val),
                        initialValue: state.state,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: _PremiumTextField(
                        key: ValueKey('pin_${state.pincode}'),
                        label: 'Pin Code',
                        hint: '560001',
                        icon: Icons.pin_drop_rounded,
                        onChanged: (val) => context.read<PropertySetupCubit>().updatePincode(val),
                        initialValue: state.pincode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),
          _buildSectionHeader('Property Images', 'Upload high-quality images to attract more guests.'),
          SizedBox(height: 16.h),
          _buildImageUploader(context),

          SizedBox(height: 32.h),
          _buildSectionHeader('Compliance Documents', 'Upload mandatory licenses for property verification (PDF/Image).'),
          SizedBox(height: 16.h),
          _buildLicenseSection(context, state),
          
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context, PropertySetupState state) {
    return _PremiumCard(
      child: Column(
        children: [
          _LicensePicker(
            label: 'Food License',
            path: state.foodLicense,
            onPick: () => context.read<PropertySetupCubit>().pickLicense('food'),
            onRemove: () => context.read<PropertySetupCubit>().removeLicense('food'),
          ),
          SizedBox(height: 16.h),
          _LicensePicker(
            label: 'Hostel License',
            path: state.hostelLicense,
            onPick: () => context.read<PropertySetupCubit>().pickLicense('hostel'),
            onRemove: () => context.read<PropertySetupCubit>().removeLicense('hostel'),
          ),
          SizedBox(height: 16.h),
          _LicensePicker(
            label: 'Trade License',
            path: state.tradeLicense,
            onPick: () => context.read<PropertySetupCubit>().pickLicense('trade'),
            onRemove: () => context.read<PropertySetupCubit>().removeLicense('trade'),
          ),
        ],
      ),
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

  Widget _buildPropertyTypeSelector(BuildContext context, PropertySetupState state) {
    final types = ['Boys', 'Girls', 'Co-Living'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of PG',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: types.map((type) {
              final isSelected = state.hostelType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.read<PropertySetupCubit>().updateHostelType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
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
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploader(BuildContext context) {
    final images = context.watch<PropertySetupCubit>().state.images;

    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => context.read<PropertySetupCubit>().pickImages(),
              child: Container(
                width: 100.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: const Color(0xFFFF7A00), size: 28.sp),
                    SizedBox(height: 6.h),
                    Text(
                      'Add Photos',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            );
          }

          final imagePath = images[index - 1];
          return Container(
            width: 100.h,
            margin: EdgeInsets.only(right: 12.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                    image: DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => context.read<PropertySetupCubit>().removeImage(index - 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LicensePicker extends StatelessWidget {
  final String label;
  final String? path;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _LicensePicker({
    required this.label,
    required this.path,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = path != null && path!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                hasFile ? Icons.description_rounded : Icons.upload_file_rounded,
                color: hasFile ? Colors.green : const Color(0xFF94A3B8),
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  hasFile ? path!.split('/').last : 'Select PDF or Image',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: hasFile ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    fontWeight: hasFile ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (hasFile)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                    child: Icon(Icons.close, color: const Color(0xFFEF4444), size: 14.sp),
                  ),
                )
              else
                TextButton(
                  onPressed: onPick,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text(
                    'Browse',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF7A00), fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
      ],
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

class _PremiumTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final String? initialValue;

  const _PremiumTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: widget.onTap,
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _isFocused ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                  width: _isFocused ? 2 : 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: _isFocused ? const Color(0xFFFF7A00) : const Color(0xFF94A3B8), size: 22.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: widget.readOnly
                        ? Text(
                            widget.initialValue?.isNotEmpty == true ? widget.initialValue! : widget.hint,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: widget.initialValue?.isNotEmpty == true ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : TextFormField(
                            initialValue: widget.initialValue,
                            onChanged: widget.onChanged,
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp, fontWeight: FontWeight.w500),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
