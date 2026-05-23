import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/location/location_cubit.dart';
import 'package:stayindia_owner/core/location/location_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:latlong2/latlong.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/screens/map_picker_screen.dart';

class AddHostelSheet extends StatefulWidget {
  const AddHostelSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHostelSheet(),
    );
  }

  @override
  State<AddHostelSheet> createState() => _AddHostelSheetState();
}

class _AddHostelSheetState extends State<AddHostelSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _floorsController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = "men";

  double? _latitude;
  double? _longitude;

  late LocationCubit _locationCubit;

  @override
  void initState() {
    super.initState();
    _locationCubit = di.sl<LocationCubit>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _areaController.dispose();
    _floorsController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _locationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: BlocProvider.value(
        value: _locationCubit,
        child: MultiBlocListener(
          listeners: [
            BlocListener<HostelCubit, HostelState>(
              listener: (context, state) async {
                if (state is HostelOperationSuccess) {
                  final prefs = await SharedPreferences.getInstance();
                  final accepted = prefs.getBool('privacy_policy_accepted') ?? false;
                  if (!accepted) {
                    if (context.mounted) {
                      _showPrivacyPolicyDialog(context, state.message);
                    }
                  } else {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  }
                } else if (state is HostelError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
            BlocListener<LocationCubit, LocationState>(
              listener: (context, state) {
                if (state is LocationFetched) {
                  setState(() {
                    _latitude = state.latitude;
                    _longitude = state.longitude;
                    if (_addressController.text.isEmpty) {
                      _addressController.text = state.address;
                    }
                    if (_cityController.text.isEmpty) {
                      _cityController.text = state.city;
                    }
                    if (_stateController.text.isEmpty) {
                      _stateController.text = state.state;
                    }
                    if (_areaController.text.isEmpty) {
                      _areaController.text = state.area;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location fetched successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is LocationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ],
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      24.w,
                      24.w,
                      MediaQuery.of(context).viewInsets.bottom +
                          MediaQuery.of(context).padding.bottom +
                          24.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hostel Name *'),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Enter hostel name',
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('Address *'),
                        _buildTextField(
                          controller: _addressController,
                          hint: 'Enter full address',
                          maxLines: 3,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('City *'),
                        _buildTextField(
                          controller: _cityController,
                          hint: 'e.g. Mumbai',
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('State *'),
                        _buildTextField(
                          controller: _stateController,
                          hint: 'e.g. Maharashtra',
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('Area *'),
                        _buildTextField(
                          controller: _areaController,
                          hint: 'e.g. Madhapur',
                        ),
                        SizedBox(height: 20.h),
                        _buildLocationPicker(),
                        SizedBox(height: 20.h),
                        _buildLabel('Number of Floors *'),
                        _buildTextField(
                          controller: _floorsController,
                          hint: 'e.g. 3',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('Contact Phone *'),
                        _buildTextField(
                          controller: _contactController,
                          hint: 'e.g. +91 9876543210',
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel('Hostel Description'),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: 'Briefly describe your hostel...',
                          maxLines: 4,
                        ),
                        SizedBox(height: 24.h),
                        _buildLabel('Hostel Type *'),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildTypeCard("Men", "men", Icons.people_outlined),
                            SizedBox(width: 12.w),
                            _buildTypeCard(
                              "Women",
                              "women",
                              Icons.person_outline,
                            ),
                            SizedBox(width: 12.w),
                            _buildTypeCard(
                              "Co-ed",
                              "co-ed",
                              Icons.apartment_outlined,
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        _buildAddButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Hostel',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.roomCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.roomCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String label, String type, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.roomCardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
                size: 24.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Hostel Live Location',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (_latitude != null && _longitude != null) ...[
            Text(
              'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              bool isGettingLocation = state is LocationFetching;
              return SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isGettingLocation
                            ? null
                            : () => _locationCubit.fetchCurrentLocation(),
                        icon: isGettingLocation
                            ? SizedBox(
                                height: 16.w,
                                width: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          isGettingLocation
                              ? 'Fetching...'
                              : (_latitude == null ? 'Use GPS' : 'Update GPS'),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          foregroundColor: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final LatLng? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPickerScreen(
                                initialLocation: _latitude != null && _longitude != null
                                    ? LatLng(_latitude!, _longitude!)
                                    : null,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _latitude = result.latitude;
                              _longitude = result.longitude;
                            });
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Location selected from map'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Pin on Map'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          foregroundColor: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is HostelLoading
                ? null
                : () {
                    if (_nameController.text.isEmpty ||
                        _addressController.text.isEmpty ||
                        _cityController.text.isEmpty ||
                        _stateController.text.isEmpty ||
                        _areaController.text.isEmpty ||
                        _floorsController.text.isEmpty ||
                        _contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }

                    if (_latitude == null ||
                        _longitude == null ||
                        (_latitude == 0 && _longitude == 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location is required! Please use GPS or Pin on Map.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    context.read<HostelCubit>().createHostel(
                      name: _nameController.text,
                      address: _addressController.text,
                      city: _cityController.text,
                      stateName: _stateController.text,
                      area: _areaController.text,
                      floors: int.tryParse(_floorsController.text) ?? 1,
                      hostelType: _selectedType,
                      contactNumber: _contactController.text,
                      description: _descriptionController.text,
                      lat: _latitude,
                      lng: _longitude,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: state is HostelLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Add Hostel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Widget buildPolicySection({required String title, required String body}) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.r),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          child: Container(
            padding: EdgeInsets.all(24.w),
            constraints: BoxConstraints(maxHeight: 0.72.sh, maxWidth: 340.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: const Color(0xFF2563EB),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  "Please review and accept our Privacy Policy to complete your hostel setup.",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: EdgeInsets.all(14.w),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to Stay India Owner App.",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            buildPolicySection(
                              title: "1. Data Collection & Property Management",
                              body: "By adding your hostel, you authorize Stay India to collect and store property-specific information including the hostel name, contact number, coordinates, floors structure, rooms categories, and pricing details. This data is essential for managing your properties, configuring floor layouts, assigning beds, and managing tenants.",
                            ),
                            buildPolicySection(
                              title: "2. Tenant & Room Allocation Data",
                              body: "Any information added regarding tenants (e.g. names, sharing preferences, document attachments) is securely stored and used solely for property management operations by you. We do not sell or share your tenants' personal data with unauthorized third parties.",
                            ),
                            buildPolicySection(
                              title: "3. Location and Address Verification",
                              body: "We collect geographic coordinates (latitude and longitude) of your properties to enable correct location-based matches for potential tenants in the Stay India platform.",
                            ),
                            buildPolicySection(
                              title: "4. Security and Retention",
                              body: "Your data is hosted in highly secure cloud environments. We implement advanced encryption protocols to safeguard your property and financial transactions.",
                            ),
                            buildPolicySection(
                              title: "5. Term Acceptance",
                              body: "By clicking 'Accept & Continue', you confirm that you own or are legally authorized to manage this property and that you agree to Stay India's privacy policy and owner terms of service.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('privacy_policy_accepted', true);
                      
                      if (context.mounted) {
                        Navigator.pop(dialogContext); // Close dialog
                        Navigator.pop(context); // Close sheet
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Accept & Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
