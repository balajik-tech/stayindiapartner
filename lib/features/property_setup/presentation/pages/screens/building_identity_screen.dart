import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'map_picker_screen.dart';

class BuildingIdentityScreen extends StatefulWidget {
  const BuildingIdentityScreen({super.key});

  @override
  State<BuildingIdentityScreen> createState() => _BuildingIdentityScreenState();
}

class _BuildingIdentityScreenState extends State<BuildingIdentityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _gstController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PropertySetupCubit>();
    _nameController = TextEditingController(text: cubit.state.buildingName);
    _gstController = TextEditingController(text: cubit.state.gstNumber);
    _addressController = TextEditingController(text: cubit.state.detailedAddress);
    _areaController = TextEditingController(text: cubit.state.area);
    _cityController = TextEditingController(text: cubit.state.city);
    _stateController = TextEditingController(text: cubit.state.state);
    _pincodeController = TextEditingController(text: cubit.state.pincode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertySetupCubit, PropertySetupState>(
      listenWhen: (prev, curr) => 
        prev.buildingName != curr.buildingName || 
        prev.gstNumber != curr.gstNumber ||
        prev.detailedAddress != curr.detailedAddress ||
        prev.area != curr.area ||
        prev.city != curr.city ||
        prev.state != curr.state ||
        prev.pincode != curr.pincode ||
        prev.error != curr.error ||
        prev.isSaving != curr.isSaving,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.isSaving) {
        }

        if (_nameController.text != state.buildingName) _nameController.text = state.buildingName;
        if (_gstController.text != state.gstNumber) _gstController.text = state.gstNumber;
        if (_addressController.text != state.detailedAddress) _addressController.text = state.detailedAddress;
        if (_areaController.text != state.area) _areaController.text = state.area;
        if (_cityController.text != state.city) _cityController.text = state.city;
        if (_stateController.text != state.state) _stateController.text = state.state;
        if (_pincodeController.text != state.pincode) _pincodeController.text = state.pincode;
      },
      child: BlocBuilder<PropertySetupCubit, PropertySetupState>(
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E3A8A),
                        letterSpacing: -0.5,
                      ),
                    ),
                SizedBox(height: 8.h),
                Text(
                  'Start by giving your property a name and identifying its type.',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),

                _buildSectionCard([
                  _buildHostelTypeToggle(context, state),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'Property Name',
                    hint: 'e.g. Royal Heritage Hostel',
                    icon: Icons.business_rounded,
                    controller: _nameController,
                    onChanged: (val) => context.read<PropertySetupCubit>().updateBuildingName(val),
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'GST Number (Optional)',
                    hint: 'Enter GSTIN',
                    icon: Icons.description_rounded,
                    controller: _gstController,
                    onChanged: (val) => context.read<PropertySetupCubit>().updateGstNumber(val),
                  ),
                ]),

                SizedBox(height: 32.h),

                Text(
                  'Location Details',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pin your property on the map for accurate guest navigation.',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),

                _buildSectionCard([
                  _buildTextField(
                    context,
                    label: 'Location on Map',
                    hint: 'Tap to pin location',
                    icon: Icons.map_rounded,
                    readOnly: true,
                    onTap: () async {
                      final cubit = context.read<PropertySetupCubit>();
                      final ll.LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPickerScreen(
                            initialLocation: cubit.state.lat != null 
                                ? ll.LatLng(cubit.state.lat!, cubit.state.lng!) 
                                : null,
                          ),
                        ),
                      );
                      
                      if (result != null) {
                        cubit.updateCoordinates(result.latitude, result.longitude);
                      }
                    },
                    initialValue: state.lat != null ? 'Location pinned: ${state.lat?.toStringAsFixed(4)}, ${state.lng?.toStringAsFixed(4)}' : '',
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'Detailed Address',
                    hint: 'Street, Landmark, etc.',
                    icon: Icons.location_on_rounded,
                    controller: _addressController,
                    onChanged: (val) => context.read<PropertySetupCubit>().updateDetailedAddress(val),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'Area',
                          hint: 'e.g. HSR Layout',
                          icon: Icons.grid_view_rounded,
                          controller: _areaController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updateArea(val),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'City',
                          hint: 'e.g. Bangalore',
                          icon: Icons.location_city_rounded,
                          controller: _cityController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updateCity(val),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'State',
                          hint: 'e.g. Karnataka',
                          icon: Icons.public_rounded,
                          controller: _stateController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updateState(val),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'Pin Code',
                          hint: '5600...',
                          icon: Icons.pin_drop_rounded,
                          controller: _pincodeController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updatePincode(val),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ]),

                SizedBox(height: 32.h),

                Text(
                  'Property Images',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Upload high-quality images to attract more guests.',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16.h),
                _buildImageCategories(context, state),

                SizedBox(height: 32.h),

                Text(
                  'Compliance Documents',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Upload mandatory licenses for property verification (PDF/Image).',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),
                _buildSectionCard([
                  _buildFilePicker(
                    context,
                    label: 'Food License (FSSAI)',
                    hint: state.foodLicense?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('food'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Hostel License / Shops & Est.',
                    hint: state.hostelLicense?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('hostel'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Trade License',
                    hint: state.tradeLicense?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('trade'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Fire Safety Certificate',
                    hint: state.fireSafety?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('fire'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Police NOC',
                    hint: state.policeNoc?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('police'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'GST Registration',
                    hint: state.gstRegistration?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('gst'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Health and Sanitation NOC',
                    hint: state.healthSanitation?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('health'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Commercial Utility Bill',
                    hint: state.utilityBill?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('utility'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Pollution Control NOC',
                    hint: state.pollutionNoc?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('pollution'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'Resident Police Verification',
                    hint: state.residentVerification?.split('/').last ?? 'Select PDF or Image',
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('resident'),
                  ),
                ]),
              ],
            ),
          ),
          _buildLoadingOverlay(state),
        ],
      );
    },
  ),
);
  }

  Widget _buildLoadingOverlay(PropertySetupState state) {
    if (!state.isSaving) return const SizedBox.shrink();
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              SizedBox(height: 16.h),
              Text(
                'Analyzing Image Quality...',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 4.h),
              Text(
                'Ensuring photos are clear and bright',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHostelTypeToggle(BuildContext context, PropertySetupState state) {
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
          height: 50.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: types.map((type) {
              final isSelected = state.hostelType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<PropertySetupCubit>().updateHostelType(type);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: isSelected ? [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                      ] : null,
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
    TextEditingController? controller,
    String? initialValue,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: readOnly 
                    ? Text(
                        initialValue?.isNotEmpty == true ? initialValue! : hint,
                        style: TextStyle(
                          fontSize: 14.sp, 
                          color: initialValue?.isNotEmpty == true ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : TextFormField(
                        controller: controller,
                        onChanged: onChanged,
                        keyboardType: keyboardType,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCategories(BuildContext context, PropertySetupState state) {
    final categories = [
      {'id': 'Exterior', 'name': 'Exterior & Entrance', 'icon': Icons.business_rounded},
      {'id': 'Reception', 'name': 'Reception & Lobby', 'icon': Icons.countertops_rounded},
      {'id': 'Rooms', 'name': 'Rooms & Bedrooms', 'icon': Icons.bed_rounded},
      {'id': 'Dining', 'name': 'Common Hall & Dining', 'icon': Icons.chair_rounded},
      {'id': 'Kitchen', 'name': 'Kitchen & Pantry', 'icon': Icons.kitchen_rounded},
      {'id': 'Bathrooms', 'name': 'Bathrooms & Washrooms', 'icon': Icons.bathtub_rounded},
      {'id': 'Balcony', 'name': 'Balcony & Terrace', 'icon': Icons.balcony_rounded},
      {'id': 'TV', 'name': 'Common TV Area', 'icon': Icons.tv_rounded},
      {'id': 'Gym', 'name': 'Gym & Recreation', 'icon': Icons.fitness_center_rounded},
      {'id': 'Laundry', 'name': 'Laundry Area', 'icon': Icons.local_laundry_service_rounded},
      {'id': 'Parking', 'name': 'Parking Space', 'icon': Icons.local_parking_rounded},
      {'id': 'Corridors', 'name': 'Corridors & Stairs', 'icon': Icons.stairs_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final images = state.categorizedImages[cat['id']] ?? [];
          final hasImage = images.isNotEmpty;

          return Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: hasImage ? const Color(0xFFFF7A00).withValues(alpha: 0.3) : const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                    image: hasImage ? DecorationImage(
                      image: FileImage(File(images.last)),
                      fit: BoxFit.cover,
                    ) : null,
                  ),
                  child: !hasImage ? Icon(cat['icon'] as IconData, color: const Color(0xFF1E3A8A), size: 24.sp) : null,
                ),
                SizedBox(height: 12.h),
                Text(
                  cat['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showImageSourceSheet(context, cat['id'] as String);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasImage ? Icons.edit_rounded : Icons.add_circle_outline_rounded, 
                        color: const Color(0xFFFF7A00), 
                        size: 16.sp
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        hasImage ? 'CHANGE' : 'ADD',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: const Color(0xFFFF7A00)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilePicker(
    BuildContext context, {
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.file_present_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF1E3A8A),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Browse', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet(BuildContext context, String category) {
    final cubit = context.read<PropertySetupCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
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
              Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E3A8A)),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceButton(
                      context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        cubit.pickCategoryImage(category, source: ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildSourceButton(
                      context,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        cubit.pickCategoryImage(category, source: ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF7A00), size: 32.sp),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}
