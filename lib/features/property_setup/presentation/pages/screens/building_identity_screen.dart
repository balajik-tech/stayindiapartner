import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:stayindia_owner/core/utils/text_utils.dart';
import 'package:stayindia_owner/core/widgets/app_toast.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'geofence_intro_screen.dart';
import 'package:stayindia_owner/core/widgets/local_pdf_preview_screen.dart';

class BuildingIdentityScreen extends StatefulWidget {
  const BuildingIdentityScreen({super.key});

  @override
  State<BuildingIdentityScreen> createState() => _BuildingIdentityScreenState();
}

class _BuildingIdentityScreenState extends State<BuildingIdentityScreen> {
  static const int maxPropertyImages = 10;
  static const int maxPropertyNameLength = 100;

  late final _nameLengthLimit = LengthLimitingTextInputFormatter(
    maxPropertyNameLength,
  );

  late final List<TextInputFormatter> _nameFormatters = [
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.characters.length > maxPropertyNameLength) {
        AppToast.show(
          context,
          'Property name can have at most $maxPropertyNameLength characters.',
        );
      }
      return _nameLengthLimit.formatEditUpdate(oldValue, newValue);
    }),
  ];

  // GSTIN: 15 characters, letters and digits only, always upper-case.
  static final List<TextInputFormatter> _gstFormatters = [
    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
    LengthLimitingTextInputFormatter(15),
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          newValue.copyWith(text: newValue.text.toUpperCase()),
    ),
  ];

  static final List<TextInputFormatter> _pincodeFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

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
    _addressController = TextEditingController(
      text: cubit.state.detailedAddress,
    );
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
        // Cubit errors are shown once, by the stepper page.
        if (state.isSaving) {}

        if (_nameController.text != state.buildingName) {
          _nameController.text = state.buildingName;
        }
        if (_gstController.text != state.gstNumber) {
          _gstController.text = state.gstNumber;
        }
        if (_addressController.text != state.detailedAddress) {
          _addressController.text = state.detailedAddress;
        }
        if (_areaController.text != state.area) {
          _areaController.text = state.area;
        }
        if (_cityController.text != state.city) {
          _cityController.text = state.city;
        }
        if (_stateController.text != state.state) {
          _stateController.text = state.state;
        }
        if (_pincodeController.text != state.pincode) {
          _pincodeController.text = state.pincode;
        }
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
                      'Add photos so guests know what to expect.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildImageTopCategories(context, state),
                    SizedBox(height: 32.h),

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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
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
                        inputFormatters: _nameFormatters,
                        onChanged: (val) => context
                            .read<PropertySetupCubit>()
                            .updateBuildingName(val),
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        context,
                        label: 'gst_number'.tr(),
                        hint: 'gst_number_hint'.tr(),
                        icon: Icons.description_rounded,
                        controller: _gstController,
                        inputFormatters: _gstFormatters,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (val) => context
                            .read<PropertySetupCubit>()
                            .updateGstNumber(val),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
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
                              builder: (context) => GeofenceIntroScreen(
                                initialLocation: cubit.state.lat != null
                                    ? ll.LatLng(
                                        cubit.state.lat!,
                                        cubit.state.lng!,
                                      )
                                    : null,
                              ),
                            ),
                          );

                          if (result != null) {
                            cubit.updateCoordinates(
                              result.latitude,
                              result.longitude,
                            );
                          }
                        },
                        initialValue: state.lat != null
                            ? 'location_pinned'.tr(
                                namedArgs: {
                                  'lat': state.lat!.toStringAsFixed(4),
                                  'lng': state.lng!.toStringAsFixed(4),
                                },
                              )
                            : '',
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        context,
                        label: 'detailed_address'.tr(),
                        hint: 'detailed_address_hint'.tr(),
                        icon: Icons.location_on_rounded,
                        controller: _addressController,
                        onChanged: (val) => context
                            .read<PropertySetupCubit>()
                            .updateDetailedAddress(val),
                      ),
                      SizedBox(height: 24.h),
                      Column(
                        children: [
                          _buildTextField(
                            context,
                            label: 'area'.tr(),
                            hint: 'area_hint'.tr(),
                            icon: Icons.grid_view_rounded,
                            controller: _areaController,
                            onChanged: (val) => context
                                .read<PropertySetupCubit>()
                                .updateArea(val),
                          ),
                          SizedBox(height: 24.h),
                          _buildTextField(
                            context,
                            label: 'city'.tr(),
                            hint: 'city_hint'.tr(),
                            icon: Icons.location_city_rounded,
                            controller: _cityController,
                            onChanged: (val) => context
                                .read<PropertySetupCubit>()
                                .updateCity(val),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Column(
                        children: [
                          _buildTextField(
                            context,
                            label: 'state_label'.tr(),
                            hint: 'state_hint'.tr(),
                            icon: Icons.public_rounded,
                            controller: _stateController,
                            onChanged: (val) => context
                                .read<PropertySetupCubit>()
                                .updateState(val),
                          ),
                          SizedBox(height: 24.h),
                          _buildTextField(
                            context,
                            label: 'pin_code'.tr(),
                            hint: 'pin_code_hint'.tr(),
                            icon: Icons.pin_drop_rounded,
                            controller: _pincodeController,
                            inputFormatters: _pincodeFormatters,
                            onChanged: (val) => context
                                .read<PropertySetupCubit>()
                                .updatePincode(val),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ]),

                    SizedBox(height: 32.h),

                    // Text(
                    //   'property_images'.tr(),
                    //   style: TextStyle(
                    //     fontSize: 22.sp,
                    //     fontWeight: FontWeight.w900,
                    //     color: const Color(0xFF1E3A8A),
                    //     letterSpacing: -0.5,
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    // Text(
                    //   'property_images_sub'.tr(),
                    //   style: TextStyle(
                    //     fontSize: 14.sp,
                    //     color: const Color(0xFF64748B),
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // SizedBox(height: 16.h),
                    // _buildImageCategories(context, state),

                    // SizedBox(height: 32.h),

                    //  commented compliance documents

                    // Text(
                    //   'compliance_docs'.tr(),
                    //   style: TextStyle(
                    //     fontSize: 22.sp,
                    //     fontWeight: FontWeight.w900,
                    //     color: const Color(0xFF1E3A8A),
                    //     letterSpacing: -0.5,
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    // Text(
                    //   'compliance_docs_sub'.tr(),
                    //   style: TextStyle(
                    //     fontSize: 14.sp,
                    //     color: const Color(0xFF64748B),
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // SizedBox(height: 24.h),
                    // _buildSectionCard([
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'food_license'.tr(),
                    //     filePath: state.foodLicense,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('food'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('food', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'hostel_license'.tr(),
                    //     filePath: state.hostelLicense,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('hostel'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('hostel', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'trade_license'.tr(),
                    //     filePath: state.tradeLicense,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('trade'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('trade', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'fire_safety'.tr(),
                    //     filePath: state.fireSafety,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('fire'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('fire', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'police_noc'.tr(),
                    //     filePath: state.policeNoc,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('police'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('police', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'shops_establishment'.tr(),
                    //     filePath: state.shopsEstablishment,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('shops'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('shops', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'gst_registration'.tr(),
                    //     filePath: state.gstRegistration,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('gst'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('gst', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'health_noc'.tr(),
                    //     filePath: state.healthSanitation,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('health'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('health', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'utility_bill'.tr(),
                    //     filePath: state.utilityBill,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('utility'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('utility', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'pollution_noc'.tr(),
                    //     filePath: state.pollutionNoc,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('pollution'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('pollution', idx),
                    //   ),
                    //   SizedBox(height: 20.h),
                    //   _buildFilePicker(
                    //     context,
                    //     label: 'resident_verification'.tr(),
                    //     filePath: state.residentVerification,
                    //     onTap: () => context
                    //         .read<PropertySetupCubit>()
                    //         .pickLicense('resident'),
                    //     onRemoveIndex: (idx) => context
                    //         .read<PropertySetupCubit>()
                    //         .removeLicenseAtIndex('resident', idx),
                    //   ),
                    // ]),
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
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'ensuring_photos_clear'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
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

  Widget _buildHostelTypeToggle(
    BuildContext context,
    PropertySetupState state,
  ) {
    final types = [
      {'id': 'Boys', 'key': 'type_boys'},
      {'id': 'Girls', 'key': 'type_girls'},
      {'id': 'Co-Living', 'key': 'type_coliving'},
    ];

    final selectedIndex = types.indexWhere((t) => t['id'] == state.hostelType);
    final hasSelection = selectedIndex != -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'type_of_pg'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
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
                            context.read<PropertySetupCubit>().updateHostelType(
                              type['id'] as String,
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.transparent,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF64748B),
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextUtils.capitalize(label),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
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
                          initialValue?.isNotEmpty == true
                              ? initialValue!
                              : hint,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: initialValue?.isNotEmpty == true
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : TextFormField(
                          controller: controller,
                          onChanged: onChanged,
                          keyboardType: keyboardType,
                          inputFormatters: inputFormatters,
                          textCapitalization: textCapitalization,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 16.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
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
      // {
      //   'id': 'Exterior',
      //   'name': 'exterior_entrance'.tr(),
      //   'icon': Icons.business_rounded,
      // },
      {
        'id': 'Reception',
        'name': 'reception_lobby'.tr(),
        'icon': Icons.countertops_rounded,
      },
      {'id': 'Rooms', 'name': 'rooms_bedrooms'.tr(), 'icon': Icons.bed_rounded},
      {'id': 'Dining', 'name': 'common_hall'.tr(), 'icon': Icons.chair_rounded},
      {
        'id': 'Kitchen',
        'name': 'kitchen_pantry'.tr(),
        'icon': Icons.kitchen_rounded,
      },
      {
        'id': 'Bathrooms',
        'name': 'bathrooms'.tr(),
        'icon': Icons.bathtub_rounded,
      },
      {'id': 'Balcony', 'name': 'balcony'.tr(), 'icon': Icons.balcony_rounded},
      {'id': 'TV', 'name': 'tv_area'.tr(), 'icon': Icons.tv_rounded},
      {'id': 'Gym', 'name': 'gym'.tr(), 'icon': Icons.fitness_center_rounded},
      {
        'id': 'Laundry',
        'name': 'laundry'.tr(),
        'icon': Icons.local_laundry_service_rounded,
      },
      {
        'id': 'Parking',
        'name': 'parking'.tr(),
        'icon': Icons.local_parking_rounded,
      },
      {
        'id': 'Corridors',
        'name': 'corridors'.tr(),
        'icon': Icons.stairs_rounded,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final images = state.categorizedImages[cat['id']] ?? [];
          final hasImage = images.isNotEmpty;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showImageSourceSheet(
                context,
                cat['id'] as String,
                cat['name'] as String,
              );
            },
            child: Container(
              width: 120.w,
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: hasImage
                      ? const Color(0xFFFF7A00).withValues(alpha: 0.3)
                      : const Color(0xFFF1F5F9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                          image: hasImage
                              ? DecorationImage(
                                  image: ResizeImage(
                                    FileImage(File(images.last)),
                                    width: 128,
                                    height: 128,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasImage
                            ? Icon(
                                cat['icon'] as IconData,
                                color: const Color(0xFF1E3A8A),
                                size: 24.sp,
                              )
                            : null,
                      ),
                      if (hasImage)
                        Positioned(
                          top: -6.r,
                          left: -6.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${images.length}/5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasImage
                            ? Icons.edit_rounded
                            : Icons.add_circle_outline_rounded,
                        color: const Color(0xFFFF7A00),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        hasImage
                            ? '${'btn_edit'.tr()} (${images.length})'
                                  .toUpperCase()
                            : 'btn_add'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFF7A00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageTopCategories(
    BuildContext context,
    PropertySetupState state,
  ) {
    final images = state.categorizedImages['Exterior'] ?? [];
    final cubit = context.read<PropertySetupCubit>();

    return Container(
      width: double.infinity,
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
        children: [
          GestureDetector(
            onTap: () => _onAddPropertyImage(context, images.length),
            child: CustomPaint(
              painter: DashedRectPainter(
                color: images.isNotEmpty
                    ? const Color(0xFFFF7A00).withValues(alpha: 0.5)
                    : const Color(0xFFCBD5E1),
                strokeWidth: 1.5,
                gap: 4,
              ),
              child: Container(
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: images.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(images.last)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.1),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (images.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF7ED),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: const Color(0xFFEA580C),
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Add photos',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'JPG or PNG · up to 5 MB each',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      if (images.length < maxPropertyImages)
                        Positioned(
                          left: 12.r,
                          bottom: 12.r,
                          child: _buildAddMoreChip(),
                        ),
                      Positioned(
                        top: 12.r,
                        right: 12.r,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.collections_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${images.length} Photos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '${images.length} of $maxPropertyImages added · first photo becomes the cover',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (images.isNotEmpty) ...[
            SizedBox(height: 20.h),
            SizedBox(
              height: 65.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length +
                    (images.length < maxPropertyImages ? 1 : 0),
                itemBuilder: (context, idx) {
                  if (idx == images.length) {
                    return _buildAddImageTile(context, images.length);
                  }
                  final imgPath = images[idx];
                  return Container(
                    width: 60.w,
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.all(5.r),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, imgPath),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              image: DecorationImage(
                                image: ResizeImage(
                                  FileImage(File(imgPath)),
                                  width: 180,
                                  height: 180,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -3.r,
                          right: -3.r,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              cubit.removeCategoryImage('Exterior', idx);
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
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }



  void _onAddPropertyImage(BuildContext context, int imageCount) {
    if (imageCount >= maxPropertyImages) {
      AppToast.show(
        context,
        'You can add up to $maxPropertyImages photos. Remove one to add another.',
      );
      return;
    }
    HapticFeedback.selectionClick();
    _showTopImagePickerBottomSheet(context);
  }

  Widget _buildAddMoreChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A00),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            'Add more',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageTile(BuildContext context, int imageCount) {
    return GestureDetector(
      onTap: () => _onAddPropertyImage(context, imageCount),
      child: Container(
        width: 50.w,
        margin: EdgeInsets.only(right: 12.w, top: 5.r, bottom: 5.r),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFFF7A00).withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          color: const Color(0xFFEA580C),
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildFilePicker(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required String? filePath,
    required Function(int) onRemoveIndex,
  }) {
    final files =
        filePath?.split(',').where((f) => f.isNotEmpty).toList() ?? [];
    final count = files.length;
    final hasFiles = files.isNotEmpty;
    final canAdd = count < 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (hasFiles)
              Text(
                '$count/5 files',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF7A00),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasFiles) ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: count,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, idx) {
                    final path = files[idx];
                    final isImage =
                        path.toLowerCase().endsWith('.jpg') ||
                        path.toLowerCase().endsWith('.jpeg') ||
                        path.toLowerCase().endsWith('.png');
                    final fileName = path.split('/').last;

                    return Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          if (isImage)
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, path),
                              child: Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  image: DecorationImage(
                                    image: ResizeImage(
                                      FileImage(File(path)),
                                      width: 120,
                                      height: 120,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocalPdfPreviewScreen(
                                      filePath: path,
                                      title: label,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.file_present_rounded,
                                  color: const Color(0xFF1E3A8A),
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isImage) {
                                  _showFullScreenImage(context, path);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LocalPdfPreviewScreen(
                                            filePath: path,
                                            title: label,
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF1E293B),
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'click_to_view'.tr(),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              onRemoveIndex(idx);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.all(6.r),
                              backgroundColor: Colors.red.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (canAdd) SizedBox(height: 16.h),
              ],
              if (canAdd)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasFiles
                            ? 'Upload another document'
                            : 'Select PDF or Image',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onTap();
                      },
                      icon: Icon(
                        Icons.add_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        hasFiles ? 'Add'.tr() : 'browse'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16539B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: const Color(0xFF64748B),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Maximum 5 documents uploaded',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
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
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
            ),
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

  void _showTopImagePickerBottomSheet(BuildContext context) {
    final cubit = context.read<PropertySetupCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'property_images'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Add photo using camera or gallery',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24.h),
              _buildImageSourceListItem(
                context,
                icon: Icons.camera_alt_rounded,
                title: 'camera'.tr(),
                subtitle: 'Take a photo with your camera',
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickCategoryImage(
                    'Exterior',
                    source: ImageSource.camera,
                    maxImages: maxPropertyImages,
                  );
                },
              ),
              SizedBox(height: 12.h),
              _buildImageSourceListItem(
                context,
                icon: Icons.photo_library_rounded,
                title: 'gallery'.tr(),
                subtitle: 'Choose an existing photo from gallery',
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickCategoryImage(
                    'Exterior',
                    source: ImageSource.gallery,
                    maxImages: maxPropertyImages,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF7A00),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(
    BuildContext context,
    String category,
    String categoryName, {
    int maxImages = 5,
  }) {
    final cubit = context.read<PropertySetupCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<PropertySetupCubit, PropertySetupState>(
            builder: (context, state) {
              final images = state.categorizedImages[category] ?? [];
              final count = images.length;
              final hasImages = images.isNotEmpty;
              final canAdd = count < 5;

              return Container(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
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
                      '$categoryName ($count/5)',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Upload up to 5 images to showcase this section.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasImages) ...[
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 90.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: count,
                          itemBuilder: (context, idx) {
                            final imgPath = images[idx];
                            return Container(
                              width: 90.w,
                              margin: EdgeInsets.only(right: 12.w),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showFullScreenImage(context, imgPath),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        image: DecorationImage(
                                          image: ResizeImage(
                                            FileImage(File(imgPath)),
                                            width: 180,
                                            height: 180,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -4.r,
                                    right: -4.r,
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        cubit.removeCategoryImage(
                                          category,
                                          idx,
                                        );
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
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    if (canAdd) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildSourceButton(
                              context,
                              icon: Icons.camera_alt_rounded,
                              label: 'camera'.tr(),
                              onTap: () {
                                cubit.pickCategoryImage(
                                  category,
                                  source: ImageSource.camera,
                                );
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
                                cubit.pickCategoryImage(
                                  category,
                                  source: ImageSource.gallery,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: const Color(0xFF64748B),
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'max_images_reached'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final double radius = 16.0;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );

    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
