import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _profileImage;
  File? _coverImage;
  final _picker = ImagePicker();
  bool _isPublic = true;

  Future<void> _pickImage(bool isCover) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        if (isCover) {
          _coverImage = File(pickedFile.path);
        } else {
          _profileImage = File(pickedFile.path);
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
                          SizedBox(height: 24.h),
                          _buildForm(),
                          SizedBox(height: 24.h),
                          _buildPrivacyToggle(),
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
          maxLines: 4,
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

  Widget _buildPrivacyToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(
            _isPublic ? Icons.public_rounded : Icons.lock_rounded,
            color: _isPublic ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPublic ? 'Public Community' : 'Private Community',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15.sp),
                ),
                Text(
                  _isPublic ? 'Anyone can discover and join.' : 'Only invited members can join.',
                  style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
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
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
