import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/payment_report_cubit.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class RecordPaymentBottomSheetNew extends StatefulWidget {
  final List<TenantEntity> tenants;

  const RecordPaymentBottomSheetNew({super.key, required this.tenants});

  static void show(BuildContext context, List<TenantEntity> tenants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentReportCubit>(),
        child: RecordPaymentBottomSheetNew(tenants: tenants),
      ),
    );
  }

  @override
  State<RecordPaymentBottomSheetNew> createState() =>
      _RecordPaymentBottomSheetNewState();
}

class _RecordPaymentBottomSheetNewState
    extends State<RecordPaymentBottomSheetNew> {
  TenantEntity? _selectedTenant;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Rent';
  String _selectedMode = 'Cash';
  bool _sendWhatsapp = true;
  File? _screenshot;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _screenshot = File(pickedFile.path));
    }
  }

  void _savePayment() {
    if (_selectedTenant == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tenant and enter amount'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    context.read<PaymentReportCubit>().submitPayment(
      tenantId: _selectedTenant!.id,
      hostelId: _selectedTenant!.hostelId,
      bookingId: _selectedTenant!.bookingId,
      amount: amount,
      category: _selectedCategory,
      mode: _selectedMode,
      date: DateTime.now().toIso8601String(),
      referenceNo: _referenceController.text.isEmpty
          ? null
          : _referenceController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      screenshotPath: _screenshot?.path,
      sendWhatsapp: _sendWhatsapp,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record a payment',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTenantSelector(),
            SizedBox(height: 16.h),
            _buildAmountInput(),
            SizedBox(height: 16.h),
            _buildCategorySelector(),
            SizedBox(height: 20.h),
            _buildModeSelector(),
            SizedBox(height: 20.h),
            if (_selectedMode == 'UPI') ...[
              _buildReferenceInput(),
              SizedBox(height: 16.h),
            ],
            _buildDateAndCollector(),
            SizedBox(height: 16.h),
            if (_selectedMode == 'Cash') ...[_buildNoteInput()],
            SizedBox(height: 16.h),
            if (_selectedMode == 'UPI') ...[_buildScreenshotButton()],
            SizedBox(height: 16.h),
            _buildInfoBox(),
            SizedBox(height: 16.h),
            _buildWhatsappToggle(),
            SizedBox(height: 24.h),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedTenant?.id,
          hint: Text(
            'Select Tenant',
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grayColor2),
          ),
          items: widget.tenants.map((tenant) {
            return DropdownMenuItem(
              value: tenant.id,
              child: Row(
                children: [
                  CustomAvatar(
                    imageUrl: ApiConstants.getImageUrl(tenant.avatar),
                    name: tenant.fullName,
                    size: 32.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tenant.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Room ${tenant.roomTypename} · Bed ${tenant.bedNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.grayColor2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;

            final tenant = widget.tenants.firstWhere(
                  (t) => t.id == val,
            );




            setState(() {
              _selectedTenant = tenant;
            });

            debugPrint('========== SELECTED TENANT ==========');
            debugPrint(
              'Tenant ID: ${_selectedTenant?.id}',
              );
            debugPrint(
              'Tenant Name: ${_selectedTenant?.fullName}',
            );
            debugPrint(
              'Tenant Avatar: ${_selectedTenant?.avatar}',
            );
            debugPrint(
              'Tenant Hostel ID: ${_selectedTenant?.hostelId}',
            );
            debugPrint(
              'Tenant Booking ID: ${_selectedTenant?.bookingId}',
            );
            debugPrint(
              'Tenant Room Type: ${_selectedTenant?.roomTypename}',
            );
            debugPrint(
              'Tenant Bed Number: ${_selectedTenant?.bedNumber}',
            );

            debugPrint('======================================');
          },
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Text(
            '₹',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
              ),
            ),
          ),
          if (_selectedTenant != null)
            Text(
              'Rent ${_selectedTenant!.roomTypename}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grayColor2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Rent', 'Deposit', 'Utilities', 'Other'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              cat,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.grayColor2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      {'label': 'Cash', 'icon': Icons.payments_outlined},
      {'label': 'UPI', 'icon': Icons.qr_code_2_rounded},
      // {'label': 'Bank', 'icon': Icons.account_balance_outlined},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: modes.map((mode) {
        final isSelected = _selectedMode == mode['label'];
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _selectedMode = mode['label'] as String),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(
                    mode['icon'] as IconData,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.grayColor2,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    mode['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.grayColor2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReferenceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UTR / reference no.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.grayColor2,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter UTR number',
                  ),
                ),
              ),
              Icon(Icons.copy_rounded, size: 18.sp, color: AppColors.greyText),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '12 digits, from the tenant\'s payment app',
          style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.greyText),
        ),
      ],
    );
  }

  Widget _buildDateAndCollector() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoField(label: 'Received on', value: 'Today'),
        ),
        if (_selectedMode == 'Cash') ...[
          SizedBox(width: 16.w),
          Expanded(
            child: _buildInfoField(label: 'Collected by', value: 'You'),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.grayColor2),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _noteController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a note (optional)',
          hintStyle: GoogleFonts.inter(color: AppColors.grayColor2),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    final isCash = _selectedMode == 'Cash';
    final bgColor = isCash ? const Color(0xFFEFF6FF) : const Color(0xFFEFF6FF);
    final textColor = isCash ? AppColors.primaryBlue : AppColors.primaryBlue;
    final icon = isCash
        ? Icons.info_outline_rounded
        : Icons.verified_user_outlined;
    final text = isCash
        ? 'No bank trail — the receipt is the only proof.'
        : 'UTR is traceable through both banks if disputed.';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _screenshot == null
                  ? Icons.image_outlined
                  : Icons.check_circle_rounded,
              size: 20.sp,
              color: _screenshot == null ? AppColors.greyText : Colors.green,
            ),
            SizedBox(width: 8.w),
            Text(
              _screenshot == null
                  ? 'Attach screenshot optional'
                  : 'Screenshot attached',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsappToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Send receipt on WhatsApp',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        Switch.adaptive(
          value: _sendWhatsapp,
          thumbColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 1),
          ),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBlue.withValues(alpha: 1);
            }
            return Colors.grey.withValues(alpha: 1);
          }),
          onChanged: (val) => setState(() => _sendWhatsapp = val),
        )
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save payment',
          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
