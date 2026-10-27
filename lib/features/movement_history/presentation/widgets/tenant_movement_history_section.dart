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
  static const int _pageSize = 10;
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _headerText = Color(0xFF2563EB);
  static const Color _bodyText = Color(0xFF1B2838);

  late DateTimeRange _selectedDateRange = _todayRange();
  int _visibleCount = _pageSize;

  static DateTimeRange _todayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: today, end: today);
  }

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
        _visibleCount = _pageSize;
      });
    }
  }

  static bool _isOutAction(String action) => action.toUpperCase().contains('OUT');

  /// Pairs each OUT with the IN that follows it. Built from the full history so
  /// durations that cross the selected range's edges stay correct.
  static List<_LogRow> _buildLogRows(List<MovementHistoryEntity> history) {
    final events = List<MovementHistoryEntity>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final rows = <_LogRow>[];
    DateTime? openOut;
    for (final event in events) {
      if (_isOutAction(event.action)) {
        // Two OUTs in a row: the first one never got a matching IN.
        if (openOut != null) rows.add(_LogRow(outTime: openOut));
        openOut = event.timestamp;
      } else {
        rows.add(_LogRow(outTime: openOut, inTime: event.timestamp));
        openOut = null;
      }
    }
    if (openOut != null) rows.add(_LogRow(outTime: openOut));
    return rows;
  }

  static String _formatDuration(Duration d) {
    final mins = d.inMinutes % 60;
    return '${d.inHours}h ${mins.toString().padLeft(2, '0')}m';
  }

  bool _inSelectedRange(DateTime time) {
    final start = _selectedDateRange.start;
    final end = DateTime(_selectedDateRange.end.year, _selectedDateRange.end.month, _selectedDateRange.end.day)
        .add(const Duration(days: 1));
    return !time.isBefore(start) && time.isBefore(end);
  }

  String _formatRangeLabel() {
    final fmt = DateFormat('dd-MM-yyyy');
    final start = fmt.format(_selectedDateRange.start);
    final end = fmt.format(_selectedDateRange.end);
    return start == end ? start : '$start  –  $end';
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
    final allRows = _buildLogRows(state.history);
    final rows = allRows.where((r) => _inSelectedRange(r.sortTime)).toList();
    final visibleRows = rows.take(_visibleCount).toList();

    final latest = state.history.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
    final currentStatus = latest.action.toUpperCase();
    final isOutside = _isOutAction(currentStatus) || currentStatus == 'OUTSIDE';
    final statusColor = isOutside ? Colors.red : Colors.green;
    final statusBgColor = isOutside ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Movement History",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: _bodyText,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
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
                          color: _bodyText,
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
                  "Status changed via ${latest.source ?? 'Geofencing'} at ${DateFormat('hh:mm a').format(latest.timestamp)}.",
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeField(context),
              SizedBox(height: 16.h),
              _buildLogCard(visibleRows, isLastRowLatest: visibleRows.isNotEmpty && identical(visibleRows.last, allRows.last)),
              if (rows.length > _visibleCount) ...[
                SizedBox(height: 12.h),
                Center(
                  child: InkWell(
                    onTap: () => setState(() => _visibleCount += _pageSize),
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
              SizedBox(height: 12.h),
              Text(
                "Hours(out) = Out time to In time. Hours(in) = In time to the next Out time.",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () => _selectDateRange(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatRangeLabel(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _bodyText,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 18.sp, color: _bodyText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// [isLastRowLatest] marks the last row as still running, since nothing
  /// has happened after it yet.
  Widget _buildLogCard(List<_LogRow> rows, {required bool isLastRowLatest}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Text(
              "Check-in / out log",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: _bodyText,
              ),
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Text(
                "No check-in / out entries for the selected dates.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildLogTable(rows, isLastRowLatest: isLastRowLatest),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogTable(List<_LogRow> rows, {required bool isLastRowLatest}) {
    final timeFmt = DateFormat('hh:mm a');
    final dateFmt = DateFormat('dd MMM');

    TableRow header() => TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
          children: ['Sl. No', 'Date', 'Out time', 'In time', 'Hours(out)', 'Hours(in)']
              .map((label) => _cell(label, color: _headerText, weight: FontWeight.w700))
              .toList(),
        );

    final tableRows = <TableRow>[header()];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final next = i + 1 < rows.length ? rows[i + 1] : null;
      final isRunning = isLastRowLatest && next == null;

      String hoursOut = '—';
      if (row.outTime != null && row.inTime != null) {
        hoursOut = _formatDuration(row.inTime!.difference(row.outTime!));
      } else if (row.outTime != null && isRunning) {
        hoursOut = 'Running';
      }

      String hoursIn = '—';
      if (row.inTime != null && next?.outTime != null) {
        hoursIn = _formatDuration(next!.outTime!.difference(row.inTime!));
      } else if (row.inTime != null && isRunning) {
        hoursIn = 'Running';
      }

      tableRows.add(TableRow(
        decoration: BoxDecoration(
          color: isRunning ? const Color(0xFFFFF7ED) : Colors.white,
          border: const Border(top: BorderSide(color: _border)),
        ),
        children: [
          _cell('${i + 1}'),
          _cell(dateFmt.format(row.sortTime)),
          _cell(row.outTime != null ? timeFmt.format(row.outTime!) : '—'),
          _cell(row.inTime != null ? timeFmt.format(row.inTime!) : '—'),
          _cell(hoursOut, weight: isRunning ? FontWeight.w800 : FontWeight.w500),
          _cell(hoursIn),
        ],
      ));
    }

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows,
    );
  }

  Widget _cell(String text, {Color color = _bodyText, FontWeight weight = FontWeight.w500}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(fontSize: 11.sp, fontWeight: weight, color: color),
      ),
    );
  }
}

/// One out-and-back trip. Either side can be missing: a trip that is still
/// going has no [inTime], and an IN with no OUT before it has no [outTime].
class _LogRow {
  final DateTime? outTime;
  final DateTime? inTime;

  _LogRow({this.outTime, this.inTime});

  DateTime get sortTime => (outTime ?? inTime)!;
}
