import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/bookings/domain/settlement_payment.dart';
import 'package:stayindia_owner/features/electricity_bills/data/datasources/electricity_remote_datasource.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/features/staff/domain/entities/staff.dart';
import 'package:stayindia_owner/features/staff/domain/repositories/staff_repository.dart';
import 'package:stayindia_owner/injection_container.dart';

typedef CheckoutConfirmedCallback =
    void Function({
      required double securityDeposit,
      required double pendingRent,
      required double utilityDue,
      required double finalSettlement,
      required List<SettlementPayment> settlementPayments,
    });

class CheckoutSettlementModal extends StatefulWidget {
  final String tenantName;
  final String tenantId;
  final String hostelId;
  final String bookingId;
  final double securityDeposit;
  final CheckoutConfirmedCallback onCheckoutConfirmed;

  const CheckoutSettlementModal({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.hostelId,
    required this.bookingId,
    required this.securityDeposit,
    required this.onCheckoutConfirmed,
  });

  static void show(
    BuildContext context, {
    required String tenantName,
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double securityDeposit,
    required CheckoutConfirmedCallback onCheckoutConfirmed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Dragging down would throw away recorded payments by accident.
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSettlementModal(
        tenantName: tenantName,
        tenantId: tenantId,
        hostelId: hostelId,
        bookingId: bookingId,
        securityDeposit: securityDeposit,
        onCheckoutConfirmed: onCheckoutConfirmed,
      ),
    );
  }

  @override
  State<CheckoutSettlementModal> createState() =>
      _CheckoutSettlementModalState();
}

class _CheckoutSettlementModalState extends State<CheckoutSettlementModal> {
  static const Color _red = Color(0xFFDC2626);
  static const Color _green = Color(0xFF16A34A);
  static const Color _amber = Color(0xFFEA580C);
  static const Color _slate = Color(0xFF475569);
  static const Color _border = Color(0xFFE2E8F0);

  bool _isLoading = true;
  String? _errorMessage;
  double _securityDeposit = 0.0;
  double _pendingRent = 0.0;
  double _utilityDue = 0.0;
  double _totalDues = 0.0;
  // Dues as loaded from the server, so editing the fields can't bypass the check.
  double _fetchedDues = 0.0;

  final List<String> _pendingBillIds = [];

  final List<SettlementPayment> _payments = [];
  List<Staff> _staff = [];
  SettlementPaymentMethod _method = SettlementPaymentMethod.cash;
  SettlementHandlerType _handlerType = SettlementHandlerType.owner;
  Staff? _selectedStaff;
  bool _paymentsExpanded = true;

  double get _blockingDues =>
      _fetchedDues > _totalDues ? _fetchedDues : _totalDues;

  /// Positive: owner refunds tenant. Negative: tenant pays owner.
  double get _netSettlement => _securityDeposit - _blockingDues;

  SettlementDirection get _direction => _netSettlement < 0
      ? SettlementDirection.tenantToOwner
      : SettlementDirection.ownerToTenant;

  bool get _tenantPays => _direction == SettlementDirection.tenantToOwner;

  double _sumOf(SettlementDirection direction) => _payments
      .where((p) => p.direction == direction)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get _recordedTotal => _tenantPays
      ? _sumOf(SettlementDirection.tenantToOwner) -
            _sumOf(SettlementDirection.ownerToTenant)
      : _sumOf(SettlementDirection.ownerToTenant) -
            _sumOf(SettlementDirection.tenantToOwner);

  /// Amount still to move in the settlement direction; negative means overpaid.
  double get _remaining => _netSettlement.abs() - _recordedTotal;

  bool get _isSettled => _remaining.abs() < 0.5;

  late TextEditingController _depositController;
  late TextEditingController _pendingRentController;
  late TextEditingController _utilityController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController();
    _pendingRentController = TextEditingController();
    _utilityController = TextEditingController();
    _fetchSettlementData();
    _fetchStaff();
  }

  @override
  void dispose() {
    _depositController.dispose();
    _pendingRentController.dispose();
    _utilityController.dispose();
    _amountController.dispose();
    _otherNameController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onValuesChanged() {
    final double dep = double.tryParse(_depositController.text) ?? 0.0;
    final double rent = double.tryParse(_pendingRentController.text) ?? 0.0;
    final double util = double.tryParse(_utilityController.text) ?? 0.0;

    setState(() {
      _securityDeposit = dep;
      _pendingRent = rent;
      _utilityDue = util;
      _totalDues = _pendingRent + _utilityDue;
    });
  }

  Future<void> _fetchStaff() async {
    if (widget.hostelId.isEmpty) return;
    try {
      final staff = await sl<StaffRepository>().getStaff(widget.hostelId);
      if (!mounted) return;
      setState(() => _staff = staff.where((s) => s.isActive).toList());
    } catch (_) {
      // Staff list is optional; owner / other remain selectable.
    }
  }

  Future<void> _fetchSettlementData() async {
    try {
      final paymentRepo = sl<PaymentRepository>();
      final rentals = await paymentRepo.getTenantRentals(
        tenantId: widget.tenantId,
        hostelId: widget.hostelId,
      );

      double rentAccumulator = 0.0;
      double utilityAccumulator = 0.0;
      double depositAccumulator = 0.0;
      _pendingBillIds.clear();

      for (var rental in rentals) {
        if (!rental.isPaid) {
          double rentVal = rental.bookingAmount;
          double utilVal =
              rental.electricityBill + rental.parkingBill + rental.maintenance;

          if (rentVal == 0 && utilVal == 0 && rental.payableAmount > 0) {
            rentVal = rental.payableAmount;
          }

          rentAccumulator += rentVal;
          utilityAccumulator = utilVal;
        } else {
          if (rental.isElectricityBillPending) {
            utilityAccumulator = rental.electricityBillShare;
          }
        }
        if (rental.isElectricityBillPending &&
            rental.electricityBillId != null &&
            rental.electricityBillId!.isNotEmpty) {
          if (!_pendingBillIds.contains(rental.electricityBillId)) {
            _pendingBillIds.add(rental.electricityBillId!);
          }
        }
        depositAccumulator += rental.deposit;
      }

      if (_pendingBillIds.isEmpty && utilityAccumulator > 0) {
        try {
          final res = await sl<ElectricityRemoteDataSource>()
              .fetchElectricityBills(hostelId: widget.hostelId);
          final items = res['data']?['items'] ?? res['data'] ?? [];
          if (items is List) {
            for (var item in items) {
              if (item is Map) {
                final billId = item['_id']?.toString();
                final splits = item['tenantSplits'];
                if (billId != null && splits is List) {
                  for (var split in splits) {
                    if (split is Map) {
                      final tId =
                          (split['tenant'] is Map
                                  ? split['tenant']['_id']
                                  : split['tenant'])
                              ?.toString();
                      final status = split['status']?.toString().toUpperCase();
                      if (tId == widget.tenantId && status == 'PENDING') {
                        if (!_pendingBillIds.contains(billId)) {
                          _pendingBillIds.add(billId);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      final secDeposit = widget.securityDeposit > 0
          ? widget.securityDeposit
          : depositAccumulator;

      if (!mounted) return;
      setState(() {
        _securityDeposit = secDeposit;
        _pendingRent = rentAccumulator;
        _utilityDue = utilityAccumulator;
        _totalDues = _pendingRent + _utilityDue;
        _fetchedDues = _totalDues;

        _depositController.text = _securityDeposit.toStringAsFixed(0);
        _pendingRentController.text = _pendingRent.toStringAsFixed(0);
        _utilityController.text = _utilityDue.toStringAsFixed(0);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load settlement details. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addPayment() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      _showSnack('Enter an amount greater than 0');
      return;
    }
    if (amount > _remaining + 0.5) {
      _showSnack(
        'Amount exceeds the remaining ${_formatAmount(_remaining < 0 ? 0 : _remaining)}',
      );
      return;
    }

    String handlerName;
    String? staffId;
    switch (_handlerType) {
      case SettlementHandlerType.owner:
        handlerName = 'Owner';
      case SettlementHandlerType.staff:
        if (_selectedStaff == null) {
          _showSnack('Select the staff member');
          return;
        }
        handlerName = _selectedStaff!.name;
        staffId = _selectedStaff!.id;
      case SettlementHandlerType.other:
        handlerName = _otherNameController.text.trim();
        if (handlerName.isEmpty) {
          _showSnack('Enter the name of the person');
          return;
        }
    }

    final now = DateTime.now();
    setState(() {
      _payments.add(
        SettlementPayment(
          localId: now.microsecondsSinceEpoch.toString(),
          amount: amount,
          direction: _direction,
          method: _method,
          handlerType: _handlerType,
          handlerStaffId: staffId,
          handlerName: handlerName,
          paidAt: now,
        ),
      );
      _amountController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removePayment(SettlementPayment payment) {
    setState(() => _payments.removeWhere((p) => p.localId == payment.localId));
  }

  String _formatAmount(double value) =>
      '₹${NumberFormat.decimalPattern('en_IN').format(value.round())}';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      height: media.size.height - media.padding.top,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : _errorMessage != null
                ? _buildError()
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStatusBanner(),
                        SizedBox(height: 14.h),
                        _buildBreakdownCard(),
                        SizedBox(height: 14.h),
                        _buildSettlementCard(),
                        if (_netSettlement.abs() >= 0.5) ...[
                          SizedBox(height: 14.h),
                          _buildPaymentsCard(),
                          SizedBox(height: 14.h),
                          _buildRemainingCard(),
                        ],
                      ],
                    ),
                  ),
          ),
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                8.h,
                20.w,
                media.viewInsets.bottom + media.padding.bottom + 16.h,
              ),
              child: _SlideToConfirmButton(
                label: 'Slide to Confirm Check-out',
                subLabel: _isSettled
                    ? null
                    : _remaining < 0
                    ? 'Recorded payments exceed the settlement amount'
                    : _tenantPays
                    ? 'Complete the remaining payment to enable checkout'
                    : 'Complete the refund payment to enable checkout',
                enabled: _isSettled,
                onConfirmed: _handleConfirmCheckout,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 8.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settlement Summary',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 24.sp, color: AppColors.greyText),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Text(
              'Verify all financial balances for ${widget.tenantName} before confirming the check-out.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
            SizedBox(height: 12.h),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchSettlementData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final String text;
    final Color color;
    final IconData icon;
    if (_isSettled) {
      text = 'All balances settled. Ready to check out';
      color = _green;
      icon = Icons.check_circle_rounded;
    } else if (_tenantPays) {
      text = 'Tenant has pending dues to pay';
      color = _red;
      icon = Icons.warning_amber_rounded;
    } else {
      text = 'Owner has refund to pay to tenant';
      color = _green;
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFFFAFAFA),
      ),
      child: Column(
        children: [
          _buildFinancialInputRow(
            'Refundable Security Deposit',
            _depositController,
            isPositive: true,
          ),
          const Divider(height: 16),
          _buildFinancialInputRow(
            'Pending Rent',
            _pendingRentController,
            isPositive: false,
          ),
          const Divider(height: 16),
          _buildFinancialInputRow(
            'Utility / Electricity Bills',
            _utilityController,
            isPositive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard() {
    final double amount = _netSettlement.abs();
    final bool nothingDue = amount < 0.5;
    final Color color = _tenantPays && !nothingDue ? _red : _green;
    final String title = nothingDue
        ? 'Nothing to Settle'
        : _tenantPays
        ? 'Tenant Pays Owner'
        : 'Owner Pays Tenant';
    final String subtitle = nothingDue
        ? 'Deposit fully covers the dues'
        : _tenantPays
        ? 'Amount payable by tenant'
        : 'Amount to be refunded to tenant';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: color,
            child: Icon(
              nothingDue
                  ? Icons.check_rounded
                  : _tenantPays
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: _slate),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _paymentsExpanded = !_paymentsExpanded),
            borderRadius: BorderRadius.circular(12.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.totalBlue,
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryBlue,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tenantPays ? 'Received by Owner' : 'Paid by Owner',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        _tenantPays
                            ? 'Total amount received from tenant'
                            : 'Total amount paid to tenant',
                        style: TextStyle(fontSize: 12.sp, color: _slate),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatAmount(_recordedTotal),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Icon(
                  _paymentsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _slate,
                ),
              ],
            ),
          ),
          if (_paymentsExpanded) ...[
            SizedBox(height: 14.h),
            _buildAmountEntryRow(),
            SizedBox(height: 12.h),
            _buildHandlerSelector(),
            SizedBox(height: 12.h),
            if (_payments.isEmpty)
              _buildEmptyPayments()
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _payments.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _buildPaymentTile(_payments[i]),
                    ],
                  ],
                ),
              ),
            if (_remaining > 0.5) ...[
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: () => _amountFocus.requestFocus(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add More Payments'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAmountEntryRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        _buildMethodChip(SettlementPaymentMethod.cash),
        SizedBox(width: 6.w),
        _buildMethodChip(SettlementPaymentMethod.upi),
        SizedBox(width: 6.w),
        SizedBox(
          height: 44.h,
          child: ElevatedButton(
            onPressed: _addPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Add',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodChip(SettlementPaymentMethod method) {
    final bool selected = _method == method;
    final bool isCash = method == SettlementPaymentMethod.cash;
    final Color color = isCash ? _green : const Color(0xFF5F259F);
    return InkWell(
      onTap: () => setState(() => _method = method),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? color : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCash ? Icons.payments_rounded : Icons.qr_code_2_rounded,
              size: 16.sp,
              color: color,
            ),
            SizedBox(width: 4.w),
            Text(
              isCash ? 'Cash' : 'UPI',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? color : _slate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandlerSelector() {
    final chips = <Widget>[
      _buildHandlerChip(
        label: 'Owner (You)',
        selected: _handlerType == SettlementHandlerType.owner,
        onTap: () => setState(() {
          _handlerType = SettlementHandlerType.owner;
          _selectedStaff = null;
        }),
      ),
      for (final staff in _staff)
        _buildHandlerChip(
          label: staff.role.isNotEmpty
              ? '${staff.name} · ${staff.role}'
              : staff.name,
          selected:
              _handlerType == SettlementHandlerType.staff &&
              _selectedStaff?.id == staff.id,
          onTap: () => setState(() {
            _handlerType = SettlementHandlerType.staff;
            _selectedStaff = staff;
          }),
        ),
      _buildHandlerChip(
        label: 'Someone else',
        selected: _handlerType == SettlementHandlerType.other,
        onTap: () => setState(() {
          _handlerType = SettlementHandlerType.other;
          _selectedStaff = null;
        }),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tenantPays ? 'Tenant paid to' : 'Paid to tenant by',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _slate,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(spacing: 8.w, runSpacing: 8.h, children: chips),
        if (_handlerType == SettlementHandlerType.other) ...[
          SizedBox(height: 10.h),
          TextField(
            controller: _otherNameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Name of the person (e.g. Security guard)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: _border),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHandlerChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.totalBlue : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? AppColors.primaryBlue : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryBlue : _slate,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPayments() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 28.sp,
            color: AppColors.greyText,
          ),
          SizedBox(height: 8.h),
          Text(
            'No payments added yet',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _slate,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _tenantPays
                ? 'Add payment when you receive dues from tenant'
                : 'Add payment when you give refund to tenant',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(SettlementPayment payment) {
    final bool isCash = payment.method == SettlementPaymentMethod.cash;
    final Color color = isCash ? _green : const Color(0xFF5F259F);
    final bool counter = payment.direction != _direction;
    final String handlerLine =
        payment.direction == SettlementDirection.tenantToOwner
        ? 'Received by ${payment.handlerName}'
        : 'Paid by ${payment.handlerName}';

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 0, 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              isCash ? Icons.payments_rounded : Icons.qr_code_2_rounded,
              color: color,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCash ? 'Cash Payment' : 'UPI Payment',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  handlerLine,
                  style: TextStyle(fontSize: 12.sp, color: _slate),
                ),
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(payment.paidAt),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Text(
            '${counter ? '− ' : ''}${_formatAmount(payment.amount)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: counter ? _red : AppColors.darkText,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20.sp, color: _slate),
            onSelected: (_) => _removePayment(payment),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingCard() {
    final bool overpaid = _remaining < -0.5;
    final Color color = _isSettled
        ? _green
        : overpaid
        ? _red
        : _amber;
    final String title = _isSettled
        ? 'Fully Settled'
        : overpaid
        ? 'Excess Recorded'
        : _tenantPays
        ? 'Remaining Balance'
        : 'Remaining to Pay';
    final String subtitle = _isSettled
        ? 'No balance pending on either side'
        : overpaid
        ? 'Remove extra payments to match the settlement'
        : _tenantPays
        ? 'Amount still to be received from tenant'
        : 'Amount still to be paid to tenant';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: _slate),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(_isSettled ? 0 : _remaining.abs()),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmCheckout() async {
    if (!_isSettled) return;

    if (_pendingBillIds.isNotEmpty) {
      final upiUsed = _payments.any(
        (p) =>
            p.direction == SettlementDirection.tenantToOwner &&
            p.method == SettlementPaymentMethod.upi,
      );
      final elecDS = sl<ElectricityRemoteDataSource>();
      for (final billId in _pendingBillIds) {
        try {
          await elecDS.updateTenantBillStatus(
            billId: billId,
            tenantId: widget.tenantId,
            payload: {
              "status": "PAID",
              "paymentMethod": upiUsed ? "UPI" : "CASH",
              "reference": "",
              "notes": "Settled at checkout",
            },
          );
        } catch (_) {
          // Continue if error or already paid
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
      final finalSettlementWithoutUtility = _securityDeposit - _pendingRent;
      widget.onCheckoutConfirmed(
        securityDeposit: _securityDeposit,
        pendingRent: _pendingRent,
        utilityDue: 0,
        finalSettlement: finalSettlementWithoutUtility,
        settlementPayments: List.unmodifiable(_payments),
      );
    }
  }

  Widget _buildFinancialInputRow(
    String title,
    TextEditingController controller, {
    required bool isPositive,
  }) {
    final Color color = isPositive ? _green : _red;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: _slate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 40.h,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              onChanged: (_) => _onValuesChanged(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 8.h,
                ),
                prefixText: isPositive ? '+ ₹' : '- ₹',
                prefixStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideToConfirmButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final bool enabled;
  final VoidCallback onConfirmed;

  const _SlideToConfirmButton({
    required this.label,
    required this.onConfirmed,
    this.subLabel,
    this.enabled = true,
  });

  @override
  State<_SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<_SlideToConfirmButton> {
  double _position = 0.0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final Color thumbColor = widget.enabled
        ? const Color(0xFFEF4444)
        : const Color(0xFFFCA5A5);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDistance = constraints.maxWidth - 56.h;
        return Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: widget.enabled
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(28.h),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 48.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _confirmed ? 'Processing...' : widget.label,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: _confirmed
                              ? const Color(0xFF16A34A)
                              : widget.enabled
                              ? const Color(0xFF64748B)
                              : const Color(0xFFB91C1C).withValues(alpha: 0.6),
                        ),
                      ),
                      if (!_confirmed && widget.subLabel != null)
                        Text(
                          widget.subLabel!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed || !widget.enabled) return;
                    setState(() {
                      _position += details.delta.dx;
                      if (_position < 0) _position = 0;
                      if (_position > maxDistance) _position = maxDistance;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_confirmed || !widget.enabled) return;
                    if (_position >= maxDistance * 0.85) {
                      setState(() {
                        _position = maxDistance;
                        _confirmed = true;
                      });
                      widget.onConfirmed();
                    } else {
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    margin: EdgeInsets.all(4.h),
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: thumbColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.enabled
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
