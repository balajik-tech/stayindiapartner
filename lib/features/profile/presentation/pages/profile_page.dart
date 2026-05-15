import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final authState = context.watch<AuthCubit>().state;
    final owner = authState is AuthAuthenticated ? authState.owner : null;
    final role = owner?.role.toLowerCase() ?? 'owner';
    final bool isStaff = role != 'owner' && role != 'manager';

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileLoaded ? state.profile : 
                        (state is ProfileUpdateSuccess ? state.profile : null);
          final name = profile?.fullName ?? owner?.name ?? 'Owner';
          final phone = profile != null ? '+91 ${profile.phone}' : (owner != null ? '+91 ${owner.phone}' : 'Stay India Member');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildProfileHeader(context, name, phone, profile?.avatar)),
              SliverToBoxAdapter(child: _buildQuickActions(context, role, owner)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!isStaff) ...[
                      _buildSectionLabel('personal_management'.tr()),
                      _buildSectionBlock([
                        _ProfileTile(
                          icon: Icons.person_rounded,
                          title: 'account_settings'.tr(),
                          subtitle: 'account_settings_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.credit_card_rounded,
                          title: 'subscription'.tr(),
                          subtitle: 'subscription_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.card_membership_rounded,
                          title: 'digital_certificate'.tr(),
                          subtitle: 'digital_certificate_sub'.tr(),
                          onTap: () {},
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ] else ...[
                      _buildSectionLabel('personal_management'.tr()),
                      _buildSectionBlock([
                        _ProfileTile(
                          icon: Icons.person_rounded,
                          title: 'account_settings'.tr(),
                          subtitle: 'account_settings_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage())),
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ],

                    if (!isStaff) ...[
                      _buildSectionLabel('hostel_configuration'.tr()),
                      _buildSectionBlock([
                        _ProfileTile(
                          icon: Icons.business_rounded,
                          title: 'hostel_profile'.tr(),
                          subtitle: 'hostel_profile_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HostelProfilePage())),
                        ),
                        _ProfileTile(
                          icon: Icons.wifi_rounded,
                          title: 'amenities'.tr(),
                          subtitle: 'amenities_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AmenitiesPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.rule_rounded,
                          title: 'house_rules'.tr(),
                          subtitle: 'house_rules_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HouseRulesPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.restaurant_rounded,
                          title: 'food_menu'.tr(),
                          subtitle: 'food_menu_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodMenuPage())),
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ],

                    if (!isStaff) ...[
                      _buildSectionLabel('business_management'.tr()),
                      _buildSectionBlock([
                        _ProfileTile(
                          icon: Icons.insights_rounded,
                          title: 'financial_insights'.tr(),
                          subtitle: 'financial_insights_sub'.tr(),
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
                          title: 'stock_management'.tr(),
                          subtitle: 'stock_management_sub'.tr(),
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
                          title: 'staff_management'.tr(),
                          subtitle: 'staff_management_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffManagementPage())),
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ],

                    _buildSectionLabel('support_legal'.tr()),
                    _buildSectionBlock([
                      _ProfileTile(
                        icon: Icons.language_rounded,
                        title: 'change_language'.tr(),
                        subtitle: 'language_sub'.tr(),
                        onTap: () => _showLanguagePicker(context),
                      ),
                      _ProfileTile(
                        icon: Icons.verified_user_rounded,
                        title: 'privacy_policy'.tr(),
                        subtitle: 'privacy_policy_sub'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsPage(readOnly: true),
                          ),
                        ),
                      ),
                      if (!isStaff) ...[
                        _ProfileTile(
                          icon: Icons.help_center_rounded,
                          title: 'help_support'.tr(),
                          subtitle: 'help_support_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.chat_bubble_rounded,
                          title: 'feedback'.tr(),
                          subtitle: 'feedback_sub'.tr(),
                          onTap: () {},
                        ),
                      ],
                    ]),

                    SizedBox(height: 32.h),

                    if (!isStaff) ...[
                      _buildSectionLabel('tools_reports'.tr()),
                      _buildSectionBlock([
                        _ProfileTile(
                          icon: Icons.card_giftcard_rounded,
                          title: 'refer_friend'.tr(),
                          subtitle: 'refer_friend_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferFriendPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.star_rate_rounded,
                          title: 'rate_us'.tr(),
                          subtitle: 'rate_us_sub'.tr(),
                          onTap: () {},
                        ),
                        _ProfileTile(
                          icon: Icons.system_update_rounded,
                          title: 'update_app'.tr(),
                          subtitle: 'update_app_sub'.tr(),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('App is up to date! (v1.0.4)')),
                            );
                          },
                        ),
                        _ProfileTile(
                          icon: Icons.campaign_rounded,
                          title: 'send_announcements'.tr(),
                          subtitle: 'send_announcements_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendAnnouncementsPage())),
                        ),
                        _ProfileTile(
                          icon: Icons.analytics_rounded,
                          title: 'my_reports'.tr(),
                          subtitle: 'my_reports_sub'.tr(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsDashboardPage())),
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ],

                    _buildSectionLabel('application'.tr()),
                    _buildSectionBlock([
                      if (!isStaff)
                        _ProfileTile(
                          icon: Icons.share_rounded,
                          title: 'share_app'.tr(),
                          subtitle: 'share_app_sub'.tr(),
                          onTap: () {},
                        ),
                      _ProfileTile(
                        icon: Icons.logout_rounded,
                        title: 'logout'.tr(),
                        subtitle: 'logout_sub'.tr(),
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
                'edit_profile'.tr(),
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

  Widget _buildQuickActions(BuildContext context, String role, dynamic owner) {
    final bool hasInsights = owner?.hasPermission('reports') ?? true;
    final bool hasStock = owner?.hasPermission('stock') ?? true;
    final bool hasStaff = owner?.hasPermission('staff') ?? true;

    if (!hasInsights && !hasStock && !hasStaff) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120.h,
      padding: EdgeInsets.only(top: 24.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          if (hasInsights)
            _QuickActionCard(
              icon: Icons.insights_rounded,
              label: 'insights_quick'.tr(),
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
          if (hasInsights && (hasStock || hasStaff)) SizedBox(width: 12.w),
          if (hasStock)
            _QuickActionCard(
              icon: Icons.inventory_2_rounded,
              label: 'stock_quick'.tr(),
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
          if (hasStock && hasStaff) SizedBox(width: 12.w),
          if (hasStaff)
            _QuickActionCard(
              icon: Icons.people_alt_rounded,
              label: 'staff_quick'.tr(),
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

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      backgroundColor: Colors.white,
      builder: (context) {
        final currentLocale = context.locale.languageCode;
        final languages = [
          {'code': 'en', 'name': 'English', 'native': 'English'},
          {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
          {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
          {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
          {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
        ];

        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'change_language'.tr(),
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'language_sub'.tr(),
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.h),
                  ...languages.map((lang) {
                    final isSelected = currentLocale == lang['code'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.08) : Colors.white,
                        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                              title: Text('change_language_confirm_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
                              content: Text('change_language_confirm_msg'.tr(namedArgs: {'language': lang['native']!})),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: Text('cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                                  child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final newLocale = Locale(lang['code']!);
                            final nav = Navigator.of(context);
                            await context.setLocale(newLocale);
                            nav.pop();
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        leading: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue : AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.language_rounded, color: isSelected ? Colors.white : AppColors.primaryBlue, size: 20.sp),
                        ),
                        title: Text(
                          lang['name']!,
                          style: TextStyle(fontSize: 15.sp, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          lang['native']!,
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                        ),
                        trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 22.sp) : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
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
