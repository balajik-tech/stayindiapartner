import 'package:flutter/material.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/ui_constants.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'account_settings_page.dart';
import 'my_hostels_page.dart';
import 'room_master_page.dart';
import 'subscription_page.dart';
import 'help_support_page.dart';
import 'hostel_profile_page.dart';
import 'amenities_page.dart';
import 'house_rules_page.dart';
import 'room_configuration_page.dart';
import 'food_menu_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), 
      body: Column(
        children: [
          _AnimatedPremiumHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final authCubit = context.read<AuthCubit>();
                final hostelCubit = context.read<HostelCubit>();
                final profileCubit = context.read<ProfileCubit>();
                await authCubit.restoreSession();
                await hostelCubit.getHostels();
                await profileCubit.loadProfile();
              },
              color: AppColors.primaryBlue,
              edgeOffset: 20,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                children: [
                  _buildSectionLabel('PERSONAL MANAGEMENT'),
                  _PremiumSectionBlock(
                    backgroundColor: const Color(0xFFFFFFFF),
                    children: [
                      _PremiumTile(
                        icon: Icons.person_rounded,
                        title: 'Account Settings',
                        subtitle: 'Name, phone, email & identity',
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage()));
                          if (context.mounted) context.read<AuthCubit>().restoreSession();
                        },
                      ),
                      BlocBuilder<HostelCubit, HostelState>(
                        builder: (context, state) {
                          final count = state is HostelLoaded ? state.hostels.length : 0;
                          return _PremiumTile(
                            icon: Icons.apartment_rounded,
                            title: 'My Hostels',
                            subtitle: '$count ${count == 1 ? 'property' : 'properties'} active',
                            isHighlighted: true,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHostelsPage())),
                          );
                        },
                      ),
                      _PremiumTile(
                        icon: Icons.credit_card_rounded,
                        title: 'Subscription',
                        subtitle: 'Premium Plan  Pro Member',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.card_membership_rounded,
                        title: 'Digital Certificate',
                        subtitle: 'Official Association Membership',
                        onTap: () {
                           
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),
                  _buildSectionLabel('HOSTEL CONFIGURATION'),
                  _PremiumSectionBlock(
                    backgroundColor: const Color(0xFFFFFFFF),
                    children: [
                      _PremiumTile(
                        icon: Icons.business_rounded,
                        title: 'Hostel Profile',
                        subtitle: 'Address, location & contact info',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HostelProfilePage())),
                      ),
                      _PremiumTile(
                        icon: Icons.wifi_rounded,
                        title: 'Amenities',
                        subtitle: 'WiFi, AC, Laundry & more',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AmenitiesPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.rule_rounded,
                        title: 'House Rules',
                        subtitle: 'Timings & visitor policies',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HouseRulesPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.view_quilt_rounded,
                        title: 'Room Master',
                        subtitle: 'Pricing, types & bed rules',
                        onTap: () {
                          final dashboardCubit = context.read<DashboardCubit>();
                          final hostelState = context.read<HostelCubit>().state;
                          if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                            dashboardCubit.fetchDashboardData(hostelState.hostels[hostelState.selectedHostelIndex].id);
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(value: dashboardCubit, child: const RoomMasterPage())));
                        },
                      ),
                      _PremiumTile(
                        icon: Icons.layers_rounded,
                        title: 'Room Configuration',
                        subtitle: 'Floor plans, rooms & beds',
                        onTap: () {
                          final dashboardCubit = context.read<DashboardCubit>();
                          final hostelState = context.read<HostelCubit>().state;
                          if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                            dashboardCubit.fetchDashboardData(hostelState.hostels[hostelState.selectedHostelIndex].id);
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(value: dashboardCubit, child: const RoomConfigurationPage())));
                        },
                      ),
                      _PremiumTile(
                        icon: Icons.restaurant_rounded,
                        title: 'Food Menu',
                        subtitle: 'Manage daily meals',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodMenuPage())),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),
                  _buildSectionLabel('SUPPORT & SYSTEM'),
                  _PremiumSectionBlock(
                    backgroundColor: const Color(0xFFFFFFFF),
                    children: [
                      _PremiumTile(
                        icon: Icons.help_center_rounded,
                        title: 'Help & Support',
                        subtitle: 'FAQs, chat & contact support',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 40.h),
                  _SystemActionButton(
                    label: 'Logout from Account',
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFE03131),
                    onTap: () => _handleLogout(context),
                  ),
                  SizedBox(height: 16.h),
                  _SystemActionButton(
                    label: 'Delete Account Permanently',
                    icon: Icons.delete_forever_rounded,
                    color: Colors.grey.shade600,
                    isOutline: true,
                    onTap: () => _handleDeleteAccount(context),
                  ),
                  
                  UIConstants.bottomPaddingBox(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.greyText.withValues(alpha: 0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await _showConfirmDialog(context, 'Logout', 'Are you sure you want to logout?');
    if (confirm == true && context.mounted) context.read<AuthCubit>().logout();
  }

  void _handleDeleteAccount(BuildContext context) async {
    final confirm = await _showConfirmDialog(context, 'Delete Account', 'This is permanent and cannot be undone. Confirm?', isDestructive: true);
    if (confirm == true && context.mounted) context.read<AuthCubit>().deleteAccount();
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content, {bool isDestructive = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: isDestructive ? Colors.red : AppColors.primaryBlue),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPremiumHeader extends StatefulWidget {
  @override
  State<_AnimatedPremiumHeader> createState() => _AnimatedPremiumHeaderState();
}

class _AnimatedPremiumHeaderState extends State<_AnimatedPremiumHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
    
    
    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.state is ProfileInitial) {
      profileCubit.loadProfile();
    }
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final name = profile?.fullName ?? 'Owner';
        final phone = profile != null ? '+91 ${profile.phone}' : 'Stay India Member';

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 64.h, 24.w, 48.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14193F), Color(0xFF1A2151), Color(0xFF3359AD)],
                      stops: [0.0, 0.4, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A2151).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              MainNavigationPage.scaffoldKey.currentState?.openDrawer();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(Icons.menu_rounded, color: Colors.white, size: 24.sp),
                            ),
                          ),
                          const SizedBox.shrink(), 
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                        ),
                        child: CustomAvatar(
                          imageUrl: ApiConstants.getImageUrl(profile?.avatar),
                          name: name,
                          size: 96.0,
                          isCircle: true,
                          fontSize: 36.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                          if (profile?.isVerifiedOwner ?? true) ...[ 
                            SizedBox(width: 8.w),
                            const Icon(Icons.verified, color: Colors.blue, size: 24),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _PremiumSectionBlock extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;

  const _PremiumSectionBlock({required this.children, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PremiumTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PremiumTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  State<_PremiumTile> createState() => _PremiumTileState();
}

class _PremiumTileState extends State<_PremiumTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: widget.isHighlighted 
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1.5),
                color: AppColors.primaryBlue.withValues(alpha: 0.02),
              )
            : null,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: widget.isHighlighted 
                      ? AppColors.primaryBlue 
                      : AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  widget.icon, 
                  color: widget.isHighlighted ? Colors.white : AppColors.primaryBlue, 
                  size: 22.sp
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.greyText.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greyText.withValues(alpha: 0.2),
                size: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isOutline;
  final VoidCallback onTap;

  const _SystemActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isOutline = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isOutline ? Colors.grey.shade200 : color.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
