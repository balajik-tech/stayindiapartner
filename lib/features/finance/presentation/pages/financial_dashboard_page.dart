import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/occupancy_revenue_chart.dart';
import '../widgets/metric_card.dart';
import '../../data/services/pdf_export_service.dart';
import 'package:intl/intl.dart';
import 'revenue_history_page.dart';
import '../cubit/revenue_history_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';

class FinancialDashboardPage extends StatefulWidget {
  const FinancialDashboardPage({super.key});

  @override
  State<FinancialDashboardPage> createState() => _FinancialDashboardPageState();
}

class _FinancialDashboardPageState extends State<FinancialDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final hostelState = context.read<HostelCubit>().state;
    String? hostelId;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    context.read<FinanceCubit>().loadDashboard(hostelId: hostelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: _buildAppBar(),
      body: BlocBuilder<FinanceCubit, FinanceState>(
        builder: (context, state) {
          if (state.status == FinanceStatus.loading && state.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primaryBlue,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 32.h),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildMetricGrid(state),
                  SizedBox(height: 32.h),
                  _buildChartSection(
                    title: 'Revenue Trends',
                    subtitle: 'Daily earnings overview',
                    child: RevenueChart(trends: state.revenueTrends),
                  ),
                  SizedBox(height: 24.h),
                  _buildChartSection(
                    title: 'Occupancy vs Capacity',
                    subtitle: 'Beds distribution',
                    child: OccupancyRevenueChart(
                      occupied: state.stats?.occupiedBeds ?? 0,
                      total: state.stats?.totalBeds ?? 0,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Financials',
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 24.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      actions: [
        _buildExportButton(),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildExportButton() {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final hasData = state.stats != null;
        return InkWell(
          onTap: !hasData ? null : () async {
            final hostelState = context.read<HostelCubit>().state;
            String hostelName = 'All Properties';
            if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
              hostelName = hostelState.hostels[hostelState.selectedHostelIndex].name;
            }

            await PdfExportService.exportFinancialReport(
              hostelName: hostelName,
              stats: state.stats!,
              trends: state.revenueTrends,
            );
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: hasData ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.ios_share_rounded,
                  color: hasData ? AppColors.primaryBlue : Colors.grey,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Export',
                  style: TextStyle(
                    color: hasData ? AppColors.primaryBlue : Colors.grey,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
                letterSpacing: -0.5,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => sl<RevenueHistoryCubit>(),
                      child: const RevenueHistoryPage(),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.history_rounded, size: 18.sp, color: AppColors.primaryBlue),
              label: Text(
                'View History',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Real-time data from your properties',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid(FinanceState state) {
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.4,
      children: [
        MetricCard(
          title: 'Total Revenue',
          value: currencyFormat.format(state.stats?.totalRevenue ?? 0),
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.primaryBlue,
        ),
        MetricCard(
          title: 'This Month',
          value: currencyFormat.format(state.stats?.thisMonthRevenue ?? 0),
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF099268),
        ),
        MetricCard(
          title: 'Occupancy',
          value: '${(state.stats?.occupancyRate ?? 0).toStringAsFixed(1)}%',
          icon: Icons.bed_rounded,
          color: const Color(0xFFF08C00),
        ),
        MetricCard(
          title: 'Pending',
          value: currencyFormat.format(state.stats?.pendingPayments ?? 0),
          icon: Icons.hourglass_empty_rounded,
          color: const Color(0xFFE03131),
        ),
      ],
    );
  }

  Widget _buildChartSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.3)),
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
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_horiz_rounded, color: AppColors.greyText.withValues(alpha: 0.5)),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(height: 200.h, child: child),
        ],
      ),
    );
  }
}
