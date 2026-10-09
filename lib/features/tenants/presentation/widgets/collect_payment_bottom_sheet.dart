import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/payment_report_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';

enum StayType {
  MONTHLY,
  CUSTOM,
}

class CollectPaymentBottomSheet extends StatefulWidget {
  final String? tenantId;
  final String? hostelId;
  final String? bookingId;

  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? sharingType;
  final String? email;
  final String? userPhotoPath;
  final String? aadharPhotoPath;
  final String? aadharCardbackPath;
  final String? employeeIdProofPath;
  final List<Map<String, String>>? guardianMobiles;
  final double securityDeposit;
  final double rent;
  final String checkInDate;
  final String checkOutDate;
  final String? forthePeriod;
  final double maintainance;
  final String? roomType;
  final String? aadhaarNumber;
  final String? dob;
  final String? gender;
  final String? address;

  final Hostel? selectedHostel;
  final dynamic selectedRoom;
  final String? selectedBed;
  final StayType? stayType;
  final AddTenantCubit? addTenantCubit;
  final double totalAmount;

  const CollectPaymentBottomSheet({
    super.key,
    this.tenantId,
    this.hostelId,
    this.bookingId,
    this.phone,
    this.firstName,
    this.lastName,
    this.sharingType,
    this.email,
    this.userPhotoPath,
    this.aadharPhotoPath,
    this.aadharCardbackPath,
    this.employeeIdProofPath,
    this.guardianMobiles,
    required this.securityDeposit,
    required this.rent,
    this.checkInDate = '',
    this.checkOutDate = '',
    this.forthePeriod,
    required this.maintainance,
    this.roomType,
    this.aadhaarNumber,
    this.dob,
    this.gender,
    this.address,
    this.selectedHostel,
    this.selectedRoom,
    this.selectedBed,
    this.stayType,
    this.addTenantCubit,
    required this.totalAmount,
  });

  @override
  State<CollectPaymentBottomSheet> createState() =>
      _CollectPaymentBottomSheetState();
}

class _CollectPaymentBottomSheetState
    extends State<CollectPaymentBottomSheet> {
  late TextEditingController _collectingNowController;
  final TextEditingController _discountController = TextEditingController();
  double _discountAmount = 0.0;
  String _paymentMethod = 'Cash';
  String _collectionType = 'Full amount';
  bool _isSubmitting = false;

  int get _occupiedDays {
    if (widget.checkInDate.isEmpty) return 0;
    try {
      final checkIn = DateTime.parse(widget.checkInDate);
      if (widget.stayType == StayType.MONTHLY || widget.stayType == null) {
        final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
        return monthEnd.day - checkIn.day + 1;
      } else if (widget.stayType == StayType.CUSTOM &&
          widget.checkOutDate.isNotEmpty) {
        final checkOut = DateTime.parse(widget.checkOutDate);
        return checkOut.difference(checkIn).inDays + 1;
      }
    } catch (_) {}
    return 0;
  }

  int get _daysInMonth {
    if (widget.checkInDate.isEmpty) return 30;
    try {
      final checkIn = DateTime.parse(widget.checkInDate);
      final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
      return monthEnd.day;
    } catch (_) {}
    return 30;
  }

  double get _calculatedProratedRent {
    if (widget.stayType == StayType.MONTHLY || widget.stayType == null) {
      if (_occupiedDays > 0 && _daysInMonth > 0) {
        return (widget.rent / _daysInMonth) * _occupiedDays;
      }
    } else if (widget.stayType == StayType.CUSTOM) {
      if (_occupiedDays > 0) {
        return widget.rent * _occupiedDays;
      }
    }
    return widget.rent;
  }

  bool get _isProrated {
    if (widget.stayType == StayType.MONTHLY || widget.stayType == null) {
      return _occupiedDays > 0 && _occupiedDays < _daysInMonth;
    } else if (widget.stayType == StayType.CUSTOM) {
      return true;
    }
    return false;
  }

  double get _baseTotal {
    if (widget.totalAmount > 0) {
      return widget.totalAmount;
    }
    return _calculatedProratedRent +
        widget.securityDeposit +
        widget.maintainance;
  }

  @override
  void initState() {
    super.initState();
    _collectingNowController =
        TextEditingController(text: _baseTotal.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _collectingNowController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _onCollectionTypeChanged(String type) {
    double totalDue =
        (_baseTotal - _discountAmount).clamp(0, double.infinity);
    setState(() {
      _collectionType = type;
      _collectingNowController.text = totalDue.toStringAsFixed(0);
    });
  }

  void _showDiscountDialog() {
    _discountController.text =
        _discountAmount > 0 ? _discountAmount.toStringAsFixed(0) : '';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Add Discount or Waiver',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter discount or waiver amount',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (_discountAmount > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    _discountAmount = 0.0;
                    double totalDue = _baseTotal.clamp(0, double.infinity);
                    _collectingNowController.text =
                        totalDue.toStringAsFixed(0);
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double discount =
                    double.tryParse(_discountController.text.trim()) ?? 0.0;
                double maxTotal = _baseTotal;
                if (discount > maxTotal) {
                  discount = maxTotal;
                }
                setState(() {
                  _discountAmount = discount;
                  double totalDue =
                      (maxTotal - _discountAmount).clamp(0, double.infinity);
                  _collectingNowController.text =
                      totalDue.toStringAsFixed(0);
                });
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleProceed() async {
    setState(() => _isSubmitting = true);

    double finalTotal =
        (_baseTotal - _discountAmount).clamp(0, double.infinity);

    try {
      String? tenantId = widget.tenantId;
      String? bookingId = widget.bookingId;
      String? hostelId = widget.hostelId;

      if ((tenantId == null || tenantId.isEmpty) && widget.addTenantCubit != null) {
        final response = await widget.addTenantCubit!.submit(
          hostel: widget.selectedHostel!,
          room: widget.selectedRoom!,
          bed: widget.selectedBed!,
          phone: widget.phone!,
          firstName: widget.firstName,
          lastName: widget.lastName,
          sharingType: widget.sharingType,
          email: widget.email,
          userPhotoPath: widget.userPhotoPath,
          aadharPhotoPath: widget.aadharPhotoPath,
          aadharCardbackPath: widget.aadharCardbackPath,
          employeeIdProofPath: widget.employeeIdProofPath,
          guardianMobiles: widget.guardianMobiles,
          deposit: widget.securityDeposit,
          rent: widget.rent,
          startDate: (widget.checkInDate.isNotEmpty)
              ? DateTime.parse(widget.checkInDate)
              : DateTime.now(),
          bookingType: widget.stayType?.name.toString(),
          maintenance: widget.maintainance.toString(),
          roomType: widget.roomType,
          endDate: (widget.checkOutDate.isNotEmpty)
              ? DateTime.parse(widget.checkOutDate)
              : DateTime.now(),
          aadhaarNumber: widget.aadhaarNumber,
          dob: widget.dob,
          gender: widget.gender,
          address: widget.address,
          totalAmount: finalTotal,
        );

        if (response != null) {
          final data = response['data'] ?? response;
          tenantId = (data['tenant']?['_id'] ??
                  data['tenantId'] ??
                  data['id'] ??
                  '')
              .toString();
          bookingId =
              (data['bookingId'] ?? data['_id'] ?? '').toString();
          hostelId = (data['hostel']?['_id'] ?? widget.selectedHostel?.id)
              .toString();
        } else {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      }

      if (tenantId != null && tenantId.isNotEmpty && finalTotal > 0) {
        double rentPaid = _calculatedProratedRent;
        double depositPaid = widget.securityDeposit;
        double maintenancePaid = widget.maintainance;

        String paymentDateStr = widget.checkInDate.isNotEmpty
            ? DateTime.parse(widget.checkInDate).toIso8601String()
            : DateTime.now().toIso8601String();

        String startDatePayload = widget.checkInDate.isNotEmpty
            ? (widget.checkInDate.contains('T')
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.checkInDate))
                : widget.checkInDate)
            : '';

        String endDatePayload = widget.checkOutDate.isNotEmpty
            ? (widget.checkOutDate.contains('T')
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.checkOutDate))
                : widget.checkOutDate)
            : '';

        await context.read<PaymentReportCubit>().submitPayment(
              tenantId: tenantId,
              hostelId: hostelId,
              bookingId: bookingId,
              amount: finalTotal,
              rent: rentPaid,
              deposit: depositPaid,
              utilities: 0,
              others: maintenancePaid,
              category: 'Rent',
              mode: _paymentMethod,
              date: paymentDateStr,
              startDate: startDatePayload,
              endDate: endDatePayload,
              forthePeriod: widget.forthePeriod,
              sendWhatsapp: true,
            );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double originalTotal = _baseTotal;
    double finalTotal =
        (originalTotal - _discountAmount).clamp(0, double.infinity);
    final authState = context.read<AuthCubit>().state;
    String collectorName = "You";
    if (authState is AuthAuthenticated) {
      collectorName = "${authState.owner.name} (you)";
    }

    String? rentSubtitle;
    if (_isProrated) {
      rentSubtitle =
          '$_occupiedDays days stay (Prorated: ₹${NumberFormat('#,##,###').format(_calculatedProratedRent)})';
    } else if (widget.checkInDate.isNotEmpty) {
      try {
        final checkIn = DateTime.parse(widget.checkInDate);
        final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
        rentSubtitle =
            '${DateFormat('dd MMM').format(checkIn)} - ${DateFormat('dd MMM').format(monthEnd)}';
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: SingleChildScrollView(
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collect Payment',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Not collected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  _buildDueItem('Rent', widget.rent, subtitle: rentSubtitle),
                  if (widget.securityDeposit > 0) ...[
                    SizedBox(height: 12.h),
                    _buildDueItem('Security deposit', widget.securityDeposit),
                  ],
                  if (widget.maintainance > 0) ...[
                    SizedBox(height: 12.h),
                    _buildDueItem('Maintainance', widget.maintainance),
                  ],
                  SizedBox(height: 12.h),
                  // if (_discountAmount > 0) ...[
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Text(
                  //             'Discount / Waiver',
                  //             style: TextStyle(
                  //               fontSize: 14.sp,
                  //               color: Colors.green[700],
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //           SizedBox(width: 8.w),
                  //           GestureDetector(
                  //             onTap: _showDiscountDialog,
                  //             child: Icon(
                  //               Icons.edit_outlined,
                  //               size: 16.sp,
                  //               color: const Color(0xFF2563EB),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       Text(
                  //         '- ₹${NumberFormat('#,##,###').format(_discountAmount)}',
                  //         style: TextStyle(
                  //           fontSize: 15.sp,
                  //           fontWeight: FontWeight.w700,
                  //           color: Colors.green[700],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ] else ...[
                  //   GestureDetector(
                  //     onTap: _showDiscountDialog,
                  //     child: Row(
                  //       children: [
                  //         Text(
                  //           '+ Add discount or waiver',
                  //           style: TextStyle(
                  //             fontSize: 14.sp,
                  //             color: const Color(0xFF2563EB),
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Divider(color: Colors.grey[200]),
                  ),
                  if (_discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total due',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(originalTotal)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(finalTotal)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(originalTotal)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Payment method',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildMethodBtn('Cash'),
                SizedBox(width: 8.w),
                _buildMethodBtn('UPI / QR', value: 'UPI'),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Received by',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                collectorName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _paymentMethod == 'Cash'
                            ? 'Mark cash as received'
                            : _paymentMethod == 'UPI'
                                ? 'Mark UPI as received'
                                : 'Send payment link',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueItem(String label, double amount, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodBtn(String label, {String? value}) {
    String actualValue = value ?? label;
    bool isSelected = _paymentMethod == actualValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = actualValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
