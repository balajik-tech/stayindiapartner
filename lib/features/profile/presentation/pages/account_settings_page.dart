import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';

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
      _firstNameController.text = state.profile.firstName;
      _lastNameController.text = state.profile.lastName;
      _phoneController.text = state.profile.phone;
      _emailController.text = state.profile.email;
      _addressController.text = state.profile.address;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      if (mounted) {
        context.read<ProfileCubit>().uploadProfileImage(File(result.files.single.path!));
      }
    }
  }

  void _saveProfile() {
    HapticFeedback.mediumImpact();
    context.read<ProfileCubit>().updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) _populateControllers(state);
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          context.read<AuthCubit>().restoreSession();
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
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

            final profile = state is ProfileLoaded ? state.profile : null;

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
                        children: [
                          _buildAnimatedHeader(profile),
                          SizedBox(height: 32.h),
                          _buildSectionLabel('PERSONAL INFORMATION'),
                          _buildEditableBlock([
                            _EditableRow(
                              label: 'First Name',
                              value: _firstNameController.text,
                              icon: Icons.person_rounded,
                              onTap: () => _showEditSheet('First Name', _firstNameController),
                            ),
                            _EditableRow(
                              label: 'Last Name',
                              value: _lastNameController.text,
                              icon: Icons.person_rounded,
                              onTap: () => _showEditSheet('Last Name', _lastNameController),
                            ),
                            _EditableRow(
                              label: 'Phone Number',
                              value: '+91 ${_phoneController.text}',
                              icon: Icons.phone_rounded,
                              isLocked: true,
                            ),
                            _EditableRow(
                              label: 'Email Address',
                              value: _emailController.text,
                              icon: Icons.email_rounded,
                              onTap: () => _showEditSheet('Email Address', _emailController, inputType: TextInputType.emailAddress),
                            ),
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionLabel('ADDRESS'),
                          _buildEditableBlock([
                            _EditableRow(
                              label: 'Current Address',
                              value: _addressController.text,
                              icon: Icons.location_on_rounded,
                              onTap: () => _showEditSheet('Address', _addressController, isLongText: true),
                            ),
                          ]),
                          SizedBox(height: 32.h),
                          _buildDeleteAccountButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildStickyCTA(state is ProfileUpdating),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Account Settings',
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
                        onTap: _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  name,
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                ),
                Text(
                  '+91 ${_phoneController.text}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.greyText.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEditableBlock(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
                  child: Divider(height: 1, color: Colors.grey.shade50),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickyCTA(bool isUpdating) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
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
      child: ElevatedButton(
        onPressed: isUpdating ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          elevation: 0,
        ),
        child: isUpdating
            ? SizedBox(height: 24.h, width: 24.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text('Save Changes', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => _confirmDelete(context),
        child: Text(
          'Delete My Account',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF04438).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => navigator.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await profileCubit.deleteAccount();
              authCubit.logout();
              navigator.popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(String title, TextEditingController controller, {TextInputType inputType = TextInputType.text, bool isLongText = false}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text(
              'Update $title',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  const _EditableRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLocked = false,
    this.onTap,
  });

  @override
  State<_EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<_EditableRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(widget.icon, color: AppColors.primaryBlue, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.greyText.withValues(alpha: 0.6), letterSpacing: 0.5),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.value.isEmpty ? 'Not set' : widget.value,
                      style: TextStyle(
                        fontSize: 15.sp, 
                        fontWeight: FontWeight.w700, 
                        color: widget.isLocked ? AppColors.darkText.withValues(alpha: 0.5) : AppColors.darkText
                      ),
                    ),
                    if (widget.isLocked)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text('Cannot be changed', style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              Icon(
                widget.isLocked ? Icons.lock_outline_rounded : Icons.edit_rounded,
                color: AppColors.darkText.withValues(alpha: 0.45),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
