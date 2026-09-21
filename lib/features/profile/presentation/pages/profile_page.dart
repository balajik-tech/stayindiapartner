import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:stayindia_owner/features/finance/presentation/pages/financial_dashboard_page.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/app_bootstrapper.dart';
import '../../../bank_account/presentation/pages/bank_accounts_page.dart';
import '../../../finance/presentation/cubit/payment_report_cubit.dart';
import '../../../finance/presentation/pages/payment_report_page.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../domain/entities/hostel.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/hostel_state.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/share_app_bottom_sheet.dart';
import 'account_settings_page.dart';
import 'help_support_page.dart';
import 'subscription_page.dart';
import 'hostel_profile_page.dart';
import 'amenities_page.dart';
import 'house_rules_page.dart';
import 'food_menu_page.dart';
import 'hostel_configuration_page.dart';
import 'package:stayindia_owner/features/auth/presentation/pages/terms_and_conditions_page.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/request_service_page.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/my_requests_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  ProfileEntity? _cachedProfile;
  List<Hostel>? _cachedHostels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    _refreshData();
  }

  void _refreshData() {
    if (mounted) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated || authState is AuthProfileCompleted) {
        context.read<ProfileCubit>().loadProfile(force: true);
        context.read<HostelCubit>().getHostels(forceRefresh: true);
        context.read<NotificationCubit>().fetchNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final owner = authState is AuthAuthenticated ? authState.owner : null;
    final role = owner?.role.toLowerCase() ?? 'owner';
    final bool isStaff = role != 'owner' && role != 'manager';
    
    final hostelState = context.watch<HostelCubit>().state;
    if (hostelState is HostelLoaded) {
      _cachedHostels = hostelState.hostels;
    }

    int totalPending = 0;
    int hostelCount = 0;
    int totalBeds = 0;
    
    final hostels = _cachedHostels;
    if (hostels != null) {
      hostelCount = hostels.length;
      for (var h in hostels) {
        totalBeds += h.totalBeds ?? 0;
        totalPending += h.pendingItemsCount ?? 0;
        if (!(h.hasBankAccount ?? false)) totalPending++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _cachedProfile = state.profile;
          } else if (state is ProfileUpdateSuccess) {
            _cachedProfile = state.profile;
          }
          
          final profile = _cachedProfile;
          final name = (profile?.dlKyc?.name?.trim().isNotEmpty == true)
              ? profile!.dlKyc!.name!.trim()
              : (((profile?.firstName?.trim().isNotEmpty == true) ||
                        (profile?.lastName?.trim().isNotEmpty == true))
                    ? '${profile?.lastName ?? ''} ${profile?.firstName ?? ''} '
                          .trim()
                    : (owner?.name ?? ''));

          final phone =
              (profile?.phone != null && profile!.phone.trim().isNotEmpty)
              ? '+91 ${profile.phone}'
              : ((owner?.phone != null && owner!.phone.trim().isNotEmpty)
                    ? '+91 ${owner.phone}'
                    : '');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildAccountHeader(context),
              ),
              SliverToBoxAdapter(
                child: _buildProfileCard(
                  context,
                  name,
                  phone,
                  profile?.avatar,
                  profile?.dlKyc?.isAadharVerified,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 24.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!isStaff) ...[
                      _MenuSection(
                        title: 'business'.tr(),
                        children: [
                          _MenuTile(
                            icon: Icons.workspace_premium_rounded,
                            imagePath: 'assets/images/profile_management.png',
                            title: 'management_plans'.tr(),
                            subtitle: hostelCount == 1
                                ? 'management_plan_subtitle_single'.tr(
                              namedArgs: {'count': hostelCount.toString()},
                            )
                                : 'management_plans_subtitle'.tr(
                              namedArgs: {'count': hostelCount.toString()},
                            ),
                            iconBgColor: const Color(0xFFEEEDFE),
                            iconColor: const Color(0xFF3C3489),
                            // badge: const _StatusBadge(
                            //   text: '1 renews in 11 days',
                            //   color: Color(0xFF92400E),
                            //   bgColor: Color(0xFFFEF3C7),
                            // ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionPage(),
                              ),
                            ),
                          ),
                          _MenuTile(
                            icon: Icons.bar_chart_outlined,
                            imagePath: 'assets/images/profile_financial.png',
                            title: 'financial_insights'.tr(),
                            subtitle: 'financial_insights_desc'.tr(),
                            iconBgColor: const Color(0xFFE6F1FB),
                            iconColor: const Color(0xFF185FA5),
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
                          _MenuTile(
                            icon: Icons.history_rounded,
                            title: 'collection'.tr(),
                            imagePath: 'assets/images/profile_collection.png',
                            subtitle: 'collection_desc'.tr(),
                            iconBgColor: const Color(0xFFFAEEDA),
                            iconColor: const Color(0xFF854F0B),
                            // badge: _StatusBadge(
                            //   text: 'pending_count'.tr(namedArgs: {'count': '4'}),
                            //   color: Color(0xFFB91C1C),
                            //   bgColor: Color(0xFFFEE2E2),
                            // ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => sl<PaymentReportCubit>(),
                                  child: const PaymentReportPage(),
                                ),
                              ),
                            ),
                          ),
                          _MenuTile(
                            icon: Icons.account_balance_rounded,
                            title: 'bank_accounts'.tr(),
                            imagePath: 'assets/images/profile_bankaccount.png',
                            subtitle: 'bank_accounts_desc'.tr(),
                            iconBgColor: const Color(0xFFE1F5EE),
                            iconColor: const Color(0xFF0F6E56),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BankAccountsPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                        child: Text(
                          'hostel_configuration'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      _HostelConfigCard(
                        propertiesCount: hostelCount,
                        bedsCount: totalBeds,
                        pendingCount: totalPending,
                        pendingItems: totalPending > 0 ? 'pending_count'.tr(namedArgs: {'count': totalPending.toString()}) : 'all_set'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HostelConfigurationPage(),
                          ),
                        ),
                      ),
                    ],

                    _ReferralCard(
                      onTap: () => _showBottomSheetOnce(context, () async {
                        final referralId = await context
                            .read<ProfileCubit>()
                            .generateReferral();
                        if (!context.mounted) return;
                        await ShareAppBottomSheet.show(
                          context,
                          shareLink: referralId != null
                              ? '${ApiConstants.partnerAppLink}?ref=$referralId'
                              : ApiConstants.partnerAppLink,
                        );
                      }),
                    ),

                    _MenuSection(
                      title: 'support_legal'.tr(),
                      children: [
                        _MenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'help_support'.tr(),
                          subtitle: 'help_support_desc'.tr(),
                          iconBgColor: const Color(0xFFFAEEDA),
                          iconColor: const Color(0xFF854F0B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportPage(),
                            ),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.language_rounded,
                          title: 'change_language'.tr(),
                          subtitle: 'language_name'.tr(),
                          iconBgColor: const Color(0xFFE1F5EE),
                          iconColor: const Color(0xFF0F6E56),
                          onTap: () => _showLanguagePicker(context),
                        ),
                        _MenuTile(
                          icon: Icons.security,
                          title: 'privacy_policy'.tr(),
                          subtitle: 'privacy_policy_desc'.tr(),
                          imagePath: 'assets/images/profile_privacy.png',
                          iconBgColor: const Color(0xFFEEEDFE),
                          iconColor: const Color(0xFF3C3489),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsAndConditionsPage(readOnly: true),
                            ),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.info_outline_rounded,
                          title: 'about_stay_india'.tr(),
                          iconBgColor: const Color(0xFFE6F1FB),
                          iconColor: const Color(0xFF185FA5),
                          onTap: () => {
                            _openUrl(ApiConstants.ABOUT_US)
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),
                    _buildFooter(context),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }



  Widget _buildAccountHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'account'.tr(),
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  // border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B54A4),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'rewards'.tr(),
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF7A8699),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              BouncingWrapper(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, notificationState) {
                    final int unreadCount = notificationState is NotificationLoaded
                        ? notificationState.unreadCount
                        : 0;

                    return Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: const Color(0xFF16294D),
                            size: 20.sp,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: AppColors.orangeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String name,
    String phone,
    String? avatar,
    bool? isAaadharVerified,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1B54A4),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B54A4).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CustomAvatar(
            imageUrl: ApiConstants.getImageUrl(avatar),
            name: name,
            size: 56.0,
            isCircle: true,
            fontSize: 20.sp,
            backgroundColor:Color(0xFFe8f1fa)
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color(0xFFB5D4F4).withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: isAaadharVerified == true ? Color(0xFF059669) : Colors.red,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isAaadharVerified == true ? 'ekyc_verified'.tr() : 'ekyc_pending'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:  isAaadharVerified == true ? Color(0xFF059669): Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 13, color: const Color(0xFF1B54A4)),
                  SizedBox(width: 4.w),
                  Text(
                    'edit'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B54A4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ElevatedButton(
            onPressed: () => _handleLogout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C599D),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'logout'.tr(),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 8.w),
                const Icon(Icons.logout_rounded, size: 20),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: OutlinedButton(
            onPressed: () => _handleDeactivateAccount(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA32D2D),
              side: const BorderSide(color: Color(0xFFE24B4A)),
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor:  Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'delete_account'.tr(),
                  style: TextStyle(color:Color(0xFFA32D2D),fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 8.w),
                Image.asset('assets/images/profile_delete.png', width: 16,height: 16),
              ],
            ),
          ),
        ),
        // SizedBox(height: 32.h),
        // Text(
        //   'follow_stay_india'.tr(),
        //   style: TextStyle(
        //     fontSize: 12.sp,
        //     color: const Color(0xFF94A3B8),
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     _SocialIcon(icon: Icons.facebook, color: const Color(0xFF1877F2)),
        //     SizedBox(width: 20.w),
        //     _SocialIcon(icon: Icons.camera_alt, color: const Color(0xFFE4405F)),
        //     SizedBox(width: 20.w),
        //     _SocialIcon(icon: Icons.play_arrow_rounded, color: const Color(0xFFFF0000)),
        //   ],
        // ),
        SizedBox(height: 24.h),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final info = snapshot.data!;

            return Text(
              '${ApiConstants.environment} • v${info.version} (${info.buildNumber})',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF9AA5B4),
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        SizedBox(height: 80.h),
      ],
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

  void _handleDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'delete_account'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.error,
          ),
        ),
        content: Text('delete_account_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'delete_permanently'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AuthCubit>().deleteAccount();
    }
  }

  void _handleDeactivateAccount(BuildContext context) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 4.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        title: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFEAB308),
              size: 44.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Account Options',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage your StayIndia account and properties.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF0f0f0f),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),

            _DeactivateOptionTile(
              title: 'DEACTIVATE PROPERTIES ONLY',
              subtitle:
                  'Remove all your property listings from the platform. Your account and user profile will remain active.',
              icon: Icons.business_rounded,
              color: const Color(0xFF102d44),
              bgColor: const Color(0xFFe7edf9),
              onTap: () => Navigator.pop(context, 'PROPERTIES'),
            ),

            SizedBox(height: 16.h),

            _DeactivateOptionTile(
              title: 'DEACTIVATE ACCOUNT PERMANENTLY',
              subtitle:
                  'Your account, user profile, and all property listings will be permanently deactivated. This action is irreversible.',
              icon: Icons.person_remove_rounded,
              color: const Color(0xFF4a1d19),
              bgColor: const Color(0xFFfceadf),
              onTap: () => Navigator.pop(context, 'ACCOUNT'),
            ),
            SizedBox(height: 8.h),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: const Color(0xFF4d4762),
              ),
            ),
          ),
        ],
      ),
    );

    if (action != null && context.mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 4.h),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          title: Text(
            'confirm_deactivation'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.error,
            ),
          ),
          content: Text(
            'confirm_deactivation_message'.tr(namedArgs: {'action': action}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(
                'confirm'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        try {
          await context.read<ProfileCubit>().deactivateAccount(action);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deactivation successful.'),
                backgroundColor: Colors.green,
              ),
            );

            context.read<AuthCubit>().logout();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    }
  }

  bool _isBottomSheetInProgress = false;

  Future<void> _showBottomSheetOnce(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    if (_isBottomSheetInProgress) return;

    _isBottomSheetInProgress = true;

    try {
      await action();
    } catch (e, stackTrace) {
      debugPrint('Bottom sheet error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isBottomSheetInProgress = false;
    }
  }
}

class _DeactivateOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _DeactivateOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.blackColor,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _MenuSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16294D),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Container(padding:EdgeInsets.symmetric(horizontal: 16),child: _buildDashedDivider())

              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildDashedDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 0,
        bottom: 0,
      ),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: CustomPaint(
          painter: DashedDividerPainter(
            color: Color(0xFFdfe5ee),
            dashWidth: 5,
            dashSpace: 4,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color iconBgColor;
  final Color iconColor;
  final Widget? badge;
  final bool showChevron;
  final bool isDestructive;
  final String? imagePath;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.iconBgColor,
    required this.iconColor,
    this.badge,
    this.imagePath="",
    this.showChevron = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child:imagePath.toString().isNotEmpty ?
                Image.asset(imagePath.toString(),width: 18,height: 18):
                Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDestructive ? Colors.red : const Color(0xFF16294D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF7A8699),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC6D9EE)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF1B54A4),
                  size: 16.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const _StatusBadge({
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _HostelConfigCard extends StatelessWidget {
  final int propertiesCount;
  final int bedsCount;
  final String pendingItems;
  final int pendingCount;
  final VoidCallback onTap;

  const _HostelConfigCard({
    required this.propertiesCount,
    required this.bedsCount,
    required this.pendingItems,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg = const Color(0xFFE6F4EA);
    Color statusText = const Color(0xFF1E8E3E);

    if (pendingCount > 0) {
      statusBg = pendingCount == 1 ? const Color(0xFFFEF7E0) : const Color(0xFFFEF2F2);
      statusText = pendingCount == 1 ? const Color(0xFFB45309) : const Color(0xFFB91C1C);
    }

    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: pendingCount > 0 ? statusBg : const Color(0xFFF0D5A8)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset('assets/images/profile_hostel.png', width: 22,height: 22),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'properties_count'.tr(namedArgs: {'count': propertiesCount.toString()})} - ${'beds_count'.tr(namedArgs: {'count': bedsCount.toString()})}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16294D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'hostel_config_desc'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if(pendingItems.isNotEmpty)
                    Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      pendingItems,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC6D9EE)),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF1B54A4),
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ReferralCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFB7E4C6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F7E8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset('assets/images/profile_gift.png', width: 18,height: 18),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'refer_friend'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'refer_friend_desc'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Text(
                  //   'refer_friend_stats'.tr(namedArgs: {'joined': '2', 'earned': '₹1,000'}),
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w400,
                  //     color: const Color(0xFF1B7A3D),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC6D9EE)),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF1B54A4),
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

