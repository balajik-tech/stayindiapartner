import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:stayindia_owner/features/finance/presentation/pages/financial_dashboard_page.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/features/stock_management/presentation/pages/stock_dashboard_page.dart';
import 'package:stayindia_owner/features/stock_management/presentation/cubit/stock_cubit.dart';
import 'package:stayindia_owner/features/staff/presentation/pages/staff_management_page.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'account_settings_page.dart';
import 'help_support_page.dart';
import 'subscription_page.dart';
import 'hostel_profile_page.dart';
import 'amenities_page.dart';
import 'house_rules_page.dart';
import 'food_menu_page.dart';
import 'refer_friend_page.dart';
import 'announcements_page.dart';
import 'reports_dashboard_page.dart';
import 'package:stayindia_owner/features/auth/presentation/pages/terms_and_conditions_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.state is ProfileInitial) {
      profileCubit.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileLoaded ? state.profile : 
                        (state is ProfileUpdateSuccess ? state.profile : null);
          final name = profile?.fullName ?? 'Owner';
          final phone = profile != null ? '+91 ${profile.phone}' : 'Stay India Member';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildProfileHeader(context, name, phone, profile?.avatar)),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionLabel('PERSONAL MANAGEMENT'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.person_rounded,
                        title: 'Account Settings',
                        subtitle: 'Name, phone, email & identity',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.credit_card_rounded,
                        title: 'Subscription',
                        subtitle: 'Premium Plan • Pro Member',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.card_membership_rounded,
                        title: 'Digital Certificate',
                        subtitle: 'Official Association Membership',
                        onTap: () {},
                      ),
                    ]),

                    SizedBox(height: 32.h),
                    _buildSectionLabel('HOSTEL CONFIGURATION'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.business_rounded,
                        title: 'Hostel Profile',
                        subtitle: 'Address, location & contact info',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HostelProfilePage())),
                      ),
                      _ProfileTile(
                        icon: Icons.wifi_rounded,
                        title: 'Amenities',
                        subtitle: 'WiFi, AC, Laundry & more',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AmenitiesPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.rule_rounded,
                        title: 'House Rules',
                        subtitle: 'Timings & visitor policies',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HouseRulesPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.restaurant_rounded,
                        title: 'Food Menu',
                        subtitle: 'Manage daily meals',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodMenuPage())),
                      ),
                    ]),

                    SizedBox(height: 32.h),
                    _buildSectionLabel('BUSINESS MANAGEMENT'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.insights_rounded,
                        title: 'Financial Insights',
                        subtitle: 'Revenue, occupancy & analytics',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => sl<FinanceCubit>(),
                              child: const FinancialDashboardPage(),
                            ),
                          ),
                        ),
                      ),
                      _ProfileTile(
                        icon: Icons.inventory_2_rounded,
                        title: 'Stock Management',
                        subtitle: 'Inventory tracking & alerts',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => sl<StockCubit>(),
                              child: const StockDashboardPage(),
                            ),
                          ),
                        ),
                      ),
                      _ProfileTile(
                        icon: Icons.people_alt_rounded,
                        title: 'Staff Management',
                        subtitle: 'Roles, attendance & salaries',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffManagementPage())),
                      ),
                    ]),

                    SizedBox(height: 32.h),
                    _buildSectionLabel('SUPPORT & LEGAL'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.verified_user_rounded,
                        title: 'Privacy & Policy',
                        subtitle: 'Data usage & terms of service',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsPage(readOnly: true),
                          ),
                        ),
                      ),
                      _ProfileTile(
                        icon: Icons.help_center_rounded,
                        title: 'Help & Support',
                        subtitle: 'FAQs, chat & documentation',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.chat_bubble_rounded,
                        title: 'Feedback',
                        subtitle: 'Tell us how to improve',
                        onTap: () {},
                      ),
                    ]),

                    SizedBox(height: 32.h),
                    _buildSectionLabel('TOOLS & REPORTS'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.card_giftcard_rounded,
                        title: 'Refer a Friend',
                        subtitle: 'Earn rewards for inviting owners',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferFriendPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.star_rate_rounded,
                        title: 'Rate Us',
                        subtitle: 'Love Stay India? Let us know!',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.system_update_rounded,
                        title: 'Update App',
                        subtitle: 'Check for latest features & fixes',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('App is up to date! (v1.0.4)')),
                          );
                        },
                      ),
                      _ProfileTile(
                        icon: Icons.campaign_rounded,
                        title: 'Send Announcements',
                        subtitle: 'Broadcast to all tenants instantly',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendAnnouncementsPage())),
                      ),
                      _ProfileTile(
                        icon: Icons.analytics_rounded,
                        title: 'My Reports',
                        subtitle: 'Detailed business & financial exports',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsDashboardPage())),
                      ),
                    ]),

                    SizedBox(height: 32.h),
                    _buildSectionLabel('APPLICATION'),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.share_rounded,
                        title: 'Share App',
                        subtitle: 'Invite other owners to Stay India',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out from this device',
                        titleColor: AppColors.error,
                        onTap: () => _handleLogout(context),
                      ),
                    ]),
                    
                    SizedBox(height: 140.h),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String phone, String? avatar) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 54.h, 20.w, 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF98125), width: 1.5),
            ),
            child: CustomAvatar(
              imageUrl: ApiConstants.getImageUrl(avatar),
              name: name,
              size: 52.0,
              isCircle: true,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          BouncingWrapper(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage())),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2C599D), width: 1.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C599D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.only(top: 24.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _QuickActionCard(
            icon: Icons.insights_rounded,
            label: 'Insights',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => sl<FinanceCubit>(),
                  child: const FinancialDashboardPage(),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _QuickActionCard(
            icon: Icons.inventory_2_rounded,
            label: 'Stock',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => sl<StockCubit>(),
                  child: const StockDashboardPage(),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _QuickActionCard(
            icon: Icons.people_alt_rounded,
            label: 'Staff',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffManagementPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionBlock(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                  child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) context.read<AuthCubit>().logout();
  }


}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentOrange, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
