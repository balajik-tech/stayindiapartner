import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/unified_header.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../domain/entities/stock_item.dart';
import '../../core/stock_constants.dart';
import '../widgets/numpad_entry_sheet.dart';
import 'stock_detail_page.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  void _loadStocks() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<StockCubit>().loadStocks(hostelId);
    }
  }

  String _getActivePropertyId() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = context.locale.languageCode == 'te';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<HostelCubit, HostelState>(
        listenWhen: (prev, curr) =>
            (prev is! HostelLoaded && curr is HostelLoaded) ||
            (prev is HostelLoaded &&
                curr is HostelLoaded &&
                prev.selectedHostelIndex != curr.selectedHostelIndex),
        listener: (context, state) {
          _loadStocks();
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
                child: BlocBuilder<StockCubit, StockState>(
                  builder: (context, state) {
                    final allowedNames = {'mixed vegetables', 'rice', 'atta', 'gas'};
                    final items = List<StockItem>.from(
                      state.items.where((i) => allowedNames.contains(i.name.toLowerCase())),
                    );

                    final mixedVeg = items.firstWhere(
                      (i) => i.name.toLowerCase() == 'mixed vegetables',
                      orElse: () => StockItem(
                        id: '',
                        propertyId: '',
                        name: 'Mixed Vegetables',
                        category: 'Vegetables',
                        unit: 'KG',
                        currentQuantity: 0,
                        minimumThreshold: 5,
                        pricePerUnit: 0,
                        createdBy: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    final rice = items.firstWhere(
                      (i) => i.name.toLowerCase() == 'rice',
                      orElse: () => StockItem(
                        id: '',
                        propertyId: '',
                        name: 'Rice',
                        category: 'Grocery',
                        unit: 'KG',
                        currentQuantity: 0,
                        minimumThreshold: 10,
                        pricePerUnit: 0,
                        createdBy: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    final atta = items.firstWhere(
                      (i) => i.name.toLowerCase() == 'atta',
                      orElse: () => StockItem(
                        id: '',
                        propertyId: '',
                        name: 'Atta',
                        category: 'Grocery',
                        unit: 'KG',
                        currentQuantity: 0,
                        minimumThreshold: 10,
                        pricePerUnit: 0,
                        createdBy: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    final gas = items.firstWhere(
                      (i) => i.name.toLowerCase() == 'gas',
                      orElse: () => StockItem(
                        id: '',
                        propertyId: '',
                        name: 'Gas',
                        category: 'Other',
                        unit: 'PCS',
                        currentQuantity: 0,
                        minimumThreshold: 1,
                        pricePerUnit: 0,
                        createdBy: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );

                    final displayItems = [mixedVeg, rice, atta, gas]
                        .where((item) => item.id.isNotEmpty)
                        .toList();
                    final lowStockItems = displayItems.where((item) =>
                        item.currentQuantity <= item.minimumThreshold).toList();

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Localized Screen Title
                                Text(
                                  StringUtils.translate('inventory_overview', context: context),
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  isTelugu ? "మీ హాస్టల్ స్టాక్ మరియు సామాగ్రి నిర్వహణ" : "Manage your property inventory and supplies",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // STOCK ALERTS Section
                                if (lowStockItems.isNotEmpty) ...[
                                  ...lowStockItems.map((item) => Column(
                                    children: [
                                      _buildStockAlertsCard(context, item, isTelugu),
                                      SizedBox(height: 12.h),
                                    ],
                                  )),
                                  SizedBox(height: 8.h),
                                ],

                                // Quick Add Grid
                                _buildQuickAddGrid(context, items, isTelugu),
                                SizedBox(height: 24.h),

                                // Stock Levels Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isTelugu ? "స్టాక్ స్థాయిలు" : "Stock Levels",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                              ],
                            ),
                          ),
                        ),
                        if (state is StockLoading && items.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state is StockError && items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text('Error: ${state.message}')),
                          )
                        else if (displayItems.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48.sp,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    isTelugu ? "ఇంకా స్టాక్ వివరాలు నమోదు చేయలేదు" : "No stock data entered yet",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    isTelugu ? "స్టాక్ జోడించడానికి పైన ఉన్న బటన్లపై క్లిక్ చేయండి" : "Tap on any quick add item to register stock levels",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index >= displayItems.length) return null;
                                  return _buildStockItemCard(displayItems[index]);
                                },
                                childCount: displayItems.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
    final activePropertyId = _getActivePropertyId();

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
              stockCubit.loadStocks(activePropertyId);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickAddGrid(BuildContext context, List<StockItem> items, bool isTelugu) {
    final mixedVegItem = items.cast<StockItem?>().firstWhere((i) => i != null && i.name.toLowerCase() == 'mixed vegetables', orElse: () => null);
    final riceItem = items.cast<StockItem?>().firstWhere((i) => i != null && i.name.toLowerCase() == 'rice', orElse: () => null);
    final attaItem = items.cast<StockItem?>().firstWhere((i) => i != null && i.name.toLowerCase() == 'atta', orElse: () => null);
    final gasItem = items.cast<StockItem?>().firstWhere((i) => i != null && i.name.toLowerCase() == 'gas', orElse: () => null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTelugu ? "త్వరిత స్టాక్ జోడింపు" : "Quick Add Stock",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 2.2,
          children: [
            _buildQuickAddButton(
              title: isTelugu ? 'కూరగాయలు' : 'Vegetables',
              subtitle: 'Mixed Vegetables',
              icon: Icons.eco_rounded,
              color: const Color(0xFF10B981),
              imagePath: 'assets/images/vegetables_basket.png',
              onTap: () => _showNumpadBottomSheet(
                context,
                itemName: 'Mixed Vegetables',
                category: 'Vegetables',
                defaultUnit: 'KG',
                existingItem: mixedVegItem,
              ),
            ),
            _buildQuickAddButton(
              title: isTelugu ? 'బియ్యం' : 'Rice',
              subtitle: 'Rice Stock',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFD97706),
              imagePath: 'assets/images/grain_sack.png',
              onTap: () => _showNumpadBottomSheet(
                context,
                itemName: 'Rice',
                category: 'Grocery',
                defaultUnit: 'KG',
                existingItem: riceItem,
              ),
            ),
            _buildQuickAddButton(
              title: isTelugu ? 'గోధుమ పిండి' : 'Atta',
              subtitle: 'Atta Flour',
              icon: Icons.bakery_dining_rounded,
              color: const Color(0xFFFF7000),
              imagePath: 'assets/images/grain_sack.png',
              onTap: () => _showNumpadBottomSheet(
                context,
                itemName: 'Atta',
                category: 'Grocery',
                defaultUnit: 'KG',
                existingItem: attaItem,
              ),
            ),
            _buildQuickAddButton(
              title: isTelugu ? 'గ్యాస్' : 'Gas',
              subtitle: 'LPG Cylinder',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFEF4444),
              imagePath: 'assets/images/lpg_cylinder.png',
              onTap: () => _showNumpadBottomSheet(
                context,
                itemName: 'Gas',
                category: 'Other',
                defaultUnit: 'PCS',
                existingItem: gasItem,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getItemImagePath(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('vegetable')) {
      return 'assets/images/vegetables_basket.png';
    } else if (name == 'rice' || name == 'atta') {
      return 'assets/images/grain_sack.png';
    } else if (name == 'gas') {
      return 'assets/images/lpg_cylinder.png';
    }
    return '';
  }

  Widget _buildQuickAddButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    icon,
                    color: color,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAlertMessage(StockItem item, bool isTelugu) {
    final name = item.name.toLowerCase();
    final qtyStr = item.currentQuantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    final unitStr = item.unit.toLowerCase() == 'pcs'
        ? (isTelugu ? 'ముక్కలు' : 'pieces')
        : (isTelugu ? 'కిలోలు' : 'kg');

    if (name.contains('vegetable')) {
      return isTelugu
          ? "🚨 కూరగాయలు తక్కువగా ఉన్నాయి! కేవలం $qtyStr $unitStr మాత్రమే ఉన్నాయి! ఇప్పుడే ఆర్డర్ చేయండి!"
          : "🚨 VEGETABLES ARE LOW! Only $qtyStr $unitStr left! Order now!";
    } else if (name == 'rice') {
      return isTelugu
          ? "🚨 బియ్యం తక్కువగా ఉంది! కేవలం $qtyStr $unitStr మాత్రమే ఉంది! ఇప్పుడే ఆర్డర్ చేయండి!"
          : "🚨 RICE IS LOW! Only $qtyStr $unitStr left! Order now!";
    } else if (name == 'atta') {
      return isTelugu
          ? "🚨 గోధుమ పిండి తక్కువగా ఉంది! కేవలం $qtyStr $unitStr మాత్రమే ఉంది! ఇప్పుడే ఆర్డర్ చేయండి!"
          : "🚨 ATTA IS LOW! Only $qtyStr $unitStr left! Order now!";
    } else if (name == 'gas') {
      return isTelugu
          ? "🚨 గ్యాస్ తక్కువగా ఉంది! కేవలం $qtyStr $unitStr మాత్రమే ఉంది! ఇప్పుడే ఆర్డర్ చేయండి!"
          : "🚨 GAS IS LOW! Only $qtyStr $unitStr left! Order now!";
    }
    return isTelugu
        ? "🚨 ${item.name} తక్కువగా ఉంది! కేవలం $qtyStr $unitStr మాత్రమే ఉంది!"
        : "🚨 ${item.name.toUpperCase()} IS LOW! Only $qtyStr $unitStr left!";
  }

  Widget _buildStockAlertsCard(BuildContext context, StockItem item, bool isTelugu) {
    final alertMessage = _getAlertMessage(item, isTelugu);
    final imagePath = _getItemImagePath(item.name);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFEF2F2),
            const Color(0xFFFEE2E2),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFDC2626),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      StringUtils.translate('stock_alerts', context: context),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  alertMessage,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF991B1B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Image.asset(
            imagePath,
            width: 50.w,
            height: 50.w,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFCA5A5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28.sp),
            ),
          ),
        ],
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
        if (item.id.isEmpty) {
          _showNumpadBottomSheet(
            context,
            itemName: item.name,
            category: item.category,
            defaultUnit: item.unit,
            existingItem: null,
          );
        } else {
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
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  _getItemImagePath(item.name),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      item.category == 'Vegetables'
                          ? Icons.eco_rounded
                          : item.category == 'Cleaning'
                              ? Icons.clean_hands_rounded
                              : Icons.inventory_2_rounded,
                      color: statusColor,
                      size: 24.sp,
                    ),
                  ),
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
                      fontSize: 15.sp,
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
                      if (item.pricePerUnit > 0) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '₹${item.pricePerUnit.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}/${item.unit}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                        text: item.currentQuantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
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
}
