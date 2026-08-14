import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

import 'join_association_sheet.dart';

enum MembershipStatus {
  newUser,
  applied,
  approved,
  paid,
  renewalDue,
  expired
}

class MembershipCardWidget extends StatefulWidget {
  final CommunityThemeEntity theme;
  const MembershipCardWidget({super.key, required this.theme});

  @override
  State<MembershipCardWidget> createState() => _MembershipCardWidgetState();
}

class _MembershipCardWidgetState extends State<MembershipCardWidget> {
  MembershipStatus _status = MembershipStatus.newUser;

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();

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
          _buildHeader(accent),
          if (_status == MembershipStatus.newUser) ...[
            SizedBox(height: 8.h),
            Text(
              '5 properties are listed on your account. Choose which of them to register — applications are reviewed by the association before the membership fee becomes payable.',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 24.h),
          _buildStatusProgress(),
          SizedBox(height: 8.h),
          _buildContent(),
          SizedBox(height: 20.h),
          _buildFooter(accent),
          SizedBox(height: 16.h),
          _buildPreviewToggles(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    String title = '';
    String? badgeText;
    Color? badgeColor;
    Color? textColor = Colors.white;
    Color? smallCircleColor = accent;
    Color? progressNumberCirlceColor = Color(0xFF1E3A68);

    switch (_status) {
      case MembershipStatus.newUser:
        title = 'Join the Welfare Association';
        break;
      case MembershipStatus.applied:
        title = 'Thank you, Ramesh';
        badgeText = 'Pending approval';
        badgeColor =  Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor =  Colors.black;
        break;
      case MembershipStatus.approved:
        title = 'Application approved';
        badgeText = 'Payment pending';
        badgeColor =  Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor =  Colors.black;
        break;
      case MembershipStatus.paid:
      case MembershipStatus.renewalDue:
        title = _status == MembershipStatus.paid ? "You're a member" : "Ramesh Kumar";
        badgeText = 'Active';
        badgeColor = widget.theme.accentColor.toColor().withValues(alpha: 0.2);
        break;
      case MembershipStatus.expired:
        title = 'Ramesh Kumar';
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
                  backgroundColor: _status == MembershipStatus.expired ? Colors.white : smallCircleColor,
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

  Widget _buildStatusProgress() {
    int currentStep = 0;
    switch (_status) {
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

    final List<String> steps = ['APPLIED', 'APPROVED', 'PAID', 'ID ISSUED'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
              width: (MediaQuery.of(context).size.width - 152.w) * (currentStep / 4),
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
                          : (isCurrent ? Colors.white : Color(0xFF1E3A68)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? widget.theme.accentColor.toColor() : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : Text(
                              '$stepIndex',
                              style: GoogleFonts.inter(
                                color: isCurrent ? AppColors.primaryBlue : Colors.white,
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

  Widget _buildContent() {
    switch (_status) {
      case MembershipStatus.newUser:
        return _NewUserMembershipView(
          theme: widget.theme,
          onRequestToJoin: _showRequestToJoinSheet,
        );
      case MembershipStatus.applied:
        return _AppliedMembershipView(theme: widget.theme);
      case MembershipStatus.approved:
        return _ApprovedMembershipView(
          theme: widget.theme,
          onPay: _showPayMembershipSheet,
        );
      case MembershipStatus.paid:
        return _ActiveMembershipView(theme: widget.theme);
      case MembershipStatus.renewalDue:
        return _RenewalDueMembershipView(theme: widget.theme);
      case MembershipStatus.expired:
        return _ExpiredMembershipView(theme: widget.theme);
    }
  }

  Widget _buildFooter(Color accent) {
    if (_status == MembershipStatus.newUser || _status == MembershipStatus.applied) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white12),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                flex: 6, // 60%
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status == MembershipStatus.newUser
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
                      _status == MembershipStatus.newUser
                          ? 'Talk to the membership desk about eligibility, fees or documents.'
                          : 'Quote reference TNIT-APP-2026-5170 when you call.',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              Expanded(
                flex: 4, // 40%
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall('+919840012345'),
                  icon: Icon(
                    Icons.phone,
                    color: accent,
                    size: 12.sp,
                  ),
                  label: Text(
                    _status == MembershipStatus.newUser
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
              ),
            ],
          ),
          // if (_status == MembershipStatus.applied) ...[
          //   SizedBox(height: 24.h),
          //   Center(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         _TextLink(
          //           label: 'Admin demo: approve this application',
          //           onTap: () => setState(() => _status = MembershipStatus.approved),
          //         ),
          //         SizedBox(width: 24.w),
          //         _TextLink(
          //           label: 'Reset preview',
          //           onTap: () => setState(() => _status = MembershipStatus.newUser),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
        ],
      );
    }

    // if (_status == MembershipStatus.approved) {
    //   return Center(
    //     child: _TextLink(
    //       label: 'Reset preview',
    //       onTap: () => setState(() => _status = MembershipStatus.newUser),
    //     ),
    //   );
    // }

    return const SizedBox.shrink();
  }

  Widget _buildPreviewToggles() {
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
              _previewButton('Active', MembershipStatus.paid),
              _previewButton('Renewal due', MembershipStatus.renewalDue),
              _previewButton('Lapsed', MembershipStatus.expired),
              _previewButton('New user', MembershipStatus.newUser),
              _previewButton('Applied', MembershipStatus.applied),
              _previewButton('Approved', MembershipStatus.approved),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewButton(String label, MembershipStatus status) {
    final isSelected = _status == status;
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: () => setState(() => _status = status),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? widget.theme.accentColor.toColor() : Colors.white54,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            decoration: isSelected ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  void _showRequestToJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestToJoinSheet(theme: widget.theme),
    ).then((submitted) {
      if (submitted == true) {
        setState(() {
          _status = MembershipStatus.applied;
        });
      }
    });
  }

  void _showPayMembershipSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PayMembershipSheet(theme: widget.theme),
    ).then((paid) {
      if (paid == true) {
        setState(() {
          _status = MembershipStatus.paid;
        });
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

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
  const _AppliedMembershipView({required this.theme});

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBox(
          label: 'APPLICATION REFERENCE',
          value: 'TNIT-APP-2026-5170',
          subValue: 'Submitted 14 Aug 2026',
          icon: Icons.calendar_today_outlined,
          theme: theme,
        ),
        SizedBox(height: 16.h),
        _PropertySummaryBox(
          count: 2,
          properties: const ['Sri Balaji Men\'s Hostel', 'Balaji Ladies Hostel'],
          locations: const ['Guindy, Chennai', 'Velachery, Chennai'],
          theme: theme,
        ),
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
}

class _ApprovedMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  final VoidCallback onPay;

  const _ApprovedMembershipView({
    required this.theme,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBox(
          label: 'APPLICATION REFERENCE',
          value: 'TNIT-APP-2026-3623',
          subValue: 'Approved 14 Aug 2026',
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
          label: 'Pay membership · ₹2,000',
          icon: Icons.account_balance_wallet_outlined,
          theme: theme,
          onPressed: onPay,
        ),
      ],
    );
  }
}

class _ActiveMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _ActiveMembershipView({required this.theme});

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
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
          id: 'TNIT-MEM-2026-1614',
          validUntil: '14 Aug 2027',
          theme: theme,
        ),
        SizedBox(height: 16.h),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'View ID card',
        //         icon: Icons.visibility_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'Download',
        //         icon: Icons.download_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 16.h),
        // Center(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       _TextLink(label: 'Membership timeline'),
        //       SizedBox(width: 24.w),
        //       _TextLink(label: 'Preview what is sent'),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class _RenewalDueMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _RenewalDueMembershipView({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'MEMBER SINCE',
                value: '13 Sept 2025',
                subValue: 'Chennai',
                theme: theme,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryItem(
                label: 'PROPERTIES',
                value: '3 registered',
                subValue: 'Sri Balaji Men\'s Hostel +2',
                theme: theme,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _MembershipIdBox(
          id: 'TNIT-MEM-2025-8842',
          validUntil: '11 Sept 2026',
          theme: theme,
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
                      'Renewal due in 28 days',
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                child: Text(
                  'Renew · ₹2,000',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'View ID card',
        //         icon: Icons.visibility_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'Download',
        //         icon: Icons.download_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _ExpiredMembershipView extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _ExpiredMembershipView({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'MEMBER SINCE',
                value: '15 Jun 2025',
                subValue: 'Chennai',
                theme: theme,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryItem(
                label: 'PROPERTIES',
                value: '3 registered',
                subValue: 'Sri Balaji Men\'s Hostel +2',
                theme: theme,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _MembershipIdBox(
          id: 'TNIT-MEM-2024-5501',
          validUntil: 'Expired 04 Jul 2026',
          isExpired: true,
          theme: theme,
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                child: Text(
                  'Renew · ₹2,000',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'View ID card',
        //         icon: Icons.visibility_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _OutlineButton(
        //         label: 'Download',
        //         icon: Icons.download_outlined,
        //         onPressed: () {},
        //       ),
        //     ),
        //   ],
        // ),
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
  final CommunityThemeEntity theme;

  const _MembershipIdBox({
    required this.id,
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:  Image.asset(
              'assets/images/whatsapp_iconn.png',
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
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
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11.sp,
            ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
  const _RequestToJoinSheet({required this.theme});

  @override
  State<_RequestToJoinSheet> createState() => _RequestToJoinSheetState();
}

class _RequestToJoinSheetState extends State<_RequestToJoinSheet> {
  final List<Map<String, dynamic>> _properties = [
    {
      'name': 'Sri Balaji Men\'s Hostel',
      'location': 'Guindy, Chennai · 120 beds',
      'type': 'MEN\'S HOSTEL',
      'selected': false
    },
    {
      'name': 'Balaji Ladies Hostel',
      'location': 'Velachery, Chennai · 86 beds',
      'type': 'WORKING WOMEN\'S HOSTEL',
      'selected': false
    },
    {
      'name': 'BK Co-living',
      'location': 'Sholinganallur, Chennai · 64 beds',
      'type': 'CO-LIVING PG',
      'selected': false
    },
    {
      'name': 'Sri Balaji Students PG',
      'location': 'Peelamedu, Coimbatore · 48 beds',
      'type': 'STUDENTS\' PG',
      'selected': false
    },
    {
      'name': 'Balaji Service Suites',
      'location': 'RS Puram, Coimbatore · 22 beds',
      'type': 'SERVICE APARTMENT',
      'selected': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final selectedCount = _properties.where((p) => p['selected']).length;

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
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
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
                    'RK',
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
                        'Ramesh Kumar',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '+91 9840012345',
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
              InkWell(
                onTap: () {
                  setState(() {
                    final allSelected = _properties.every((p) => p['selected']);
                    for (var p in _properties) {
                      p['selected'] = !allSelected;
                    }
                  });
                },
                child: Text(
                  _properties.every((p) => p['selected']) ? 'Deselect all' : 'Select all',
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
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final p = _properties[index];
                final isSelected = p['selected'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      p['selected'] = !isSelected;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0x336FA641)  : Colors.white,
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
                            ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                            : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                p['location'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  p['type'],
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
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                '$selectedCount of ${_properties.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0 ? () => Navigator.pop(context, true) : null,
              icon: Icon(Icons.check, color: selectedCount > 0 ? primary : primary, size: 14.sp),
              label: Text(
                selectedCount > 0 ? 'Submit application · $selectedCount properties' : 'Submit application',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
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
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            dashCount,
            (_) => Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(width: dashWidth, height: 1, color: Colors.white24),
            ),
          ),
        );
      },
    );
  }
}

class _PayMembershipSheet extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _PayMembershipSheet({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

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
                  'Pay membership',
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
                _buildRow('Member', 'Ramesh Kumar'),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                _buildRow('Application', 'TNIT-APP-2026-4557'),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                _buildRow('Properties', '1'),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                _buildRow('Plan', 'Annual membership'),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                _buildRow('Valid until', '14 Aug 2027'),
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
                      '₹2,000',
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
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(Icons.credit_card, color: primary, size: 18.sp),
              label: Text(
                'Pay ₹2,000',
                style: GoogleFonts.inter(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
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
}
