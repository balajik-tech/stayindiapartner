import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectTenantPaymentSheet extends StatefulWidget {
  final String billId;
  final String tenantId;
  final String tenantName;
  final String bedNumber;
  final double shareAmount;
  final Future<bool> Function({
    required String paymentMethod,
    required String reference,
    required String notes,
  }) onConfirm;

  const CollectTenantPaymentSheet({
    super.key,
    required this.billId,
    required this.tenantId,
    required this.tenantName,
    required this.bedNumber,
    required this.shareAmount,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String billId,
    required String tenantId,
    required String tenantName,
    required String bedNumber,
    required double shareAmount,
    required Future<bool> Function({
      required String paymentMethod,
      required String reference,
      required String notes,
    }) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CollectTenantPaymentSheet(
          billId: billId,
          tenantId: tenantId,
          tenantName: tenantName,
          bedNumber: bedNumber,
          shareAmount: shareAmount,
          onConfirm: onConfirm,
        ),
      ),
    );
  }

  @override
  State<CollectTenantPaymentSheet> createState() => _CollectTenantPaymentSheetState();
}

class _CollectTenantPaymentSheetState extends State<CollectTenantPaymentSheet> {
  String _paymentMethod = 'UPI'; // 'CASH' or 'UPI'
  late TextEditingController _referenceController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.onConfirm(
        paymentMethod: _paymentMethod,
        reference: _referenceController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tenant electricity bill split status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 16.h),
              Text(
                'Record Tenant Share Payment',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 16.h),

              // Tenant Info Card
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF112D4E),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.bedNumber.isNotEmpty ? widget.bedNumber : 'T',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
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
                            widget.tenantName,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Bed ${widget.bedNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${widget.shareAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // Payment Method Selector
              Text(
                'PAYMENT METHOD',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _paymentMethod = 'UPI'),
                      borderRadius: BorderRadius.circular(12.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'UPI'
                              ? const Color(0xFF112D4E)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _paymentMethod == 'UPI'
                                ? const Color(0xFF112D4E)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_rounded,
                              size: 18.sp,
                              color: _paymentMethod == 'UPI' ? Colors.white : const Color(0xFF334155),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'UPI',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: _paymentMethod == 'UPI' ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _paymentMethod = 'CASH'),
                      borderRadius: BorderRadius.circular(12.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'CASH'
                              ? const Color(0xFF112D4E)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _paymentMethod == 'CASH'
                                ? const Color(0xFF112D4E)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 18.sp,
                              color: _paymentMethod == 'CASH' ? Colors.white : const Color(0xFF334155),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'CASH',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: _paymentMethod == 'CASH' ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Reference
              Text(
                'REFERENCE / TRANSACTION ID',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _referenceController,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: _paymentMethod == 'UPI' ? 'e.g. UPI982736182' : 'Reference (optional)',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Notes
              Text(
                'NOTES (OPTIONAL)',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _notesController,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Received via GPay',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Confirm Payment Primary Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112D4E),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Confirm Payment',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              SizedBox(height: 8.h),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
