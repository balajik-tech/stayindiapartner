import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart' as cropper;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_wrapper.dart';
import '../cubit/owner_community_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateCommunityPage extends StatefulWidget {
  final String level;
  final String? stateId;
  final String? districtId;
  final String? wardId;
  final String? localityId;
  final String locationSummary;

  const CreateCommunityPage({
    super.key,
    required this.level,
    this.stateId,
    this.districtId,
    this.wardId,
    this.localityId,
    required this.locationSummary,
  });

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _rulesController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _profileImage;
  File? _coverImage;
  File? _govtCertificate;
  File? _associationCertificate;
  String? _selectedRole;
  final _picker = ImagePicker();

  final List<String> _executiveRoles = [
    'President',
    'Vice President',
    'General Secretary',
    'Joint Secretary',
    'Chief Financial Officer / Treasurer',
    'Chief Legal Advisor',
    'Technical & Compliance Head',
    'Public Relations Officer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _rulesController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final croppedFile = await cropper.ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: isCover ? const cropper.CropAspectRatio(ratioX: 16, ratioY: 9) : const cropper.CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          cropper.AndroidUiSettings(
            toolbarTitle: isCover ? 'crop_cover_photo'.tr() : 'crop_profile_photo'.tr(),
            toolbarColor: AppColors.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isCover ? cropper.CropAspectRatioPreset.ratio16x9 : cropper.CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: isCover ? cropper.CropStyle.rectangle : cropper.CropStyle.circle,
          ),
          cropper.IOSUiSettings(
            title: isCover ? 'crop_cover_photo'.tr() : 'crop_profile_photo'.tr(),
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: isCover ? cropper.CropStyle.rectangle : cropper.CropStyle.circle,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          if (isCover) {
            _coverImage = File(croppedFile.path);
          } else {
            _profileImage = File(croppedFile.path);
          }
        });
      }
    }
  }

  Future<void> _pickCertificate(bool isGovt) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final croppedFile = await cropper.ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const cropper.CropAspectRatio(ratioX: 1, ratioY: 1.41), 
        uiSettings: [
          cropper.AndroidUiSettings(
            toolbarTitle: 'crop_certificate'.tr(),
            toolbarColor: AppColors.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: cropper.CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          cropper.IOSUiSettings(
            title: 'crop_certificate'.tr(),
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          if (isGovt) {
            _govtCertificate = File(croppedFile.path);
          } else {
            _associationCertificate = File(croppedFile.path);
          }
        });
      }
    }
  }

  Future<void> _cropExistingCertificate(bool isGovt) async {
    final file = isGovt ? _govtCertificate : _associationCertificate;
    if (file == null) return;

    final croppedFile = await cropper.ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const cropper.CropAspectRatio(ratioX: 1, ratioY: 1.41),
      uiSettings: [
        cropper.AndroidUiSettings(
          toolbarTitle: 'crop_certificate'.tr(),
          toolbarColor: AppColors.primaryBlue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: cropper.CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        cropper.IOSUiSettings(
          title: 'crop_certificate'.tr(),
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        if (isGovt) {
          _govtCertificate = File(croppedFile.path);
        } else {
          _associationCertificate = File(croppedFile.path);
        }
      });
    }
  }

  void _viewFullScreen(File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  cacheWidth: 1080,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<OwnerCommunityCubit, OwnerCommunityState>(
        listener: (context, state) {
          if (state is OwnerCommunityLoaded && !state.isCreating) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('community_created_success'.tr())),
            );
            Navigator.pop(context); 
            Navigator.pop(context); 
          } else if (state is OwnerCommunityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLocationSummary(),
                            SizedBox(height: 32.h),
                            _buildForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _pickImage(true),
          child: Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.8),
                  AppColors.primaryBlue,
                ],
              ),
            ),
            child: _coverImage != null
                ? Image.file(
                    _coverImage!,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: Colors.white.withValues(alpha: 0.6), size: 32.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'add_cover_photo'.tr(),
                          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 24.w,
          child: Text(
            'create_community_title'.tr(namedArgs: {'level': widget.level.toLowerCase() == 'state' ? 'level_state'.tr() : (widget.level.toLowerCase() == 'district' ? 'level_district'.tr() : 'level_ward'.tr())}),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: 32.w,
          child: GestureDetector(
            onTap: () => _pickImage(false),
            child: Stack(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                            cacheWidth: 160,
                            cacheHeight: 160,
                          ),
                        )
                      : Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 36.sp),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: AppColors.primaryBlue, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'community_location'.tr(),
                  style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.greyText),
                ),
                Text(
                  widget.locationSummary,
                  style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'community_name_label'.tr(),
          hint: 'community_name_hint'.tr(),
          icon: Icons.edit_rounded,
          validator: (val) {
            if (val == null || val.isEmpty) return 'name_required_err'.tr();
            if (val.length < 3) return 'name_short_err'.tr();
            return null;
          },
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _descController,
          label: 'description_label'.tr(),
          hint: 'description_hint'.tr(),
          icon: Icons.description_rounded,
          maxLines: 3,
          validator: (val) {
            if (val == null || val.isEmpty) return 'desc_required_err'.tr();
            return null;
          },
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _rulesController,
          label: 'community_rules_label'.tr(),
          hint: 'community_rules_hint'.tr(),
          icon: Icons.rule_rounded,
          maxLines: 3,
        ),
        SizedBox(height: 32.h),
        _buildSectionHeader('exec_verification_title'.tr(), 'exec_verification_desc'.tr()),
        SizedBox(height: 20.h),
        _buildDropdownField(
          label: 'designated_role_label'.tr(),
          value: _selectedRole,
          items: _executiveRoles,
          onChanged: (val) => setState(() => _selectedRole = val),
          validator: (val) => val == null ? 'role_required_err'.tr() : null,
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _fullNameController,
          label: 'full_name_label'.tr(),
          hint: 'full_name_hint'.tr(),
          icon: Icons.person_rounded,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          validator: (val) {
            if (val == null || val.isEmpty) return 'name_required_err'.tr();
            if (val.split(' ').length < 2) return 'name_parts_err'.tr();
            return null;
          },
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _phoneController,
          label: 'official_phone_label'.tr(),
          hint: 'official_phone_hint'.tr(),
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (val) {
            if (val == null || val.isEmpty) return 'phone_len_err'.tr();
            if (val.length != 10) return 'phone_len_err'.tr();
            if (!RegExp(r'^[6-9]').hasMatch(val)) return 'phone_invalid_err'.tr();
            return null;
          },
        ),
        SizedBox(height: 32.h),
        _buildSectionHeader('verification_certs_title'.tr(), ''),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildCertificateUploadCard(
                title: 'govt_cert_label'.tr(),
                file: _govtCertificate,
                isGovt: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildCertificateUploadCard(
                title: 'assoc_cert_label'.tr(),
                file: _associationCertificate,
                isGovt: false,
              ),
            ),
          ],
        ),
        if (_govtCertificate == null || _associationCertificate == null)
          Padding(
            padding: EdgeInsets.only(top: 12.h, left: 4.w),
            child: Text(
              'certs_mandatory_msg'.tr(),
              style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.red.shade400, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        if (desc.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            desc,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.greyText, height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          items: items.map((role) => DropdownMenuItem(
            value: role,
            child: Text(
              role,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppColors.darkText),
            ),
          )).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            hintText: 'select_role_hint'.tr(),
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(Icons.badge_rounded, color: Colors.grey.shade400, size: 20.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(16.w),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(16.w),
            errorStyle: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateUploadCard({
    required String title,
    required File? file,
    required bool isGovt,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: file != null ? () => _viewFullScreen(file) : () => _pickCertificate(isGovt),
          child: Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: file != null ? Colors.white : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: file != null ? AppColors.primaryBlue.withValues(alpha: 0.2) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: file != null ? [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ] : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: file != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        file,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 28.sp),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.upload_file_rounded, color: AppColors.primaryBlue, size: 24.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'tap_to_upload'.tr(),
                        style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        if (file != null) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallActionButton(
                icon: Icons.crop_rounded,
                onTap: () => _cropExistingCertificate(isGovt),
                label: 'crop'.tr(),
              ),
              SizedBox(width: 12.w),
              _buildSmallActionButton(
                icon: Icons.refresh_rounded,
                onTap: () => _pickCertificate(isGovt),
                label: 'change'.tr(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSmallActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.darkText),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
      builder: (context, state) {
        final isLoading = state is OwnerCommunityLoaded && state.isCreating;

        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, MediaQuery.of(context).padding.bottom + 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
            ],
          ),
          child: BouncingWrapper(
            onTap: isLoading ? null : _handleCreate,
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'submit_for_verification'.tr(),
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_govtCertificate == null || _associationCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Both certificates are required for verification')));
      return;
    }

    context.read<OwnerCommunityCubit>().createCommunity(
      _nameController.text,
      _descController.text,
      level: widget.level,
      stateId: widget.stateId,
      districtId: widget.districtId,
      wardId: widget.wardId,
      localityId: widget.localityId,
      imagePath: _profileImage?.path,
      coverImagePath: _coverImage?.path,
      rules: _rulesController.text.isNotEmpty ? _rulesController.text : null,
      executiveRole: _selectedRole,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      govtCertificatePath: _govtCertificate?.path,
      associationCertificatePath: _associationCertificate?.path,
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
