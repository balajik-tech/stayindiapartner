import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import '../../domain/entities/financial_entities.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenueTrend> trends;

  const RevenueChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        ),
      );
    }

    final displayTrends = List<RevenueTrend>.from(trends);
    if (displayTrends.length == 1) {
      displayTrends.insert(
        0,
        RevenueTrend(
          date: displayTrends[0].date,
          revenue: displayTrends[0].revenue,
          count: 0,
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (displayTrends.length / 5).clamp(1, 100).toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < displayTrends.length) {
                  final date = displayTrends[index].date;
                  final displayDate =
                      date.length >= 2 ? date.substring(date.length - 2) : date;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      displayDate,
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}k'
                        : value.toStringAsFixed(0),
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: displayTrends
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                .toList(),
            isCurved: true,
            color: AppColors.primaryBlue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: trends.length == 1),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
