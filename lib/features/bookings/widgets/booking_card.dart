import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/date_formatter.dart';
import '../cubit/bookings_cubit.dart';
import '../pages/room_selection_page.dart';
import 'package:stayindia_owner/features/bookings/domain/booking.dart';
import 'qr_check_in_dialog.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/responsive_widgets.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isCompact;

  const BookingCard({super.key, required this.booking, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView(context);
    }

    final isKycPending = !booking.isKycVerified;
    final isRequest = [
      BookingStatus.confirmed,
      BookingStatus.pending,
    ].contains(booking.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            TenantDetailsSheet.show(
              context,
              name: booking.tenantName,
              imageUrl: booking.tenantAvatar,
              room: booking.roomTypeName,
              tenantId: booking.tenantId ?? '',
              hostelId: booking.hostelId ?? '',
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Profile Avatar, Name, Phone & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileAvatar(),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  booking.tenantName.isNotEmpty ? booking.tenantName : booking.tenantPhone,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildStatusBadge(),
                            ],
                          ),
                          if (booking.tenantName.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              booking.tenantPhone,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyText.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (booking.createdAt != null && isRequest)
                      Text(
                        DateFormatter.formatTimeAgo(
                          booking.createdAt,
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Middle Row: Simple inline details (Check-in Date & Room Type)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11.sp,
                      color: AppColors.greyText.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormatter.formatISO(booking.checkInDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Icon(
                      Icons.bed_outlined,
                      size: 13.sp,
                      color: AppColors.greyText.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      booking.roomTypeName.isNotEmpty
                          ? booking.roomTypeName
                          : (booking.sharingType ?? 'N/A'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    if (isKycPending) ...[
                      _buildKycWarningBadge(context),
                    ],
                  ],
                ),

                if (booking.status != BookingStatus.checkedIn &&
                    booking.roomTypeName.isEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildPendingAllocationBadge(context),
                ],
                SizedBox(height: 12.h),

                // Bottom row: Actions
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final imageUrl = ApiConstants.getImageUrl(booking.tenantAvatar);
    final initials = booking.tenantName.isNotEmpty
        ? booking.tenantName[0].toUpperCase()
        : 'T';

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 26.r,
        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12.sp,
              color: AppColors.greyText.withValues(alpha: 0.6),
            ),
            SizedBox(width: 4.w),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.greyText.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        booking.status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.primaryBlue;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.checkedIn:
        return const Color(0xFF12B76A);
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return AppColors.greyText;
    }
  }

  Widget _buildKycWarningBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFEDF89)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFB54708),
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            StringUtils.translate('kyc_pending', context: context),
            style: TextStyle(
              color: const Color(0xFFB54708),
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAllocationBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bed_outlined, color: const Color(0xFFB42318), size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            StringUtils.translate('no_bed_assigned', context: context),
            style: TextStyle(
              color: const Color(0xFFB42318),
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (booking.status == BookingStatus.checkedOut ||
        booking.status == BookingStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: booking.status == BookingStatus.cancelled
              ? Colors.red.shade50
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: booking.status == BookingStatus.cancelled
                ? Colors.red.shade100
                : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            booking.status == BookingStatus.cancelled
                ? StringUtils.translate(
                    'booking_cancelled_status',
                    context: context,
                  )
                : StringUtils.translate('stay_completed', context: context),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: booking.status == BookingStatus.cancelled
                  ? Colors.red.shade700
                  : AppColors.greyText,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    if (booking.status == BookingStatus.checkedIn) {
      return AdaptiveActionRow(
        children: [
          ResponsiveButton(
            label: StringUtils.translate('change_room', context: context),
            icon: Icons.bed_outlined,
            onPressed: () => _navigateToRoomSelection(context),
            isPrimary: true,
          ),
          ResponsiveButton(
            label: StringUtils.translate('checkout', context: context),
            icon: Icons.logout,
            onPressed: () => _showCheckoutConfirmation(context),
            isPrimary: true,
            isDestructive: true,
          ),
        ],
      );
    }

    return AdaptiveActionRow(
      children: [
        ResponsiveButton(
          label: StringUtils.translate('assign_room', context: context),
          icon: Icons.add_task_rounded,
          onPressed: () => _showCheckInDialog(context),
          isPrimary: true,
        ),
        ResponsiveButton(
          label: StringUtils.translate('reject', context: context),
          icon: Icons.close,
          onPressed: () => _showCancelConfirmation(context),
          isPrimary: false,
          isDestructive: true,
        ),
      ],
    );
  }

  void _navigateToRoomSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BookingsCubit>(),
          child: RoomSelectionPage(
            bookingId: booking.id,
            hostelId: booking.hostelId ?? '',
            tenantName: booking.tenantName,
            bookedSharingType: booking.sharingType,
            bookedRoomType: booking.roomType,
          ),
        ),
      ),
    );
  }

  void _showCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<BookingsCubit>(),
        child: QrCheckInDialog(booking: booking),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          StringUtils.translate('reject_booking_title', context: context),
        ),
        content: Text(
          StringUtils.translate(
            'reject_booking_confirm',
            context: context,
            namedArgs: {'name': booking.tenantName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(StringUtils.translate('cancel', context: context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().cancelBooking(booking.id);
            },
            child: Text(
              StringUtils.translate('reject', context: context),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          StringUtils.translate('confirm_checkout_title', context: context),
        ),
        content: Text(
          StringUtils.translate(
            'confirm_checkout_desc',
            context: context,
            namedArgs: {'name': booking.tenantName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(StringUtils.translate('no', context: context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().checkoutBooking(booking.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              StringUtils.translate('checkout', context: context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    final imageUrl = ApiConstants.getImageUrl(booking.tenantAvatar);
    final initials = booking.tenantName.isNotEmpty
        ? booking.tenantName[0].toUpperCase()
        : 'T';

    return InkWell(
      onTap: () {
        TenantDetailsSheet.show(
          context,
          name: booking.tenantName,
          imageUrl: booking.tenantAvatar,
          room: booking.roomTypeName,
          tenantId: booking.tenantId ?? '',
          hostelId: booking.hostelId ?? '',
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.roomCardBorder.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Text(
                      initials,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.tenantName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.tenantPhone}  •  ${DateFormatter.formatISO(booking.checkInDate)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.greyText.withValues(alpha: 0.4),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
