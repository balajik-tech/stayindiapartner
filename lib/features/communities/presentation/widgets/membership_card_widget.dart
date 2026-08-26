import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../razorpay/presentation/bloc/razorpay_cubit.dart';
import '../../../razorpay/presentation/bloc/razorpay_state.dart';
import '../../../razorpay/presentation/screens/razorpay_payment_screen.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';
import '../cubit/association_membership_cubit.dart';
import '../../domain/entities/association_membership_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

enum MembershipStatus { newUser, applied, approved, paid, renewalDue, expired }

class MembershipCardWidget extends StatefulWidget {
  final CommunityThemeEntity theme;
  final String? portalId;

  const MembershipCardWidget({super.key, required this.theme, this.portalId});

  @override
  State<MembershipCardWidget> createState() => _MembershipCardWidgetState();
}

class _MembershipCardWidgetState extends State<MembershipCardWidget> {
  MembershipStatus? _previewStatus;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(MembershipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portalId != widget.portalId) {
      _initData();
    }
  }

  void _initData() {
    final portalId = _getPortalId();
    if (portalId.isNotEmpty) {
      context.read<AssociationMembershipCubit>().loadMembershipData(portalId);
    }
  }

  String _getPortalId() {
    if (widget.portalId != null && widget.portalId!.trim().isNotEmpty) {
      return widget.portalId!.trim();
    }
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded &&
        profileState.profile.associationId != null &&
        profileState.profile.associationId!.trim().isNotEmpty) {
      return profileState.profile.associationId!.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();

    return BlocBuilder<AssociationMembershipCubit, AssociationMembershipState>(
      builder: (context, state) {
        if (state is AssociationMembershipLoading) {
          return Container(
            margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            padding: EdgeInsets.all(20.w),
            height: 200.h,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        AssociationMembershipEntity? membership;
        List<MembershipPropertyEntity> eligibleProperties = [];
        MembershipStatus membershipStatus = MembershipStatus.newUser;

        if (state is AssociationMembershipLoaded) {
          membership = state.membership;
          eligibleProperties = state.eligibleProperties;
          membershipStatus = _previewStatus ?? _mapStatusString(state.status, membership?.timeline, expiredAt: membership?.validUntil);
        }

        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(accent, membershipStatus),
              if (membershipStatus == MembershipStatus.newUser) ...[
                SizedBox(height: 8.h),
                Text(
                  '${eligibleProperties.isNotEmpty ? eligibleProperties.length : 5} properties are listed on your account. Choose which of them to register — applications are reviewed by the association before the membership fee becomes payable.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              _buildStatusProgress(membershipStatus, membership?.timeline),
              SizedBox(height: 8.h),
              _buildContent(membershipStatus, membership, state is AssociationMembershipLoaded ? state.paymentDetails : null),
              SizedBox(height: 20.h),
              _buildFooter(accent, membershipStatus, membership),
              SizedBox(height: 8.h),
              // _buildPreviewToggles(membershipStatus),
            ],
          ),
        );
      },
    );
  }

  MembershipStatus _mapStatusString(String statusStr, Map<String, dynamic>? timeline, {DateTime? expiredAt}) {
    statusStr = statusStr.toUpperCase().trim();

    // Check expiry logic first if we have the date
    if (expiredAt != null) {
      final now = DateTime.now();
      final difference = expiredAt.difference(now).inDays;

      if (difference < 0) {
        return MembershipStatus.expired;
      } else if (difference <= 28) {
        return MembershipStatus.renewalDue;
      }
    }

    if (statusStr == 'EXPIRED' || statusStr == 'LAPSED') {
      return MembershipStatus.expired;
    } else if (statusStr == 'RENEWAL_DUE') {
      return MembershipStatus.renewalDue;
    } else if (timeline != null) {
      if (timeline['idIssued'] == true ||
          timeline['paid'] == true ||
          statusStr == 'PAID' ||
          statusStr == 'ACTIVE') {
        return MembershipStatus.paid;
      } else if (timeline['approved'] == true ||
          statusStr == 'APPROVED' ||
          statusStr == 'PAYMENT_PENDING') {
        return MembershipStatus.approved;
      } else if (timeline['applied'] == true ||
          statusStr == 'PENDING_APPROVAL' ||
          statusStr == 'APPLIED') {
        return MembershipStatus.applied;
      }
    } else {
      if (statusStr == 'PAID' || statusStr == 'ACTIVE') {
        return MembershipStatus.paid;
      } else if (statusStr == 'APPROVED' || statusStr == 'PAYMENT_PENDING') {
        return MembershipStatus.approved;
      } else if (statusStr == 'PENDING_APPROVAL' || statusStr == 'APPLIED') {
        return MembershipStatus.applied;
      }
    }
    return MembershipStatus.newUser;
  }

  Widget _buildHeader(Color accent, MembershipStatus status) {
    String title = '';
    String? badgeText;
    Color? badgeColor;
    Color? textColor = Colors.white;
    Color? smallCircleColor = accent;

    final profileState = context.watch<ProfileCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    String userFirstName = '';
    String userFullName = '';

    if (profileState is ProfileLoaded) {
      userFirstName = profileState.profile.firstName.trim();
      userFullName = profileState.profile.fullName.trim();
    } else if (authState is AuthAuthenticated) {
      userFullName = authState.owner.name.trim();
      userFirstName = userFullName.split(' ').first;
    }

    switch (status) {
      case MembershipStatus.newUser:
        title = 'Join the Welfare Association';
        break;
      case MembershipStatus.applied:
        title = 'Thank you, $userFirstName';
        badgeText = 'Pending approval';
        badgeColor = const Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor = Colors.black;
        break;
      case MembershipStatus.approved:
        title = 'Application approved';
        badgeText = 'Payment pending';
        badgeColor = const Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor = Colors.black;
        break;
      case MembershipStatus.paid:
      case MembershipStatus.renewalDue:
        title = status == MembershipStatus.paid
            ? "You're a member"
            : userFullName;
        badgeText = 'Active';
        badgeColor = widget.theme.accentColor.toColor().withValues(alpha: 0.2);
        break;
      case MembershipStatus.expired:
        title = userFullName;
        badgeText = 'Expired';
        badgeColor = Colors.white.withValues(alpha: 0.2);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBERSHIP',
          style: GoogleFonts.inter(
            color: accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (badgeText != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 4.r,
                  backgroundColor: status == MembershipStatus.expired
                      ? Colors.white
                      : smallCircleColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusProgress(MembershipStatus status, Map<String, dynamic>? timeline) {
    int currentStep = 0;
    if (timeline != null) {
      if (timeline['idIssued'] == true) {
        currentStep = 4;
      } else if (timeline['paid'] == true) {
        currentStep = 3;
      } else if (timeline['approved'] == true) {
        currentStep = 2;
      } else if (timeline['applied'] == true) {
        currentStep = 1;
      } else {
        currentStep = 0;
      }
    } else {
      switch (status) {
        case MembershipStatus.newUser:
          currentStep = 0;
          break;
        case MembershipStatus.applied:
          currentStep = 1;
          break;
        case MembershipStatus.approved:
          currentStep = 2;
          break;
        case MembershipStatus.paid:
        case MembershipStatus.renewalDue:
        case MembershipStatus.expired:
          currentStep = 4;
          break;
      }
    }

    final List<String> steps = ['APPLIED', 'APPROVED', 'PAID', 'ID ISSUED'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Positioned(
            top: 8.h,
            left: 30.w,
            right: 30.w,
            child: Container(
              height: 2.h,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          if (currentStep > 0)
            Positioned(
              top: 8.h,
              left: 30.w,
              width:
                  (MediaQuery.of(context).size.width - 152.w) *
                  (currentStep / 4),
              child: Container(
                height: 2.h,
                color: widget.theme.accentColor.toColor(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final stepIndex = index + 1;
              final isCompleted = currentStep >= stepIndex;
              final isCurrent = currentStep == stepIndex;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? widget.theme.accentColor.toColor()
                          : (isCurrent ? Colors.white : const Color(0xFF1E3A68)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? widget.theme.accentColor.toColor()
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : Text(
                              '$stepIndex',
                              style: GoogleFonts.inter(
                                color: isCurrent
                                    ? AppColors.primaryBlue
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    steps[index],
                    style: GoogleFonts.inter(
                      color: isCompleted ? Colors.white : Colors.white30,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MembershipStatus status, AssociationMembershipEntity? membership, MembershipPaymentDetailsEntity? paymentDetails) {
    switch (status) {
      case MembershipStatus.newUser:
        return _NewUserMembershipView(
          theme: widget.theme,
          onRequestToJoin: () => _showRequestToJoinSheet(context),
        );
      case MembershipStatus.applied:
        return _AppliedMembershipView(
          theme: widget.theme,
          membership: membership,
        );
      case MembershipStatus.approved:
        return _ApprovedMembershipView(
          theme: widget.theme,
          membership: membership,
          onPay: () => _showPayMembershipSheet(membership, paymentDetails),
        );
      case MembershipStatus.paid:
        return _ActiveMembershipView(
          theme: widget.theme,
          membership: membership,
        );
      case MembershipStatus.renewalDue:
        return _RenewalDueMembershipView(
          theme: widget.theme,
          membership: membership,
          onRenew: () => _showRenewMembershipSheet(membership, paymentDetails),
        );
      case MembershipStatus.expired:
        return _ExpiredMembershipView(
          theme: widget.theme,
          membership: membership,
          onRenew: () => _showRenewMembershipSheet(membership, paymentDetails),
        );
    }
  }

  Widget _buildFooter(Color accent, MembershipStatus status, AssociationMembershipEntity? membership) {
    if (status == MembershipStatus.newUser ||
        status == MembershipStatus.applied) {
      final appRef = membership?.applicationReference ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white12),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status == MembershipStatus.newUser
                        ? 'Questions before you join?'
                        : 'Need to check on your application?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    status == MembershipStatus.newUser
                        ? 'Talk to the membership desk about eligibility, fees or documents.'
                        : 'Quote reference $appRef when you call.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              OutlinedButton.icon(
                onPressed: () => _makePhoneCall('+919840012345'),
                icon: Icon(
                  Icons.phone,
                  color: accent,
                  size: 12.sp,
                ),
                label: Text(
                  status == MembershipStatus.newUser
                        ? 'Call +91 98400 12345'
                        : 'Call desk',
                  style: GoogleFonts.inter(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: accent.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 6.h,
                  ),
                ),
              ),
            ],
          )
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPreviewToggles(MembershipStatus currentStatus) {
    return Column(
      children: [
        const Divider(color: Colors.white12),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PREVIEW',
                style: GoogleFonts.inter(
                  color: Colors.white24,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 16.w),
              _previewButton('Active', MembershipStatus.paid, currentStatus),
              _previewButton('Renewal due', MembershipStatus.renewalDue, currentStatus),
              _previewButton('Lapsed', MembershipStatus.expired, currentStatus),
              _previewButton('New user', MembershipStatus.newUser, currentStatus),
              _previewButton('Applied', MembershipStatus.applied, currentStatus),
              _previewButton('Approved', MembershipStatus.approved, currentStatus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewButton(String label, MembershipStatus status, MembershipStatus currentStatus) {
    final isSelected = currentStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: () => setState(() {
          _previewStatus = status;
        }),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected
                ? widget.theme.accentColor.toColor()
                : Colors.white54,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            decoration: isSelected ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  void _showRequestToJoinSheet(BuildContext context) {

    final profileState = context.read<ProfileCubit>().state;

    bool? isKYCVerified;
    if (profileState is ProfileLoaded) {
      isKYCVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
      debugPrint('isKYCVerified: $isKYCVerified');
    }

    if ( isKYCVerified == null || !isKYCVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your KYC verification'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationPage(initialIndex: 4),
        ),
            (route) => false,
      );

      return;
    }

    final cubit = context.read<AssociationMembershipCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: _RequestToJoinSheet(
          theme: widget.theme,
          portalId: _getPortalId(),
        ),
      ),
    );
  }

  void _showPayMembershipSheet(AssociationMembershipEntity? membership, MembershipPaymentDetailsEntity? paymentDetails) {
    if (membership == null) return;
    final cubit = context.read<AssociationMembershipCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: _PayMembershipSheet(
          theme: widget.theme,
          membership: membership,
          paymentDetails: paymentDetails,
          portalId: _getPortalId(),
        ),
      ),
    );
  }

  void _showRenewMembershipSheet(AssociationMembershipEntity? membership, MembershipPaymentDetailsEntity? paymentDetails) {
    if (membership == null) return;
    final cubit = context.read<AssociationMembershipCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: _PayMembershipSheet(
          theme: widget.theme,
          membership: membership,
          paymentDetails: paymentDetails,
          portalId: _getPortalId(),
          isRenewal: true,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

class _NewUserMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final VoidCallback onRequestToJoin;

  const _NewUserMembershipView({
    required this.theme,
    required this.onRequestToJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        _ActionButton(
          label: 'Request to join',
          icon: Icons.person_outline,
          theme: theme,
          onPressed: onRequestToJoin,
        ),
      ],
    );
  }
}

class _AppliedMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;

  const _AppliedMembershipView({
    required this.theme,
    this.membership,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();

    String appRef = '';
    String submittedDate = '';
    List<String> propertyNames = const [
    ];
    List<String> propertyLocations = const [
    ];
    int count = 0;

    if (membership != null) {
      appRef = membership!.applicationReference ?? appRef;
      if (membership!.submittedAt != null) {
        submittedDate = _formatDate(membership!.submittedAt);
      }
      if (membership!.properties.isNotEmpty) {
        count = membership!.properties.length;
        propertyNames = membership!.properties.map((p) => p.name).toList();
        propertyLocations = membership!.properties.map((p) => p.location).toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBox(
          label: 'APPLICATION REFERENCE',
          value: appRef,
          subValue: submittedDate,
          icon: Icons.calendar_today_outlined,
          theme: theme,
        ),
        SizedBox(height: 16.h),
        if(count != 0)...[
          _PropertySummaryBox(
            count: count,
            properties: propertyNames,
            locations: propertyLocations,
            theme: theme,
          )
        ],
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.only(left: 12.w),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accent, width: 2)),
          ),
          child: Text(
            'The association verifies your details and property registration, usually within three working days. Once approved, the membership fee becomes payable and your membership ID is issued after payment.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Submitted ${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Submitted ${date.toString()}';
    }
  }
}

class _ApprovedMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;
  final VoidCallback onPay;

  const _ApprovedMembershipView({
    required this.theme,
    this.membership,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
    final appRef = membership?.applicationReference ?? '';
    final approvedDate = _formatApprovedDate(membership?.approvedAt);
    final totalFee = membership?.totalFee ?? 0;
    final feeText = _formatAmount(totalFee);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBox(
          label: 'APPLICATION REFERENCE',
          value: appRef,
          subValue: approvedDate,
          icon: Icons.check_circle_outline,
          accent: accent,
          theme: theme,
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.only(left: 12.w),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accent, width: 2)),
          ),
          child: Text(
            'Your membership ID is generated once the annual fee is paid. Payment is handled by the association\'s secure payment gateway.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        _ActionButton(
          label: 'Pay membership · $feeText',
          icon: Icons.account_balance_wallet_outlined,
          theme: theme,
          onPressed: onPay,
        ),
      ],
    );
  }

  static String _formatApprovedDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Approved ${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Approved ${date.toString()}';
    }
  }

  static String _formatAmount(dynamic amount) {
    if (amount == null) return '';
    final numVal = num.tryParse(amount.toString());
    if (numVal == null) return '₹$amount';
    final str = numVal.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return '₹${buffer.toString()}';
  }
}

class _ActiveMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;

  const _ActiveMembershipView({
    required this.theme,
    this.membership,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
    final memId = membership?.membershipId ?? '';
    final expiry = membership?.expiredAt;
    final validUntil = membership?.validUntil;
    final whatsappLink = membership?.whatsappLink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12.w),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accent, width: 2)),
          ),
          child: Text(
            'Your membership ID has been issued. Use the WhatsApp button beside it to get your certificate and receipt.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        _MembershipIdBox(
          id: memId,
          validUntil: validUntil != null
              ? 'Valid until ${_RenewalDueMembershipView._formatExpiryDate(validUntil)}'
              : '',
          theme: theme,
          whatsappLink: whatsappLink,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _RenewalDueMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;
  final VoidCallback onRenew;

  const _RenewalDueMembershipView({
    required this.theme,
    this.membership,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

    final now = DateTime.now();
    final expiry = membership?.expiredAt ?? now.add(const Duration(days: 28));
    // final validUntil = membership?.validUntil ?? now.add(const Duration(days: 28));
    // final daysRemaining = validUntil.difference(now).inDays;

    final validUntil = membership?.validUntil ??
        now.add(const Duration(days: 28));

    final today = DateTime(now.year, now.month, now.day);
    final validUntilDate = DateTime(
      validUntil.year,
      validUntil.month,
      validUntil.day,
    );

    final daysRemaining = validUntilDate.difference(today).inDays;


    final totalFee = membership?.totalFee ?? 0;
    final feeText = _ApprovedMembershipView._formatAmount(totalFee);
    final memId = membership?.membershipId ?? '';
    final whatsappLink = membership?.whatsappLink ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'MEMBER SINCE',
                value: _formatDate(membership?.approvedAt) ?? '',
                subValue: 'Chennai',
                theme: theme,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryItem(
                label: 'PROPERTIES',
                value: '${membership?.properties.length ?? 0} registered',
                subValue: membership?.properties.isNotEmpty == true
                    ? membership!.properties.first.name
                    : 'N/A',
                theme: theme,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _MembershipIdBox(
          id: memId,
          validUntil: 'Valid until ${_formatExpiryDate(validUntil)}',
          theme: theme,
          whatsappLink: whatsappLink,
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Renewal due in $daysRemaining days',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Renew early to keep your ID active without a break.',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onRenew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Renew · $feeText',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  static String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatExpiryDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _ExpiredMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;
  final VoidCallback onRenew;

  const _ExpiredMembershipView({
    required this.theme,
    this.membership,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

    final totalFee = membership?.totalFee ?? 2000;
    final feeText = _ApprovedMembershipView._formatAmount(totalFee);
    final memId = membership?.membershipId ?? '';
    final expiry = membership?.expiredAt;
    final whatsappLink = membership?.whatsappLink ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'MEMBER SINCE',
                value: _RenewalDueMembershipView._formatDate(membership?.approvedAt) ?? '',
                subValue: 'Chennai',
                theme: theme,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryItem(
                label: 'PROPERTIES',
                value: '${membership?.properties.length ?? 0} registered',
                subValue: membership?.properties.isNotEmpty == true
                    ? membership!.properties.first.name
                    : 'N/A',
                theme: theme,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _MembershipIdBox(
          id: memId,
          validUntil: expiry != null
              ? 'Lapsed on ${_RenewalDueMembershipView._formatExpiryDate(expiry)}'
              : '',
          isExpired: true,
          theme: theme,
            whatsappLink: whatsappLink
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your membership has lapsed',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Renew to reactivate your ID and member benefits.',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onRenew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Renew · $feeText',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// Reusable Components
class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color? accent;
  final CommunityThemeEntity theme;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    this.accent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: theme.accentColor.toColor().withValues(alpha: 0.6),
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(icon, color: accent ?? Colors.white54, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                subValue,
                style: GoogleFonts.inter(
                  color: accent ?? Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertySummaryBox extends StatelessWidget {
  final int count;
  final List<String> properties;
  final List<String> locations;
  final CommunityThemeEntity theme;

  const _PropertySummaryBox({
    required this.count,
    required this.properties,
    required this.locations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count PROPERTIES SUBMITTED',
            style: GoogleFonts.inter(
              color: theme.accentColor.toColor().withValues(alpha: 0.6),
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            separatorBuilder: (_, __) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(color: Colors.white12, height: 1),
            ),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    properties[index],
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    locations[index],
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MembershipIdBox extends StatelessWidget {
  final String id;
  final String validUntil;
  final bool isExpired;
  final String? whatsappLink;
  final CommunityThemeEntity theme;

  const _MembershipIdBox({
    required this.id,
    required this.whatsappLink,
    required this.validUntil,
    this.isExpired = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEMBERSHIP ID',
                  style: GoogleFonts.inter(
                    color: theme.accentColor.toColor().withValues(alpha: 0.6),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  id,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                if (validUntil.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: isExpired ? Colors.white54 : Colors.white70,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        validUntil,
                        style: GoogleFonts.inter(
                          color: isExpired ? Colors.white54 : Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await shareMembershipIdViaWhatsApp(
                // membershipId: id,
                whatsappLink: whatsappLink!,
              );
            },
            borderRadius: BorderRadius.circular(50.r),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/whatsapp_iconn.png',
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> shareMembershipIdViaWhatsApp({
    // required String membershipId,
    required String whatsappLink,
  }) async {
    final message =
        'Hello, my Membership ID is . '
        'Please share my membership certificate and receipt.';

    final encodedMessage = Uri.encodeComponent(message);

    final whatsappUrl = Uri.parse(
      whatsappLink,
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not open WhatsApp');
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final CommunityThemeEntity theme;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.subValue,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: theme.accentColor.toColor().withValues(alpha: 0.6),
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subValue,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final CommunityThemeEntity theme;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: theme.primaryColor.toColor(), size: 16.sp),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: theme.primaryColor.toColor(),
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor.toColor(),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18.sp),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _TextLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white54,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white30,
        ),
      ),
    );
  }
}

class _RequestToJoinSheet extends StatefulWidget {
  final CommunityThemeEntity theme;
  final String? portalId;
  final List<Map<String, dynamic>>? initialProperties;

  const _RequestToJoinSheet({
    required this.theme,
    this.portalId,
    this.initialProperties,
  });

  @override
  State<_RequestToJoinSheet> createState() => _RequestToJoinSheetState();
}

class _RequestToJoinSheetState extends State<_RequestToJoinSheet> {
  late List<MembershipPropertyEntity> _properties;
  late List<bool> _selected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _properties = [];
    _selected = [];
    final state = context.read<AssociationMembershipCubit>().state;
    if (state is AssociationMembershipLoaded) {
      _properties = state.eligibleProperties;
      _selected = List.generate(_properties.length, (index) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final selectedCount = _selected.where((s) => s).length;
    final profileState = context.watch<ProfileCubit>().state;
    final authState = context.watch<AuthCubit>().state;

    String userName = '';
    String userPhone = '';
    String userInitials = '';

    if (profileState is ProfileLoaded) {
      final p = profileState.profile;
      userName = p.fullName.trim();
      userPhone = p.phone.trim().startsWith('+') ? p.phone.trim() : '+91 ${p.phone.trim()}';
      
      String ini = '';
      if (p.firstName.trim().isNotEmpty) ini += p.firstName.trim()[0].toUpperCase();
      if (p.lastName.trim().isNotEmpty) ini += p.lastName.trim()[0].toUpperCase();
      userInitials = ini;
    } else if (authState is AuthAuthenticated) {
      userName = authState.owner.name.trim();
      userPhone = authState.owner.phone.trim().startsWith('+') 
          ? authState.owner.phone.trim() 
          : '+91 ${authState.owner.phone.trim()}';
      
      final parts = userName.split(' ');
      if (parts.isNotEmpty) {
        String ini = parts.first[0].toUpperCase();
        if (parts.length > 1) {
          ini += parts.last[0].toUpperCase();
        }
        userInitials = ini;
      }
    }

    return BlocListener<AssociationMembershipCubit, AssociationMembershipState>(
      listener: (context, state) {
        if (state is AssociationMembershipLoaded) {
          if (state.membership != null && state.status != 'NEW_USER') {
            Navigator.pop(context, state.membership);
          }
        } else if (state is AssociationMembershipError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
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
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.home_outlined, color: accent, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Request to join',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18.sp, color: primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: primary,
                    child: Text(
                      userInitials,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          userPhone,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'YOUR ACCOUNT',
                      style: GoogleFonts.inter(
                        color: accent,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROPERTIES TO REGISTER',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_properties.isNotEmpty)
                  InkWell(
                    onTap: () {
                      setState(() {
                        final allSelected = _selected.every((s) => s);
                        for (var i = 0; i < _selected.length; i++) {
                          _selected[i] = !allSelected;
                        }
                      });
                    },
                    child: Text(
                      _selected.every((s) => s) ? 'Deselect all' : 'Select all',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              )
            else if (_properties.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Center(
                  child: Text(
                    'No eligible properties found',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final p = _properties[index];
                    final isSelected = _selected[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selected[index] = !isSelected;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0x336FA641) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? accent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                color: isSelected ? accent : Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: isSelected ? accent : Colors.grey.shade300,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16.sp,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (p.location.isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      p.location,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      p.type,
                                      style: GoogleFonts.inter(
                                        color: primary,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (selectedCount > 0)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                child: Text(
                  '$selectedCount of ${_properties.length} selected',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (selectedCount > 0)
                    ? () {
                        final List<String> propertyIds = [];
                        for (int i = 0; i < _selected.length; i++) {
                          if (_selected[i]) {
                            propertyIds.add(_properties[i].id);
                          }
                        }
                        context.read<AssociationMembershipCubit>().submit(
                          widget.portalId ?? '',
                          propertyIds,
                        );
                      }
                    : () {
                  final List<String> propertyIds = [];
                  context.read<AssociationMembershipCubit>().submit(
                    widget.portalId ?? '',
                    propertyIds,
                  );
                },
                icon: Icon(
                  Icons.check,
                  color: primary,
                  size: 14.sp,
                ),
                label: Text(
                  selectedCount >= 0
                      ? 'Submit application · $selectedCount ${selectedCount == 1 ? 'property' : 'properties'}'
                      : 'Submit application',
                  style: GoogleFonts.inter(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  disabledBackgroundColor: accent.withValues(alpha: 0.5),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your name and mobile number come from your account. The application goes to the association for approval — no fee is payable until it is approved.',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: AppColors.greyText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();
        return Row(
          children: List.generate(
            dashCount,
            (_) => Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(
                width: dashWidth,
                height: 1,
                color: Colors.white24,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PayMembershipSheet extends StatefulWidget {
  final CommunityThemeEntity theme;
  final AssociationMembershipEntity? membership;
  final MembershipPaymentDetailsEntity? paymentDetails;
  final String portalId;
  final bool isRenewal;

  const _PayMembershipSheet({
    required this.theme,
    this.membership,
    this.paymentDetails,
    required this.portalId,
    this.isRenewal = false,
  });

  @override
  State<_PayMembershipSheet> createState() => _PayMembershipSheetState();
}

class _PayMembershipSheetState extends State<_PayMembershipSheet> {
  @override
  void initState() {
    super.initState();
    // Refresh details if they are missing or if we want to ensure latest
    if (widget.paymentDetails == null && widget.membership != null) {
      context.read<AssociationMembershipCubit>().refreshPaymentDetails(widget.membership!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final profileState = context.watch<ProfileCubit>().state;
    final authState = context.watch<AuthCubit>().state;

    String? memberName = '';
    if (profileState is ProfileLoaded) {
      memberName = profileState.profile.dlKyc?.name?.trim();
      if (memberName == null || memberName.isEmpty) {
        memberName = profileState.profile.fullName.trim();
      }
    }

    if (memberName == null || memberName.isEmpty) {
      if (authState is AuthAuthenticated) {
        memberName = authState.owner.name.trim();
      }
    }

    return BlocBuilder<AssociationMembershipCubit, AssociationMembershipState>(
      builder: (context, state) {
        MembershipPaymentDetailsEntity? details = widget.paymentDetails;
        if (state is AssociationMembershipLoaded && state.paymentDetails != null) {
          details = state.paymentDetails;
        }

        final appRef = details?.applicationReference ??
            widget.membership?.applicationReference ??
            '';
        final propCount = details?.properties.toString() ??
            widget.membership?.properties.length.toString() ??
            '1';
        final double totalFeeValue =
        (details != null && details.totalFee > 0)
            ? details.totalFee
            : (details != null && details.amount > 0)
            ? details.amount
            : (widget.membership?.totalFee ?? 0);

        final feeText = _ApprovedMembershipView._formatAmount(totalFeeValue);
        final validUntil = details != null
            ? _formatValidUntil(details.validForMonths)
            : '';

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
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
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.home_outlined, color: accent, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.isRenewal ? 'Renew membership' : 'Pay membership',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.sp, color: primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRow('Member', memberName!),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    _buildRow('Application', appRef),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    _buildRow('Properties', propCount),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    _buildRow('Plan', 'Annual membership'),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    _buildRow('Valid until', validUntil),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount payable',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          feeText,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1E3A68),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final cubit = context.read<AssociationMembershipCubit>();
                    final profileState = context.read<ProfileCubit>().state;
                    final authState = context.read<AuthCubit>().state;
                    String email = '';
                    String mobile = '';

                    if (profileState is ProfileLoaded) {
                      email = profileState.profile.email;
                      mobile = profileState.profile.phone;
                    } else if (authState is AuthAuthenticated) {
                      email = authState.owner.email ?? '';
                      mobile = authState.owner.phone;
                    }
                    final portalId = widget.portalId;
                    final membershipId = widget.membership!.id;
                    final bool isRenewal = widget.isRenewal;

                    final Map<String, dynamic>? order;
                    if (isRenewal) {
                      order = await cubit.generateRenewalOrder(membershipId);
                    } else {
                      order = await cubit.generatePaymentOrder(membershipId);
                    }

                    if (order != null && mounted) {
                      _navigateToRazorpay(
                        context,
                        amount: (order['amount'] as num).toDouble() / 100,
                        planName: 'Association Membership',
                        orderId: order['orderId'].toString(),
                        portalId: portalId,
                        email: email,
                        mobile: mobile,
                        customApiKey: order['keyId']?.toString(),
                      );
                    }
                  },
                  icon: Icon(Icons.credit_card, color: primary, size: 18.sp),
                  label: Text(
                    '${widget.isRenewal ? 'Renew' : 'Pay'} $feeText',
                    style: GoogleFonts.inter(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'You\'ll be redirected to a secure payment gateway (UPI / card / net-banking). Your membership ID is generated once payment succeeds, and the digital certificate is sent to your WhatsApp number. This preview does not process real payments.',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.greyText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValidUntil(int months) {
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month + months, now.day);
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${expiry.day} ${monthNames[expiry.month - 1]} ${expiry.year}';
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey.shade500,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _navigateToRazorpay(
    BuildContext context, {
    required double amount,
    required String planName,
    required String orderId,
    required String portalId,
    String? email,
    String? mobile,
    String? customApiKey,
  }) {
    // Razorpay expects amount in paise
    final int totalAmountToPay = (amount * 100).round();
    final cubit = context.read<AssociationMembershipCubit>();
    final navigator = Navigator.of(context);

    debugPrint("========== Razorpay Request ==========${ApiConstants.razorpayKey}");

    navigator.push(
      MaterialPageRoute(
        builder: (_) => RazorpayPaymentScreen(
          apiKey: ApiConstants.razorpayKey,
          amount: totalAmountToPay,
          name: planName,
          orderId: orderId,
          description: 'Payment for $planName',
          email: email ?? '',
          contact: mobile ?? '',
          onSuccess: (result) {
            debugPrint('========== Razorpay Success ==========');
            debugPrint('Payment ID : ${result.paymentId}');
            debugPrint('Order ID   : ${result.orderId}');
            debugPrint('Signature  : ${result.signature}');
            debugPrint('======================================');

            // Call verify-payment API
            cubit.verifyPayment(
              portalId: portalId,
              orderId: result.orderId ?? '',
              paymentId: result.paymentId ?? '',
              signature: result.signature ?? '',
            );

            // Pop RazorpayPaymentScreen
            navigator.pop();

            // Pop the bottom sheet (which was behind the Razorpay screen)
            if (navigator.canPop()) {
              navigator.pop(true);
            }
          },
          onFailure: (message) {
            debugPrint('========== Razorpay Failure ==========');
            debugPrint('Error: $message');
            debugPrint('=====================================');

            // Pop RazorpayPaymentScreen
            navigator.pop();

            // Pop the bottom sheet
            if (navigator.canPop()) {
              navigator.pop(true);
            }

            if (message.trim().isNotEmpty || message != 'undefined') {
              ScaffoldMessenger.of(navigator.context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
