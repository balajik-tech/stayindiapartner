import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/revenue_history_cubit.dart';
import 'package:stayindia_owner/features/finance/domain/entities/revenue_history_item.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:intl/intl.dart';

class RevenueHistoryPage extends StatefulWidget {
  const RevenueHistoryPage({super.key});

  @override
  State<RevenueHistoryPage> createState() => _RevenueHistoryPageState();
}

class _RevenueHistoryPageState extends State<RevenueHistoryPage> {
  String _selectedType = 'ALL';
  String? _selectedHostelId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      _selectedHostelId ??= hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    context.read<RevenueHistoryCubit>().fetchRevenueHistory(
          hostelId: _selectedHostelId,
          type: _selectedType == 'ALL' ? null : _selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: Text(
          'Revenue History',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<RevenueHistoryCubit, RevenueHistoryState>(
              builder: (context, state) {
                if (state is RevenueHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RevenueHistoryError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                if (state is RevenueHistoryLoaded) {
                  if (state.items.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) => _RevenueItemCard(item: state.items[index]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      color: Colors.white,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedType == 'ALL',
            onSelected: () => _updateType('ALL'),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'Rent',
            isSelected: _selectedType == 'RENT',
            onSelected: () => _updateType('RENT'),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'Maintenance',
            isSelected: _selectedType == 'MAINTENANCE',
            onSelected: () => _updateType('MAINTENANCE'),
          ),
        ],
      ),
    );
  }

  void _updateType(String type) {
    setState(() => _selectedType = type);
    _fetchData();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No revenue history found',
            style: TextStyle(fontSize: 16.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.greyText,
          ),
        ),
      ),
    );
  }
}

class _RevenueItemCard extends StatelessWidget {
  final RevenueHistoryItem item;

  const _RevenueItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.tenantName,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '₹${item.total.toInt()}',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            item.hostelName,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AmountRow(label: 'Rent', amount: item.rent),
                  SizedBox(height: 4.h),
                  _AmountRow(label: 'Maintenance', amount: item.maintenance),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(item.paymentDate),
                    style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                  ),
                  Text(
                    item.month,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;

  const _AmountRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
        Text('₹${amount.toInt()}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.darkText)),
      ],
    );
  }
}
