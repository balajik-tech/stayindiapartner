import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/features/electricity_bills/data/models/electricity_bill_model.dart';

import '../../../../core/theme/app_colors.dart';

class AddElectricityBillSheet extends StatefulWidget {
  final String hostelId;
  final List<ElectricityRoomModel> rooms;
  final String? initialRoomCode;
  final ElectricityBillModel? initialBill;
  final DateTime? defaultStartDate;
  final DateTime? defaultEndDate;
  final Future<bool> Function(ElectricityBillModel bill) onSave;
  final Function(String billId)? onDelete;

  const AddElectricityBillSheet({
    super.key,
    required this.hostelId,
    required this.rooms,
    this.initialRoomCode,
    this.initialBill,
    this.defaultStartDate,
    this.defaultEndDate,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String hostelId,
    required List<ElectricityRoomModel> rooms,
    String? initialRoomCode,
    ElectricityBillModel? initialBill,
    DateTime? defaultStartDate,
    DateTime? defaultEndDate,
    required Future<bool> Function(ElectricityBillModel bill) onSave,
    Function(String billId)? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddElectricityBillSheet(
          hostelId: hostelId,
          rooms: rooms,
          initialRoomCode: initialRoomCode,
          initialBill: initialBill,
          defaultStartDate: defaultStartDate,
          defaultEndDate: defaultEndDate,
          onSave: onSave,
          onDelete: onDelete,
        ),
      ),
    );
  }

  @override
  State<AddElectricityBillSheet> createState() => _AddElectricityBillSheetState();
}

class _AddElectricityBillSheetState extends State<AddElectricityBillSheet> {
  late String _selectedRoomCode;
  late DateTime _billStartDate;
  late DateTime _billEndDate;
  late DateTime _dueDate;
  late TextEditingController _monthController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.initialBill != null) {
      _selectedRoomCode = widget.initialBill!.roomCode;
      _billStartDate = widget.initialBill!.billStartDate;
      _billEndDate = widget.initialBill!.billEndDate;
      _dueDate = widget.initialBill!.dueDate;
      _monthController = TextEditingController(text: widget.initialBill!.month);
      _amountController = TextEditingController(
        text: widget.initialBill!.amount > 0
            ? widget.initialBill!.amount.toStringAsFixed(0)
            : '',
      );
      _noteController = TextEditingController(text: widget.initialBill!.note ?? '');
    } else {
      _selectedRoomCode = widget.initialRoomCode ??
          (widget.rooms.isNotEmpty ? widget.rooms.first.code : '');
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      _billStartDate = widget.defaultStartDate ?? DateTime(now.year, now.month, 1);
      if (!_billStartDate.isBefore(today)) {
        _billStartDate = yesterday;
      }
      final minEndDate = _billStartDate.add(const Duration(days: 1));
      _billEndDate = widget.defaultEndDate ?? now;
      if (_billEndDate.isBefore(minEndDate)) {
        _billEndDate = minEndDate;
      }
      if (_billEndDate.isAfter(now)) {
        _billEndDate = now;
      }
      _dueDate = _billEndDate.add(const Duration(days: 5));
      _monthController = TextEditingController(
        text: DateFormat('MMMM yyyy').format(_billStartDate),
      );
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _monthController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initial,
    DateTime? firstDate,
    DateTime? lastDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final effectiveFirst = firstDate ?? DateTime(2020);
    final effectiveLast = lastDate ?? now;

    DateTime effectiveInitial = initial;
    if (effectiveInitial.isBefore(effectiveFirst)) {
      effectiveInitial = effectiveFirst;
    }
    if (effectiveInitial.isAfter(effectiveLast)) {
      effectiveInitial = effectiveLast;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: effectiveFirst,
      lastDate: effectiveLast,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF112D4E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  void _onStartDateChanged(DateTime date) {
    setState(() {
      _billStartDate = date;
      _monthController.text = DateFormat('MMMM yyyy').format(date);
      final now = DateTime.now();
      final minEndDate = date.add(const Duration(days: 1));
      if (_billEndDate.isBefore(minEndDate)) {
        _billEndDate = minEndDate;
      }
      if (_billEndDate.isAfter(now)) {
        _billEndDate = now;
      }
      if (_dueDate.isBefore(_billEndDate)) {
        _dueDate = _billEndDate.add(const Duration(days: 5));
      }
    });
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid bill amount')),
        );
        return;
      }

      final room = widget.rooms.firstWhere(
        (r) => r.code.toLowerCase() == _selectedRoomCode.toLowerCase() || r.id == _selectedRoomCode,
        orElse: () => ElectricityRoomModel(
          id: _selectedRoomCode,
          code: _selectedRoomCode,
          name: 'Room $_selectedRoomCode',
        ),
      );

      final monthText = _monthController.text.trim().isNotEmpty
          ? _monthController.text.trim()
          : DateFormat('MMMM yyyy').format(_billStartDate);

      final noteText = _noteController.text.trim();

      final bill = ElectricityBillModel(
        id: widget.initialBill?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        hostelId: widget.hostelId,
        roomId: room.id,
        roomCode: room.code,
        roomName: room.name,
        billStartDate: _billStartDate,
        billEndDate: _billEndDate,
        dueDate: _dueDate,
        month: monthText,
        amount: amount,
        note: noteText.isNotEmpty ? noteText : null,
        status: widget.initialBill?.status,
        tenantSplits: widget.initialBill?.tenantSplits,
      );

      setState(() {
        _isSaving = true;
      });

      try {
        final success = await widget.onSave(bill);
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Electricity bill saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialBill != null;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
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
                isEditing ? 'Edit room electricity bill' : 'Add room electricity bill',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 16.h),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROOM NO. Field
                    Text(
                      'ROOM NO.',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        _selectedRoomCode,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Room selection pills
                    if (widget.rooms.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.rooms.map((room) {
                            final isSelected = room.code == _selectedRoomCode;
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: InkWell(
                                onTap: isEditing
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedRoomCode = room.code;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20.r),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ?  AppColors.primaryBlue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ?  AppColors.primaryBlue
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Text(
                                    room.code,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    SizedBox(height: 16.h),

                    // BILL START DATE & BILL END DATE Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BILL START DATE',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              InkWell(
                                onTap: () {
                                  final now = DateTime.now();
                                  final yesterday = DateTime(now.year, now.month, now.day - 1);
                                  _pickDate(
                                    initial: _billStartDate.isAfter(yesterday) ? yesterday : _billStartDate,
                                    lastDate: yesterday,
                                    onPicked: _onStartDateChanged,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateFormat.format(_billStartDate),
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 15.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BILL END DATE',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              InkWell(
                                onTap: () {
                                  final minEndDate = _billStartDate.add(const Duration(days: 1));
                                  final now = DateTime.now();
                                  final effectiveLast = now.isBefore(minEndDate) ? minEndDate : now;
                                  _pickDate(
                                    initial: _billEndDate.isBefore(minEndDate) ? minEndDate : _billEndDate,
                                    firstDate: minEndDate,
                                    lastDate: effectiveLast,
                                    onPicked: (picked) {
                                      setState(() {
                                        _billEndDate = picked;
                                        if (_dueDate.isBefore(_billEndDate)) {
                                          _dueDate = _billEndDate.add(const Duration(days: 5));
                                        }
                                      });
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateFormat.format(_billEndDate),
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 15.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // DUE DATE & MONTH Row
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             'DUE DATE',
                    //             style: GoogleFonts.inter(
                    //               fontSize: 10.sp,
                    //               fontWeight: FontWeight.w700,
                    //               color: const Color(0xFF64748B),
                    //               letterSpacing: 0.5,
                    //             ),
                    //           ),
                    //           SizedBox(height: 6.h),
                    //           InkWell(
                    //             onTap: () => _pickDate(
                    //               initial: _dueDate,
                    //               onPicked: (picked) {
                    //                 setState(() {
                    //                   _dueDate = picked;
                    //                 });
                    //               },
                    //             ),
                    //             borderRadius: BorderRadius.circular(10.r),
                    //             child: Container(
                    //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                    //               decoration: BoxDecoration(
                    //                 color: const Color(0xFFF1F5F9),
                    //                 borderRadius: BorderRadius.circular(10.r),
                    //               ),
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Text(
                    //                     dateFormat.format(_dueDate),
                    //                     style: GoogleFonts.inter(
                    //                       fontSize: 12.sp,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: const Color(0xFF1E293B),
                    //                     ),
                    //                   ),
                    //                   Icon(
                    //                     Icons.calendar_today_rounded,
                    //                     size: 15.sp,
                    //                     color: const Color(0xFF64748B),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     SizedBox(width: 10.w),
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             'MONTH',
                    //             style: GoogleFonts.inter(
                    //               fontSize: 10.sp,
                    //               fontWeight: FontWeight.w700,
                    //               color: const Color(0xFF64748B),
                    //               letterSpacing: 0.5,
                    //             ),
                    //           ),
                    //           SizedBox(height: 6.h),
                    //           TextFormField(
                    //             controller: _monthController,
                    //             style: GoogleFonts.inter(
                    //               fontSize: 12.sp,
                    //               fontWeight: FontWeight.w600,
                    //               color: const Color(0xFF1E293B),
                    //             ),
                    //             decoration: InputDecoration(
                    //               hintText: 'e.g. October 2026',
                    //               hintStyle: GoogleFonts.inter(
                    //                 fontSize: 12.sp,
                    //                 color: const Color(0xFF94A3B8),
                    //               ),
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    //               filled: true,
                    //               fillColor: const Color(0xFFF8FAFC),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10.r),
                    //                 borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10.r),
                    //                 borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // SizedBox(height: 16.h),

                    // AMOUNT (₹)
                    Text(
                      'AMOUNT (₹)',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 3000',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter bill amount';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16.h),

                    // NOTE (OPTIONAL)
                    Text(
                      'NOTE (OPTIONAL)',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _noteController,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Meter reading taken on 30th evening',
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
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Save Bill Primary Button
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Bill' : 'Save Bill',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              if (isEditing && widget.onDelete != null) ...[
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () {
                    widget.onDelete!(widget.initialBill!.id);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    minimumSize: Size(double.infinity, 40.h),
                  ),
                  child: Text(
                    'Delete Bill',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 4.h),

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
