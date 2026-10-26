import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/data/models/tenant_model.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/injection_container.dart';

class TenantHistoryPage extends StatefulWidget {
  final String tenantName;
  final List<TenantPaymentItemEntity> payments;
  final String? checkInDate;
  final String? tenantId;

  /// Current dues from the tenant details sheet. When null, falls back to the
  /// unpaid amounts on the rentals listed here.
  final double? dueAmount;

  const TenantHistoryPage({
    super.key,
    required this.tenantName,
    required this.payments,
    this.checkInDate,
    this.tenantId,
    this.dueAmount,
  });

  @override
  State<TenantHistoryPage> createState() => _TenantHistoryPageState();
}

const _successGreen = Color(0xFF12B76A);
const _successGreenBg = Color(0xFFECFDF3);
const _dueRed = Color(0xFFF04438);
const _dueRedBg = Color(0xFFFFF1F0);
const _pendingOrange = Color(0xFFF79009);
const _pendingOrangeBg = Color(0xFFFFFAEB);
const _utilityPurple = Color(0xFF7A5AF8);
const _utilityPurpleBg = Color(0xFFF4F3FF);

/// Payment components shown as filters and as the per-entry breakdown.
enum _Category {
  rent('Rent', Icons.home_rounded, _successGreen, _successGreenBg),
  deposit('Deposit', Icons.shield_rounded, _pendingOrange, _pendingOrangeBg),
  maintenance(
    'Maintenance',
    Icons.build_rounded,
    AppColors.primaryBlue,
    AppColors.totalBlue,
  ),
  utility('Utility Bill', Icons.bolt_rounded, _utilityPurple, _utilityPurpleBg);

  const _Category(this.label, this.icon, this.color, this.background);

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  double amountOf(TenantPaymentItemEntity p) => switch (this) {
    _Category.rent => p.rent ?? 0,
    _Category.deposit => p.deposit ?? 0,
    _Category.maintenance => p.maintenance ?? 0,
    _Category.utility => p.utilityBill ?? 0,
  };
}

final _rupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

class _TenantHistoryPageState extends State<TenantHistoryPage> {
  late List<TenantPaymentItemEntity> _payments;
  late String _tenantName;
  String? _checkInDate;
  int? _daysSinceFirstRental;
  bool _isLoading = false;
  _Category? _filter;

  @override
  void initState() {
    super.initState();
    _payments = List.from(widget.payments);
    _tenantName = widget.tenantName;
    _checkInDate = widget.checkInDate;

    if (widget.tenantId != null && widget.tenantId!.isNotEmpty) {
      _fetchTenantHistory();
    }
  }

  Future<void> _fetchTenantHistory() async {
    if (widget.tenantId == null || widget.tenantId!.isEmpty) return;

    if (_payments.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final dio = sl<Dio>();
      final response = await dio.get(
        ApiConstants.tenantRentalByTenant(widget.tenantId!),
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        Map<String, dynamic>? dataMap;
        List listData = [];

        if (resData is Map<String, dynamic>) {
          final dataField = resData['data'];
          if (dataField is Map<String, dynamic>) {
            dataMap = dataField;
          } else if (dataField is List) {
            listData = dataField;
          } else if (resData['rentals'] is List) {
            dataMap = resData;
          }
        } else if (resData is List) {
          listData = resData;
        }

        int? days;
        String? firstRentalDate;

        if (dataMap != null) {
          if (dataMap['rentals'] is List) {
            listData = dataMap['rentals'] as List;
          }
          if (dataMap['daysSinceFirstRental'] is num) {
            days = (dataMap['daysSinceFirstRental'] as num).toInt();
          }
          if (dataMap['firstRentalDate'] != null) {
            firstRentalDate = dataMap['firstRentalDate'].toString();
          }
        }

        final List<TenantPaymentItemEntity> fetchedPayments = [];
        String? nameFromApi;

        for (final item in listData) {
          if (item is Map<String, dynamic>) {
            final entity = TenantPaymentItemModel.fromJson(item);
            fetchedPayments.add(entity);

            if (nameFromApi == null && item['tenant'] is Map<String, dynamic>) {
              final t = item['tenant'] as Map<String, dynamic>;
              final fn = t['firstName']?.toString() ?? '';
              final ln = t['lastName']?.toString() ?? '';
              final full = '$fn $ln'.trim();
              if (full.isNotEmpty) {
                nameFromApi = full;
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _payments = fetchedPayments;
            if (nameFromApi != null && nameFromApi.isNotEmpty) {
              _tenantName = nameFromApi;
            }
            if (days != null) {
              _daysSinceFirstRental = days;
            }
            if (firstRentalDate != null && firstRentalDate.isNotEmpty) {
              _checkInDate = firstRentalDate;
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = _filter;
    final visible = filter == null
        ? _payments
        : _payments.where((p) => filter.amountOf(p) > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _fetchTenantHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
          children: [
            _buildSummaryRow(),
            SizedBox(height: 12.h),
            _buildFilterChips(),
            SizedBox(height: 10.h),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            else if (visible.isEmpty)
              _buildEmptyState()
            else
              ...visible.map(_buildPaymentCard),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: AppColors.darkText,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tenant History',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _tenantName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.greyText, fontSize: 13.sp),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.roomCardBorder),
      ),
    );
  }

  int get _daysStayed {
    if (_checkInDate != null && _checkInDate!.isNotEmpty) {
      final startDt = DateTime.tryParse(_checkInDate!)?.toLocal();
      if (startDt != null) {
        final now = DateTime.now();
        final diff = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(startDt.year, startDt.month, startDt.day)).inDays;
        return diff >= 0 ? diff + 1 : 0;
      }
    }
    return _daysSinceFirstRental != null ? _daysSinceFirstRental! + 1 : 0;
  }

  double get _dues =>
      widget.dueAmount ?? _payments.fold(0.0, (sum, p) => sum + p.dueAmount);

  Widget _buildSummaryRow() {
    final totalPaid = _payments.fold(0.0, (sum, p) => sum + p.paidAmount);
    final dues = _dues;
    final hasDues = dues > 0;
    final days = _daysStayed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildSummaryTile(
              icon: Icons.currency_rupee_rounded,
              label: 'Paid Amount',
              color: _successGreen,
              background: _successGreenBg,
              value: _buildAmountText(_rupees.format(totalPaid), _successGreen),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildSummaryTile(
              icon: Icons.schedule_rounded,
              label: 'Number of Days',
              color: AppColors.primaryBlue,
              background: AppColors.totalBlue,
              value: Text.rich(
                TextSpan(
                  text: '$days',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                  children: [
                    TextSpan(
                      text: days == 1 ? ' Day' : ' Days',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildSummaryTile(
              icon: hasDues
                  ? Icons.receipt_long_rounded
                  : Icons.verified_rounded,
              label: 'Dues',
              color: hasDues ? _dueRed : _successGreen,
              background: hasDues ? _dueRedBg : _successGreenBg,
              value: _buildAmountText(
                hasDues ? _rupees.format(dues) : 'Clear',
                hasDues ? _dueRed : _successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountText(String text, Color color) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required Widget value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 2.h),
          value,
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'All',
            icon: Icons.list_alt_rounded,
            color: AppColors.primaryBlue,
            background: AppColors.totalBlue,
            selected: _filter == null,
            onTap: () => setState(() => _filter = null),
          ),
          for (final c in _Category.values) ...[
            SizedBox(width: 8.w),
            _buildFilterChip(
              label: c.label,
              icon: c.icon,
              color: c.color,
              background: c.background,
              selected: _filter == c,
              // Tapping the active filter again goes back to All.
              onTap: () => setState(() => _filter = _filter == c ? null : c),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required Color background,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? background : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.4)
                : AppColors.roomCardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: selected ? color : AppColors.greyText,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 36.sp,
            color: AppColors.greyText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            _filter == null
                ? 'No payment history found'
                : 'No ${_filter!.label.toLowerCase()} payments found',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate, String pattern) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final dt = DateTime.tryParse(isoDate);
    return dt != null ? DateFormat(pattern).format(dt.toLocal()) : isoDate;
  }

  ({String label, Color color, Color background}) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
        return (
          label: 'Paid',
          color: _successGreen,
          background: _successGreenBg,
        );
      case 'FAILED':
      case 'CANCELLED':
        return (label: 'Failed', color: _dueRed, background: _dueRedBg);
      default:
        return (
          label: 'Pending',
          color: _pendingOrange,
          background: _pendingOrangeBg,
        );
    }
  }

  Widget _buildPaymentCard(TenantPaymentItemEntity p) {
    final style = _statusStyle(p.status);
    final isPaid = style.label == 'Paid';
    final amount = isPaid || p.paidAmount > 0 ? p.paidAmount : p.totalAmount;

    // A single-component entry is titled after that component; mixed entries
    // are a regular rent payment.
    final present = _Category.values.where((c) => c.amountOf(p) > 0).toList();
    final single = present.length == 1 ? present.first : null;
    final title = switch (single) {
      _Category.deposit => 'Security Deposit',
      _Category.maintenance => 'Maintenance Charge',
      _Category.utility => 'Electricity Bill',
      _ => isPaid ? 'Payment Received' : 'Payment Due',
    };
    final lead = single ?? _Category.rent;

    final subtitle = [
      _formatDate(p.paymentDate ?? p.month, 'MMM d, yyyy • h:mm a'),
      if (!isPaid && (p.dueDate ?? '').isNotEmpty)
        'Due ${_formatDate(p.dueDate, 'd MMM')}',
    ].where((s) => s.isNotEmpty).join(' • ');

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: lead.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  single == null ? Icons.payments_rounded : lead.icon,
                  size: 20.sp,
                  color: lead.color,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isPaid ? AppColors.greyText : style.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _rupees.format(amount),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? AppColors.darkText : style.color,
                    ),
                  ),
                  if (!isPaid) ...[
                    SizedBox(height: 2.h),
                    _buildChip(style.label, style.color, style.background),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              for (final c in _Category.values) ...[
                if (c != _Category.values.first) SizedBox(width: 6.w),
                Expanded(child: _buildBreakdownCell(c, c.amountOf(p))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCell(_Category c, double value) {
    final active = value > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active ? c.background : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              c.label,
              style: TextStyle(
                fontSize: 10.sp,
                color: active ? c.color : AppColors.greyText,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _rupees.format(value),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? c.color : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color, Color background) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
