import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../domain/entities/stock_item.dart';
import '../../core/stock_constants.dart';
import 'add_stock_item_page.dart';
import 'stock_detail_page.dart';

class StockDashboardPage extends StatefulWidget {
  const StockDashboardPage({super.key});

  @override
  State<StockDashboardPage> createState() => _StockDashboardPageState();
}

class _StockDashboardPageState extends State<StockDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  void _loadStocks() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<StockCubit>().loadStocks(hostelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: _buildAppBar(),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StockError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is StockLoaded || state is StockItemDetailLoaded || state is StockActionSuccess) {
            return RefreshIndicator(
              onRefresh: () async => _loadStocks(),
              color: const Color(0xFF2C5990),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 80.h),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryGrid(state.summary),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inventory Items',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        _buildFilterButton(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if (state.items.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) => _buildStockItemCard(state.items[index]),
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final hostelState = context.read<HostelCubit>().state;
          if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
             final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
             final stockCubit = context.read<StockCubit>();
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BlocProvider.value(
                value: stockCubit,
                child: AddStockItemPage(propertyId: hostelId),
              )),
            );
          }
        },
        backgroundColor: const Color(0xFF2C5990),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Stock Management',
        style: TextStyle(
          color: const Color(0xFF1A1A1A),
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> summary) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          title: 'Total Items',
          value: summary['totalItems'].toString(),
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF2C5990),
        ),
        _buildMetricCard(
          title: 'Low Stock',
          value: summary['lowStockCount'].toString(),
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFF98125),
        ),
        _buildMetricCard(
          title: 'Total Value',
          value: currencyFormat.format(summary['totalValue']),
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF10B981),
        ),
        _buildMetricCard(
          title: 'Recent Usage',
          value: '${summary['recentUsageCount'] ?? 0} items', 
          icon: Icons.history_rounded,
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF111827)),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockItemCard(StockItem item) {
    Color statusColor = const Color(0xFF10B981); // Green
    String statusText = 'Safe';
    
    if (item.currentQuantity <= 0) {
      statusColor = const Color(0xFFEF4444); // Red
      statusText = 'Critical';
    } else if (item.currentQuantity <= item.minimumThreshold) {
      statusColor = const Color(0xFFF98125); // Orange
      statusText = 'Low Stock';
    }

    return BouncingWrapper(
      onTap: () {
        final stockCubit = context.read<StockCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlocProvider.value(
            value: stockCubit,
            child: StockDetailPage(item: item),
          )),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  item.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2C5990)),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StockConstants.getLocalizedNameForEntity(item, context.locale.languageCode),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A)),
                  ),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.currentQuantity} ${item.unit}',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF111827)),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 16.sp, color: const Color(0xFF4B5563)),
          SizedBox(width: 6.w),
          Text(
            'Filters',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Icon(Icons.inventory_2_outlined, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(
            'No items found',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
          ),
          Text(
            'Add your first stock item to start tracking.',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
