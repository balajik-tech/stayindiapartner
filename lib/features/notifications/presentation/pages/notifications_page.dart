import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return BlocProvider.value(
      value: sl<NotificationCubit>()..fetchNotifications(showLoading: false),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'icon': Icons.notifications_rounded},
    {'label': 'Bookings', 'icon': Icons.bookmark_rounded},
    {'label': 'Payments', 'icon': Icons.payments_rounded},
    {'label': 'Notices', 'icon': Icons.campaign_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          int unreadCount = 0;
          List<NotificationEntity> filteredNotifications = [];

          if (state is NotificationLoaded) {
            unreadCount = state.notifications.where((n) => !n.isRead).length;
            filteredNotifications = _filterNotifications(state.notifications);
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark, // Android: black icons
              statusBarBrightness: Brightness.light,    // iOS
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildHeader(context, unreadCount),
                    _buildFilterTabs(),
                    Expanded(
                      child: _buildBody(state, filteredNotifications),
                    ),
                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  List<NotificationEntity> _filterNotifications(List<NotificationEntity> notifications) {
    if (_selectedFilter == 'All') return notifications;
    
    return notifications.where((n) {
      final type = n.type.toUpperCase();
      switch (_selectedFilter) {
        case 'Bookings':
          return type.contains('BOOKING') || type.contains('CHECK_IN');
        case 'Payments':
          return type.contains('PAYMENT') || type.contains('BILL');
        case 'Notices':
          return type.contains('NOTICE') || type.contains('ANNOUNCEMENT');
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 32.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C599D),
            Color(0xFF1E3A8A),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40.r),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                  ),
                ),
                if (unreadCount > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF98125),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '$unreadCount unread',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () {
                context.read<NotificationCubit>().markAllAsRead();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Mark all read',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['label'];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter['label']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(NotificationState state, List<NotificationEntity> notifications) {
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
      if (notifications.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => context.read<NotificationCubit>().fetchNotifications(showLoading: false),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return _NotificationItem(notification: notifications[index]);
          },
        ),
      );
    }

    return const SizedBox.shrink();
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
    final type = _getTypeInfo(notification.type);
    final isUnread = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: type.borderColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5.w,
                color: type.borderColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: type.borderColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              type.label,
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: type.borderColor,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatDate(notification.createdAt),
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  width: 8.r,
                                  height: 8.r,
                                  decoration: BoxDecoration(
                                    color: type.borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        notification.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
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

  _TypeInfo _getTypeInfo(String type) {
    final upperType = type.toUpperCase();
    if (upperType.contains('BOOKING')) {
      return _TypeInfo(
        label: 'Booking',
        borderColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFF0FDF4),
      );
    } else if (upperType.contains('PAYMENT')) {
      return _TypeInfo(
        label: 'Payment',
        borderColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
      );
    } else if (upperType.contains('NOTICE') || upperType.contains('SOS')) {
      return _TypeInfo(
        label: 'Notice',
        borderColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      );
    }
    return _TypeInfo(
      label: 'Update',
      borderColor: const Color(0xFF3B82F6),
      bgColor: const Color(0xFFEFF6FF),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}

class _TypeInfo {
  final String label;
  final Color borderColor;
  final Color bgColor;

  _TypeInfo({
    required this.label,
    required this.borderColor,
    required this.bgColor,
  });
}
