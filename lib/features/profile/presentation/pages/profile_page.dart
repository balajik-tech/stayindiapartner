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
import '../../../digilocker/domain/entities/digilocker_credentials.dart';
import '../../../digilocker/presentation/pages/DigiLockerStorage.dart';
import '../../../digilocker/presentation/utils/digilocker_navigator.dart';
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
import 'government_licenses_page.dart';
import 'package:stayindia_owner/features/offers/presentation/pages/offers_management_page.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String _isAddressStored = "";

  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.state is ProfileInitial) {
      profileCubit.loadProfile();
    }
    _checkAddressStored();

  }

  Future<void> _checkAddressStored() async {
    final isStored = await DigiLockerStorage.getAddress();

    if (!mounted) return;

    setState(() {
      _isAddressStored = isStored!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final owner = authState is AuthAuthenticated ? authState.owner : null;
    final role = owner?.role.toLowerCase() ?? 'owner';
    final bool isStaff = role != 'owner' && role != 'manager';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileLoaded
              ? state.profile
              : (state is ProfileUpdateSuccess ? state.profile : null);
          final name = profile?.fullName ?? owner?.name ?? 'Owner';
          final phone = (profile?.phone != null && profile!.phone.trim().isNotEmpty)
              ? '+91 ${profile.phone}'
              : ((owner?.phone != null && owner!.phone.trim().isNotEmpty)
                  ? '+91 ${owner.phone}'
                  : '');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(
                  context,
                  name,
                  phone,
                  profile?.avatar,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildGovernmentLicensesCard(context),
              ),
              SliverToBoxAdapter(
                child: _buildQuickActions(context, role, owner),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!isStaff) ...[
                      _buildGridSection('1. ${'personal_management'.tr()}', [
                        _ProfileCard(
                          icon: Icons.person_rounded,
                          title: 'account_settings'.tr(),
                          iconBgColor: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountSettingsPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.credit_card_rounded,
                          title: 'subscription'.tr(),
                          iconBgColor: const Color(0xFFF0FDF4),
                          iconColor: const Color(0xFF16A34A),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionPage(),
                            ),
                          ),
                        ),
                        // _ProfileCard(
                        //   icon: Icons.stars_rounded,
                        //   title: 'membership_id'.tr() == 'membership_id'
                        //       ? 'Membership ID'
                        //       : 'membership_id'.tr(),
                        //   iconBgColor: const Color(0xFFFEF9C3),
                        //   iconColor: const Color(0xFFCA8A04),
                        //   onTap: () =>
                        //       _showMembershipCard(context, name, phone),
                        // ),
                        // _ProfileCard(
                        //   icon: Icons.card_membership_rounded,
                        //   title: 'digital_certificate'.tr(),
                        //   iconBgColor: const Color(0xFFF5F3FF),
                        //   iconColor: const Color(0xFF7C3AED),
                        //   onTap: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => BlocProvider(
                        //         create: (context) =>
                        //             sl<HostelCubit>()..getHostels(),
                        //         child: const DigitalCertificatePage(),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ]),
                    ] else ...[
                      _buildGridSection('1. ${'personal_management'.tr()}', [
                        _ProfileCard(
                          icon: Icons.person_rounded,
                          title: 'account_settings'.tr(),
                          iconBgColor: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountSettingsPage(),
                            ),
                          ),
                        ),
                      ]),
                    ],

                    if (!isStaff) ...[
                      _buildGridSection('2. ${'hostel_configuration'.tr()}', [
                        _ProfileCard(
                          icon: Icons.business_rounded,
                          title: 'hostel_profile'.tr(),
                          iconBgColor: const Color(0xFFFFF1F2),
                          iconColor: const Color(0xFFE11D48),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HostelProfilePage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.wifi_rounded,
                          title: 'amenities'.tr(),
                          iconBgColor: const Color(0xFFECFDF5),
                          iconColor: const Color(0xFF059669),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AmenitiesPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.rule_rounded,
                          title: 'house_rules'.tr(),
                          iconBgColor: const Color(0xFFFFF7ED),
                          iconColor: const Color(0xFFEA580C),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HouseRulesPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.restaurant_rounded,
                          title: 'food_menu'.tr(),
                          iconBgColor: const Color(0xFFFEF2F2),
                          iconColor: const Color(0xFFDC2626),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FoodMenuPage(),
                            ),
                          ),
                        ),
                      ]),
                    ],

                    // if (!isStaff) ...[
                    //   _buildGridSection('3. ${'business_management'.tr()}', [
                    //     _ProfileCard(
                    //       icon: Icons.insights_rounded,
                    //       title: 'financial_insights'.tr(),
                    //       iconBgColor: const Color(0xFFEFF6FF),
                    //       iconColor: const Color(0xFF2563EB),
                    //       onTap: () => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => BlocProvider(
                    //             create: (context) => sl<FinanceCubit>(),
                    //             child: const FinancialDashboardPage(),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     _ProfileCard(
                    //       icon: Icons.inventory_2_rounded,
                    //       title: 'stock_management'.tr(),
                    //       iconBgColor: const Color(0xFFFAF5FF),
                    //       iconColor: const Color(0xFF9333EA),
                    //       onTap: () => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => BlocProvider(
                    //             create: (context) => sl<StockCubit>(),
                    //             child: const StockDashboardPage(),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     _ProfileCard(
                    //       icon: Icons.people_alt_rounded,
                    //       title: 'staff_management'.tr(),
                    //       iconBgColor: const Color(0xFFF0FDFA),
                    //       iconColor: const Color(0xFF0D9488),
                    //       onTap: () => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => const StaffManagementPage(),
                    //         ),
                    //       ),
                    //     ),
                    //   ]),
                    // ],

                    _buildGridSection('3. ${'support_legal'.tr()}', [
                      _ProfileCard(
                        icon: Icons.language_rounded,
                        title: 'change_language'.tr(),
                        iconBgColor: const Color(0xFFF1F5F9),
                        iconColor: const Color(0xFF475569),
                        onTap: () => _showLanguagePicker(context),
                      ),
                      _ProfileCard(
                        icon: Icons.verified_user_rounded,
                        title: 'privacy_policy'.tr(),
                        iconBgColor: const Color(0xFFECFEFF),
                        iconColor: const Color(0xFF0891B2),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TermsAndConditionsPage(readOnly: true),
                          ),
                        ),
                      ),
                      if (!isStaff) ...[
                        _ProfileCard(
                          icon: Icons.help_center_rounded,
                          title: 'help_support'.tr(),
                          iconBgColor: const Color(0xFFFFFBEB),
                          iconColor: const Color(0xFFD97706),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.chat_bubble_rounded,
                          title: 'feedback'.tr(),
                          iconBgColor: const Color(0xFFFFF1F2),
                          iconColor: const Color(0xFFE11D48),
                          onTap: () {},
                        ),
                      ],
                    ]),

                    if (!isStaff) ...[
                      _buildGridSection('4. ${'tools_reports'.tr()}', [
                        _ProfileCard(
                          icon: Icons.card_giftcard_rounded,
                          title: 'refer_friend'.tr(),
                          iconBgColor: const Color(0xFFFCE7F3),
                          iconColor: const Color(0xFFDB2777),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReferFriendPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.star_rate_rounded,
                          title: 'rate_us'.tr(),
                          iconBgColor: const Color(0xFFFEF9C3),
                          iconColor: const Color(0xFFCA8A04),
                          onTap: () {

                          },
                        ),
                        _ProfileCard(
                          icon: Icons.system_update_rounded,
                          title: 'update_app'.tr(),
                          iconBgColor: const Color(0xFFF0FDF4),
                          iconColor: const Color(0xFF16A34A),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('App is up to date! (v1.0.4)'),
                              ),
                            );
                          },
                        ),
                        _ProfileCard(
                          icon: Icons.campaign_rounded,
                          title: 'send_announcements'.tr(),
                          iconBgColor: const Color(0xFFEFF6FF),
                          iconColor: const Color(0xFF2563EB),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SendAnnouncementsPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.analytics_rounded,
                          title: 'my_reports'.tr(),
                          iconBgColor: const Color(0xFFECFDF5),
                          iconColor: const Color(0xFF059669),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReportsDashboardPage(),
                            ),
                          ),
                        ),
                        _ProfileCard(
                          icon: Icons.local_offer_rounded,
                          title: 'hostel_offers'.tr(),
                          iconBgColor: const Color(0xFFFFF7ED),
                          iconColor: const Color(0xFFEA580C),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OffersManagementPage(),
                            ),
                          ),
                        ),
                      ]),
                    ],

                    _buildGridSection('5. ${'application'.tr()}', [
                      if (!isStaff)
                        _ProfileCard(
                          icon: Icons.share_rounded,
                          title: 'share_app'.tr(),
                          iconBgColor: const Color(0xFFF5F3FF),
                          iconColor: const Color(0xFF7C3AED),
                          onTap: () {},
                        ),
                      _ProfileCard(
                        icon: Icons.logout_rounded,
                        title: 'logout'.tr(),
                        titleColor: AppColors.error,
                        iconBgColor: const Color(0xFFFEF2F2),
                        iconColor: const Color(0xFFDC2626),
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

  Widget _buildGovernmentLicensesCard(BuildContext context) {
    return BouncingWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => sl<HostelCubit>()..getHostels(),
            child: const GovernmentLicensesPage(),
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E3A8A), // Premium Dark Blue
              Color(0xFF3B82F6), // Royal Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                top: -20.h,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -30.w,
                bottom: -30.h,
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '🏛️',
                        style: TextStyle(
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Govt. Licenses & Verifications',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'OFFICIAL',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'FSSAI, Trade License, Police Verification & more',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String phone,
    String? avatar,
  ) {

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                    if (phone.isNotEmpty) ...[
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
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        BouncingWrapper(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountSettingsPage(),
                            ),
                          ),
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
                  ],
                ),
              ),
              SizedBox(width: 6.h),
            ],
          ),
        ),

        if (_isAddressStored.isNotEmpty)
          Positioned(
            top: 70.h,   // Relative to Stack top
            right: 35.w, // Relative to Stack right
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFF4CAF50),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    color: const Color(0xFF2E7D32),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Verified",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffManagementPage(),
                ),
              ),
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
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withValues(alpha: 0.85),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGridSection(String label, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        SizedBox(height: 8.h),
        GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.3,
          children: children,
        ),
        SizedBox(height: 28.h),
      ],
    );
  }

  void _showMembershipCard(BuildContext context, String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFBF953F),
                Color(0xFFFCF6BA),
                Color(0xFFB38728),
                Color(0xFFFBF5B7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFFFFD700),
                      size: 48.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'GOLDEN PG STATUS',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFB38728),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'MEMBERSHIP ID',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF475569),
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'SI-OWNER-${phone.replaceAll("+91 ", "").replaceAll(" ", "")}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFFB38728),
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Verified Stay India Premium Partner',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFFFD700),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: const Text(
                        'Awesome',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
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
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'language_sub'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ...languages.map((lang) {
                    final isSelected = currentLocale == lang['code'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.border.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              title: Text(
                                'change_language_confirm_title'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              content: Text(
                                'change_language_confirm_msg'.tr(
                                  namedArgs: {'language': lang['native']!},
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: Text('cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryBlue,
                                  ),
                                  child: Text(
                                    'confirm'.tr(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.language_rounded,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryBlue,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          lang['native']!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryBlue,
                                size: 22.sp,
                              )
                            : null,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'logout_confirm_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('logout_confirm_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'logout'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) context.read<AuthCubit>().logout();
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconBgColor;
  final Color? iconColor;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryBlue,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.border,
              size: 16.sp,
            ),
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

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      scaleFactor: 0.96,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentOrange, size: 24.sp),
            SizedBox(height: 6.h),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
