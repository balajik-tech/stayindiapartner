import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../injection_container.dart';
import '../../../digilocker/domain/entities/digilocker_credentials.dart';
import '../../../digilocker/domain/entities/kyc_result.dart';
import '../../../digilocker/presentation/cubit/digilocker_cubit.dart';
import '../../../digilocker/presentation/cubit/digilocker_state.dart';
import '../../../digilocker/presentation/utils/digilocker_navigator.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  ProfileEntity? _currentProfile;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateControllers(ProfileState state) {
    if (state is ProfileLoaded) {
      _currentProfile = state.profile;
      _firstNameController.text = state.profile.firstName;
      _lastNameController.text = state.profile.lastName;
      _phoneController.text = state.profile.phone;
      _emailController.text = state.profile.email;
      // loadAddress();
      if(state.profile.dlKyc?.isAadharVerified == true){
        _addressController.text = state.profile.address;
      }else{
        loadAddress2();
      }

    }
  }

  // Future<void> loadAddress() async {
  //   final address = await getAddress();
  //   if (address != null) {
  //     _addressController.text = address;
  //   }
  //   final result = await getDigiLockerDetails();
  //   if (result?.name != null && result!.name!.trim().isNotEmpty) {
  //     final fullName = result.name!.trim();
  //
  //     final nameParts = fullName.split(RegExp(r'\s+'));
  //
  //     _lastNameController.text = nameParts.first;
  //
  //     if (nameParts.length > 1) {
  //       _firstNameController.text = nameParts.sublist(1).join(' ');
  //     } else {
  //       _firstNameController.text = '';
  //     }
  //   }
  // }
  //
  // /// Get address from saved DigiLocker details
  // static Future<String?> getAddress() async {
  //   final result = await getDigiLockerDetails();
  //   return result?.aadharAddress;
  // }


  /// Get DigiLocker details
  static Future<KycResult?> getDigiLockerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString('digi_locker_details');
    if (jsonString == null) return null;

    final Map<String, dynamic> json =
    jsonDecode(jsonString) as Map<String, dynamic>;

    return KycResult.fromJson(json);
  }

  Future<void> loadAddress2() async {
    final digilockerCubit = sl<DigiLockerCubit>();
    await digilockerCubit.loadKycResultFromStorage();

    if (digilockerCubit.state is DigiLockerLoaded) {
      final result = (digilockerCubit.state as DigiLockerLoaded).result;

      debugPrint("edit profile address:::${result.aadharAddress}");

      if (result.aadharAddress != null) {
        setState(() {
          _addressController.text = result.aadharAddress!;
        });
      }

      if (result.name != null && result.name!.trim().isNotEmpty) {
        final fullName = result.name!.trim();
        final nameParts = fullName.split(RegExp(r'\s+'));

        setState(() {
          _lastNameController.text = nameParts.first;
        });

        if (nameParts.length > 1) {
          setState(() {
            _firstNameController.text = nameParts.sublist(1).join(' ');
          });
        } else {
          setState(() {
            _firstNameController.text = '';
          });
        }
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
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
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        context.read<ProfileCubit>().uploadProfileImage(File(croppedFile.path));
      }
    }
  }

  void _saveProfile() async {
    HapticFeedback.mediumImpact();

    // Get current profile from ProfileCubit
    final profileState = context.read<ProfileCubit>().state;
    final currentProfile = profileState is ProfileLoaded ? profileState.profile : _currentProfile;

    // Get DigiLocker KYC details
    final kycResult = await getDigiLockerDetails();

    // Build the data map for API call
    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      if (currentProfile?.dob != null) 'dob': currentProfile!.dob,
      if (currentProfile?.gender != null) 'gender': currentProfile!.gender,
    };

    // Add KYC data if available
    if (kycResult != null) {
      data['dlKyc'] = {
        'is_aadhar_verified': _addressController.text.trim().isNotEmpty,
        'gender': kycResult.gender,
        'masked_aadhaar': kycResult.maskedAadhaar ??
            KycResult.maskAadhaar(kycResult.aadharNumber),
        'dob': kycResult.dob,
        'date_time': kycResult.dateTime ??
            kycResult.capturedAt.toIso8601String(),
        'name': kycResult.name,
        'fathername': kycResult.fatherName,
        'aadhar_address': kycResult.aadharAddress,
        'aadhar_filename': kycResult.aadharFilename,
        'aadhar_img_filename': kycResult.aadharImgFilename,
        'adharimg': kycResult.adharImg,
      };
    } else if (currentProfile?.dlKyc != null) {
      // Use existing dlKyc from profile
      final dlKyc = currentProfile!.dlKyc!;
      data['dlKyc'] = {
        'is_aadhar_verified': dlKyc.isAadharVerified,
        'gender': dlKyc.gender,
        'masked_aadhaar': dlKyc.maskedAadhaar,
        'dob': dlKyc.dob,
        'date_time': dlKyc.dateTime,
        'name': dlKyc.name,
        'fathername': dlKyc.fatherName,
        'aadhar_address': dlKyc.aadharAddress,
        'aadhar_filename': dlKyc.aadharFilename,
        'aadhar_img_filename': dlKyc.aadharImgFilename,
        'adharimg': dlKyc.adharImg,
      };
    }

    // Remove null values
    data.removeWhere((key, value) => value == null);

    try {
      // Call AuthRepository updateProfile API directly
      final authRepository = sl<AuthRepository>();
      await authRepository.updateProfile(data);

      // Refresh profile and show success message
      context.read<ProfileCubit>().loadProfile();
      context.read<AuthCubit>().refreshProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('update_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) _populateControllers(state);
        if (state is ProfileUpdateSuccess) {
          setState(() {
            _currentProfile = state.profile;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('update_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.read<AuthCubit>().refreshProfile();
          Navigator.pop(context);
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(context),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading && _firstNameController.text.isEmpty) {
              return const DetailsSkeleton();
            }

            if (state is ProfileLoaded) {
              _currentProfile = state.profile;
            }

            final profile = _currentProfile;

            return Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          // padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
                          children: [
                            // _buildAnimatedHeader(profile),
                            buildProfileHeader(profile),

                            SizedBox(height: 24.h),

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(
                                    'personal_info'.tr().toUpperCase(),
                                  ),
                                ],
                              ) ,
                            ),


                            _buildEditableBlock(_buildPersonalInfoRows()),
                            if (_currentProfile?.dlKyc?.isAadharVerified ==
                                true)
                              _buildLockedHint(
                                "Locked fields come from Aadhaar. To change these, re-verify with a new document.",
                              ),
                            SizedBox(height: 24.h),

                            if (_currentProfile?.dlKyc?.isAadharVerified == true)...[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionLabel('CONTACT DETAILS'),
                                  ],
                                ) ,
                              ),
                              _buildEditableBlock([
                                _EditableRow(
                                  label: 'phone_number'.tr(),
                                  value: _phoneController.text.trim().isEmpty
                                      ? ""
                                      : '+91 ${_phoneController.text}',
                                  icon: Icons.phone_rounded,
                                  isLocked: false,
                                  onTap: () => _showEditSheet(
                                    'phone_number'.tr(),
                                    _phoneController,
                                    inputType: TextInputType.phone,
                                  ),
                                ),
                                _EditableRow(
                                  label: 'email_address'.tr(),
                                  value: _emailController.text,
                                  icon: Icons.email_rounded,
                                  isLocked: false,
                                  onTap: () => _showEditSheet(
                                    'email_address'.tr(),
                                    _emailController,
                                    inputType: TextInputType.emailAddress,
                                  ),
                                ),
                              ]),
                            ],
                            SizedBox(height: 24.h),

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionLabel('address'.tr().toUpperCase()),

                                      ],
                                    ) ,
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: _currentProfile?.dlKyc?.isAadharVerified ==
                                        true ? 0:16),
                                    child:  _buildAddressSection(),
                                  ),


                                  if (_currentProfile?.dlKyc?.isAadharVerified ==
                                      true)
                                    _buildLockedHint(
                                      "Address is locked. To change it, re-verify with an updated Aadhaar.",
                                    ),
                                ],
                              ) ,
                            ),
                            SizedBox(height: 48.h),
                            // _buildDeleteAccountButton(context), //commented delete account button
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_currentProfile?.dlKyc?.isAadharVerified ==
                      true)...[
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildStickyCTA(state is ProfileUpdating),
                    )
                  ]
                  ,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEkycCard() {
    final bool isVerified = _addressController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 216, 215,1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Status Chip
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 7.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color:  const Color(0xFF9C3A32),
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "eKYC Pending",
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8F3B35),
                        letterSpacing: 0
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            /// Description
            Text(
              "Your identity isn't verified yet. To add bank accounts and receive funds from tenants you need to complete eKYC.",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                height: 1.5,
                color: const Color(0xFF914542),
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            /// Button
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton.icon(
                onPressed
                    : () async {
                  final credentials = DigiLockerCredentials(
                    companyName: 'punithOiXa',
                    secretToken: 'K1tPIbkUX6eZE28sgP5qCIrwmTJnW5F1',
                    redirectUrl: 'https://digilocker.meon.co.in/digilocker/thank-you-page',
                  );

                  await DigiLockerNavigator.verifyWithDigiLocker(
                    context: context,
                    credentials: credentials,
                    documents: 'aadhaar',
                    onResult: (result) async {
                      if (result != null) {
                        print(result);

                        // Save KYC result to API using DigiLockerCubit with profile data
                        final digilockerCubit = sl<DigiLockerCubit>();
                        await digilockerCubit.saveKycResult(
                          result,
                          firstName: _firstNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          address: _addressController.text.trim(),
                        );

                        // Refresh profile after saving
                        context.read<ProfileCubit>().loadProfile();
                        context.read<AuthCubit>().refreshProfile();
                      }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(192, 71, 66, 1),
                  disabledBackgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                icon: Icon(
                  isVerified
                      ? Icons.check_circle_outline
                      : Icons.security,
                  color: Colors.white,
                  size: 22.sp,
                ),
                label: Text(
                  "Verify with eKYC",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/Aadhaar.svg',
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "Powered by Aadhaar eKYC via DigiLocker",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF914542),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget buildVerifiedEkycCard() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }

        final dlKyc = state.profile.dlKyc;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF3D9),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: const Color(0xFF2E7D32),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Aadhaar verified via DigiLocker",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "Verified on ${DateFormatter.formatISO(dlKyc?.dateTime) ?? '-'} . Aadhaar ${dlKyc?.maskedAadhaar ?? '-'}",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Color(0xFF989692),
                  fontWeight: FontWeight.w700,
                ),
              )
            )

            ,
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkText,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'account_settings'.tr(),
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(dynamic profile) {
    final name = '${_firstNameController.text} ${_lastNameController.text}';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CustomAvatar(
                        imageUrl: ApiConstants.getImageUrl(profile?.avatar),
                        name: name,
                        size: 100.0,
                        isCircle: true,
                        fontSize: 38.sp,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                if (_phoneController.text.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '+91 ${_phoneController.text}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyText,
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

  Widget buildProfileHeader(dynamic profile) {
    final String name =
    '${_firstNameController.text} ${_lastNameController.text}'.trim();
    final bool isVerified =
        _currentProfile?.dlKyc?.isAadharVerified == true;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.r),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Avatar with camera button + verified badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isVerified
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          width: 0,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CustomAvatar(
                          imageUrl: ApiConstants.getImageUrl(profile?.avatar),

                          name: name,
                          size: 70,
                          isCircle: true,
                          fontSize: 26.sp,
                        ),
                      ),
                    ),

                    if (isVerified)
                      Positioned(
                        bottom: 4,
                        right: 2,
                        child: Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),

                    // Positioned(
                    //   right: -2,
                    //   bottom: -2,
                    //   child: GestureDetector(
                    //     onTap: _pickAndUploadImage,
                    //     child: Container(
                    //       padding: EdgeInsets.all(6.r),
                    //       decoration: BoxDecoration(
                    //         color: AppColors.primaryBlue,
                    //         shape: BoxShape.circle,
                    //         border: Border.all(
                    //           color: Colors.white,
                    //           width: 2,
                    //         ),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.15),
                    //             blurRadius: 6,
                    //             offset: const Offset(0, 2),
                    //           ),
                    //         ],
                    //       ),
                    //       child: Icon(
                    //         Icons.camera_alt_rounded,
                    //         color: Colors.white,
                    //         size: 16.sp,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(width: 18.w),

                /// Name & Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name.isEmpty ? "User Name" : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      if (_phoneController.text.trim().isNotEmpty)
                        Text(
                          '+91 ${_phoneController.text}',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider(height: 1, color: Colors.grey.shade100),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
            child: isVerified
                ? Container(margin: EdgeInsets.symmetric(horizontal: 8.w),
                child: buildVerifiedEkycCard())
                : _buildEkycCard(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonalInfoRows() {
    final bool isVerified =
        _currentProfile?.dlKyc?.isAadharVerified == true;
    final String fullName = _currentProfile?.dlKyc?.name??'${_firstNameController.text} ${_lastNameController.text}'.trim();
    final String? dob = _currentProfile?.dlKyc?.dob ;
    final String? gender = _currentProfile?.dlKyc?.gender;

    if (isVerified) {
      return [
        _EditableRow(
          label: "Full name",
          value: fullName,
          icon: Icons.person_rounded,
          isLocked: true,
        ),
        _EditableRow(
          label: "Date of birth",
          value: (dob == null || dob.trim().isEmpty) ? '' : dob,
          icon: Icons.calendar_today_rounded,
          isLocked: true,
        ),
        _EditableRow(
          label: "Gender",
          value: (gender == null || gender.trim().isEmpty) ? '' : gender,
          icon: Icons.wc_rounded,
          isLocked: true,
          imageAsset: 'assets/images/gender.png',
        ),
      ];
    }

    return [
      _EditableRow(
        label: "Full name",
        value: fullName,
        icon: Icons.person_rounded,
        onTap: () => _showEditSheet(
          'first_name'.tr(),
          _firstNameController,
        ),
      ),
      _EditableRow(
        label: "Date of birth",
        value: '',
        placeholder: "Add after verification",
        icon: Icons.calendar_today_rounded,
        isLocked: true,
        showTrailingIcon: false,
      ),
      _EditableRow(
        label: "Gender",
        value: '',
        placeholder: "Add after verification",
        icon: Icons.wc_rounded,
        isLocked: true,
        showTrailingIcon: false,
        imageAsset: 'assets/images/gender.png',
      ),
    ];
  }

  Widget _buildAddressSection() {
    final bool isVerified =
        _currentProfile?.dlKyc?.isAadharVerified == true;

    if (isVerified) {
      return _buildEditableBlock([
        _EditableRow(
          label: 'current_address'.tr(),
          value: _addressController.text,
          icon: Icons.location_on_rounded,
          isLocked: true,
        ),
      ]);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: Colors.grey.shade400,
            size: 22.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            "Address will auto-fill from Aadhaar once verified",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedHint(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 24.w, right: 24.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Color(0xFF989692),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
      child: Text(
        label,
        style:  GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Color(0xFF898782),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEditableBlock(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade300, // Change shade as needed
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(height: 1, color: Colors.grey.shade300),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickyCTA(bool isUpdating) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
          child: ElevatedButton(
            onPressed: isUpdating ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blackColor,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: isUpdating
                ? SizedBox(
              height: 24.h,
              width: 24.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : Text(
              'save_changes'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _confirmDelete,
        child: Text(
          'delete_my_account'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF04438).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'delete_account'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('delete_account_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'delete_permanently'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ProfileCubit>().deleteAccount().then((_) {
        if (mounted) {
          context.read<AuthCubit>().logout();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  void _showEditSheet(
      String title,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        bool isLongText = false,
      }) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'update_field'.tr(namedArgs: {'field': title}),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              keyboardType: inputType,
              maxLines: isLongText ? 4 : 1,
              autofocus: true,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                'confirm'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableRow extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLocked;
  final VoidCallback? onTap;
  final String? placeholder;
  final bool showTrailingIcon;
  final String? imageAsset;

  const _EditableRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLocked = false,
    this.onTap,
    this.placeholder,
    this.showTrailingIcon = true,
    this.imageAsset,
  });

  @override
  State<_EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<_EditableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLocked ? null : (_) => _controller.forward(),
      onTapUp: widget.isLocked ? null : (_) => _controller.reverse(),
      onTapCancel: widget.isLocked ? null : () => _controller.reverse(),
      onTap: widget.isLocked ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              widget.imageAsset != null
                  ? Image.asset(
                widget.imageAsset!,
                width: 24,
                height: 24,
                color: Colors.grey.shade400,
              ) :
              Icon(
                widget.icon,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF989692),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      widget.value.isNotEmpty
                          ? TextUtils.toTitleCase(widget.value)
                          : (widget.placeholder ?? 'not_set'.tr()),
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: widget.value.isNotEmpty
                            ? AppColors.darkText
                            : AppColors.greyText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showTrailingIcon)
                widget.isLocked
                    ? Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF989692),
                  size: 16.sp,
                )
                    : Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                      Color(0xFF989692).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF989692),
                    size: 14.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
