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
import 'package:stayindia_owner/core/constants/ui_constants.dart';
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
              padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 32.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2151), Color(0xFF3359AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2151).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.close_rounded, size: 20.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: CustomAvatar(
                          imageUrl: imageUrl,
                          name: name,
                          size: 72.0,
                          isCircle: true,
                          fontSize: 28.sp,
                        ),
                      ),
                      SizedBox(width: 18.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.only(left: 8.w, bottom: 16.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.greyText.withValues(alpha: 0.8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title is coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 22.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.greyText.withValues(alpha: 0.3),
                  size: 14.sp,
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
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFEE4E2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: const Color(0xFFF04438), size: 22.sp),
                SizedBox(width: 12.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF04438),
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
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
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
                      color: AppColors.greyText.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Switch Property',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = index == state.selectedHostelIndex;
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : AppColors.greyText.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<HostelCubit>().selectHostel(index);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          leading: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : AppColors.greyText.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apartment_rounded, 
                              color: isSelected ? Colors.white : AppColors.greyText,
                            ),
                          ),
                          title: Text(
                            hostel.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primaryBlue : AppColors.darkText,
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 24.sp) 
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: UIConstants.bottomPadding(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}

