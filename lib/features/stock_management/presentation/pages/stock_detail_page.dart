import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_transaction.dart';
import '../../core/stock_constants.dart';

class StockDetailPage extends StatefulWidget {
  final StockItem item;
  const StockDetailPage({super.key, required this.item});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<StockCubit>().loadItemDetail(widget.item.id);
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

          StockItem currentItem = widget.item;
          List<StockTransaction> history = [];

          if (state is StockItemDetailLoaded) {
            currentItem = state.item;
            history = state.history;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(currentItem),
                SizedBox(height: 32.h),
                _buildActionButtons(currentItem),
                SizedBox(height: 32.h),
                Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A1A)),
                ),
                SizedBox(height: 16.h),
                if (history.isEmpty)
                  _buildEmptyHistory()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) => _buildTransactionCard(history[index], currentItem.unit),
                  ),
              ],
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Item Details',
        style: TextStyle(color: const Color(0xFF1A1A1A), fontSize: 20.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildInfoCard(StockItem item) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(color: const Color(0xFF2C5990).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16.r)),
                child: Center(
                  child: Icon(Icons.inventory_2_rounded, color: const Color(0xFF2C5990), size: 32.sp),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StockConstants.getLocalizedNameForEntity(item, 'en'),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A1A)),
                    ),
                    if (StockConstants.getLocalizedNameForEntity(item, 'en').toLowerCase() != item.name.toLowerCase())
                      Text(
                        item.name,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    Text(item.category, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(color: Color(0xFFF1F5F9)),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Current Stock', '${item.currentQuantity} ${item.unit}'),
              _buildMetric('Unit Price', '₹${item.pricePerUnit}'),
              _buildMetric('Min Level', '${item.minimumThreshold} ${item.unit}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF111827))),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildActionButtons(StockItem item) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Add Stock',
            icon: Icons.add_circle_outline_rounded,
            color: const Color(0xFF10B981),
            onTap: () => _showTransactionModal(item, 'IN'),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionButton(
            label: 'Consume',
            icon: Icons.remove_circle_outline_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => _showTransactionModal(item, 'OUT'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(StockTransaction tx, String unit) {
    final isAdd = tx.type == 'IN';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: (isAdd ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAdd ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isAdd ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 16.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdd ? 'Stock Refill' : 'Stock Consumption',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A)),
                ),
                Text(
                  '${DateFormat('dd MMM').format(tx.entryDate)} • ${tx.paymentMode}',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isAdd ? '+' : '-'}${tx.quantity} $unit',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: isAdd ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              if (tx.totalCost > 0)
                Text(
                  '₹${tx.totalCost}',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionModal(StockItem item, String type) {
    final quantityController = TextEditingController();
    final costController = TextEditingController();
    final noteController = TextEditingController();
    final stockCubit = context.read<StockCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 32.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text(type == 'IN' ? 'Add Stock' : 'Consume Stock', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A1A))),
            SizedBox(height: 24.h),
            _buildModalField('Quantity (${item.unit})', quantityController, keyboardType: TextInputType.number),
            if (type == 'IN') ...[
              SizedBox(height: 16.h),
              _buildModalField('Total Cost (₹)', costController, keyboardType: TextInputType.number),
            ],
            SizedBox(height: 16.h),
            _buildModalField('Note (Optional)', noteController),
            SizedBox(height: 32.h),
            BouncingWrapper(
              onTap: () {
                final qty = double.tryParse(quantityController.text) ?? 0;
                if (qty <= 0) return;
                
                if (type == 'IN') {
                  final cost = double.tryParse(costController.text) ?? 0;
                  final pricePerUnit = cost > 0 && qty > 0 ? cost / qty : item.pricePerUnit;
                  stockCubit.addStockTransaction(
                    item.id, 
                    item.propertyId, 
                    qty, 
                    pricePerUnit, 
                    cost, 
                    'Cash', 
                    DateTime.now(), 
                    noteController.text
                  );
                } else {
                  stockCubit.consumeStockTransaction(item.id, item.propertyId, qty, noteController.text);
                }
                Navigator.pop(context);
              },
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFF2C5990), borderRadius: BorderRadius.circular(18.r)),
                child: Center(child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B))),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Icon(Icons.history_toggle_off_rounded, size: 48.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 12.h),
          Text('No transactions yet', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
