import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const TenantHistoryPage({
    super.key,
    required this.tenantName,
    required this.payments,
    this.checkInDate,
    this.tenantId,
  });

  @override
  State<TenantHistoryPage> createState() => _TenantHistoryPageState();
}

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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildSummaryRow(),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_payments.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Text(
                    'No payment history found',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              )
            else
              _buildTimelineList(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tenant History',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _tenantName,
            style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.greyText),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final double totalPaid = _payments.fold(0, (sum, p) => sum + p.paidAmount);
    final String totalPaidStr = totalPaid >= 1000
        ? '${(totalPaid / 1000).toStringAsFixed(1)}K'
        : totalPaid.toStringAsFixed(0);

    String daysStr = '0';
    if (_checkInDate != null && _checkInDate!.isNotEmpty) {
      try {
        final startDt = DateTime.parse(_checkInDate!).toLocal();
        final now = DateTime.now();
        final startZero = DateTime(startDt.year, startDt.month, startDt.day);
        final nowZero = DateTime(now.year, now.month, now.day);
        final diff = nowZero.difference(startZero).inDays;
        daysStr = (diff >= 0 ? diff + 1 : 0).toString();
      } catch (_) {
        if (_daysSinceFirstRental != null) {
          daysStr = (_daysSinceFirstRental! + 1).toString();
        }
      }
    } else if (_daysSinceFirstRental != null) {
      daysStr = (_daysSinceFirstRental! + 1).toString();
    }

    final String transfersStr = _totalTransactions != null
        ? _totalTransactions.toString()
        : '0';

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(daysStr, 'Days', Icons.access_time),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildSummaryCard(
              totalPaidStr,
              'Total Paid',
              Icons.currency_rupee,
              valueColor: const Color(0xFF27C26C),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildSummaryCard(
              transfersStr,
              'Transfers',
              Icons.swap_horiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.greyText),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final p = _payments[index];

          return _buildTimelineItem(
            isFirst: index == 0,
            isLast: index == _payments.length - 1,
            month: _formatMonth(p.month),
            date: p.paymentDate != null ? _formatDate(p.paymentDate!) : '',
            amount: p.paidAmount.toStringAsFixed(0),
            method: p.paymentType,
            rent: p.rent,
            deposit: p.deposit,
            maintenance: p.maintenance,
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}${_getDaySuffix(dt.day)}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _formatMonth(String monthStr) {
    if (monthStr.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(monthStr);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      if (dt != null) {
        return '${months[dt.month - 1]} ${dt.year}';
      }
      final parts = monthStr.split('-');
      if (parts.length >= 2) {
        final m = int.parse(parts[1]) - 1;
        if (m >= 0 && m < 12) {
          return '${months[m]} ${parts[0]}';
        }
      }
      return monthStr;
    } catch (_) {
      return monthStr;
    }
  }

  Widget _buildTimelineItem({
    required bool isFirst,
    required bool isLast,
    required String month,
    required String date,
    required String amount,
    required String method,
    double? rent,
    double? deposit,
    double? maintenance,
  }) {
    final hasBreakdown = rent != null || deposit != null || maintenance != null;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 20.h,
                color: isFirst ? Colors.transparent : Colors.grey[300],
              ),
              (method.toUpperCase() == 'RAZORPAY')
                  ? Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/login_logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF27C26C),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.money,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.grey[300],
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h, top: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Received',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            month,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.roomCardBorder,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              method,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (hasBreakdown) ...[
                    SizedBox(height: 12.h),
                    Divider(
                      height: 1,
                      color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (rent != null) _buildBreakdownItem('Rent', rent),
                        if (deposit != null)
                          _buildBreakdownItem('Security Deposit', deposit),
                        if (maintenance != null)
                          _buildBreakdownItem('Maintenance', maintenance),
                      ],
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

  Widget _buildBreakdownItem(String label, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.greyText),
        ),
        SizedBox(height: 2.h),
        Text(
          '₹${val.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
