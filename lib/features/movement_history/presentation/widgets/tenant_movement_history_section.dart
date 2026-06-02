import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/movement_history/domain/entities/movement_history_entity.dart';
import 'package:stayindia_owner/features/movement_history/presentation/cubit/movement_history_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';

class TenantMovementHistorySection extends StatefulWidget {
  final String tenantId;

  const TenantMovementHistorySection({super.key, required this.tenantId});

  @override
  State<TenantMovementHistorySection> createState() => _TenantMovementHistorySectionState();
}

class _TenantMovementHistorySectionState extends State<TenantMovementHistorySection> {
  DateTimeRange? _selectedDateRange;
  int _visibleCount = 2;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _visibleCount = 2;
      });
    }
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (checkDate == today) {
      return "Today";
    } else if (checkDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MovementHistoryCubit>()..loadHistory(widget.tenantId),
      child: BlocBuilder<MovementHistoryCubit, MovementHistoryState>(
        builder: (context, state) {
          if (state is MovementHistoryLoading || state is MovementHistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovementHistoryError) {
            return Center(child: Text('Error loading history: ${state.message}'));
          } else if (state is MovementHistoryLoaded) {
            if (state.history.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    "No movement history available",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MovementHistoryLoaded state) {
    final filteredHistory = _selectedDateRange != null
        ? state.history.where((entry) {
            final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
            final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
            return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
          }).toList()
        : state.history;

    final Map<String, List<_TimelineItem>> groupedHistory = {};
    
    final history = List<MovementHistoryEntity>.from(filteredHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final limit = _visibleCount < history.length ? _visibleCount : history.length;

    for (int i = 0; i < limit; i++) {
      final entry = history[i];
      final dateStr = _formatDateHeader(entry.timestamp);
      
      String durationStr = '';
      if (i < history.length - 1) {
        final prevEntry = history[i + 1];
        final diff = entry.timestamp.difference(prevEntry.timestamp);
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        if (hours > 0) {
          durationStr = 'Duration: $hours hrs $mins mins';
        } else {
          durationStr = 'Duration: $mins mins';
        }
      }

      if (!groupedHistory.containsKey(dateStr)) {
        groupedHistory[dateStr] = [];
      }
      groupedHistory[dateStr]!.add(_TimelineItem(
        entity: entry,
        durationStr: durationStr,
        isFirstInGroup: groupedHistory[dateStr]!.isEmpty,
      ));
    }

    final realHistory = state.history;
    final currentStatus = realHistory.isNotEmpty ? realHistory.first.action.toUpperCase() : 'UNKNOWN';
    final isOutside = currentStatus.contains('OUT') || currentStatus == 'OUTSIDE';
    final statusColor = isOutside ? Colors.red : Colors.green;
    final statusBgColor = isOutside ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Movement History",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B2838),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.date_range_rounded,
                        size: 20.sp,
                        color: _selectedDateRange != null ? AppColors.primaryBlue : Colors.grey[600],
                      ),
                      onPressed: () => _selectDateRange(context),
                    ),
                    if (_selectedDateRange != null) ...[
                      SizedBox(width: 4.w),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 20.sp,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = null;
                            _visibleCount = 2;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (realHistory.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            currentStatus,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (realHistory.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tenant is currently: ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2838),
                          ),
                        ),
                        TextSpan(
                          text: currentStatus,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Status changed via ${realHistory.first.source ?? 'Geofencing'} at ${DateFormat('hh:mm a').format(realHistory.first.timestamp)}.",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 20.h),
        if (filteredHistory.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Text(
                "No movement history for selected range.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
            ),
          )
        else
          ...groupedHistory.entries.map((group) {
            final items = group.value;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14.sp, color: const Color(0xFF475569)),
                      SizedBox(width: 6.w),
                      Text(
                        group.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B2838),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLastInGroup = index == items.length - 1;
                      final isOutsideAction = item.entity.action.toUpperCase().contains('OUT');
                      
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 80.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(item.entity.timestamp),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1B2838),
                                    ),
                                  ),
                                  if (item.durationStr.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: Text(
                                        item.durationStr,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 28.w,
                                  decoration: BoxDecoration(
                                    color: isOutsideAction ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isOutsideAction ? Icons.meeting_room_rounded : Icons.vpn_key_rounded,
                                      color: isOutsideAction ? Colors.red : Colors.green,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                                if (!isLastInGroup)
                                  Expanded(
                                    child: Container(
                                      width: 2.w,
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  )
                                else
                                  SizedBox(height: 16.h),
                              ],
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOutsideAction ? "OUTSIDE" : "IN HOSTEL",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1B2838),
                                    ),
                                  ),
                                  Text(
                                    isOutsideAction ? "Checked Out" : "Checked In",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        if (history.length > _visibleCount) ...[
          SizedBox(height: 12.h),
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  _visibleCount += 2;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Show More",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryBlue,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimelineItem {
  final MovementHistoryEntity entity;
  final String durationStr;
  final bool isFirstInGroup;

  _TimelineItem({
    required this.entity,
    required this.durationStr,
    required this.isFirstInGroup,
  });
}
