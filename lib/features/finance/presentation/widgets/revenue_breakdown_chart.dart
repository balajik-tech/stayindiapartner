import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import '../../domain/entities/financial_entities.dart';
import 'package:intl/intl.dart';

class RevenueBreakdownChart extends StatelessWidget {
  final FinancialStats stats;

  const RevenueBreakdownChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final double monthlyRent = stats.totalRevenue -
        stats.securityDeposit -
        stats.maintenance -
        stats.dailyRent;

    final double total = stats.totalRevenue;

    if (total <= 0) {
      return Center(
        child: Text(
          'No revenue data available',
          style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        ),
      );
    }

    final currencyFormat = NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30.r,
              sections: [
                if (monthlyRent > 0)
                  PieChartSectionData(
                    color: AppColors.primaryBlue,
                    value: monthlyRent,
                    title: '',
                    radius: 30.r,
                  ),
                if (stats.dailyRent > 0)
                  PieChartSectionData(
                    color: const Color(0xFF0C8599),
                    value: stats.dailyRent,
                    title: '',
                    radius: 30.r,
                  ),
                if (stats.securityDeposit > 0)
                  PieChartSectionData(
                    color: const Color(0xFF6741D9),
                    value: stats.securityDeposit,
                    title: '',
                    radius: 30.r,
                  ),
                if (stats.maintenance > 0)
                  PieChartSectionData(
                    color: const Color(0xFFE8590C),
                    value: stats.maintenance,
                    title: '',
                    radius: 30.r,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(context, 'monthly_rent', AppColors.primaryBlue, monthlyRent, currencyFormat),
              if (stats.dailyRent > 0) ...[
                SizedBox(height: 8.h),
                _buildLegend(context, 'daily_rent', const Color(0xFF0C8599), stats.dailyRent, currencyFormat),
              ],
              if (stats.securityDeposit > 0) ...[
                SizedBox(height: 8.h),
                _buildLegend(context, 'security_deposit', const Color(0xFF6741D9), stats.securityDeposit, currencyFormat),
              ],
              if (stats.maintenance > 0) ...[
                SizedBox(height: 8.h),
                _buildLegend(context, 'maintenance', const Color(0xFFE8590C), stats.maintenance, currencyFormat),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, String key, Color color, double amount, NumberFormat format) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringUtils.translate(key, context: context),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                format.format(amount),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
