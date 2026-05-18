import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/notifications/domain/entities/notification_entity.dart';
import 'package:stayindia_owner/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationCubit>()..fetchNotifications(),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: Text(
              'Mark all as read',
              style: GoogleFonts.outfit(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade300,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: GoogleFonts.outfit(color: AppColors.greyText),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<NotificationCubit>().fetchNotifications(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationItem(notification: notification);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64.sp,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We\'ll notify you when something important happens.',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.greyText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isSOS = notification.type == 'SOS_ALERT';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSOS ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
          width: isSOS ? 1.5 : 0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4.w,
                color: isSOS
                    ? AppColors.sosRed
                    : (notification.isRead
                          ? Colors.transparent
                          : AppColors.primaryBlue),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5.sp,
                                color: isSOS
                                    ? AppColors.sosRed
                                    : AppColors.darkText,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _formatDate(notification.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              color: AppColors.greyText.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          color: AppColors.greyText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}
