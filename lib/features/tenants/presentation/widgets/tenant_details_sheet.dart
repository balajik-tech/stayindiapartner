import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/history/tenant_history_page.dart';
import 'package:stayindia_owner/features/notices/presentation/pages/give_notice_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/add_note_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/complaints_history_page.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class TenantDetailsSheet extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final String room;
  final String tenantId;
  final String hostelId;

  const TenantDetailsSheet({
    super.key,
    required this.name,
    this.imageUrl,
    required this.room,
    required this.tenantId,
    required this.hostelId,
  });

  static void show(
    BuildContext context, {
    required String name,
    String? imageUrl,
    required String room,
    required String tenantId,
    required String hostelId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TenantDetailsSheet(
        name: name,
        imageUrl: imageUrl,
        room: room,
        tenantId: tenantId,
        hostelId: hostelId,
      ),
    );
  }

  @override
  State<TenantDetailsSheet> createState() => _TenantDetailsSheetState();
}

class _TenantDetailsSheetState extends State<TenantDetailsSheet> {
  late final TenantDetailCubit _cubit;
  final PaymentRepository _paymentRepository = sl<PaymentRepository>();

  Map<String, dynamic>? _bills;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TenantDetailCubit>();
    if (widget.tenantId.isNotEmpty && widget.hostelId.isNotEmpty) {
      _cubit.loadDetail(widget.tenantId, widget.hostelId);
      _loadBills();
    }
  }

  Future<void> _loadBills() async {
    try {
      final bills = await _paymentRepository.getBills(
        tenantId: widget.tenantId,
        hostelId: widget.hostelId,
      );
      if (mounted) setState(() => _bills = bills);
    } catch (_) {}
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Container(
        height: 0.9.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: BlocBuilder<TenantDetailCubit, TenantDetailState>(
          builder: (context, state) {
            final detail = state is TenantDetailLoaded ? state.detail : null;
            return Column(
              children: [
                _buildHeader(context, detail),
                if (state is TenantDetailLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is TenantDetailError)
                  Expanded(
                    child: Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20.w),
                      children: [
                        _buildContactInfo(detail),
                        SizedBox(height: 24.h),
                        _buildStayDetails(detail),
                        SizedBox(height: 24.h),
                        _buildKycDocuments(detail),
                        SizedBox(height: 24.h),
                        if (_bills != null) ...[
                          _buildBillsSummary(_bills!),
                          SizedBox(height: 24.h),
                        ],
                        _buildPaymentHistory(context, detail),
                        SizedBox(height: 24.h),
                        _buildComplaintsHistory(context),
                        SizedBox(height: 32.h),
                        _buildFooterActions(context, detail),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TenantDetailEntity? detail) {
    final displayName = detail?.name ?? widget.name;
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                (() {
                  final avatarUrl =
                      ApiConstants.getImageUrl(detail?.avatar) ??
                      widget.imageUrl;
                  final initials = displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : 'T';

                  return GestureDetector(
                    onTap: () {
                      if (avatarUrl != null && avatarUrl.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(10.w),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10.h,
                                  right: 10.w,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      onBackgroundImageError:
                          (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? (e, stackTrace) {}
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            )
                          : null,
                    ),
                  );
                })(),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.verified,
                            size: 20.sp,
                            color: const Color(0xFF27C26C),
                          ),
                        ],
                      ),
                      if (detail?.isAway == true) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 12.sp,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'currently_away'.tr(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Builder(builder: (_) {
                        final rawRoom = detail?.stay?.roomTypename ?? widget.room;
                        final roomLabel = rawRoom.isEmpty ? null : rawRoom;

                        final rawBed = detail?.stay?.bedNumber ?? '';
                        String bedLabel = '';
                        if (rawBed.isNotEmpty) {
                          final num = int.tryParse(rawBed);
                          if (num != null && num >= 1) {
                            bedLabel = String.fromCharCode(64 + num);
                          } else {
                            bedLabel = rawBed.toUpperCase();
                          }
                        }

                        final rawAcType = detail?.stay?.acType ?? '';
                        String acLabel = '';
                        if (rawAcType.toUpperCase().contains('NON')) {
                          acLabel = 'Non-AC';
                        } else if (rawAcType.toUpperCase() == 'AC') {
                          acLabel = 'AC';
                        }

                        final rawSharing = detail?.stay?.sharingType ?? '';
                        String sharingLabel = '';
                        final sharingMap = {
                          'SINGLE': '1 Sharing',
                          'DOUBLE': '2 Sharing',
                          'TRIPLE': '3 Sharing',
                          'QUADRUPLE': '4 Sharing',
                          'QUINTUPLE': '5 Sharing',
                          'DORMITORY': 'Dormitory',
                        };
                        sharingLabel = sharingMap[rawSharing.toUpperCase()] ?? (rawSharing.isNotEmpty ? rawSharing : '');

                        if (roomLabel == null) {
                          return Text(
                            'not_assigned'.tr(),
                            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                          );
                        }

                        return Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildInfoChip(
                              label: roomLabel.toLowerCase().startsWith('room') ? roomLabel : 'Room $roomLabel',
                              color: const Color(0xFF1B2838),
                            ),
                            if (bedLabel.isNotEmpty)
                              _buildInfoChip(label: 'Bed $bedLabel', color: const Color(0xFF1B2838)),
                            if (acLabel.isNotEmpty)
                              _buildInfoChip(
                                label: acLabel,
                                color: acLabel == 'AC' ? const Color(0xFF0277BD) : const Color(0xFF558B2F),
                              ),
                            if (sharingLabel.isNotEmpty)
                              _buildInfoChip(label: sharingLabel, color: const Color(0xFF6A1B9A)),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, size: 28.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: _buildSectionTitle(title),
        ),
        child,
      ],
    );
  }

  Widget _buildContactInfo(TenantDetailEntity? detail) {
    final phone = detail?.mobile ?? '';
    final email = detail?.email ?? '';
    return _buildSection(
      'contact_info'.tr(),
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            _buildContactItem(Icons.phone_iphone_rounded, 'phone'.tr(), phone),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(
                color: AppColors.roomCardBorder.withValues(alpha: 0.5),
              ),
            ),
            _buildContactItem(Icons.mail_outline_rounded, 'email'.tr(), email),
            if (detail?.parentMobile != null &&
                detail!.parentMobile!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
              ),
              _buildContactItem(
                Icons.family_restroom_rounded,
                'parent_guardian'.tr(),
                detail.parentMobile!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: AppColors.roomCardBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStayDetails(TenantDetailEntity? detail) {
    final stay = detail?.stay;
    final checkIn = stay?.checkInDate != null
        ? _formatDate(stay!.checkInDate!)
        : '';
    final rent = stay != null ? stay.rent.toStringAsFixed(0) : '';
    return _buildSection(
      'stay_details'.tr(),
      Row(
        children: [
          Expanded(
            child: _buildStayItem(
              Icons.calendar_today_rounded,
              'check_in_date_req'.tr().replaceAll(' *', ''),
              checkIn,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStayItem(
              Icons.payments_rounded,
              'monthly_rent'.tr(),
              rent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: AppColors.greyText),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycDocuments(TenantDetailEntity? detail) {
    final verified = detail?.kycVerified ?? false;
    final aadharPhotoUrl = ApiConstants.getImageUrl(detail?.aadharCardPhoto);
    final aadharPhotoBackUrl = ApiConstants.getImageUrl(detail?.idPhotoBack);
    final maskedAadhaar = detail?.aadhaarNumber;

    return _buildSection(
      'kyc_docs'.tr(),
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFFF9FAFB),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/Aadhaar.svg',
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aadhaar_card'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if(maskedAadhaar!.isNotEmpty)...[
                        Text(
                          maskedAadhaar,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color:  AppColors.greyText,
                          ),
                        )
                      ],
                      Row(
                        children: [
                          Icon(
                            verified
                                ? Icons.verified_user
                                : Icons.info_outline_rounded,
                            size: 14.sp,
                            color: verified
                                ? const Color(0xFF27C26C)
                                : AppColors.greyText,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            verified
                                ? 'verified_secured'.tr()
                                : 'verification_pending'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: verified
                                  ? const Color(0xFF27C26C)
                                  : AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (aadharPhotoUrl != null && aadharPhotoUrl.isNotEmpty) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SizedBox(height: 12.h),
              Text(
                'Uploaded Front Document:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10.w),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                aadharPhotoUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(20.w),
                                      child: const Text(
                                        'Failed to load Aadhar Card image',
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.5,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      aadharPhotoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 30.sp,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Failed to load Aadhar image',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  'Tap to view and zoom',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ],
            if (aadharPhotoBackUrl != null && aadharPhotoBackUrl.isNotEmpty) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SizedBox(height: 12.h),
              Text(
                'Uploaded Back Document:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10.w),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                aadharPhotoBackUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(20.w),
                                      child: const Text(
                                        'Failed to load Aadhar Card image',
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.5,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      aadharPhotoBackUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 30.sp,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Failed to load Aadhar image',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  'Tap to view and zoom',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillsSummary(Map<String, dynamic> bills) {
    final summary = bills['summary'] ?? {};
    final totalDue =
        (summary['totalDue'] ??
                bills['totalDue'] ??
                bills['pendingAmount'] ??
                0)
            .toDouble();
    final pendingCount =
        summary['pendingCount'] ??
        bills['pendingCount'] ??
        bills['pendingMonths'] ??
        0;
    final isDue = totalDue > 0;
    return _buildSection(
      'dues_summary'.tr(),
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDue ? const Color(0xFFFFF1F0) : const Color(0xFFECFDF3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDue
                ? const Color(0xFFF04438).withValues(alpha: 0.3)
                : const Color(0xFF12B76A).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDue ? Icons.warning_amber_rounded : Icons.verified_rounded,
              color: isDue ? const Color(0xFFF04438) : const Color(0xFF12B76A),
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDue ? 'amount_due'.tr() : 'all_dues_clear'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDue
                          ? const Color(0xFFF04438).withValues(alpha: 0.6)
                          : const Color(0xFF12B76A).withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isDue ? '${totalDue.toStringAsFixed(0)}' : 'great_job'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDue
                          ? const Color(0xFFF04438)
                          : const Color(0xFF12B76A),
                    ),
                  ),
                ],
              ),
            ),
            if (pendingCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF04438),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'pending_count_label'.tr(
                    namedArgs: {'count': pendingCount.toString()},
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(
    BuildContext context,
    TenantDetailEntity? detail,
  ) {
    final payments = detail?.payments ?? [];
    final preview = payments.take(4).toList();
    return _buildSection(
      'payment_history'.tr(),
      Column(
        children: [
          if (preview.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 32.sp,
                    color: AppColors.greyText.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'no_payment_records'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: preview.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final color = p.status == 'PAID'
                      ? const Color(0xFF27C26C)
                      : const Color(0xFFF04438);
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: AppColors.roomCardBorder.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      _buildPaymentItem(
                        _formatMonth(p.month),
                        p.paymentDate != null
                            ? _formatDate(p.paymentDate!)
                            : '',
                        p.status,
                        color,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TenantHistoryPage(
                        tenantName: widget.name,
                        payments: payments,
                        checkInDate: detail?.stay?.checkInDate,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'view_full_history'.tr(),
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18.sp,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    String month,
    String date,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            month,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.greyText,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsHistory(BuildContext context) {
    return _buildSection(
      'complaints_history'.tr(),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.report_problem_outlined,
                    color: Colors.orange,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'maintenance_issues'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'track_problems'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ComplaintsHistoryPage(hostelId: widget.hostelId),
                      ),
                    );
                  },
                  child: Text(
                    'history'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, TenantDetailEntity? detail) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (detail != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiveNoticePage(
                          tenant: detail.toTenantEntity(widget.hostelId),
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(color: AppColors.roomCardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'give_notice'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
            // SizedBox(width: 12.w),

            // Commented Add Note

            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const AddNotePage(),
            //         ),
            //       );
            //     },
            //     style: OutlinedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(vertical: 14.h),
            //       side: BorderSide(color: AppColors.roomCardBorder),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10.r),
            //       ),
            //     ),
            //     child: Text(
            //       'Add Note',
            //       style: TextStyle(
            //         fontSize: 16.sp,
            //         fontWeight: FontWeight.bold,
            //         color: AppColors.darkText,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatMonth(String month) {
    try {
      final parts = month.split('-');
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final m = int.parse(parts[1]) - 1;
      return '${months[m]} ${parts[0]}';
    } catch (_) {
      return month;
    }
  }
}
