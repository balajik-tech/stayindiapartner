import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/staff/presentation/pages/staff_management_page.dart';
import 'package:stayindia_owner/features/finance/presentation/pages/financial_dashboard_page.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.85.sw,
      backgroundColor: const Color(0xFFF6F7F9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          _buildPremiumHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionLabel('PROPERTY'),
                _buildInteractiveMenuItem(
                  context,
                  icon: Icons.apartment_rounded,
                  title: 'Switch Property',
                  isHighlighted: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showSwitchHostelSheet(context);
                  },
                ),
                SizedBox(height: 24.h),
                _buildSectionLabel('MANAGEMENT'),
                _buildInteractiveMenuItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: 'Staff Management',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffManagementPage()),
                    );
                  },
                ),
                _buildInteractiveMenuItem(
                  context,
                  icon: Icons.insights_rounded,
                  title: 'Financial Insights',
                  isElevated: true,
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
                _buildInteractiveMenuItem(context, icon: Icons.verified_user_rounded, title: 'Privacy & Policy'),
                _buildInteractiveMenuItem(context, icon: Icons.help_rounded, title: 'Help & Support'),
                _buildInteractiveMenuItem(context, icon: Icons.chat_bubble_rounded, title: 'Feedback'),
                
                SizedBox(height: 24.h),
                _buildSectionLabel('APPLICATION'),
                _buildInteractiveMenuItem(context, icon: Icons.share_rounded, title: 'Share App'),
                _buildInteractiveMenuItem(context, icon: Icons.menu_book_rounded, title: 'User Manual'),
                _buildInteractiveMenuItem(context, icon: Icons.info_outline_rounded, title: 'Version 1.0.0'),
                
                SizedBox(height: 40.h),
                _buildPremiumLogout(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<HostelCubit, HostelState>(
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.5), width: 2),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFF7A00).withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)
                              ],
                            ),
                            child: CustomAvatar(
                              imageUrl: imageUrl,
                              name: name,
                              size: 56.0,
                              isCircle: true,
                              fontSize: 22.sp,
                            ),
                          ),
                          BouncingWrapper(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded, size: 20.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_rounded, size: 12.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInteractiveMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isHighlighted = false,
    bool isElevated = false,
    VoidCallback? onTap,
  }) {
    return BouncingWrapper(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is coming soon!')),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isHighlighted ? const Color(0xFFFFE4C4) : const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isHighlighted ? const Color(0xFFFF7A00).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? const Color(0xFFFF7A00) : const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLogout(BuildContext context) {
    return BouncingWrapper(
      onTap: () => _handleLogout(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: const Color(0xFFEF4444), size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFEF4444),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: Text('Are you sure you want to sign out of your account?', style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
        builder: (context, state) {
          if (state is! HostelLoaded) return const SizedBox.shrink();
          
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                      color: const Color(0xFFE2E8F0),
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
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.h),
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
                      return BouncingWrapper(
                        onTap: () {
                          context.read<HostelCubit>().selectHostel(index);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF7A00).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.apartment_rounded, 
                                  color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF64748B),
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hostel.name,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                        color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: const Color(0xFFFF7A00), size: 22.sp),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

