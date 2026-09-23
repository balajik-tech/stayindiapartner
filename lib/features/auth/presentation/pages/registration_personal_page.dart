import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/complete_profile_usecase.dart';
import '../widgets/auth_widgets.dart';

class RegistrationPersonalPage extends StatefulWidget {
  const RegistrationPersonalPage({super.key});

  @override
  State<RegistrationPersonalPage> createState() =>
      _RegistrationPersonalPageState();
}


class _RegistrationPersonalPageState extends State<RegistrationPersonalPage>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _streetController = TextEditingController();

  bool _isFetchingLocation = false;
  File? _selectedImage;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  // Design accent color from latest screenshot (Continue button + field borders).
  // If AppColors already exposes an orange/accent color, swap this out for that instead.
  static const Color _accentOrange = Color(0xFFE8763C);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _streetController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      HapticFeedback.mediumImpact();

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: AppColors.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);

        if (file.existsSync()) {
          setState(() {
            _selectedImage = file;
          });
        }
      }
    }
  }

  void _onContinue(BuildContext context) async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();

    final stateStr = _stateController.text.trim();
    final district = _districtController.text.trim();
    final pincode = _pincodeController.text.trim();
    final street = _streetController.text.trim();

    // final address = "$street, $district, $stateStr - $pincode";

    final addressParts = [
      street,
      district,
      stateStr,
    ].where((value) => value.toString().trim().isNotEmpty).map(
          (value) => value.toString().trim(),
    );

    final address = addressParts.join(', ');

    final finalAddress = [
      address,
      pincode,
    ].where((value) => value.toString().trim().isNotEmpty).map(
          (value) => value.toString().trim(),
    ).join(' - ');

    if (fullName.isEmpty
    // email.isEmpty ||
    // stateStr.isEmpty ||
    // district.isEmpty ||
    // pincode.isEmpty ||
    // street.isEmpty
    ) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    String phone = '';

    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      phone = state.owner.phone;
    }

    if (phone.isEmpty) {
      phone = await sl<TokenStorage>().getPhone() ?? '';
    }

    final int spaceIndex = fullName.indexOf(' ');
    final String parsedFirstName = spaceIndex == -1 ? fullName : fullName.substring(0, spaceIndex);
    final String parsedLastName = spaceIndex == -1 ? "" : fullName.substring(spaceIndex + 1);

    authCubit.completeProfile(
      ProfileParams(
        firstName: fullName.toString().trim(),
        lastName: "",
        email: email,
        phone: phone,
        address: finalAddress,
        avatarPath: _selectedImage?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.outfit()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const AuthStepProgress(
                        //   currentStep: 1,
                        //   totalSteps: 3,
                        //   stepLabels: ['Personal', 'Property', 'Setup'],
                        // ),
                        SizedBox(height: 24.h),
                        // _buildHeader(),
                        // Title now lives in the AppBar per latest design (see _buildAppBar).
                        // SizedBox(height: 32.h),
                        _buildImagePicker(),
                        SizedBox(height: 40.h),
                        _buildFormSection(),
                        SizedBox(height: 32.h),
                        // _buildLoginRedirect(context),
                        // SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      centerTitle: true,
      title: Transform.translate(
        offset: Offset(5.w, 0),
        child: Text(
          'Lets get to know you',
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      leading: BouncingWrapper(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.read<AuthCubit>().logout();
          }
        },
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 18,
        ),
        // Previous circular white-card back button (kept for reference):
        // child: Container(
        //   margin: EdgeInsets.all(10.w),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withValues(alpha: 0.05),
        //         blurRadius: 8,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: const Icon(
        //     Icons.arrow_back_ios_new_rounded,
        //     color: Colors.black,
        //     size: 16,
        //   ),
        // ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lets get to know you',
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'This helps us personalize your dashboard and verify your identity.',
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.greyText.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          BouncingWrapper(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   gradient: LinearGradient(
                  //     colors: [
                  //       AppColors.primaryBlue.withValues(alpha: 0.2),
                  //       AppColors.primaryBlue.withValues(alpha: 0.05),
                  //     ],
                  //   ),
                  // ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      //     blurRadius: 20,
                      //     offset: const Offset(0, 10),
                      //   ),
                      // ],
                    ),
                    child: CircleAvatar(
                      radius: 54.r,
                      backgroundColor: Color(0xFFECEBFF),
                      backgroundImage: _selectedImage != null
                          ? ResizeImage(
                        FileImage(_selectedImage!),
                        width: 220,
                        height: 220,
                      )
                          : null,
                      child: _selectedImage == null
                          ? Image.asset(
                        'assets/images/profileuser.png',
                        width: 54.sp,
                        height: 54.sp,
                        fit: BoxFit.contain,
                      )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    // padding: EdgeInsets.all(8.w),
                    // decoration: BoxDecoration(
                    //   color: AppColors.primaryBlue,
                    //   shape: BoxShape.circle,
                    //   border: Border.all(color: Colors.white, width: 3),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    //       blurRadius: 8,
                    //       offset: const Offset(0, 4),
                    //     ),
                    //   ],
                    // ),
                    child: Image.asset(
                      'assets/images/cameraicon.png',
                      width: 24.sp,
                      height: 24.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _selectedImage == null ? 'Add your profile photo' : 'Change photo',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        AuthTextField(
          label: 'Full name',
          controller: _fullNameController,
          hintText: 'e.g. Rahul Sharma',
          // Latest design uses an orange outline on the fields.
          borderColor: _accentOrange,
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'Email ID (optional)',
          controller: _emailController,
          hintText: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          borderColor: _accentOrange,
        ),
        SizedBox(height: 24.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       'Residential Address',
        //       style: GoogleFonts.outfit(
        //         fontSize: 14.sp,
        //         fontWeight: FontWeight.w700,
        //         color: AppColors.primaryBlue,
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: _isFetchingLocation ? null : _fetchLocation,
        //       child: Row(
        //         children: [
        //           if (_isFetchingLocation)
        //             SizedBox(
        //               width: 12.sp,
        //               height: 12.sp,
        //               child: const CircularProgressIndicator(strokeWidth: 2),
        //             )
        //           else
        //             Icon(
        //               Icons.my_location_rounded,
        //               size: 14.sp,
        //               color: AppColors.primaryBlue,
        //             ),
        //           SizedBox(width: 4.w),
        //           Text(
        //             _isFetchingLocation ? 'Fetching...' : 'Fetch Location',
        //             style: GoogleFonts.outfit(
        //               fontSize: 12.sp,
        //               fontWeight: FontWeight.w600,
        //               color: AppColors.primaryBlue,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 12.h),
        // AuthTextField(
        //   label: 'Street Address',
        //   controller: _streetController,
        //   hintText: 'House No, Building, Street Area',
        //   maxLines: 2,
        // ),
        // SizedBox(height: 16.h),
        // Row(
        //   children: [
        //     Expanded(
        //       child: AuthTextField(
        //         label: 'District/City',
        //         controller: _districtController,
        //         hintText: 'e.g. Bangalore',
        //       ),
        //     ),
        //     SizedBox(width: 16.w),
        //     Expanded(
        //       child: AuthTextField(
        //         label: 'State',
        //         controller: _stateController,
        //         hintText: 'e.g. Karnataka',
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 16.h),
        // AuthTextField(
        //   label: 'Pincode',
        //   controller: _pincodeController,
        //   hintText: 'e.g. 560001',
        //   keyboardType: TextInputType.number,
        // ),
      ],
    );
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        final addressParts = [
          place.street,
          place.thoroughfare,
          place.subThoroughfare,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");

        setState(() {
          // _streetController.text = "${place.name ?? ''} ${place.subLocality ?? ''}".trim();
          _streetController.text = addressParts.trim();
          _districtController.text =
              place.locality ?? place.subAdministrativeArea ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
        });

        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (errMsg.startsWith('Exception: ')) {
          errMsg = errMsg.substring(11);
        }

        SnackBarAction? action;
        if (e.toString().contains('Location services are disabled')) {
          action = SnackBarAction(
            label: 'Enable',
            textColor: Colors.white,
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          );
        } else if (e.toString().contains('permissions are denied') ||
            e.toString().contains('permanently denied')) {
          action = SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch location: $errMsg'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryBlue,
            action: action,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Widget _buildStickyButton() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 20.h,
        bottom: bottomPadding > 0 ? bottomPadding + 8.h : 20.h,
      ),
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
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return AuthPrimaryButton(
            label: 'Continue',
            isLoading: state is AuthLoading,
            onPressed: () => _onContinue(context),
            // Latest design uses a solid orange CTA instead of the primary blue.
            backgroundColor: _accentOrange,
          );
        },
      ),
    );
  }

  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.greyText),
        ),
        BouncingWrapper(
          onTap: () => context.read<AuthCubit>().logout(),
          child: Text(
            'Login',
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
