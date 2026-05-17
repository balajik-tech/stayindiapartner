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

  const TenantCard({
    super.key,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNotice = tenant.checkOutDate != null;
    final bool isActive = tenant.checkInDate != null && !isNotice;
    final bool isPending = tenant.checkInDate == null;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            children: [
              
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Row(
                  children: [
                    _buildProfileImage(tenant),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tenant.fullName,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkText,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildStatusIndicator(isActive, isPending, isNotice),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            tenant.mobile,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(
                        Icons.meeting_room_rounded,
                        tenant.roomTypename,
                        'position'.tr(),
                      ),
                      _buildVerticalDivider(),
                      _buildInfoItem(
                        Icons.access_time_rounded,
                        'since'.tr(namedArgs: {'date': _formatDate(tenant.checkInDate, context)}),
                        'duration'.tr(),
                      ),
                      if (isNotice) ...[
                        _buildVerticalDivider(),
                        _buildInfoItem(
                          Icons.exit_to_app_rounded,
                          _formatDate(tenant.checkOutDate, context),
                          'vacating'.tr(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    _buildQuickAction(
                      Icons.call_rounded,
                      'call_resident'.tr(),
                      const Color(0xFF27C26C),
                      () => _launchUrl('tel:${tenant.mobile}'),
                    ),
                    const Spacer(),
                    Text(
                      'view_details'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18.sp, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ],
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
        size: 52.0,
        isCircle: true,
        fontSize: 20.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: AppColors.greyText),
              SizedBox(width: 4.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.greyText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      color: Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
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
