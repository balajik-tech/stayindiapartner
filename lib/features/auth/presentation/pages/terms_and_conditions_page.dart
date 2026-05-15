import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final bool readOnly;
  /// If provided, called after policy is successfully accepted instead of
  /// the default Navigator.pop behaviour. Use this when the page is pushed
  /// with pushAndRemoveUntil and there is no page to pop back to.
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
              const SnackBar(
                content: Text('Service agreement accepted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            if (widget.onAccepted != null) {
              widget.onAccepted!();
            } else if (widget.readOnly) {
              Navigator.pop(context);
            } else {
              // Shown post-registration: navigate to dashboard, clearing all routes.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationPage()),
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
                  children: [
                    _buildContent(),
                    _buildScrollIndicator(),
                  ],
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
                  'Service Agreement',
                  style: GoogleFonts.dmSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Master Service Agreement & Privacy Policy',
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
        _buildSectionTitle('Welcome to Stay India!'),
        _buildSectionBody(
            'By using our app, you agree to the following terms and conditions. Stay India is a technology platform (SaaS) providing services across the country.'),
        SizedBox(height: 32.h),
        _buildPolicySection('1. Pan-India Services', 
            'Stay India is an advanced software platform providing its services all over India. PG owners and residents from any part of the country can utilize our digital services.'),
        _buildPolicySection('2. SaaS & Limitation of Liability', 
            'We are strictly a Software as a Service (SaaS) provider and act only as a bridge between PG owners and residents.\n\n• Physical Facilities: Stay India is not responsible for the quality of furniture, room conditions, or any physical assets within the PG.\n\n• Food Quality: The company does not take responsibility for the quality, taste, or menu of the food provided at the PG. Residents must verify this personally.'),
        _buildPolicySection('3. Data Privacy & Security', 
            'Your personal information is highly secure with us.\n\n• Collection: We collect details like your name, phone number, and Aadhaar card for verification purposes only.\n\n• Protection: We do not sell your personal data. It remains confidential and will only be shared if required by law.'),
        _buildPolicySection('4. Payments & Methods', 
            '• Payment Process: Residents shall pay rent directly to the PG owner using the QR code, Debit/Credit Card, Internet Banking, or other online payment methods available on the platform.\n\n• Liability: Stay India is not responsible for any transaction failures, payment disputes, or refund issues. These must be settled between the resident and the owner.'),
        _buildPolicySection('5. Tenant Conduct & Damage', 
            '• Discipline: Stay India is not involved in disputes arising from residents violating PG rules, late entries, or personal conflicts with owners.\n\n• Property Damage: Any damage caused by residents to the PG furniture or property is a private matter between the resident and the owner. The app is not liable for any compensation.'),
        _buildPolicySection('6. App Support & Customer Care', 
            '• Software Issues: If the app is slow or if any feature is not functioning correctly, you can immediately contact our customer care for technical support.\n\n• Assistance: For any technical help related to the software, please call our support number: +91 9888936836. Our team is ready to assist you.'),
        _buildPolicySection('7. Validity & Changes', 
            'This agreement remains valid as long as you use the app. Any future changes to these terms will be notified through the app. Until then, the current terms shall apply.'),
        
        SizedBox(height: 16.h),
        Divider(color: Colors.grey.shade200),
        SizedBox(height: 24.h),
        
        _buildSectionTitle('Contact Us'),
        SizedBox(height: 12.h),
        _buildContactRow(Icons.email_outlined, 'support@stayindia.in'),
        SizedBox(height: 8.h),
        _buildContactRow(Icons.phone_outlined, '+91 9888936836'),
        
        SizedBox(height: 32.h),
        Text(
          'Last updated: May 2024',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            color: AppColors.greyText.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primaryBlue),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
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
      child: Container(
        width: 3.w,
        color: Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
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
                      color: _isAccepted ? AppColors.primaryBlue : Colors.grey.shade300,
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
                    'I have read and I agree to follow all the Rules and Regulations mentioned above.',
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
                    color: _isAccepted ? AppColors.primaryBlue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: _isAccepted ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ] : null,
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
                            'Accept & Continue',
                            style: GoogleFonts.dmSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: _isAccepted ? Colors.white : Colors.grey.shade500,
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
