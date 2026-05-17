import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'map_picker_screen.dart';
import 'package:stayindia_owner/core/widgets/local_pdf_preview_screen.dart';


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
                      'basic_details'.tr(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E3A8A),
                        letterSpacing: -0.5,
                      ),
                    ),
                SizedBox(height: 8.h),
                Text(
                  'basic_details_sub'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),

                _buildSectionCard([
                  _buildHostelTypeToggle(context, state),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'property_name'.tr(),
                    hint: 'property_name_hint'.tr(),
                    icon: Icons.business_rounded,
                    controller: _nameController,
                    onChanged: (val) => context.read<PropertySetupCubit>().updateBuildingName(val),
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'gst_number'.tr(),
                    hint: 'gst_number_hint'.tr(),
                    icon: Icons.description_rounded,
                    controller: _gstController,
                    onChanged: (val) => context.read<PropertySetupCubit>().updateGstNumber(val),
                  ),
                ]),

                SizedBox(height: 32.h),

                Text(
                  'location_details'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'location_details_sub'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),

                _buildSectionCard([
                  _buildTextField(
                    context,
                    label: 'location_on_map'.tr(),
                    hint: 'location_hint'.tr(),
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
                    initialValue: state.lat != null ? 'location_pinned'.tr(namedArgs: {'lat': state.lat!.toStringAsFixed(4), 'lng': state.lng!.toStringAsFixed(4)}) : '',
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField(
                    context,
                    label: 'detailed_address'.tr(),
                    hint: 'detailed_address_hint'.tr(),
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
                          label: 'area'.tr(),
                          hint: 'area_hint'.tr(),
                          icon: Icons.grid_view_rounded,
                          controller: _areaController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updateArea(val),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'city'.tr(),
                          hint: 'city_hint'.tr(),
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
                          label: 'state_label'.tr(),
                          hint: 'state_hint'.tr(),
                          icon: Icons.public_rounded,
                          controller: _stateController,
                          onChanged: (val) => context.read<PropertySetupCubit>().updateState(val),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: 'pin_code'.tr(),
                          hint: 'pin_code_hint'.tr(),
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
                  'property_images'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'property_images_sub'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16.h),
                _buildImageCategories(context, state),

                SizedBox(height: 32.h),

                Text(
                  'compliance_docs'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'compliance_docs_sub'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),
                _buildSectionCard([
                  _buildFilePicker(
                    context,
                    label: 'food_license'.tr(),
                    hint: state.foodLicense?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.foodLicense,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('food'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('food'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'hostel_license'.tr(),
                    hint: state.hostelLicense?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.hostelLicense,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('hostel'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('hostel'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'trade_license'.tr(),
                    hint: state.tradeLicense?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.tradeLicense,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('trade'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('trade'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'fire_safety'.tr(),
                    hint: state.fireSafety?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.fireSafety,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('fire'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('fire'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'police_noc'.tr(),
                    hint: state.policeNoc?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.policeNoc,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('police'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('police'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'gst_registration'.tr(),
                    hint: state.gstRegistration?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.gstRegistration,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('gst'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('gst'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'health_noc'.tr(),
                    hint: state.healthSanitation?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.healthSanitation,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('health'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('health'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'utility_bill'.tr(),
                    hint: state.utilityBill?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.utilityBill,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('utility'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('utility'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'pollution_noc'.tr(),
                    hint: state.pollutionNoc?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.pollutionNoc,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('pollution'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('pollution'),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilePicker(
                    context,
                    label: 'resident_verification'.tr(),
                    hint: state.residentVerification?.split('/').last ?? 'select_pdf_image'.tr(),
                    filePath: state.residentVerification,
                    onTap: () => context.read<PropertySetupCubit>().pickLicense('resident'),
                    onRemove: () => context.read<PropertySetupCubit>().removeLicense('resident'),
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
                'analyzing_image_quality'.tr(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 4.h),
              Text(
                'ensuring_photos_clear'.tr(),
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
    final types = [
      {'id': 'Boys', 'key': 'type_boys'},
      {'id': 'Girls', 'key': 'type_girls'},
      {'id': 'Co-Living', 'key': 'type_coliving'}
    ];
    
    final selectedIndex = types.indexWhere((t) => t['id'] == state.hostelType);
    final hasSelection = selectedIndex != -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'type_of_pg'.tr(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final double toggleWidth = (constraints.maxWidth - 8.r) / 3;
            return Container(
              height: 50.h,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: [
                  if (hasSelection)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      left: selectedIndex * toggleWidth,
                      width: toggleWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: types.map((type) {
                      final isSelected = state.hostelType == type['id'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<PropertySetupCubit>().updateHostelType(type['id'] as String);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.transparent,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                                fontFamily: 'Inter',
                              ),
                              child: Text((type['key'] as String).tr()),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF94A3B8), size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: readOnly 
                    ? Text(
                        initialValue?.isNotEmpty == true ? initialValue! : hint,
                        style: TextStyle(
                          fontSize: 16.sp, 
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
                          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 16.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
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
      {'id': 'Exterior', 'name': 'exterior_entrance'.tr(), 'icon': Icons.business_rounded},
      {'id': 'Reception', 'name': 'reception_lobby'.tr(), 'icon': Icons.countertops_rounded},
      {'id': 'Rooms', 'name': 'rooms_bedrooms'.tr(), 'icon': Icons.bed_rounded},
      {'id': 'Dining', 'name': 'common_hall'.tr(), 'icon': Icons.chair_rounded},
      {'id': 'Kitchen', 'name': 'kitchen_pantry'.tr(), 'icon': Icons.kitchen_rounded},
      {'id': 'Bathrooms', 'name': 'bathrooms'.tr(), 'icon': Icons.bathtub_rounded},
      {'id': 'Balcony', 'name': 'balcony'.tr(), 'icon': Icons.balcony_rounded},
      {'id': 'TV', 'name': 'tv_area'.tr(), 'icon': Icons.tv_rounded},
      {'id': 'Gym', 'name': 'gym'.tr(), 'icon': Icons.fitness_center_rounded},
      {'id': 'Laundry', 'name': 'laundry'.tr(), 'icon': Icons.local_laundry_service_rounded},
      {'id': 'Parking', 'name': 'parking'.tr(), 'icon': Icons.local_parking_rounded},
      {'id': 'Corridors', 'name': 'corridors'.tr(), 'icon': Icons.stairs_rounded},
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.r),
                        image: hasImage ? DecorationImage(
                          image: ResizeImage(FileImage(File(images.last)), width: 128, height: 128),
                          fit: BoxFit.cover,
                        ) : null,
                      ),
                      child: !hasImage ? Icon(cat['icon'] as IconData, color: const Color(0xFF1E3A8A), size: 24.sp) : null,
                    ),
                    if (hasImage)
                      Positioned(
                        top: -6.r,
                        right: -6.r,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.read<PropertySetupCubit>().removeCategoryImage(cat['id'] as String, images.length - 1);
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                        hasImage ? 'btn_edit'.tr().toUpperCase() : 'btn_add'.tr().toUpperCase(),
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
    required String? filePath,
    VoidCallback? onRemove,
  }) {
    final hasFile = filePath != null && filePath.isNotEmpty;
    final isImage = hasFile && (filePath.toLowerCase().endsWith('.jpg') || 
                                filePath.toLowerCase().endsWith('.jpeg') || 
                                filePath.toLowerCase().endsWith('.png'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: hasFile ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            children: [
              if (isImage)
                GestureDetector(
                  onTap: () => _showFullScreenImage(context, filePath),
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      image: DecorationImage(
                        image: ResizeImage(FileImage(File(filePath)), width: 150, height: 150),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: hasFile ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocalPdfPreviewScreen(
                          filePath: filePath,
                          title: label,
                        ),
                      ),
                    );
                  } : null,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: hasFile ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      hasFile ? Icons.file_present_rounded : Icons.upload_file_rounded, 
                      color: hasFile ? const Color(0xFF1E3A8A) : const Color(0xFF94A3B8), 
                      size: 24.sp
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 14.sp, 
                        color: hasFile ? const Color(0xFF1E293B) : const Color(0xFF64748B), 
                        fontWeight: hasFile ? FontWeight.w800 : FontWeight.w600
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasFile)
                      Text(
                        'click_to_view'.tr(),
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasFile ? Colors.white : const Color(0xFF2B5797),
                  foregroundColor: hasFile ? const Color(0xFF2B5797) : Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: hasFile ? const BorderSide(color: Color(0xFF2B5797), width: 1.5) : BorderSide.none,
                  ),
                ),
                child: Text(
                  hasFile ? 'btn_edit'.tr() : 'browse'.tr(), 
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900)
                ),
              ),
              if (hasFile && onRemove != null) ...[
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onRemove();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(8.r),
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String path) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Hero(
              tag: path,
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                cacheWidth: 1080,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, String category) {
    final cubit = context.read<PropertySetupCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final hasImage = cubit.state.categorizedImages[category]?.isNotEmpty == true;
        return BlocProvider.value(
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
                  'select_image_source'.tr(),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E3A8A)),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceButton(
                        context,
                        icon: Icons.camera_alt_rounded,
                        label: 'camera'.tr(),
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
                        label: 'gallery'.tr(),
                        onTap: () {
                          Navigator.pop(context);
                          cubit.pickCategoryImage(category, source: ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                if (hasImage) ...[
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                        cubit.removeCategoryImage(category, (cubit.state.categorizedImages[category]?.length ?? 0) - 1);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      label: Text(
                        'remove'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
