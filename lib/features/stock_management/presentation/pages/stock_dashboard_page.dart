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
import 'package:stayindia_owner/core/utils/string_utils.dart';

class StockDashboardPage extends StatefulWidget {
  const StockDashboardPage({super.key});

  @override
  State<StockDashboardPage> createState() => _StockDashboardPageState();
}

class _StockDashboardPageState extends State<StockDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Grocery',
    'Vegetables',
    'Cleaning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStocks({String? search, String? category}) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<StockCubit>().loadStocks(
        hostelId,
        search:
            search ??
            (_searchController.text.isEmpty ? null : _searchController.text),
        category: (category ?? _selectedCategory) == 'All'
            ? null
            : (category ?? _selectedCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state is! StockError)
                        _buildSummaryCards(state.summary),
                      SizedBox(height: 24.h),
                      _buildSearchAndFilter(),
                      SizedBox(height: 16.h),
                      _buildCategoryChips(),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
              if (state is StockLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is StockError)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.message}')),
                )
              else if (state.items.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildStockItemCard(state.items[index]),
                      childCount: state.items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2C5990),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Text(
          StringUtils.translate('stock_management', context: context),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C5990), Color(0xFF1E3A8A)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return Row(
      children: [
        Expanded(
          child: _buildCompactMetricCard(
            StringUtils.translate('total_value', context: context),
            NumberFormat.currency(
              symbol: '₹',
              decimalDigits: 0,
            ).format(summary['totalValue'] ?? 0),
            Icons.account_balance_wallet_rounded,
            const Color(0xFF10B981),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildCompactMetricCard(
            StringUtils.translate('low_stock', context: context),
            (summary['lowStockCount'] ?? 0).toString(),
            Icons.warning_amber_rounded,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _loadStocks(search: val),
        decoration: InputDecoration(
          hintText: StringUtils.translate(
            'search_stock_hint',
            context: context,
          ),
          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF64748B),
            size: 22.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 20.sp),
                  onPressed: () {
                    _searchController.clear();
                    _loadStocks(search: '');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                StringUtils.translate(cat.toLowerCase(), context: context),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = cat);
                  _loadStocks(category: cat);
                }
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
              selectedColor: const Color(0xFF2C5990),
              backgroundColor: Colors.white,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockItemCard(StockItem item) {
    Color statusColor = const Color(0xFF10B981);
    String statusText = StringUtils.translate('in_stock', context: context);

    if (item.currentQuantity <= 0) {
      statusColor = const Color(0xFFEF4444);
      statusText = StringUtils.translate('out_of_stock', context: context);
    } else if (item.currentQuantity <= item.minimumThreshold) {
      statusColor = const Color(0xFFF59E0B);
      statusText = StringUtils.translate('low_stock', context: context);
    }

    return BouncingWrapper(
      onTap: () {
        final stockCubit = context.read<StockCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: stockCubit,
              child: StockDetailPage(item: item),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(
                  item.category == 'Vegetables'
                      ? Icons.eco_rounded
                      : item.category == 'Cleaning'
                      ? Icons.clean_hands_rounded
                      : Icons.inventory_2_rounded,
                  color: statusColor,
                  size: 26.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StockConstants.getLocalizedNameForEntity(
                      item,
                      context.locale.languageCode,
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '₹${item.pricePerUnit}/${item.unit}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: item.currentQuantity
                            .toStringAsFixed(1)
                            .replaceAll(RegExp(r'\.0$'), ''),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      TextSpan(
                        text: ' ${item.unit}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        final hostelState = context.read<HostelCubit>().state;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          final hostelId =
              hostelState.hostels[hostelState.selectedHostelIndex].id;
          final stockCubit = context.read<StockCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: stockCubit,
                child: AddStockItemPage(propertyId: hostelId),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                StringUtils.translate('add_property_first', context: context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      backgroundColor: const Color(0xFF2C5990),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        StringUtils.translate('new_item', context: context),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14.sp,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 16.h),
          Text(
            StringUtils.translate('no_matching_items', context: context),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            StringUtils.translate('adjust_search_filters', context: context),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
