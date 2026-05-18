import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import '../../domain/entities/staff.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/core/widgets/responsive_widgets.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback onTap;

  const StaffCard({super.key, required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomAvatar(
                      imageUrl: null,
                      name: staff.name,
                      size: 56.0,
                      isCircle: true,
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
                                  staff.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkText,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  staff.role.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Text(
                                staff.phone,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1),
                SizedBox(height: 16.h),
                AdaptiveActionRow(
                  spacing: 12.w,
                  runSpacing: 8.h,
                  children: [
                    _buildActionButtonWithoutExpanded(
                      context,
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: const Color(0xFF099268),
                      onTap: () => _launchCaller(staff.phone),
                    ),
                    _buildActionButtonWithoutExpanded(
                      context,
                      icon: Icons.settings_rounded,
                      label: 'Manage',
                      color: AppColors.greyText,
                      onTap: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool active = staff.isActive;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF3FEF7) : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF099268) : const Color(0xFFE03131),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: active ? const Color(0xFF099268) : const Color(0xFFE03131),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWithoutExpanded(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchCaller(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
