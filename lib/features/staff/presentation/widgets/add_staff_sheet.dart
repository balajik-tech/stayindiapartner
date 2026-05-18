import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../../domain/entities/staff.dart';
import '../cubit/staff_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class AddStaffSheet extends StatefulWidget {
  final String hostelId;
  final Staff? staff;
  final VoidCallback onAdded;

  const AddStaffSheet({
    super.key,
    required this.hostelId,
    this.staff,
    required this.onAdded,
  });

  static void show(BuildContext context,
      {required String hostelId, Staff? staff, required VoidCallback onAdded}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStaffSheet(hostelId: hostelId, staff: staff, onAdded: onAdded),
    );
  }

  @override
  State<AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends State<AddStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryController = TextEditingController();
  
  
  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _beneficiaryController = TextEditingController();

  String _selectedRole = 'Warden';
  bool _obscurePassword = true;
  String? _photoUrl;
  File? _localImage;
  bool _isUploading = false;

  final List<String> _roles = [
    'Manager',
    'Warden',
    'Security',
    'Cook',
    'Cleaning Staff',
  ];

  final Map<String, String> _roleMap = {
    'Manager': 'MANAGER',
    'Warden': 'WARDEN',
    'Security': 'SECURITY',
    'Cook': 'COOK',
    'Cleaning Staff': 'CLEANING_STAFF',
  };

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _phoneController.text = widget.staff!.phone;
      _emailController.text = widget.staff!.email ?? '';
      _salaryController.text = widget.staff!.salary.toString();
      _photoUrl = widget.staff!.photo;
      
      if (widget.staff!.paymentDetails != null) {
        _upiController.text = widget.staff!.paymentDetails!.upiId;
        _bankNameController.text = widget.staff!.paymentDetails!.bankName;
        _accountNoController.text = widget.staff!.paymentDetails!.accountNumber;
        _ifscController.text = widget.staff!.paymentDetails!.ifscCode;
        _beneficiaryController.text = widget.staff!.paymentDetails!.beneficiaryName;
      }

      final reverseRoleMap = {
        'MANAGER': 'Manager',
        'WARDEN': 'Warden',
        'SECURITY': 'Security',
        'COOK': 'Cook',
        'CLEANING_STAFF': 'Cleaning Staff',
      };
      _selectedRole = reverseRoleMap[widget.staff!.role] ?? widget.staff!.role;
    }
  }

  Future<void> _pickImage() async {
    final staffCubit = context.read<StaffCubit>();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _localImage = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final url = await staffCubit.uploadImage(pickedFile.path);
        if (!mounted) return;
        if (url != null) {
          setState(() {
            _photoUrl = url;
            _isUploading = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(StringUtils.translate('upload_failed_msg', context: context))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffSuccess) {
          Navigator.pop(context);
          widget.onAdded();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(StringUtils.translate(widget.staff != null ? 'staff_updated_msg' : 'staff_added_msg', context: context)), backgroundColor: Colors.green),
          );
        } else if (state is StaffError) {
          AppLogger.error('AddStaffSheet error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        height: 0.9.sh,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 32.h),
                      _buildPhotoUploader(),
                      SizedBox(height: 32.h),
                      _buildSectionTitle(StringUtils.translate('personal_info_section', context: context)),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _nameController,
                        label: StringUtils.translate('full_name_label', context: context),
                        hint: StringUtils.translate('enter_staff_name_hint', context: context),
                        icon: Icons.person_rounded,
                        validator: (v) => v?.isEmpty == true ? StringUtils.translate('name_required_error', context: context) : null,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _phoneController,
                        label: StringUtils.translate('phone_number_label', context: context),
                        hint: StringUtils.translate('mobile_hint', context: context),
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return StringUtils.translate('phone_required_error', context: context);
                          if (v.length != 10) return StringUtils.translate('phone_invalid_error', context: context);
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _emailController,
                        label: StringUtils.translate('email_optional_label', context: context),
                        hint: StringUtils.translate('email_hint', context: context),
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegExp.hasMatch(v)) return StringUtils.translate('email_invalid_error', context: context);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _salaryController,
                        label: StringUtils.translate('monthly_salary_label', context: context),
                        hint: StringUtils.translate('salary_hint', context: context),
                        icon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      
                      SizedBox(height: 32.h),
                      _buildSectionTitle(StringUtils.translate('access_credentials_section', context: context)),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _passwordController,
                        label: widget.staff != null ? StringUtils.translate('new_password_optional_label', context: context) : StringUtils.translate('password_label', context: context),
                        hint: widget.staff != null ? StringUtils.translate('leave_blank_hint', context: context) : StringUtils.translate('password_hint', context: context),
                        icon: Icons.lock_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: AppColors.greyText,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) => widget.staff == null
                            ? (v == null || v.length < 6 ? StringUtils.translate('password_short_error', context: context) : null)
                            : (v != null && v.isNotEmpty && v.length < 6 ? StringUtils.translate('password_short_error', context: context) : null),
                      ),
                      
                      SizedBox(height: 32.h),
                      _buildSectionTitle(StringUtils.translate('payment_details_section', context: context)),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _upiController,
                        label: StringUtils.translate('upi_label', context: context),
                        hint: StringUtils.translate('upi_hint', context: context),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _bankNameController,
                        label: StringUtils.translate('bank_name_label', context: context),
                        hint: StringUtils.translate('bank_name_hint', context: context),
                        icon: Icons.account_balance_rounded,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _accountNoController,
                        label: StringUtils.translate('account_number_label', context: context),
                        hint: StringUtils.translate('account_number_hint', context: context),
                        icon: Icons.numbers_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _ifscController,
                        label: StringUtils.translate('ifsc_code_label', context: context),
                        hint: StringUtils.translate('ifsc_hint', context: context),
                        icon: Icons.code_rounded,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _beneficiaryController,
                        label: StringUtils.translate('beneficiary_name_label', context: context),
                        hint: StringUtils.translate('beneficiary_hint', context: context),
                        icon: Icons.badge_rounded,
                      ),

                      SizedBox(height: 32.h),
                      _buildSectionTitle(StringUtils.translate('designated_role_section', context: context)),
                      SizedBox(height: 16.h),
                      _buildRoleSelector(),
                      SizedBox(height: 48.h),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.staff != null ? StringUtils.translate('edit_staff_details', context: context) : StringUtils.translate('add_new_staff', context: context),
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.darkText, letterSpacing: -0.5),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.staff != null
              ? StringUtils.translate('update_staff_info_desc', context: context)
              : StringUtils.translate('enter_staff_details_desc', context: context),
          style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPhotoUploader() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ClipOval(
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : (_localImage != null
                      ? Image.file(
                          _localImage!,
                          fit: BoxFit.cover,
                          cacheWidth: 200,
                          cacheHeight: 200,
                        )
                      : (_photoUrl != null && _photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.person_rounded, size: 50.sp, color: const Color(0xFFCBD5E1)),
                            )
                          : Icon(Icons.person_rounded, size: 50.sp, color: const Color(0xFFCBD5E1)))),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: BouncingWrapper(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText, letterSpacing: -0.3),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.r)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B))),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _roles.map((role) {
        final isSelected = _selectedRole == role;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0)),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Text(
              StringUtils.translate(role.toLowerCase().replaceAll(' ', '_'), context: context),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<StaffCubit, StaffState>(
      builder: (context, state) {
        final isLoading = state is StaffSaving;
        return BouncingWrapper(
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.staff != null ? StringUtils.translate('update_staff_button', context: context) : StringUtils.translate('create_staff_button', context: context),
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      final paymentDetails = {
        'upiId': _upiController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNoController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
        'beneficiaryName': _beneficiaryController.text.trim(),
      };

      if (widget.staff != null) {
        final data = <String, dynamic>{
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _roleMap[_selectedRole] ?? _selectedRole,
          'salary': double.tryParse(_salaryController.text) ?? 0.0,
          'photo': _photoUrl ?? '',
          'paymentDetails': paymentDetails,
        };
        if (_passwordController.text.isNotEmpty) {
          data['password'] = _passwordController.text;
        }
        context.read<StaffCubit>().updateStaff(widget.staff!.id, data);
      } else {
        
        
        
        
        
        
        
        
        
        
        context.read<StaffCubit>().createStaff(
              hostelId: widget.hostelId,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _roleMap[_selectedRole] ?? _selectedRole,
              salary: double.tryParse(_salaryController.text) ?? 0.0,
              photo: _photoUrl ?? '',
              paymentDetails: paymentDetails,
            );
      }
    }
  }
}
