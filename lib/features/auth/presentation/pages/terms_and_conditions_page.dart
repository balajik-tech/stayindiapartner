import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final bool readOnly;
  final VoidCallback? onAccepted;

  const TermsAndConditionsPage({
    super.key,
    this.readOnly = false,
    this.onAccepted,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isAccepted = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.readOnly,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && state.owner.hasAcceptedPolicy) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  StringUtils.translate(
                    'agreement_accepted_msg',
                    context: context,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            if (widget.onAccepted != null) {
              widget.onAccepted!();
            } else if (widget.readOnly) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationPage(),
                ),
                (route) => false,
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [_buildContent(), _buildScrollIndicator()],
                ),
              ),
              if (!widget.readOnly) _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.readOnly)
            BouncingWrapper(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringUtils.translate(
                    'service_agreement_title',
                    context: context,
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  StringUtils.translate(
                    'master_service_agreement_subtitle',
                    context: context,
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
      children: [
        _buildSectionTitle(
          StringUtils.translate('welcome_stay_india', context: context),
        ),
        _buildSectionBody(
          StringUtils.translate('welcome_stay_india_desc', context: context),
        ),
        SizedBox(height: 32.h),
        _buildPolicySection(
          StringUtils.translate('pan_india_services_title', context: context),
          StringUtils.translate('pan_india_services_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('saas_liability_title', context: context),
          StringUtils.translate('saas_liability_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('data_privacy_title', context: context),
          StringUtils.translate('data_privacy_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('payments_methods_title', context: context),
          StringUtils.translate('payments_methods_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('tenant_conduct_title', context: context),
          StringUtils.translate('tenant_conduct_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('app_support_title', context: context),
          StringUtils.translate('app_support_desc', context: context),
        ),
        _buildPolicySection(
          StringUtils.translate('validity_changes_title', context: context),
          StringUtils.translate('validity_changes_desc', context: context),
        ),

        SizedBox(height: 16.h),
        Divider(color: Colors.grey.shade200),
        SizedBox(height: 24.h),

        _buildSectionTitle(
          StringUtils.translate('contact_us_title', context: context),
        ),
        SizedBox(height: 12.h),
        _buildContactRow(
          Icons.email_outlined,
          'support@stayindia.in',
          Uri(scheme: 'mailto', path: 'support@stayindia.in'),
        ),
        SizedBox(height: 8.h),
        _buildContactRow(
          Icons.phone_outlined,
          '+91 9888936836',
          Uri(scheme: 'tel', path: '+919888936836'),
        ),

        SizedBox(height: 32.h),
        Text(
          StringUtils.translate(
            'last_updated',
            namedArgs: {'date': 'May 2024'},
            context: context,
          ),
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            color: AppColors.greyText.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  /// Tapping opens the mail app / dialer.
  Widget _buildContactRow(IconData icon, String text, Uri uri) {
    return InkWell(
      onTap: () => launchUrl(uri),
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primaryBlue),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          SizedBox(height: 8.h),
          _buildSectionBody(content),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
      ),
    );
  }

  Widget _buildSectionBody(String body) {
    return Text(
      body,
      style: GoogleFonts.dmSans(
        fontSize: 14.sp,
        color: AppColors.greyText,
        height: 1.6,
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(width: 3.w, color: Colors.grey.withValues(alpha: 0.05)),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        16.h,
        24.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isAccepted = !_isAccepted),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    color: _isAccepted ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _isAccepted
                          ? AppColors.primaryBlue
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: _isAccepted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    StringUtils.translate(
                      'agree_terms_checkbox',
                      context: context,
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return BouncingWrapper(
                onTap: (_isAccepted && !isLoading)
                    ? () => context.read<AuthCubit>().acceptPolicy()
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: _isAccepted
                        ? AppColors.primaryBlue
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: _isAccepted
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            StringUtils.translate(
                              'accept_continue_button',
                              context: context,
                            ),
                            style: GoogleFonts.dmSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: _isAccepted
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
