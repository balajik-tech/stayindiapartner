import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../injection_container.dart';
import '../../../../core/utils/logger.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../razorpay/presentation/bloc/razorpay_cubit.dart';
import '../../../razorpay/presentation/bloc/razorpay_state.dart';
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
  MembershipStatus _status = MembershipStatus.newUser;
  List<Map<String, dynamic>> _eligibleProperties = [];
  List<Map<String, dynamic>> _selectedProperties = [];
  Map<String, dynamic>? _membershipData;

  @override
  void initState() {
    super.initState();
    _fetchEligibleProperties();
  }

  Future<void> _fetchEligibleProperties() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get(ApiConstants.associationEligibleProperties);
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        List<dynamic> rawList = [];
        if (resData is Map) {
          if (resData['data'] is Map && resData['data']['properties'] is List) {
            rawList = resData['data']['properties'] as List;
          } else if (resData['properties'] is List) {
            rawList = resData['properties'] as List;
          } else if (resData['data'] is List) {
            rawList = resData['data'] as List;
          }
        }
        final properties = rawList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final address = map['address']?.toString().trim() ?? '';
          final city = map['city']?.toString().trim() ?? '';
          final locationParts = [
            if (address.isNotEmpty) address,
            if (city.isNotEmpty) city,
          ];
          final location = locationParts.isNotEmpty
              ? locationParts.join(', ')
              : 'Chennai';

          final hostelType = map['hostel_type']?.toString();
          final propertyTag = map['propertyTag']?.toString();

          return {
            '_id': map['_id']?.toString() ?? map['id']?.toString() ?? '',
            'name': map['name']?.toString() ?? '',
            'address': address,
            'city': city,
            'hostel_type': hostelType,
            'propertyTag': propertyTag,
            'location': location,
            'type': _formatPropertyType(hostelType, propertyTag),
            'selected': false,
            'isActive': map['isActive'] ?? true,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _eligibleProperties = properties;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch eligible properties: $e');
    }
  }

  static String _formatPropertyType(String? hostelType, String? propertyTag) {
    final typeStr = (hostelType ?? '').toLowerCase().trim();
    if (typeStr == 'men' || typeStr == 'boys' || typeStr == 'male') {
      return "MEN'S HOSTEL";
    } else if (typeStr == 'women' || typeStr == 'girls' || typeStr == 'female') {
      return "WORKING WOMEN'S HOSTEL";
    } else if (typeStr == 'co-living' || typeStr == 'coliving') {
      return "CO-LIVING PG";
    } else if (typeStr == 'students' || typeStr == 'student') {
      return "STUDENTS' PG";
    }
    if (propertyTag != null && propertyTag.trim().isNotEmpty) {
      final tagStr = propertyTag.trim().toUpperCase();
      if (tagStr == 'BOYS' || tagStr == 'MEN') return "MEN'S HOSTEL";
      if (tagStr == 'GIRLS' || tagStr == 'WOMEN') return "WORKING WOMEN'S HOSTEL";
      if (tagStr == 'PG') return "PG HOSTEL";
      return tagStr;
    }
    return "HOSTEL";
  }

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
              '${_eligibleProperties.isNotEmpty ? _eligibleProperties.length : 5} properties are listed on your account. Choose which of them to register — applications are reviewed by the association before the membership fee becomes payable.',
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

    final profileState = context.read<ProfileCubit>().state;
    String userFirstName = 'Ramesh';
    String userFullName = 'Ramesh Kumar';
    if (profileState is ProfileLoaded) {
      if (profileState.profile.firstName.trim().isNotEmpty) {
        userFirstName = profileState.profile.firstName.trim();
      }
      if (profileState.profile.fullName.trim().isNotEmpty) {
        userFullName = profileState.profile.fullName.trim();
      }
    }

    switch (_status) {
      case MembershipStatus.newUser:
        title = 'Join the Welfare Association';
        break;
      case MembershipStatus.applied:
        title = 'Thank you, $userFirstName';
        badgeText = 'Pending approval';
        badgeColor = Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor = Colors.black;
        break;
      case MembershipStatus.approved:
        title = 'Application approved';
        badgeText = 'Payment pending';
        badgeColor = Color(0xFFD3E0ED).withValues(alpha: 0.82);
        textColor = Colors.black;
        smallCircleColor = Colors.black;
        break;
      case MembershipStatus.paid:
      case MembershipStatus.renewalDue:
        title = _status == MembershipStatus.paid
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
                  backgroundColor: _status == MembershipStatus.expired
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
                          : (isCurrent ? Colors.white : Color(0xFF1E3A68)),
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

  Widget _buildContent() {
    switch (_status) {
      case MembershipStatus.newUser:
        return _NewUserMembershipView(
          theme: widget.theme,
          onRequestToJoin: _showRequestToJoinSheet,
        );
      case MembershipStatus.applied:
        return _AppliedMembershipView(
          theme: widget.theme,
          membership: _membershipData,
          selectedProperties:
              _selectedProperties.isNotEmpty ? _selectedProperties : null,
        );
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
    if (_status == MembershipStatus.newUser ||
        _status == MembershipStatus.applied) {
      final appRef = _membershipData?['applicationReference']?.toString() ??
          'TNIT-APP-2026-5170';
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
            ],
          )
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

  void _showRequestToJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestToJoinSheet(
        theme: widget.theme,
        portalId: widget.portalId,
        initialProperties: _eligibleProperties,
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _status = MembershipStatus.applied;
          if (result is Map<String, dynamic>) {
            _membershipData = result;
          } else if (result is List<Map<String, dynamic>>) {
            _selectedProperties = result;
          }
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
  final Map<String, dynamic>? membership;
  final List<Map<String, dynamic>>? selectedProperties;

  const _AppliedMembershipView({
    required this.theme,
    this.membership,
    this.selectedProperties,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();

    String appRef = 'TNIT-APP-2026-5170';
    String submittedDate = 'Submitted 14 Aug 2026';
    List<String> propertyNames = const [
      'Sri Balaji Men\'s Hostel',
      'Balaji Ladies Hostel',
    ];
    List<String> propertyLocations = const [
      'Guindy, Chennai',
      'Velachery, Chennai',
    ];
    int count = 2;

    if (membership != null) {
      if (membership!['applicationReference'] != null &&
          membership!['applicationReference'].toString().isNotEmpty) {
        appRef = membership!['applicationReference'].toString();
      }
      if (membership!['submittedAt'] != null) {
        submittedDate = _formatDate(membership!['submittedAt']);
      }
      if (membership!['properties'] is List &&
          (membership!['properties'] as List).isNotEmpty) {
        final propsList = membership!['properties'] as List;
        count = propsList.length;
        propertyNames = propsList
            .map((p) => p is Map ? (p['name']?.toString() ?? '') : '')
            .where((n) => n.isNotEmpty)
            .toList();
        propertyLocations = propsList.map((p) {
          if (p is Map) {
            final addr = p['address']?.toString().trim() ?? '';
            final city = p['city']?.toString().trim() ?? '';
            final parts = [
              if (addr.isNotEmpty) addr,
              if (city.isNotEmpty) city,
            ];
            return parts.isNotEmpty ? parts.join(', ') : 'Chennai';
          }
          return 'Chennai';
        }).toList();
      }
    } else if (selectedProperties != null && selectedProperties!.isNotEmpty) {
      count = selectedProperties!.length;
      propertyNames = selectedProperties!
          .map((p) => p['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      propertyLocations = selectedProperties!
          .map((p) => p['location']?.toString() ?? '')
          .toList();
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
        _PropertySummaryBox(
          count: count,
          properties: propertyNames,
          locations: propertyLocations,
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

  static String _formatDate(dynamic date) {
    if (date == null) return 'Submitted 14 Aug 2026';
    try {
      final dt = DateTime.parse(date.toString()).toLocal();
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
  final VoidCallback onPay;

  const _ApprovedMembershipView({required this.theme, required this.onPay});

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Renew · ₹2,000',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Renew · ₹2,000',
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
            child: Image.asset(
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
  late List<Map<String, dynamic>> _properties;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProperties != null &&
        widget.initialProperties!.isNotEmpty) {
      _properties = widget.initialProperties!
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
    } else {
      _properties = [];
      _fetchEligibleProperties();
    }
  }

  Future<void> _fetchEligibleProperties() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      final response = await dio.get(ApiConstants.associationEligibleProperties);
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        List<dynamic> rawList = [];
        if (resData is Map) {
          if (resData['data'] is Map && resData['data']['properties'] is List) {
            rawList = resData['data']['properties'] as List;
          } else if (resData['properties'] is List) {
            rawList = resData['properties'] as List;
          } else if (resData['data'] is List) {
            rawList = resData['data'] as List;
          }
        }
        final properties = rawList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final address = map['address']?.toString().trim() ?? '';
          final city = map['city']?.toString().trim() ?? '';
          final locationParts = [
            if (address.isNotEmpty) address,
            if (city.isNotEmpty) city,
          ];
          final location = locationParts.isNotEmpty
              ? locationParts.join(', ')
              : 'Chennai';

          final hostelType = map['hostel_type']?.toString();
          final propertyTag = map['propertyTag']?.toString();

          return {
            '_id': map['_id']?.toString() ?? map['id']?.toString() ?? '',
            'name': map['name']?.toString() ?? '',
            'address': address,
            'city': city,
            'hostel_type': hostelType,
            'propertyTag': propertyTag,
            'location': location,
            'type': _MembershipCardWidgetState._formatPropertyType(
              hostelType,
              propertyTag,
            ),
            'selected': false,
            'isActive': map['isActive'] ?? true,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _properties = properties;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      AppLogger.error('Failed to fetch eligible properties in sheet: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final selectedCount =
        _properties.where((p) => p['selected'] == true).length;
    final profileState = context.read<ProfileCubit>().state;

    String userName = 'Ramesh Kumar';
    String userPhone = '+91 9840012345';
    String userInitials = 'RK';

    if (profileState is ProfileLoaded) {
      final p = profileState.profile;
      if (p.fullName.trim().isNotEmpty) {
        userName = p.fullName.trim();
      }
      if (p.phone.trim().isNotEmpty) {
        userPhone = p.phone.trim().startsWith('+')
            ? p.phone.trim()
            : '+91 ${p.phone.trim()}';
      }
      String ini = '';
      if (p.firstName.trim().isNotEmpty) ini += p.firstName.trim()[0].toUpperCase();
      if (p.lastName.trim().isNotEmpty) ini += p.lastName.trim()[0].toUpperCase();
      if (ini.isNotEmpty) userInitials = ini;
    }

    return Container(
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
                      final allSelected =
                          _properties.every((p) => p['selected'] == true);
                      for (var p in _properties) {
                        p['selected'] = !allSelected;
                      }
                    });
                  },
                  child: Text(
                    _properties.every((p) => p['selected'] == true)
                        ? 'Deselect all'
                        : 'Select all',
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
                  final isSelected = p['selected'] == true;
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
                        color: isSelected
                            ? const Color(0x336FA641)
                            : Colors.white,
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
                                color: isSelected
                                    ? accent
                                    : Colors.grey.shade300,
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
                                  p['name'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if ((p['location'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    p['location'] ?? '',
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
                                    p['type'] ?? 'HOSTEL',
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
              onPressed: (selectedCount > 0 && !_isSubmitting)
                  ? () async {
                      setState(() => _isSubmitting = true);
                      final selected = _properties
                          .where((p) => p['selected'] == true)
                          .toList();
                      final propertyIds = selected
                          .map((p) => (p['_id'] ?? p['id'] ?? '').toString())
                          .where((id) => id.isNotEmpty)
                          .toList();

                      String portalId = widget.portalId ?? '';
                      if (portalId.isEmpty) {
                        final profileState = context.read<ProfileCubit>().state;
                        if (profileState is ProfileLoaded &&
                            profileState.profile.associationId != null &&
                            profileState.profile.associationId!.isNotEmpty) {
                          portalId = profileState.profile.associationId!;
                        } else {
                          portalId = '66ba10000000000000000001';
                        }
                      }

                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        final dio = sl<Dio>();
                        final response = await dio.post(
                          ApiConstants.associationMembershipApplications,
                          data: {
                            'portalId': portalId,
                            'propertyIds': propertyIds,
                          },
                        );

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          final resData = response.data;
                          Map<String, dynamic>? membership;
                          if (resData is Map &&
                              resData['data'] is Map &&
                              resData['data']['membership'] is Map) {
                            membership = Map<String, dynamic>.from(
                                resData['data']['membership'] as Map);
                          } else if (resData is Map && resData['data'] is Map) {
                            membership =
                                Map<String, dynamic>.from(resData['data'] as Map);
                          } else if (resData is Map &&
                              resData['membership'] is Map) {
                            membership = Map<String, dynamic>.from(
                                resData['membership'] as Map);
                          }
                          navigator.pop(membership ?? selected);
                        } else {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                            final msg = response.data is Map
                                ? response.data['message']?.toString()
                                : null;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    msg ?? 'Failed to submit application'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        AppLogger.error(
                            'Failed to submit membership application: $e');
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to submit application. Please try again.'),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              icon: _isSubmitting
                  ? const SizedBox.shrink()
                  : Icon(
                      Icons.check,
                      color: selectedCount > 0 ? primary : primary,
                      size: 14.sp,
                    ),
              label: _isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    )
                  : Text(
                      selectedCount > 0
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
              onPressed: () => {
                _navigateToRazorpay(
                  context,
                  amount: 2000,
                  planName: 'Associate Plan',
                  orderId: 'order_test_123456789',
                ),

              },
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
  }) {
    // Razorpay expects amount in paise
    final int totalAmountToPay = (amount * 100).round();

    final profileState = context.read<ProfileCubit>().state;

    final String email = profileState is ProfileLoaded
        ? profileState.profile.email
        : '';

    final String mobile = profileState is ProfileLoaded
        ? profileState.profile.phone
        : '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
            },
            child: BlocProvider(
              create: (_) => sl<RazorpayCubit>()
                ..openCheckout(
                  apiKey: ApiConstants.razorpayKey,
                  amount: totalAmountToPay,
                  name: planName,
                  orderId: orderId,
                  description: 'Payment for $planName',
                  email: email,
                  contact: mobile,
                ),
              child: BlocConsumer<RazorpayCubit, RazorpayState>(
                listener: (innerContext, state) {
                  if (state is RazorpaySuccess) {
                    debugPrint('========== Razorpay Success ==========');
                    debugPrint('Payment ID : ${state.result.paymentId}');
                    debugPrint('Order ID   : ${state.result.orderId}');
                    debugPrint('Signature  : ${state.result.signature}');
                    debugPrint('======================================');

                    if (Navigator.canPop(dialogContext)) {
                      Navigator.pop(dialogContext, true);
                    }
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    }
                    // No success navigation
                    // No verify-payment API call
                  } else if (state is RazorpayFailure) {
                    debugPrint('========== Razorpay Failure ==========');
                    debugPrint('Error: ${state.message}');
                    debugPrint('=====================================');

                    if (Navigator.canPop(dialogContext)) {
                      Navigator.pop(dialogContext, true);
                    }
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    }
                    // No failure screen navigation
                  }
                },
                builder: (context, state) {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }
}
