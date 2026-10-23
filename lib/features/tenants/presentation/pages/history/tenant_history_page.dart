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
  int? _totalTransactions;
  bool _isLoading = false;

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
        int? totalTransactions;
        String? firstRentalDate;

        if (dataMap != null) {
          if (dataMap['rentals'] is List) {
            listData = dataMap['rentals'] as List;
          }
          if (dataMap['daysSinceFirstRental'] is num) {
            days = (dataMap['daysSinceFirstRental'] as num).toInt();
          }
          if (dataMap['totalTransactions'] is num) {
            totalTransactions = (dataMap['totalTransactions'] as num).toInt();
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
            if (totalTransactions != null) {
              _totalTransactions = totalTransactions;
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _fetchTenantHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildSummaryCard(),
            SizedBox(height: 24.h),
            _buildSectionHeader(),
            SizedBox(height: 12.h),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            else if (_payments.isEmpty)
              _buildEmptyState()
            else
              ..._payments.asMap().entries.map(
                (e) => _buildTimelineItem(
                  e.value,
                  isFirst: e.key == 0,
                  isLast: e.key == _payments.length - 1,
                ),
              ),
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

  Widget _buildSummaryCard() {
    final totalPaid = _payments.fold(0.0, (sum, p) => sum + p.paidAmount);
    final dues = _dues;
    final since = _checkInDate != null
        ? DateTime.tryParse(_checkInDate!)?.toLocal()
        : null;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Paid',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _rupees.format(totalPaid),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (since != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 14.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Staying since ${DateFormat('d MMM yyyy').format(since)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  icon: Icons.schedule_rounded,
                  label: 'Days',
                  value: '$_daysStayed',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildStatTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'Payments',
                  value: '${_totalTransactions ?? _payments.length}',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: _buildDuesTile(dues)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.white),
          SizedBox(height: 8.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesTile(double dues) {
    final hasDues = dues > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: hasDues ? _dueRedBg : _successGreenBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasDues ? Icons.warning_amber_rounded : Icons.verified_rounded,
            size: 18.sp,
            color: hasDues ? _dueRed : _successGreen,
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              hasDues ? _rupees.format(dues) : 'Clear',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: hasDues ? _dueRed : _successGreen,
              ),
            ),
          ),
          Text(
            'Dues',
            style: TextStyle(
              fontSize: 11.sp,
              color: (hasDues ? _dueRed : _successGreen).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Payment History',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(width: 8.w),
        if (_payments.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.totalBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${_payments.length}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.totalBlueText,
              ),
            ),
          ),
      ],
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
            'No payment history found',
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

  Widget _buildTimelineItem(
    TenantPaymentItemEntity p, {
    required bool isFirst,
    required bool isLast,
  }) {
    final style = _statusStyle(p.status);
    final isPaid = style.label == 'Paid';
    final amount = isPaid || p.paidAmount > 0 ? p.paidAmount : p.totalAmount;
    final breakdown = <(String, double)>[
      if ((p.rent ?? 0) > 0) ('Rent', p.rent!),
      if ((p.deposit ?? 0) > 0) ('Deposit', p.deposit!),
      if ((p.maintenance ?? 0) > 0) ('Maintenance', p.maintenance!),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36.w,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 18.h,
                  color: isFirst
                      ? Colors.transparent
                      : AppColors.roomCardBorder,
                ),
                _buildMethodBadge(p.paymentType, style.color),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : AppColors.roomCardBorder,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.roomCardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPaid ? 'Payment Received' : 'Payment Due',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatDate(
                                p.paymentDate ?? p.month,
                                'd MMM yyyy, h:mm a',
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyText,
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
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? AppColors.darkText : style.color,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _buildChip(
                            style.label,
                            style.color,
                            style.background,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _buildChip(
                        p.paymentType.toUpperCase(),
                        AppColors.totalBlueText,
                        AppColors.totalBlue,
                      ),
                      if (!isPaid && (p.dueDate ?? '').isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          'Due ${_formatDate(p.dueDate, 'd MMM yyyy')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: style.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (breakdown.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          for (final (label, value) in breakdown)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 3.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                                  Text(
                                    _rupees.format(value),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge(String method, Color statusColor) {
    if (method.toUpperCase() == 'RAZORPAY') {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset('assets/images/login_logo.jpg', fit: BoxFit.cover),
        ),
      );
    }

    final icon = switch (method.toUpperCase()) {
      'UPI' => Icons.qr_code_2_rounded,
      'CASH' => Icons.payments_rounded,
      'CARD' => Icons.credit_card_rounded,
      'BANK' || 'BANK_TRANSFER' || 'NEFT' => Icons.account_balance_rounded,
      _ => Icons.currency_rupee_rounded,
    };

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: 18.sp, color: statusColor),
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
