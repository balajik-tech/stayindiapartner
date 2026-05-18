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
import 'package:stayindia_owner/core/utils/string_utils.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          StockItem currentItem = widget.item;
          List<StockTransaction> history = [];

          if (state is StockItemDetailLoaded) {
            currentItem = state.item;
            history = state.history;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(currentItem),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(currentItem),
                      SizedBox(height: 24.h),
                      _buildActionButtons(currentItem),
                      SizedBox(height: 32.h),
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 20.sp,
                            color: const Color(0xFF1E293B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            StringUtils.translate(
                              'activity_history',
                              context: context,
                            ),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              if (state is StockLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (history.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyHistory())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTransactionCard(
                        history[index],
                        currentItem.unit,
                      ),
                      childCount: history.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(StockItem item) {
    return SliverAppBar(
      expandedHeight: 140.h,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2C5990),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
        title: Text(
          StockConstants.getLocalizedNameForEntity(
            item,
            context.locale.languageCode,
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
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

  Widget _buildInfoCard(StockItem item) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                StringUtils.translate('current_stock', context: context),
                '${item.currentQuantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${item.unit}',
                const Color(0xFF2C5990),
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: const Color(0xFFF1F5F9),
              ),
              _buildMetric(
                StringUtils.translate('threshold', context: context),
                '${item.minimumThreshold} ${item.unit}',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(color: Color(0xFFF1F5F9)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildDetailItem(
                Icons.category_rounded,
                StringUtils.translate('category_label', context: context),
                item.category,
              ),
              const Spacer(),
              _buildDetailItem(
                Icons.payments_rounded,
                StringUtils.translate('avg_price', context: context),
                '₹${item.pricePerUnit}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF94A3B8)),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(StockItem item) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: StringUtils.translate('refill', context: context),
            icon: Icons.add_box_rounded,
            color: const Color(0xFF10B981),
            onTap: () => _showTransactionModal(item, 'IN'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionButton(
            label: StringUtils.translate('consume', context: context),
            icon: Icons.indeterminate_check_box_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => _showTransactionModal(item, 'OUT'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(StockTransaction tx, String unit) {
    final isAdd = tx.type == 'IN';
    final statusColor = isAdd
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isAdd ? Icons.add_shopping_cart_rounded : Icons.outbox_rounded,
              color: statusColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdd
                      ? StringUtils.translate(
                          'inventory_added',
                          context: context,
                        )
                      : StringUtils.translate(
                          'inventory_used',
                          context: context,
                        ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(tx.entryDate),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isAdd ? '+' : '-'}${tx.quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} $unit',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
              if (tx.totalCost > 0)
                Text(
                  '₹${tx.totalCost.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
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
        padding: EdgeInsets.fromLTRB(
          24.w,
          12.h,
          24.w,
          MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              type == 'IN'
                  ? StringUtils.translate('restock_item', context: context)
                  : StringUtils.translate('consume_item', context: context),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 24.h),
            _buildModalField(
              StringUtils.translate(
                type == 'IN' ? 'qty_to_add' : 'qty_to_remove',
                namedArgs: {'unit': item.unit},
                context: context,
              ),
              quantityController,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            if (type == 'IN') ...[
              SizedBox(height: 16.h),
              _buildModalField(
                StringUtils.translate('total_amount_label', context: context),
                costController,
                keyboardType: TextInputType.number,
              ),
            ],
            SizedBox(height: 16.h),
            _buildModalField(
              StringUtils.translate('add_note_hint', context: context),
              noteController,
            ),
            SizedBox(height: 32.h),
            BouncingWrapper(
              onTap: () {
                final qty = double.tryParse(quantityController.text) ?? 0;
                if (qty <= 0) return;

                if (type == 'IN') {
                  final cost = double.tryParse(costController.text) ?? 0;
                  final pricePerUnit = cost > 0 && qty > 0
                      ? cost / qty
                      : item.pricePerUnit;
                  stockCubit.addStockTransaction(
                    item.id,
                    item.propertyId,
                    qty,
                    pricePerUnit,
                    cost,
                    'Cash',
                    DateTime.now(),
                    noteController.text,
                  );
                } else {
                  stockCubit.consumeStockTransaction(
                    item.id,
                    item.propertyId,
                    qty,
                    noteController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5990),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C5990).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    StringUtils.translate('save_transaction', context: context),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: autofocus,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Icon(
            Icons.history_toggle_off_rounded,
            size: 60.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 16.h),
          Text(
            StringUtils.translate('no_history_found', context: context),
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
