import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/unified_header.dart';
import 'package:stayindia_owner/features/stock_management/presentation/cubit/stock_cubit.dart';
import 'package:stayindia_owner/features/stock_management/presentation/cubit/stock_state.dart';
import 'package:stayindia_owner/features/stock_management/domain/entities/stock_item.dart';
import 'package:stayindia_owner/features/stock_management/core/stock_constants.dart';
import 'package:stayindia_owner/features/stock_management/presentation/widgets/numpad_entry_sheet.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';

class AddUpdateStockPage extends StatefulWidget {
  final String propertyId;

  const AddUpdateStockPage({super.key, required this.propertyId});

  @override
  State<AddUpdateStockPage> createState() => _AddUpdateStockPageState();
}

class _AddUpdateStockPageState extends State<AddUpdateStockPage> {
  String _getActivePropertyId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return widget.propertyId;
  }

  @override
  Widget build(BuildContext context) {
    final isTe = context.locale.languageCode == 'te';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<HostelCubit, HostelState>(
        listenWhen: (prev, curr) =>
            (prev is! HostelLoaded && curr is HostelLoaded) ||
            (prev is HostelLoaded &&
                curr is HostelLoaded &&
                prev.selectedHostelIndex != curr.selectedHostelIndex),
        listener: (context, state) {
          if (state is HostelLoaded && state.hostels.isNotEmpty) {
            final hostelId = state.hostels[state.selectedHostelIndex].id;
            context.read<StockCubit>().loadStocks(hostelId);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Unified Header with back button integrated
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF1E293B), size: 20.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    const Expanded(child: UnifiedHeader()),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Add/Update Stock
                      Text(
                        StringUtils.translate('add_update_stock', context: context),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        StringUtils.translate('in_field_entry', context: context),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF7000),
                        ),
                      ),
                      
                      const Spacer(flex: 1),
  
                      // Entry Cards Grid
                      SizedBox(
                        height: 280.h,
                        child: Row(
                          children: [
                            // Add Vegetables
                            Expanded(
                              child: _buildSelectionCard(
                                title: StringUtils.translate('add_vegetables', context: context),
                                subtitle: isTe ? "కూరగాయలు జోడించు" : "Quick Vegetable Entry",
                                imageAsset: 'assets/images/vegetables_basket.png',
                                accentColor: const Color(0xFF10B981),
                                backgroundColor: const Color(0xFFECFDF5),
                                onTap: () => _showItemSelectorBottomSheet(context, 'Vegetables'),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // Add Main Stock
                            Expanded(
                              child: _buildSelectionCard(
                                title: StringUtils.translate('add_main_stock', context: context),
                                subtitle: isTe ? "మెయిన్ స్టాక్ జోడించు" : "Quick Grain/Pantry Entry",
                                imageAsset: 'assets/images/grain_sack.png',
                                accentColor: const Color(0xFFD97706),
                                backgroundColor: const Color(0xFFFEF3C7),
                                onTap: () => _showItemSelectorBottomSheet(context, 'Main'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required String imageAsset,
    required Color accentColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled Graphic Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1.5),
                ),
                padding: EdgeInsets.all(12.r),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_shopping_cart_rounded, color: accentColor, size: 48.sp),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showItemSelectorBottomSheet(BuildContext context, String type) {
    final isTe = context.locale.languageCode == 'te';
    final List<Map<String, String>> masterList = [];

    // Filter master items based on type selection
    if (type == 'Vegetables') {
      masterList.addAll(StockConstants.masterList['Vegetables']!);
    } else {
      masterList.addAll(StockConstants.masterList['Grocery']!);
      if (StockConstants.masterList['Cleaning'] != null) {
        masterList.addAll(StockConstants.masterList['Cleaning']!);
      }
      if (StockConstants.masterList['Other'] != null) {
        masterList.addAll(StockConstants.masterList['Other']!);
      }
    }

    final stockCubit = context.read<StockCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        String searchQuery = '';
        return BlocProvider.value(
          value: stockCubit,
          child: StatefulBuilder(
            builder: (stateContext, setModalState) {
            // Apply search filter locally
            final filteredList = masterList.where((item) {
              final name = item['name'] ?? '';
              final nameTe = StockConstants.getLocalizedNameForString(name, context.locale.languageCode);
              return name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  nameTe.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: 0.75.sh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type == 'Vegetables'
                            ? (isTe ? "కూరగాయల జాబితా" : "Vegetables Inventory")
                            : (isTe ? "ప్రధాన స్టాక్ జాబితా" : "Main Stock Inventory"),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Search Bar
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: isTe ? "వస్తువును వెతకండి..." : "Search item...",
                        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (itemContext, index) {
                        final item = filteredList[index];
                        final itemName = item['name'] ?? '';
                        final itemUnit = item['unit'] ?? 'KG';
                        final itemTe = StockConstants.getLocalizedNameForString(itemName, context.locale.languageCode);

                        return BlocBuilder<StockCubit, StockState>(
                          builder: (cubitContext, state) {
                            // Find existing StockItem in state
                            final StockItem? existingItem = state.items.cast<StockItem?>().firstWhere(
                                  (i) => i != null && i.name.toLowerCase() == itemName.toLowerCase(),
                                  orElse: () => null,
                                );

                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                leading: Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: type == 'Vegetables'
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      type == 'Vegetables' ? Icons.eco_rounded : Icons.inventory_2_rounded,
                                      color: type == 'Vegetables' ? const Color(0xFF10B981) : const Color(0xFFD97706),
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  itemName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: Text(
                                  isTe || itemTe != itemName ? itemTe : itemUnit,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                                onTap: () {
                                  Navigator.pop(modalContext); // Close Selector Sheet
                                  
                                  // Find the correct category from StockConstants.getAllItems()
                                  final allMasterItems = StockConstants.getAllItems();
                                  final matchedItem = allMasterItems.firstWhere(
                                    (element) => element['name']?.toLowerCase() == itemName.toLowerCase(),
                                    orElse: () => <String, String>{},
                                  );
                                  final actualCategory = matchedItem['category'] ?? (type == 'Vegetables' ? 'Vegetables' : 'Grocery');

                                  // Open custom numpad keyboard
                                  _showNumpadBottomSheet(
                                    context,
                                    itemName: itemName,
                                    category: actualCategory,
                                    defaultUnit: itemUnit,
                                    existingItem: existingItem,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

  void _showNumpadBottomSheet(
    BuildContext context, {
    required String itemName,
    required String category,
    required String defaultUnit,
    required StockItem? existingItem,
  }) {
    final stockCubit = context.read<StockCubit>();
    final activePropertyId = _getActivePropertyId(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: stockCubit,
          child: NumpadEntrySheet(
            itemName: itemName,
            category: category,
            defaultUnit: defaultUnit,
            propertyId: activePropertyId,
            existingItem: existingItem,
            onSubmitted: () {
              // Reload stocks to update dashboard state
              stockCubit.loadStocks(activePropertyId);
            },
          ),
        );
      },
    );
  }
}
