import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../../domain/entities/staff.dart';
import '../cubit/staff_cubit.dart';

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
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Warden';
  bool _obscurePassword = true;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffSuccess) {
          Navigator.pop(context);
          widget.onAdded();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff member added successfully')),
          );
        } else if (state is StaffError) {
          AppLogger.error('AddStaffSheet error: ${state.message}');
        }
      },
      child: Container(
        height: 0.85.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.staff != null ? 'Edit Staff Details' : 'Add New Staff',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkText,
                          letterSpacing: -1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.staff != null
                            ? 'Update staff information and designated role.'
                            : 'Enter staff details to grant them access to management tools.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter staff name',
                        icon: Icons.person_rounded,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Name is required' : null,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '10-digit mobile number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.length != 10
                            ? 'Enter a valid 10-digit number'
                            : null,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address (Optional)',
                        hint: 'example@stayindia.in',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _passwordController,
                        label: widget.staff != null ? 'New Password (Optional)' : 'Password',
                        hint: widget.staff != null ? 'Leave blank to keep unchanged' : 'Minimum 6 characters',
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
                            ? (v == null || v.length < 6 ? 'Password must be at least 6 characters' : null)
                            : (v != null && v.isNotEmpty && v.length < 6 ? 'Password must be at least 6 characters' : null),
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        validator: (v) => v != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Designated Role',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildRoleSelector(),
                      SizedBox(height: 40.h),
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

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.greyText.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.greyText.withValues(alpha: 0.4),
                fontSize: 15.sp,
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22.sp),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.greyText.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.darkText,
              ),
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
        return SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.staff != null ? 'Save Changes' : 'Create Staff Account',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      if (widget.staff != null) {
        final data = <String, dynamic>{
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'role': _roleMap[_selectedRole] ?? _selectedRole,
        };
        if (_passwordController.text.isNotEmpty) {
          data['password'] = _passwordController.text;
        }
        context.read<StaffCubit>().updateStaff(widget.staff!.id, data);
      } else {
        context.read<StaffCubit>().createStaff(
              hostelId: widget.hostelId,
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              password: _passwordController.text,
              role: _roleMap[_selectedRole] ?? _selectedRole,
            );
      }
    }
  }
}
