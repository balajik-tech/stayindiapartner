import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/electricity_bills/data/datasources/electricity_remote_datasource.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/injection_container.dart';

class CheckoutSettlementModal extends StatefulWidget {
  final String tenantName;
  final String tenantId;
  final String hostelId;
  final String bookingId;
  final double securityDeposit;
  final Function({
    required double securityDeposit,
    required double pendingRent,
    required double utilityDue,
    required double finalSettlement,
  })
  onCheckoutConfirmed;

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
    required Function({
      required double securityDeposit,
      required double pendingRent,
      required double utilityDue,
      required double finalSettlement,
    })
    onCheckoutConfirmed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
  bool _isLoading = true;
  String? _errorMessage;
  double _securityDeposit = 0.0;
  double _pendingRent = 0.0;
  double _utilityDue = 0.0;
  double _totalDues = 0.0;
  double _finalSettlement = 0.0;
  // Dues as loaded from the server, so editing the fields can't bypass the check.
  double _fetchedDues = 0.0;

  final List<String> _pendingBillIds = [];

  double get _blockingDues =>
      _fetchedDues > _totalDues ? _fetchedDues : _totalDues;
  bool get _hasPendingDues => _blockingDues > 0;

  late TextEditingController _depositController;
  late TextEditingController _pendingRentController;
  late TextEditingController _utilityController;

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController();
    _pendingRentController = TextEditingController();
    _utilityController = TextEditingController();
    _fetchSettlementData();
  }

  @override
  void dispose() {
    _depositController.dispose();
    _pendingRentController.dispose();
    _utilityController.dispose();
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
      _finalSettlement = _securityDeposit - _totalDues;
    });
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

      setState(() {
        _securityDeposit = secDeposit;
        _pendingRent = rentAccumulator;
        _utilityDue = utilityAccumulator;
        _totalDues = _pendingRent + _utilityDue;
        _finalSettlement = _securityDeposit - _totalDues;
        _fetchedDues = _totalDues;

        _depositController.text = _securityDeposit.toStringAsFixed(0);
        _pendingRentController.text = _pendingRent.toStringAsFixed(0);
        _utilityController.text = _utilityDue.toStringAsFixed(0);

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load settlement details. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
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
          Text(
            'Verify all financial balances for ${widget.tenantName} before confirming the checkout.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 24.h),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
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
            )
          else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _hasPendingDues
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _hasPendingDues
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFF86EFAC),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasPendingDues
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: _hasPendingDues
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasPendingDues
                              ? 'Pending Dues Found'
                              : 'Clear to Checkout',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _hasPendingDues
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF166534),
                          ),
                        ),
                        if (_hasPendingDues) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Collect ₹${_blockingDues.toStringAsFixed(0)} in pending dues before checking out this tenant.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.all(16.w),
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
                  const Divider(height: 24),
                  _buildFinancialInputRow(
                    'Pending Rent',
                    _pendingRentController,
                    isPositive: false,
                  ),
                  SizedBox(height: 12.h),
                  _buildFinancialInputRow(
                    'Utility / Electricity Bills',
                    _utilityController,
                    isPositive: false,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _finalSettlement >= 0
                            ? 'Refund to Tenant'
                            : 'Tenant Pays Owner',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '₹${_finalSettlement.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: _finalSettlement >= 0
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            _SlideToConfirmButton(
              label: _hasPendingDues
                  ? 'Clear dues to Check-out'
                  : 'Slide to Confirm Check-out',
              enabled: !_hasPendingDues,
              onConfirmed: _handleConfirmCheckout,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleConfirmCheckout() async {
    if (_hasPendingDues) return;

    if (_pendingBillIds.isNotEmpty) {
      final elecDS = sl<ElectricityRemoteDataSource>();
      for (final billId in _pendingBillIds) {
        try {
          await elecDS.updateTenantBillStatus(
            billId: billId,
            tenantId: widget.tenantId,
            payload: {
              "status": "PAID",
              "paymentMethod": "CASH",
              "reference": "",
              "notes": "",
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
      );
    }
  }

  Widget _buildFinancialInputRow(
    String title,
    TextEditingController controller, {
    required bool isPositive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF475569),
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
                color: isPositive
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
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
                  color: isPositive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: isPositive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
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
  final bool enabled;
  final VoidCallback onConfirmed;

  const _SlideToConfirmButton({
    required this.label,
    required this.onConfirmed,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDistance = constraints.maxWidth - 56.h;
        return Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(28.h),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  _confirmed ? 'Processing...' : widget.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: _confirmed
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
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
                      color: widget.enabled
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.enabled
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFCBD5E1))
                                  .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.enabled
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_outline_rounded,
                      color: AppColors.primaryBlue,
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
