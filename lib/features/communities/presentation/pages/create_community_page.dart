import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart' as cropper;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_wrapper.dart';
import '../cubit/owner_community_cubit.dart';

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
            toolbarTitle: isCover ? 'Crop Cover Photo' : 'Crop Profile Photo',
            toolbarColor: AppColors.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isCover ? cropper.CropAspectRatioPreset.ratio16x9 : cropper.CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: isCover ? cropper.CropStyle.rectangle : cropper.CropStyle.circle,
          ),
          cropper.IOSUiSettings(
            title: isCover ? 'Crop Cover Photo' : 'Crop Profile Photo',
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
      setState(() {
        if (isGovt) {
          _govtCertificate = File(pickedFile.path);
        } else {
          _associationCertificate = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<OwnerCommunityCubit, OwnerCommunityState>(
        listener: (context, state) {
          if (state is OwnerCommunityLoaded && !state.isCreating) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Community created successfully!')),
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
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationSummary(),
                          _buildForm(),
                        ],
                      ),
                    ),
                  ],
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
                ? Image.file(_coverImage!, fit: BoxFit.cover)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: Colors.white.withValues(alpha: 0.6), size: 32.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'Add Cover Photo',
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
            'Create ${widget.level.toLowerCase().capitalize()} Community',
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
                      ? ClipOval(child: Image.file(_profileImage!, fit: BoxFit.cover))
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
                  'Community Location',
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
          label: 'Community Name',
          hint: 'e.g. Hyderabad Owners Hub',
          icon: Icons.edit_rounded,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _descController,
          label: 'Description',
          hint: 'What is this community for?',
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _rulesController,
          label: 'Community Rules',
          hint: 'Enter guidelines and rules for members',
          icon: Icons.rule_rounded,
          maxLines: 3,
        ),
        SizedBox(height: 28.h),
        Text(
          'Executive Committee Verification',
          style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        SizedBox(height: 4.h),
        Text(
          'Select your official role and provide verification documents. Created communities are verified by admins.',
          style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.greyText, height: 1.4),
        ),
        SizedBox(height: 20.h),
        Text(
          'Designated Role',
          style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              hint: Text('Select Executive Role', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp)),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              items: _executiveRoles.map((role) => DropdownMenuItem(
                value: role,
                child: Text(role, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppColors.darkText)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedRole = val),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          hint: 'Enter your official full name',
          icon: Icons.person_rounded,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_rounded,
        ),
        SizedBox(height: 24.h),
        Text(
          'Verification Certificates',
          style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildCertificateUploadCard(
                title: 'Govt Certificate',
                file: _govtCertificate,
                onTap: () => _pickCertificate(true),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildCertificateUploadCard(
                title: 'Association Cert',
                file: _associationCertificate,
                onTap: () => _pickCertificate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCertificateUploadCard({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: file != null ? AppColors.primaryBlue.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: file != null ? AppColors.primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: file != null ? Colors.green : Colors.grey.shade400,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: file != null ? AppColors.primaryBlue : AppColors.darkText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              file != null ? 'Uploaded' : 'Tap to upload',
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: file != null ? Colors.green : AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp),
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
      ],
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
                        'Create Community',
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a community name')));
      return;
    }
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an executive role')));
      return;
    }
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number')));
      return;
    }
    if (_govtCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload government certificate')));
      return;
    }
    if (_associationCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload association certificate')));
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
