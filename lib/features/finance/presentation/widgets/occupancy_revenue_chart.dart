import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';

class OccupancyRevenueChart extends StatelessWidget {
  final int occupied;
  final int total;

  const OccupancyRevenueChart({super.key, required this.occupied, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const Center(child: Text('No rooms available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total.toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold, fontSize: 12);
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Occupied';
                    break;
                  case 1:
                    text = 'Available';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(meta: meta, space: 4, child: Text(text, style: style));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: occupied.toDouble(),
                color: AppColors.primaryBlue,
                width: 40.w,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: (total - occupied).toDouble(),
                color: const Color(0xFFE9ECEF),
                width: 40.w,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
