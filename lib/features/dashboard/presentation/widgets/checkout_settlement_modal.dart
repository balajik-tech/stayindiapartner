import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/injection_container.dart';

class CheckoutSettlementModal extends StatefulWidget {
  final String tenantName;
  final String tenantId;
  final String hostelId;
  final String bookingId;
  final double securityDeposit;
  final VoidCallback onCheckoutConfirmed;

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
    required VoidCallback onCheckoutConfirmed,
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
  State<CheckoutSettlementModal> createState() => _CheckoutSettlementModalState();
}

class _CheckoutSettlementModalState extends State<CheckoutSettlementModal> {
  bool _isLoading = true;
  String? _errorMessage;
  double _pendingRent = 0.0;
  double _utilityDue = 0.0;
  double _totalDues = 0.0;
  double _finalSettlement = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSettlementData();
  }

  Future<void> _fetchSettlementData() async {
    try {
      final paymentRepo = sl<PaymentRepository>();
      final bills = await paymentRepo.getBills(
        tenantId: widget.tenantId,
        hostelId: widget.hostelId,
      );

      final items = bills['items'] as List? ?? [];
      double rentAccumulator = 0.0;
      double utilityAccumulator = 0.0;

      for (var item in items) {
        if (item is Map) {
          final type = (item['paymentType'] ?? '').toString().toUpperCase();
          final due = (item['dueAmount'] ?? 0.0).toDouble();

          if (type == 'RENT') {
            rentAccumulator += due;
          } else if (type == 'ELECTRICITY' ||
              type == 'METER' ||
              type == 'UTILITY' ||
              type == 'MAINTENANCE') {
            utilityAccumulator += due;
          } else {
            rentAccumulator += due;
          }
        }
      }

      setState(() {
        _pendingRent = rentAccumulator;
        _utilityDue = utilityAccumulator;
        _totalDues = _pendingRent + _utilityDue;
        _finalSettlement = widget.securityDeposit - _totalDues;
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
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20.h,
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
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
            ),
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
            // Status Indicator Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _totalDues > 0
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _totalDues > 0
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFF86EFAC),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _totalDues > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: _totalDues > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _totalDues > 0 ? 'Pending Dues Found' : 'Clear to Checkout',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _totalDues > 0 ? const Color(0xFF991B1B) : const Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Financial Snapshot Cards
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.roomCardBorder),
                borderRadius: BorderRadius.circular(16.r),
                color: const Color(0xFFFAFAFA),
              ),
              child: Column(
                children: [
                  _buildFinancialRow(
                    'Refundable Security Deposit',
                    widget.securityDeposit,
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _buildFinancialRow(
                    'Pending Rent',
                    _pendingRent,
                    isPositive: false,
                  ),
                  SizedBox(height: 12.h),
                  _buildFinancialRow(
                    'Utility / Electricity Bills',
                    _utilityDue,
                    isPositive: false,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _finalSettlement >= 0 ? 'Refund to Tenant' : 'Tenant Oues Owner',
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
                          color: _finalSettlement >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            // Tactile Slider Confirmation
            _SlideToConfirmButton(
              label: 'Slide to Confirm Check-out',
              onConfirmed: () {
                Navigator.pop(context);
                widget.onCheckoutConfirmed();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String title, double amount, {required bool isPositive}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${isPositive ? "+" : "-"} ₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}

class _SlideToConfirmButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;

  const _SlideToConfirmButton({
    required this.label,
    required this.onConfirmed,
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
                    color: _confirmed ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                  ),
                ),
              ),
              Positioned(
                left: _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed) return;
                    setState(() {
                      _position += details.delta.dx;
                      if (_position < 0) _position = 0;
                      if (_position > maxDistance) _position = maxDistance;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_confirmed) return;
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
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
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
