import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/location/location_cubit.dart';
import 'package:stayindia_owner/core/location/location_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../widgets/auth_widgets.dart';
import 'registration_hostel_images_page.dart';


class RegistrationHostelDetailsPage extends StatefulWidget {
  const RegistrationHostelDetailsPage({super.key});

  @override
  State<RegistrationHostelDetailsPage> createState() => _RegistrationHostelDetailsPageState();
}

class _RegistrationHostelDetailsPageState extends State<RegistrationHostelDetailsPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _floorsController = TextEditingController();

  String _selectedHostelType = 'men';
  String _selectedPropertyTag = 'PG';
  String _district = '';
  String _pincode = '';
  String _village = '';
  late final LocationCubit _locationCubit;
  
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _locationCubit = di.sl<LocationCubit>();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _floorsController.dispose();
    _animController.dispose();
    
    
    _locationCubit.close();
    super.dispose();
  }

  void _onLocationFetched(LocationFetched state) {
    HapticFeedback.mediumImpact();
    setState(() {
      _addressController.text = state.address;
      _areaController.text = state.area;
      _cityController.text = state.city;
      _stateController.text = state.state;
      _district = state.district;
      _pincode = state.pincode;
      _village = state.city; 
    });
  }

  void _onContinue() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _floorsController.text.isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final locationState = _locationCubit.state;
    double? lat;
    double? lng;
    if (locationState is LocationFetched) {
      lat = locationState.latitude;
      lng = locationState.longitude;
    }

    context.read<HostelCubit>().createHostel(
          name: _nameController.text,
          address: _addressController.text,
          city: _cityController.text,
          stateName: _stateController.text,
          area: _areaController.text,
          district: _district,
          pincode: _pincode,
          village: _village.isNotEmpty ? _village : _cityController.text,
          floors: int.tryParse(_floorsController.text) ?? 1,
          hostelType: _selectedHostelType,
          propertyTag: _selectedPropertyTag,
          lat: lat,
          lng: lng,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locationCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: MultiBlocListener(
          listeners: [
            BlocListener<HostelCubit, HostelState>(
              listener: (context, state) {
                if (state is HostelOperationSuccess &&
                    state.message.contains('Hostel created successfully')) {
                  final String? hostelId = state.hostelId;
                  if (hostelId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationHostelImagesPage(hostelId: hostelId),
                      ),
                    );
                  }
                } else if (state is HostelError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: GoogleFonts.outfit()),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                }
              },
            ),
            BlocListener<LocationCubit, LocationState>(
              listener: (context, state) {
                if (state is LocationFetched) {
                  _onLocationFetched(state);
                } else if (state is LocationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: GoogleFonts.outfit()),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                }
              },
            ),
          ],
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthStepProgress(
                            currentStep: 2,
                            totalSteps: 3,
                            stepLabels: ['Personal', 'Property', 'Setup'],
                          ),
                          SizedBox(height: 48.h),
                          _buildHeader(context),
                          SizedBox(height: 48.h),
                          _buildLocationDetectionCard(),
                          SizedBox(height: 32.h),
                          _buildFormSection(),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildStickyButton(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      centerTitle: false,
      leadingWidth: 100.w,
      leading: BouncingWrapper(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.only(left: 16.w, top: 10.h, bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 14),
              SizedBox(width: 6.w),
              Text(
                'Back',
                style: GoogleFonts.outfit(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Details',
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tell us about your hostel or PG to help tenants find you.',
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.greyText.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStickyButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          return AuthPrimaryButton(
            label: 'Save & Continue',
            isLoading: state is HostelLoading,
            onPressed: _onContinue,
          );
        },
      ),
    );
  }

  Widget _buildLocationDetectionCard() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final isFetching = state is LocationFetching;
        final isFetched = state is LocationFetched;

        return BouncingWrapper(
          onTap: isFetching ? null : () => _locationCubit.fetchCurrentLocation(),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isFetched ? Colors.green.shade50 : AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isFetched ? Colors.green.shade200 : AppColors.primaryBlue.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isFetched ? Colors.green.shade100 : AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: isFetching
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
                      : Icon(
                          isFetched ? Icons.check_circle_rounded : Icons.my_location_rounded,
                          color: isFetched ? Colors.green.shade700 : AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFetched ? 'Location Detected' : 'Detect Location',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: isFetched ? Colors.green.shade900 : AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isFetched ? 'Tap to re-detect' : 'Auto-fill address using GPS',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isFetched ? Colors.green.shade700 : AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        AuthTextField(
          label: 'PG/Hostel Name *',
          controller: _nameController,
          hintText: 'e.g. Shanti PG for Men',
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'Complete Address *',
          controller: _addressController,
          hintText: 'Street, House No, Landmark',
          maxLines: 2,
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Area *',
                controller: _areaController,
                hintText: 'e.g. Ameerpet',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AuthTextField(
                label: 'City *',
                controller: _cityController,
                hintText: 'e.g. Hyderabad',
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'State *',
                controller: _stateController,
                hintText: 'e.g. Telangana',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AuthTextField(
                label: 'Total Floors *',
                controller: _floorsController,
                hintText: 'e.g. 3',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: AuthDropdown<String>(
                label: 'Hostel Type',
                value: _selectedHostelType,
                items: const [
                  DropdownMenuItem(value: 'men', child: Text('Boys Only')),
                  DropdownMenuItem(value: 'women', child: Text('Girls Only')),
                  DropdownMenuItem(value: 'co-ed', child: Text('Co-ed')),
                ],
                onChanged: (val) => setState(() => _selectedHostelType = val!),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AuthDropdown<String>(
                label: 'Property Tag',
                value: _selectedPropertyTag,
                items: const [
                  DropdownMenuItem(value: 'PG', child: Text('PG')),
                  DropdownMenuItem(value: 'BOYS', child: Text('Boys Hostel')),
                  DropdownMenuItem(value: 'GIRLS', child: Text('Girls Hostel')),
                  DropdownMenuItem(value: 'CO_LIVING', child: Text('Co-Living')),
                ],
                onChanged: (val) => setState(() => _selectedPropertyTag = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
