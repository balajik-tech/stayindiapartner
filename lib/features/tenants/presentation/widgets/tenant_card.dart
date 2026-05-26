import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class TenantCard extends StatelessWidget {
  final TenantEntity tenant;

  const TenantCard({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final bool isNotice = tenant.checkOutDate != null;
    final bool isActive = tenant.checkInDate != null && !isNotice;
    final bool isPending = tenant.checkInDate == null;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => TenantDetailsSheet.show(
            context,
            name: tenant.fullName,
            imageUrl: ApiConstants.getImageUrl(tenant.avatar),
            room: tenant.roomTypename,
            tenantId: tenant.id,
            hostelId: tenant.hostelId,
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                _buildProfileImage(tenant),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tenant.fullName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _buildStatusIndicator(
                            isActive,
                            isPending,
                            isNotice,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room_rounded,
                            size: 12.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            tenant.roomTypename,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            " • ",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12.sp,
                            color: AppColors.greyText,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(tenant.checkInDate, context),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isNotice) ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.exit_to_app_rounded,
                              size: 12.sp,
                              color: const Color(0xFFF24822),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${'vacating'.tr()}: ${_formatDate(tenant.checkOutDate, context)}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFFF24822),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactCallAction(
                      Icons.call_rounded,
                      const Color(0xFF27C26C),
                      () => _launchUrl('tel:${tenant.mobile}'),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade400,
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

  Widget _buildProfileImage(TenantEntity tenant) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: CustomAvatar(
        imageUrl: ApiConstants.getImageUrl(tenant.avatar),
        name: tenant.fullName,
        size: 38.0,
        isCircle: true,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive, bool isPending, bool isNotice) {
    Color color = AppColors.primaryBlue;
    String label;
    if (isNotice) {
      color = const Color(0xFFF24822);
      label = 'notice_status'.tr();
    } else if (isPending) {
      color = const Color(0xFFFFB800);
      label = 'pending_status'.tr();
    } else {
      label = 'active_status'.tr();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCompactCallAction(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(String? date, BuildContext context) {
    if (date == null || date.isEmpty) return 'not_available'.tr();
    try {
      final dt = DateTime.parse(date);
      return DateFormat.yMMMd(context.locale.languageCode).format(dt);
    } catch (_) {
      return date;
    }
  }
}
