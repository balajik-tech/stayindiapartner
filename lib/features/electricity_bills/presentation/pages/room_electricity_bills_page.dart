import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/cubit/hostel_cubit.dart';
import '../../../profile/presentation/cubit/hostel_state.dart';
import '../../data/models/electricity_bill_model.dart';
import '../cubit/electricity_bill_cubit.dart';
import '../cubit/electricity_bill_state.dart';
import '../widgets/add_electricity_bill_sheet.dart';
import '../widgets/electricity_settings_sheet.dart';
import '../widgets/collect_tenant_payment_sheet.dart';

class RoomElectricityBillsPage extends StatelessWidget {
  const RoomElectricityBillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ElectricityBillCubit>(),
      child: const _RoomElectricityBillsView(),
    );
  }
}

class _RoomElectricityBillsView extends StatefulWidget {
  const _RoomElectricityBillsView();

  @override
  State<_RoomElectricityBillsView> createState() =>
      _RoomElectricityBillsViewState();
}

class _RoomElectricityBillsViewState extends State<_RoomElectricityBillsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() {
    final hostelState = context.read<HostelCubit>().state;
    String hostelId = '';
    String? pgName;

    if (hostelState is HostelLoaded) {
      hostelId = hostelState.selectedHostelId ?? '';
      if (hostelState.hostels.isNotEmpty &&
          hostelState.selectedHostelIndex >= 0 &&
          hostelState.selectedHostelIndex < hostelState.hostels.length) {
        pgName = hostelState.hostels[hostelState.selectedHostelIndex].name;
      }
    }

    context.read<ElectricityBillCubit>().loadRoomsAndData(
      hostelId: hostelId,
      defaultPgName: pgName,
    );
  }

  DateTime _calculateOneMonthLater(DateTime from) {
    int year = from.year;
    int month = from.month + 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
    int day = from.day;
    int maxDaysInNextMonth = DateTime(year, month + 1, 0).day;
    if (day > maxDaysInNextMonth) {
      day = maxDaysInNextMonth;
    }
    final target = DateTime(year, month, day);
    return target.subtract(const Duration(days: 1));
  }

  Future<void> _pickDateRange(
    BuildContext context,
    ElectricityBillState state,
    bool isFromDate,
  ) async {
    final cubit = context.read<ElectricityBillCubit>();
    final initialDate = isFromDate ? state.fromDate : state.toDate;
    final firstDate = isFromDate
        ? DateTime(2020)
        : state.fromDate.add(const Duration(days: 1));

    final effectiveInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFromDate) {
        final autoToDate = _calculateOneMonthLater(picked);
        cubit.setDateRange(picked, autoToDate);
      } else {
        if (picked.isAfter(state.fromDate)) {
          cubit.setDateRange(state.fromDate, picked);
        } else {
          cubit.setDateRange(
            state.fromDate,
            state.fromDate.add(const Duration(days: 1)),
          );
        }
      }
    }
  }

  void _openAddBillSheet({
    required BuildContext context,
    required ElectricityBillState state,
    String? initialRoomCode,
    ElectricityBillModel? initialBill,
  }) {
    final isEditing = initialBill != null;

    if (!isEditing) {
      final billsInCurrentRange = state.bills.where((b) {
        final inRange =
            (b.date.isAfter(
                  state.fromDate.subtract(const Duration(seconds: 1)),
                ) ||
                b.date.isAtSameMomentAs(state.fromDate)) &&
            (b.date.isBefore(state.toDate.add(const Duration(days: 1))) ||
                b.date.isAtSameMomentAs(state.toDate));
        return inRange;
      }).toList();

      final existingRoomCodes = billsInCurrentRange
          .map((b) => b.roomCode.toLowerCase())
          .where((code) => code.isNotEmpty)
          .toSet();

      final existingRoomIds = billsInCurrentRange
          .map((b) => b.roomId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final availableRooms = state.rooms.where((room) {
        return !existingRoomCodes.contains(room.code.toLowerCase()) &&
            !existingRoomIds.contains(room.id);
      }).toList();

      if (availableRooms.isEmpty && state.rooms.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'All rooms already have electricity bills for this period.',
            ),
          ),
        );
        return;
      }

      AddElectricityBillSheet.show(
        context: context,
        hostelId: state.hostelId,
        rooms: availableRooms,
        initialRoomCode: initialRoomCode,
        initialBill: initialBill,
        defaultStartDate: state.fromDate,
        defaultEndDate: state.toDate,
        onSave: (bill) async {
          return await context
              .read<ElectricityBillCubit>()
              .createElectricityBill(bill);
        },
        onDelete: (billId) async {
          try {
            await context.read<ElectricityBillCubit>().deleteBill(billId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Electricity bill deleted successfully.'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete bill: $e')),
              );
            }
          }
        },
      );
    } else {
      if (initialBill.isPaidOrPartiallyPaid) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Paid or partially paid bills cannot be edited.'),
        //   ),
        // );
        return;
      }

      AddElectricityBillSheet.show(
        context: context,
        hostelId: state.hostelId,
        rooms: state.rooms,
        initialRoomCode: initialRoomCode,
        initialBill: initialBill,
        onSave: (bill) async {
          return await context
              .read<ElectricityBillCubit>()
              .updateElectricityBillApi(bill);
        },
        onDelete: (billId) async {
          try {
            await context.read<ElectricityBillCubit>().deleteBill(billId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Electricity bill deleted successfully.'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete bill: $e')),
              );
            }
          }
        },
      );
    }
  }

  void _openSettingsSheet(BuildContext context, ElectricityBillState state) {
    ElectricitySettingsSheet.show(
      context: context,
      currentPgName: state.pgName,
      currentSubtitle: state.subtitle,
      rooms: state.rooms,
      bills: state.bills,
      onSave: ({required pgName, required subtitle, required rooms}) {
        context.read<ElectricityBillCubit>().updateSettings(
          pgName: pgName,
          subtitle: subtitle,
          rooms: rooms,
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) return '₹0';
    final formatter = NumberFormat('#,##,###');
    return '₹${formatter.format(amount.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElectricityBillCubit, ElectricityBillState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryBlue,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Blue Header
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, st) => Icon(
                                Icons.bolt_rounded,
                                color: const Color(0xFF112D4E),
                                size: 22.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.pgName,
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                state.subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // IconButton(
                      //   onPressed: () => _openSettingsSheet(context, state),
                      //   icon: Icon(
                      //     Icons.settings_outlined,
                      //     color: Colors.white,
                      //     size: 22.sp,
                      //   ),
                      //   style: IconButton.styleFrom(
                      //     backgroundColor: Colors.white.withValues(alpha: 0.1),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(10.r),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Main White Card Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 90.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter by date section
                              _buildDateFilterCard(context, state),

                              SizedBox(height: 20.h),

                              // Helper text
                              Text(
                                'Tap any bill to edit it.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 12.h),

                              // List of Rooms and Bills
                              if (state.isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF112D4E),
                                  ),
                                )
                              else if (state.rooms.isEmpty)
                                _buildEmptyRoomsView(context, state)
                              else
                                ...state.rooms.map((room) {
                                  return _buildRoomCard(context, state, room);
                                }),
                            ],
                          ),
                        ),

                        // Bottom Right Floating Action Button (+ ADD BILL)
                        Positioned(
                          right: 20.w,
                          bottom: 24.h,
                          child: FloatingActionButton.extended(
                            onPressed: () => _openAddBillSheet(
                              context: context,
                              state: state,
                            ),
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            label: Text(
                              'ADD BILL',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateFilterCard(
    BuildContext context,
    ElectricityBillState state,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by date',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),

          // FROM and TO Date Selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    InkWell(
                      onTap: () => _pickDateRange(context, state, true),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          dateFormat.format(state.fromDate),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TO',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    InkWell(
                      onTap: () => _pickDateRange(context, state, false),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          dateFormat.format(state.toDate),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Quick Filter Pills
          Row(
            children: [
              _buildFilterPill(
                context,
                label: 'This month',
                isSelected: state.filterType == DateFilterType.thisMonth,
                onTap: () => context.read<ElectricityBillCubit>().setFilterType(
                  DateFilterType.thisMonth,
                ),
              ),
              // SizedBox(width: 8.w),
              // _buildFilterPill(
              //   context,
              //   label: 'Last month',
              //   isSelected: state.filterType == DateFilterType.lastMonth,
              //   onTap: () => context.read<ElectricityBillCubit>().setFilterType(
              //     DateFilterType.lastMonth,
              //   ),
              // ),
              // SizedBox(width: 8.w),
              // _buildFilterPill(
              //   context,
              //   label: 'Last 30 days',
              //   isSelected: state.filterType == DateFilterType.last30Days,
              //   onTap: () => context.read<ElectricityBillCubit>().setFilterType(
              //     DateFilterType.last30Days,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid, String? status) {
    final text = isPaid ? 'PAID' : (status?.toUpperCase() ?? 'PENDING');
    final isPaidState = text == 'PAID' || text == 'COMPLETED';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isPaidState ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: isPaidState
              ? const Color(0xFF166534)
              : const Color(0xFFC2410C),
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    ElectricityBillState state,
    ElectricityRoomModel room,
  ) {
    // Filter bills for this room within the date range
    final roomBills = state.bills.where((b) {
      final matchesRoom =
          (b.roomId.isNotEmpty && b.roomId == room.id) ||
          (b.roomCode.isNotEmpty &&
              b.roomCode.toLowerCase() == room.code.toLowerCase()) ||
          b.roomName.toLowerCase() == room.name.toLowerCase();

      final inRange =
          (b.date.isAfter(
                state.fromDate.subtract(const Duration(seconds: 1)),
              ) ||
              b.date.isAtSameMomentAs(state.fromDate)) &&
          (b.date.isBefore(state.toDate.add(const Duration(days: 1))) ||
              b.date.isAtSameMomentAs(state.toDate));

      return matchesRoom && inRange;
    }).toList();

    // Sort bills by date descending
    roomBills.sort((a, b) => b.date.compareTo(a.date));

    final totalAmount = roomBills.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );

    String subtitleText;
    if (roomBills.isEmpty) {
      subtitleText = 'No bills in this range';
    } else if (roomBills.length == 1) {
      subtitleText = '1 entry';
    } else {
      subtitleText = '${roomBills.length} entries';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (Badge, Room Name, Subtitle, Total Amount)
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  room.code,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitleText,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatAmount(totalAmount),
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          // Nested list of entries (if any)
          if (roomBills.isNotEmpty) ...[
            SizedBox(height: 12.h),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            SizedBox(height: 8.h),
            ...roomBills.map((bill) {
              final dateStr = DateFormat('dd MMM yyyy').format(bill.date);
              final label = (bill.note != null && bill.note!.isNotEmpty)
                  ? '$dateStr - ${bill.note}'
                  : dateStr;
              final labelDate = dateStr;

              final bool pendingStatus =  (bill.status?.toUpperCase() == 'PENDING');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (bill.isPaidOrPartiallyPaid) {
                        return;
                      }
                      _openAddBillSheet(
                        context: context,
                        state: state,
                        initialRoomCode: room.code,
                        initialBill: bill,
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 4.w,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  labelDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF334155),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 6.w),
                                if(pendingStatus)...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 1),
                                      Icon(
                                        Icons.edit_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 10,
                                      ),
                                    ],
                                  )
                                ]
                              ],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _buildStatusBadge(bill.isPaid, bill.status),
                          SizedBox(width: 8.w),
                          Text(
                            _formatAmount(bill.amount),
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (!bill.isPaid &&
                              (bill.tenantSplits == null ||
                                  bill.tenantSplits!.isEmpty)) ...[
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () {
                                CollectTenantPaymentSheet.show(
                                  context: context,
                                  billId: bill.id,
                                  tenantId: '',
                                  tenantName: room.name,
                                  bedNumber: room.code,
                                  shareAmount: bill.amount,
                                  onConfirm:
                                      ({
                                        required paymentMethod,
                                        required reference,
                                        required notes,
                                      }) async {
                                        return await context
                                            .read<ElectricityBillCubit>()
                                            .updateTenantBillStatusApi(
                                              billId: bill.id,
                                              tenantId: '',
                                              paymentMethod: paymentMethod,
                                              reference: reference,
                                              notes: notes,
                                            );
                                      },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Collect',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Tenant splits if available
                  if (bill.tenantSplits != null &&
                      bill.tenantSplits!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                        top: 4.h,
                        bottom: 8.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: bill.tenantSplits!.map((split) {
                          if (split is! Map) return const SizedBox.shrink();

                          final splitMap = Map<String, dynamic>.from(split);
                          final tenantObj = splitMap['tenant'] is Map
                              ? splitMap['tenant'] as Map<String, dynamic>
                              : <String, dynamic>{};

                          final tenantId =
                              tenantObj['_id']?.toString() ??
                              splitMap['tenantId']?.toString() ??
                              '';
                          final firstName =
                              tenantObj['firstName']?.toString() ?? '';
                          final lastName =
                              tenantObj['lastName']?.toString() ?? '';
                          var tenantName = [
                            firstName,
                            lastName,
                          ].where((s) => s.isNotEmpty && s != '.').join(' ');
                          if (tenantName.isEmpty) {
                            tenantName =
                                tenantObj['name']?.toString() ?? 'Tenant';
                          }

                          final bedNum =
                              splitMap['bedNumber']?.toString() ?? '';
                          final shareAmount =
                              double.tryParse(
                                splitMap['shareAmount']?.toString() ?? '0',
                              ) ??
                              0.0;
                          final statusStr =
                              splitMap['status']?.toString().toUpperCase() ??
                              'PENDING';
                          final isSplitPaid =
                              statusStr == 'PAID' || statusStr == 'COMPLETED';

                          return Container(
                            margin: EdgeInsets.only(bottom: 6.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    bedNum.isNotEmpty ? 'Bed $bedNum' : 'Bed',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    tenantName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '₹${shareAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                if (isSplitPaid)
                                  _buildStatusBadge(true, 'PAID')
                                else
                                  InkWell(
                                    onTap: () {
                                      CollectTenantPaymentSheet.show(
                                        context: context,
                                        billId: bill.id,
                                        tenantId: tenantId,
                                        tenantName: tenantName,
                                        bedNumber: bedNum,
                                        shareAmount: shareAmount,
                                        onConfirm:
                                            ({
                                              required paymentMethod,
                                              required reference,
                                              required notes,
                                            }) async {
                                              return await context
                                                  .read<ElectricityBillCubit>()
                                                  .updateTenantBillStatusApi(
                                                    billId: bill.id,
                                                    tenantId: tenantId,
                                                    paymentMethod:
                                                        paymentMethod,
                                                    reference: reference,
                                                    notes: notes,
                                                  );
                                            },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Collect',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }),
          ],

          // Hide add bill button if room already has a bill entry for this period
          if (roomBills.isEmpty) ...[
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: () => _openAddBillSheet(
                context: context,
                state: state,
                initialRoomCode: room.code,
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF112D4E),
                side: BorderSide.none,
                minimumSize: Size(double.infinity, 38.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                '+ Add bill for ${room.code}',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyRoomsView(
    BuildContext context,
    ElectricityBillState state,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bedroom_child_outlined,
            size: 48.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(height: 12.h),
          Text(
            'No rooms found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No tenants are currently occupying beds.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
