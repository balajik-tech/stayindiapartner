import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

// Add font_awesome_flutter to pubspec.yaml for an accurate WhatsApp glyph:
//   flutter pub add font_awesome_flutter
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// 1. Trigger widget — same GestureDetector you had, now opens the sheet
// ---------------------------------------------------------------------------

class ExploreAddButton extends StatelessWidget {
  const ExploreAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showRegisterAssociationBottomSheet(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
              color: Colors.white,
            ),
            child: Icon(Icons.add, color: AppColors.primaryBlue, size: 24.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            'explore'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Helper to show the sheet
// ---------------------------------------------------------------------------

Future<void> showRegisterAssociationBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const RegisterAssociationBottomSheet(),
  );
}

// ---------------------------------------------------------------------------
// 3. The bottom sheet itself
// ---------------------------------------------------------------------------

class RegisterAssociationBottomSheet extends StatelessWidget {
  const RegisterAssociationBottomSheet({super.key});

  static const Color _accentOrange = Color(0xFFD97B2E);
  static const Color _accentOrangeBg = Color(0xFFFBEBDD);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 12.h,
          bottom: 24.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D2C4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Text(
                'register_association_title'.tr(),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'register_association_subtitle'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),

              // Option 1 — WhatsApp (highlighted)
              _OptionTile(
                icon: FontAwesomeIcons.whatsapp,
                iconColor: const Color(0xFF25D366),
                iconSize: 28.sp,
                title: 'continue_on_whatsapp'.tr(),
                subtitle: 'whatsapp_option_subtitle'.tr(),
                badgeText: 'easiest'.tr(),
                highlighted: true,
                borderColor: _accentOrange,
                badgeColor: _accentOrangeBg,
                badgeTextColor: _accentOrange,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: launch WhatsApp flow
                },
              ),
              SizedBox(height: 12.h),

              // Option 2 — Web form
              _OptionTile(
                icon: FontAwesomeIcons.arrowUpRightFromSquare,
                iconColor: const Color(0xFF3A3A3A),
                iconSize: 24.sp,
                title: 'fill_web_form'.tr(),
                subtitle: 'web_form_option_subtitle'.tr(),
                highlighted: false,
                borderColor: const Color(0xFFE5E1D8),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: launch stayindia.in web form
                },
              ),
              SizedBox(height: 22.h),

              // Footer note
              Center(
                child: Text(
                  'approval_time_note'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFAFAA9C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Reusable option row
// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.borderColor,
    required this.onTap,
    this.iconSize,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
  });

  final FaIconData icon;
  final Color iconColor;
  final double? iconSize;
  final String title;
  final String subtitle;
  final bool highlighted;
  final Color borderColor;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(
              // ✅ Changed
              icon,
              color: iconColor,
              size: iconSize ?? 24.sp,
            ),
            SizedBox(width: 12.w),
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
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Text(
                            badgeText!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B6B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF9A9A9A),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
