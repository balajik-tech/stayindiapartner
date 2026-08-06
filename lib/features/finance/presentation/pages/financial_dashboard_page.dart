import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/revenue_breakdown_chart.dart';
import '../../data/services/pdf_export_service.dart';
import 'package:intl/intl.dart';
import 'revenue_history_page.dart';
import '../cubit/revenue_history_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

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
      body: BlocListener<HostelCubit, HostelState>(
        listenWhen: (prev, curr) =>
            (prev is! HostelLoaded && curr is HostelLoaded) ||
            (prev is HostelLoaded &&
                curr is HostelLoaded &&
                prev.selectedHostelIndex != curr.selectedHostelIndex),
        listener: (context, state) => _loadData(),
        child: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state.status == FinanceStatus.loading && state.stats == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.primaryBlue,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildPremiumHeader(state),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(),
                        SizedBox(height: 24.h),
                        _buildMetricGrid(state),
                        SizedBox(height: 32.h),
                        _buildChartSection(
                          title: StringUtils.translate(
                            'revenue_trends',
                            context: context,
                          ),
                          subtitle: StringUtils.translate(
                            'daily_earnings_overview',
                            context: context,
                          ),
                          child: RevenueChart(trends: state.revenueTrends),
                        ),
                        SizedBox(height: 24.h),
                        _buildChartSection(
                          title: StringUtils.translate(
                            'revenue_breakdown',
                            context: context,
                          ),
                          subtitle: StringUtils.translate(
                            'revenue_distribution',
                            context: context,
                          ),
                          child: state.stats != null
                              ? RevenueBreakdownChart(stats: state.stats!)
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 24.h),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(FinanceState state) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 54.h, 24.w, 40.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringUtils.translate(
                          'financial_insights',
                          context: context,
                        ),
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        StringUtils.translate(
                          'financial_insights_sub',
                          context: context,
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // _buildExportButton(state), //commend export button
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(FinanceState state) {
    final hasData = state.stats != null;
    return BouncingWrapper(
      onTap: !hasData
          ? null
          : () async {
              final hostelState = context.read<HostelCubit>().state;
              String hostelName = 'All Properties';
              if (hostelState is HostelLoaded &&
                  hostelState.hostels.isNotEmpty) {
                hostelName =
                    hostelState.hostels[hostelState.selectedHostelIndex].name;
              }

              await PdfExportService.exportFinancialReport(
                hostelName: hostelName,
                stats: state.stats!,
                trends: state.revenueTrends,
              );
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.ios_share_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              StringUtils.translate('export', context: context),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
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
              StringUtils.translate('performance_overview', context: context),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
                letterSpacing: -0.5,
              ),
            ),
            // commented history button
            // TextButton.icon(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => BlocProvider(
            //           create: (context) => sl<RevenueHistoryCubit>(),
            //           child: const RevenueHistoryPage(),
            //         ),
            //       ),
            //     );
            //   },
            //   icon: Icon(
            //     Icons.history_rounded,
            //     size: 18.sp,
            //     color: AppColors.primaryBlue,
            //   ),
            //   label: Text(
            //     StringUtils.translate('view_history', context: context),
            //     style: TextStyle(
            //       fontSize: 13.sp,
            //       fontWeight: FontWeight.bold,
            //       color: AppColors.primaryBlue,
            //     ),
            //   ),
            //   style: TextButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            //     backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12.r),
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          StringUtils.translate('real_time_data_hint', context: context),
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
          title: StringUtils.translate('total_revenue', context: context),
          value: currencyFormat.format(state.stats?.totalRevenue ?? 0),
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.primaryBlue,
        ),
        MetricCard(
          title: StringUtils.translate('this_month', context: context),
          value: currencyFormat.format(state.stats?.thisMonthRevenue ?? 0),
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF099268),
        ),
        MetricCard(
          title: StringUtils.translate('occupancy', context: context),
          value: '${(state.stats?.occupancyRate ?? 0).toStringAsFixed(1)}%',
          icon: Icons.bed_rounded,
          color: const Color(0xFFF08C00),
        ),
        MetricCard(
          title: StringUtils.translate('pending_payment', context: context),
          value: currencyFormat.format(state.stats?.pendingPayments ?? 0),
          icon: Icons.hourglass_empty_rounded,
          color: const Color(0xFFE03131),
        ),
        // Commented Cards

        // MetricCard(
        //   title: StringUtils.translate('security_deposit', context: context),
        //   value: currencyFormat.format(state.stats?.securityDeposit ?? 0),
        //   icon: Icons.shield_rounded,
        //   color: const Color(0xFF6741D9),
        // ),
        // MetricCard(
        //   title: StringUtils.translate('maintenance', context: context),
        //   value: currencyFormat.format(state.stats?.maintenance ?? 0),
        //   icon: Icons.build_circle_rounded,
        //   color: const Color(0xFFE8590C),
        // ),
        // MetricCard(
        //   title: StringUtils.translate('daily_rent', context: context),
        //   value: currencyFormat.format(state.stats?.dailyRent ?? 0),
        //   icon: Icons.today_rounded,
        //   color: const Color(0xFF0C8599),
        // ),
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
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.3),
        ),
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
              Icon(
                Icons.more_horiz_rounded,
                color: AppColors.greyText.withValues(alpha: 0.5),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(height: 200.h, child: child),
        ],
      ),
    );
  }
}
