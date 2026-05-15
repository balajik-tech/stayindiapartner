import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/complete_profile_usecase.dart';
import '../widgets/auth_widgets.dart';
import 'registration_hostel_details_page.dart';


class RegistrationPersonalPage extends StatefulWidget {
  const RegistrationPersonalPage({super.key});

  @override
  State<RegistrationPersonalPage> createState() => _RegistrationPersonalPageState();
}

class _RegistrationPersonalPageState extends State<RegistrationPersonalPage> with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  File? _selectedImage;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      HapticFeedback.mediumImpact();
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result.files.single.path!,
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
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    }
  }

  void _onContinue(BuildContext context) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || address.isEmpty) {
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

    authCubit.completeProfile(ProfileParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      avatarPath: _selectedImage?.path,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileCompleted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegistrationHostelDetailsPage(),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.outfit()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthStepProgress(
                          currentStep: 1,
                          totalSteps: 3,
                          stepLabels: ['Personal', 'Property', 'Setup'],
                        ),
                        SizedBox(height: 32.h),
                        _buildHeader(),
                        SizedBox(height: 32.h),
                        _buildImagePicker(),
                        SizedBox(height: 40.h),
                        _buildFormSection(),
                        SizedBox(height: 32.h),
                        _buildLoginRedirect(context),
                        SizedBox(height: 100.h), 
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
      centerTitle: false,
      leading: BouncingWrapper(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.read<AuthCubit>().logout();
          }
        },
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 16),
        ),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.2),
                        AppColors.primaryBlue.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54.r,
                      backgroundColor: Colors.white,
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? Icon(Icons.person_rounded, size: 54.sp, color: Colors.grey.shade200)
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 18.sp, color: Colors.white),
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
              fontWeight: FontWeight.w600,
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
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'First Name',
                controller: _firstNameController,
                hintText: 'e.g. Rahul',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AuthTextField(
                label: 'Last Name',
                controller: _lastNameController,
                hintText: 'e.g. Sharma',
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'Email Address',
          controller: _emailController,
          hintText: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'Full Residential Address',
          controller: _addressController,
          hintText: 'Street, House No, Landmark',
          maxLines: 3,
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
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return AuthPrimaryButton(
            label: 'Continue',
            isLoading: state is AuthLoading,
            onPressed: () => _onContinue(context),
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
