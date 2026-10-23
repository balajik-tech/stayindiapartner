import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/app_toast.dart';
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

  File? _selectedImage;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  // Design accent color from latest screenshot (Continue button + field borders).
  // If AppColors already exposes an orange/accent color, swap this out for that instead.
  static const Color _accentOrange = Color(0xFFE8763C);

  static const int _maxNameLength = 50;

  // Letters in any script (plus their combining marks, needed for Indic
  // names), spaces, and the punctuation names use: . ' -
  // Emojis, digits and other symbols are rejected.
  static final RegExp _nameChar = RegExp(r"[\p{L}\p{M} .'-]", unicode: true);
  static final RegExp _hasLetter = RegExp(r'\p{L}', unicode: true);

  late final List<TextInputFormatter> _nameFormatters = [
    FilteringTextInputFormatter.allow(_nameChar),
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.characters.length > _maxNameLength) {
        AppToast.show(
          context,
          'Name can have at most $_maxNameLength characters.',
        );
      }
      return _nameLengthLimit.formatEditUpdate(oldValue, newValue);
    }),
  ];
  final _nameLengthLimit = LengthLimitingTextInputFormatter(_maxNameLength);

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

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.primaryBlue,
                ),
                title: Text('Take a photo', style: GoogleFonts.outfit()),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryBlue,
                ),
                title: Text('Choose from gallery', style: GoogleFonts.outfit()),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  /// Shown when the user has denied camera/photo access. The OS only shows
  /// its own permission prompt once, so after a denial we point to Settings.
  Future<void> _showPermissionDeniedDialog(ImageSource source) {
    final what = source == ImageSource.camera ? 'camera' : 'photos';
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Allow $what access',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Stay India Partner needs $what access to set your profile photo. '
          'Please allow it in Settings.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Not now', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Geolocator.openAppSettings();
            },
            child: Text('Open Settings', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile;
    try {
      // Triggers the system permission prompt the first time.
      pickedFile = await picker.pickImage(source: source);
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code.contains('access_denied')) {
        await _showPermissionDeniedDialog(source);
      } else {
        AppToast.show(context, 'Could not open the ${source.name}.');
      }
      return;
    }

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

    if (fullName.isEmpty || email.isEmpty
    // stateStr.isEmpty ||
    // district.isEmpty ||
    // pincode.isEmpty ||
    // street.isEmpty
    ) {
      HapticFeedback.vibrate();
      AppToast.show(context, 'Please fill all required fields');
      return;
    }

    if (!_hasLetter.hasMatch(fullName)) {
      HapticFeedback.vibrate();
      AppToast.show(context, 'Please enter a valid name.');
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
          AppToast.show(context, state.message);
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

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          BouncingWrapper(
            onTap: _showImageSourcePicker,
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
                    // Vector icon instead of the 24x24 cameraicon.png, which
                    // looked blurry when scaled up on high-density screens.
                    width: 26.sp,
                    height: 26.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 14.sp,
                      color: Colors.white,
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
          keyboardType: TextInputType.name,
          inputFormatters: _nameFormatters,
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'Email ID',
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

}
