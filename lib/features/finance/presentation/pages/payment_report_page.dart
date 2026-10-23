import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import '../cubit/payment_report_cubit.dart';
import '../cubit/payment_report_state.dart';
import '../../domain/entities/payment_report_entity.dart';
import '../widgets/record_payment_bottom_sheet_new.dart';

class PaymentReportPage extends StatefulWidget {
  const PaymentReportPage({super.key});

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  String? _selectedHostelId;
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    if (_scrollController.position.extentAfter < 300) {
      final state = context.read<PaymentReportCubit>().state;
      if (state is PaymentReportLoaded && !state.isLoadingMore && state.hasMore) {
        final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

        context.read<PaymentReportCubit>().fetchMoreReport(
              hostelId: _selectedHostelId,
              startDate: DateFormat('yyyy-MM-dd').format(startDate),
              endDate: DateFormat('yyyy-MM-dd').format(endDate),
            );
      }
    }
  }

  void _fetchData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      _selectedHostelId ??=
          hostelState.hostels[hostelState.selectedHostelIndex].id;
    }

    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    context.read<PaymentReportCubit>().fetchReport(
      hostelId: _selectedHostelId,
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7FF),
        elevation: 0,
        centerTitle: true,
        title: _buildHostelSelector(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: AppColors.darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<PaymentReportCubit, PaymentReportState>(
        listener: (context, state) {
          if (state is PaymentReportLoaded && state.hasMore && !state.isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                final currentScroll = _scrollController.position.pixels;
                
                // Trigger if content is not scrollable OR if we are near the bottom
                if (maxScroll <= 0 || (maxScroll - currentScroll) < 300) {
                  final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
                  final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
                  context.read<PaymentReportCubit>().fetchMoreReport(
                        hostelId: _selectedHostelId,
                        startDate: DateFormat('yyyy-MM-dd').format(startDate),
                        endDate: DateFormat('yyyy-MM-dd').format(endDate),
                      );
                }
              }
            });
          }
        },
        builder: (context, state) {
          if (state is PaymentReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentReportError) {
            return Center(child: Text(state.message));
          }
          if (state is PaymentReportLoaded) {
            return Container(
              color: Colors.white,
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildSummary(state)),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Text(
                              'Payments received',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ...state.items
                                .where(
                                  (item) =>
                                      _selectedHostelId == null ||
                                      item.hostelId == _selectedHostelId,
                                )
                                .isEmpty
                                ? [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 30.h,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No payments found',
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.grayColor3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : state.items
                                    .where(
                                      (item) =>
                                          _selectedHostelId == null ||
                                          item.hostelId == _selectedHostelId,
                                    )
                                    .map(
                                      (item) => _PaymentItemTile(item: item),
                                    ),
                            if (state.isLoadingMore)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 24.h,
                    left: 20.w,
                    right: 20.w,
                    child: _buildRecordPaymentButton(state),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummary(PaymentReportLoaded state) {
    final summary = state.summary;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Blue header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F7FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _showMonthSheet(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Collected in ${DateFormat('MMMM').format(_selectedDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.darkText,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),

                  Text(
                    currencyFormat.format(summary?.totalCollected ?? 0),
                    style: GoogleFonts.inter(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                      letterSpacing: -1,
                    ),
                  ),

                  Text(
                    '${summary?.paymentCount ?? 0} payments from ${summary?.tenantCount ?? 0} tenants',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayLight,
                    ),
                  ),

                  // Space for overlapping card
                  SizedBox(height: 140.h),
                ],
              ),
            ),

            // White overlapping card
            Positioned(
              left: 20.w,
              right: 20.w,
              top: 130.h,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMethodRow(
                      icon: Icons.hexagon_outlined,
                      imageUrl: 'assets/images/record_app_icon.png',
                      iconColor: const Color(0xFF2C599D),
                      label: 'Via StayIndia',
                      subLabel: 'Settles to your bank',
                      amount: summary?.viaStayIndia ?? 0,
                      onTap: () {},
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(color: Colors.grey.shade100, height: 1),
                    ),

                    _buildMethodRow(
                      icon: Icons.touch_app_outlined,
                      imageUrl: 'assets/images/palm.png',
                      iconColor: AppColors.grayColor2,
                      label: 'Direct',
                      subLabel: 'Cash or your own UPI',
                      amount: summary?.direct ?? 0,
                      onTap: () {},
                    ),

                    if (summary != null && summary.settlingAmount > 0) ...[
                      SizedBox(height: 12.h),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: const Color(0xFFba6f35),
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '₹${summary.settlingAmount.toInt()} settling to your bank tomorrow',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.kAuthOrangeDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        // Space below Stack for the overlapping card
        SizedBox(height: 50.h),
      ],
    );
  }

  Widget _buildHostelSelector() {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        if (state is! HostelLoaded || state.hostels.isEmpty) {
          return const SizedBox();
        }

        final selectedHostel = state.hostels.cast<Hostel>().firstWhere(
          (h) => h.id == _selectedHostelId,
          orElse: () => state.hostels[state.selectedHostelIndex],
        );

        return GestureDetector(
          onTap: () => _showHostelSheet(context, state),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  selectedHostel.name.toLowerCase(),
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkText,
                size: 22.sp,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthSheet(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    DateTime startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, 1); // Default 1 year back


    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostel = hostelState.hostels.cast<Hostel>().firstWhere(
        (h) => h.id == _selectedHostelId,
        orElse: () => hostelState.hostels[hostelState.selectedHostelIndex],
      );
      if (hostel.createdAt != null) {
        startDate = DateTime(hostel.createdAt!.year, hostel.createdAt!.month, 1);
      }
    }

    List<DateTime> months = [];
    DateTime current = DateTime.now();
    DateTime temp = DateTime(current.year, current.month, 1);

    while (temp.isAfter(startDate) ||
        (temp.year == startDate.year && temp.month == startDate.month)) {
      months.add(temp);
      temp = DateTime(temp.year, temp.month - 1, 1);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Month',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.sp),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            StatefulBuilder(
              builder: (context, setSheetState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.5.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];

                      final isSelected =
                          month.year == _selectedDate.year &&
                              month.month == _selectedDate.month;

                      return ListTile(
                        title: Text(
                          DateFormat('MMMM yyyy').format(month),
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.darkText,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF388E3C)
                              : Colors.grey.shade400,
                          size: 24.sp,
                        ),
                        onTap: () {
                          setSheetState(() {
                            _selectedDate = month;
                          });

                          // If you also need to update the parent:
                          setState(() {
                            _selectedDate = month;
                          });

                          // _fetchData();
                          // Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => {
                    _fetchData(),
                    Navigator.pop(sheetContext)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  void _showHostelSheet(BuildContext context, HostelLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Property',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 16.h),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.hostels.length,
                  itemBuilder: (context, index) {
                    final hostel = state.hostels[index];
                    final isSelected = hostel.id == _selectedHostelId;

                    return ListTile(
                      title: Text(
                        hostel.name,
                        style: GoogleFonts.inter(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.darkText,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primaryBlue)
                          : null,
                      onTap: () {
                        // Update parent screen
                        setState(() {
                          _selectedHostelId = hostel.id;
                        });

                        // Close bottom sheet
                        Navigator.of(sheetContext).pop();

                        // Fetch report
                        _fetchData();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodRow({
    required IconData icon,
    required String imageUrl,
    required Color iconColor,
    required String label,
    required String subLabel,
    required double amount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          imageUrl.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    // color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Image.asset(
                    imageUrl,
                    width: 20.sp,
                    height: 20.sp,
                    fit: BoxFit.contain,
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grayLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toInt()}',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordPaymentButton(PaymentReportLoaded state) {
    return ElevatedButton(
      onPressed: () => RecordPaymentBottomSheetNew.show(context, state.tenants),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            'Record a direct payment',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItemTile extends StatelessWidget {
  final PaymentReportItem item;

  const _PaymentItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isStayIndia = item.paymentMethod?.toLowerCase() == 'razorpay';

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: (item.tenantName.hashCode % 2 == 0)
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.tenantName.isNotEmpty
                        ? item.tenantName.substring(0, 1).toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: (item.tenantName.hashCode % 2 == 0)
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: isStayIndia
                      ? Image.asset(
                          'assets/images/record_app_icon.png',
                          width: 16.sp,
                          height: 16.sp,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          'assets/images/money.png',
                          width: 16.sp,
                          height: 16.sp,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.roomNo?.toString().toLowerCase().contains('room') == true ? item.roomNo : 'Room ${item.roomNo ?? 'N/A'}'} · Bed ${item.bedNo ?? 'N/A'}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayColor2,
                  ),
                ),
                Text(
                  item.tenantName,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${DateFormat('dd MMM').format(item.paymentDate)} · ${isStayIndia ? 'StayIndia' : 'Direct'} · ${item.paymentMethod?.toLowerCase() == 'razorpay' ? "Settled" : item.paymentMethod.toString().trim()}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grayColor2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ ₹${item.totalPaid.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.freeGreen,
                ),
              ),
              Text(
                isStayIndia
                    ? item.bankName != null
                          ? ' · ${item.bankName}'
                          : ''
                    : 'By you',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
