import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/staff/presentation/pages/staff_management_page.dart';
import 'package:stayindia_owner/features/finance/presentation/pages/financial_dashboard_page.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.88.sw,
      backgroundColor: const Color(0xFFF8F9FA),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          _buildGradientHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionLabel('PROPERTY'),
                _buildPremiumMenuItem(
                  context, 
                  Icons.swap_horiz_rounded, 
                  'Switch Property',
                  onTap: () {
                    Navigator.pop(context);
                    _showSwitchHostelSheet(context);
                  },
                ),
                SizedBox(height: 24.h),
                _buildSectionLabel('MANAGEMENT'),
                _buildPremiumMenuItem(
                  context, 
                  Icons.people_alt_rounded, 
                  'Staff Management',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffManagementPage()),
                    );
                  },
                ),
                _buildPremiumMenuItem(
                  context, 
                  Icons.insights_rounded, 
                  'Financial Insights',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => sl<FinanceCubit>(),
                          child: const FinancialDashboardPage(),
                        ),
                      ),
                    );
                  },
                ),
                _buildPremiumMenuItem(context, Icons.verified_user_rounded, 'Privacy & Policy'),
                _buildPremiumMenuItem(context, Icons.help_rounded, 'Help & Support'),
                _buildPremiumMenuItem(context, Icons.chat_bubble_rounded, 'Feedback'),
                
                SizedBox(height: 32.h),
                _buildSectionLabel('APPLICATION'),
                _buildPremiumMenuItem(context, Icons.share_rounded, 'Share App'),
                _buildPremiumMenuItem(context, Icons.menu_book_rounded, 'User Manual'),
                _buildPremiumMenuItem(context, Icons.info_outline_rounded, 'Version 1.0.0'),
                
                SizedBox(height: 40.h),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, authState) {
        return BlocBuilder<HostelCubit, HostelState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, hostelState) {
            String name = 'Owner';
            String phone = '';
            String? imageUrl;

            if (authState is AuthAuthenticated) {
              name = authState.owner.name;
              phone = '+91 ${authState.owner.phone}';
            }

            if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
              final hostel = hostelState.hostels[hostelState.selectedHostelIndex];
              imageUrl = ApiConstants.getImageUrl(hostel.coverImage);
            }

            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 44.h, 20.w, 24.h), // Reduced vertical
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Professional slate instead of gradient
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)), // Reduced from 32
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CustomAvatar(
                        imageUrl: imageUrl,
                        name: name,
                        size: 52.0, // Reduced from 72
                        isCircle: true,
                        fontSize: 20.sp,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp, // Reduced from 22
                                fontWeight: FontWeight.w700, // Reduced from 900
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12.sp, // Reduced from 15
                                color: Colors.white.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h), // Reduced
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp, // Reduced from 13
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h), // Reduced from 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r), // Reduced from 20
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title is coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), // Reduced vertical
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF64748B), size: 18.sp), // Reduced size
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp, // Reduced from 16
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 10.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h), // Reduced from 18
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: const Color(0xFFEF4444), size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  void _showSwitchHostelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<HostelCubit, HostelState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is! HostelLoaded) return const SizedBox.shrink();
          
          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h), // Reduced
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)), // Reduced from 32
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(1.5.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Switch Property',
                  style: TextStyle(
                    fontSize: 16.sp, // Reduced from 20
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.5.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = index == state.selectedHostelIndex;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(10.r), // Reduced from 16
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<HostelCubit>().selectHostel(index);
                            Navigator.pop(context);
                          },
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apartment_rounded, 
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              size: 18.sp,
                            ),
                          ),
                          title: Text(
                            hostel.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryBlue : AppColors.darkText,
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20.sp) 
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

