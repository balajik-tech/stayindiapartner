import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/features/payments/domain/entities/tenant_rental_entity.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/history/tenant_history_page.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/payment_report_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/collect_payment_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<TenantRentalEntity>? _rentals;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TenantDetailCubit>();
    if (widget.tenantId.isNotEmpty && widget.hostelId.isNotEmpty) {
      _cubit.loadDetail(widget.tenantId, widget.hostelId);
      _loadRentals();
    }
  }

  Future<void> _loadRentals() async {
    try {
      final rentals = await _paymentRepository.getTenantRentals(
        tenantId: widget.tenantId,
        hostelId: widget.hostelId,
      );
      if (mounted) setState(() => _rentals = rentals);
    } catch (_) {}
  }

  void _openCollectPaymentForRental({
    required double rent,
    required double deposit,
    required double maintenance,
    required double totalAmount,
    String? bookingId,
    String checkInDate = '',
    String checkOutDate = '',
    String? forthePeriod,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<PaymentReportCubit>(),
          child: CollectPaymentBottomSheet(
            tenantId: widget.tenantId,
            hostelId: widget.hostelId,
            bookingId: bookingId,
            rent: rent,
            securityDeposit: deposit,
            maintainance: maintenance,
            totalAmount: totalAmount,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            forthePeriod: forthePeriod,
          ),
        );
      },
    ).then((updated) {
      if (updated == true) {
        _loadRentals();
        if (widget.tenantId.isNotEmpty && widget.hostelId.isNotEmpty) {
          _cubit.loadDetail(widget.tenantId, widget.hostelId);
        }
      }
    });
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
                        if (detail?.guardianMobiles != null &&
                            detail!.guardianMobiles.isNotEmpty) ...[
                          _buildGuardianMobilesSection(detail),
                          SizedBox(height: 24.h),
                        ],
                        if (detail?.employeeIdProof != null &&
                            detail!.employeeIdProof!.isNotEmpty) ...[
                          _buildEmployeeIdProofSection(detail),
                          SizedBox(height: 24.h),
                        ],
                        if (_rentals != null) ...[
                          _buildBillsSummary(_rentals!),
                          SizedBox(height: 24.h),
                        ],
                        _buildPaymentHistory(context, detail),
                        // SizedBox(height: 24.h),
                        // _buildComplaintsHistory(context),
                        SizedBox(height: 32.h),
                        // _buildFooterActions(context, detail),
                        // SizedBox(height: 20.h),
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

  bool _isValidIndianMobile(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
    } else if (clean.length == 12 && clean.startsWith('91')) {
      return RegExp(r'^91[6-9]\d{9}$').hasMatch(clean);
    }
    return false;
  }

  Widget _buildGuardianMobilesSection(TenantDetailEntity? detail) {
    final list = detail?.guardianMobiles ?? [];
    if (list.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      'Parent / Guardian Details',
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: list.asMap().entries.map((entry) {
            final idx = entry.key;
            final g = entry.value;
            final isValidMobile = _isValidIndianMobile(g.mobileNumber);
            return Column(
              children: [
                if (idx > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: Divider(
                      color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.person_pin_rounded,
                        color: AppColors.primaryBlue,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Name & Relation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (g.name.isNotEmpty)
                            Text(
                              g.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (g.relation.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              g.relation.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Mobile Number
                    if (g.mobileNumber.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      Text(
                        g.mobileNumber,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isValidMobile
                              ? AppColors.greyText
                              : Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 8.w),

                      // Call Button
                      IconButton(
                        onPressed: () async {
                          final clean = g.mobileNumber.replaceAll(RegExp(r'\D'), '');
                          final numberToCall =
                              clean.length == 12 && clean.startsWith('91')
                                  ? clean.substring(2)
                                  : clean;
                          if (isValidMobile) {
                            final uri = Uri.parse('tel:$numberToCall');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invalid mobile number: ${g.mobileNumber}',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.call_rounded,
                          color: isValidMobile
                              ? AppColors.primaryBlue
                              : AppColors.greyText,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 36.w,
                          minHeight: 36.w,
                        ),
                      ),
                    ],
                  ],
                )
              ],
            );
          }).toList(),
        ),
      ),
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
    // final verified = detail?.kycVerified ?? false;
    final aadharPhotoUrl = ApiConstants.getImageUrl(detail?.aadharCardPhoto);
    final aadharPhotoBackUrl = ApiConstants.getImageUrl(detail?.idPhotoBack);
    final maskedAadhaar = detail?.aadhaarNumber;
    final dlKyc = detail?.dlKyc;
    final verified = (dlKyc?.isAadharVerified ?? false);

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
                      if (maskedAadhaar != null && maskedAadhaar.isNotEmpty) ...[
                        Text(
                          maskedAadhaar,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
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
                if (dlKyc != null && dlKyc.isAadharVerified)
                  TextButton(
                    onPressed: () => _showDlKycDetails(context, dlKyc),
                    child: Text(
                      'View'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
            if (aadharPhotoUrl != null && aadharPhotoUrl.isNotEmpty && !verified) ...[
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
            if (aadharPhotoBackUrl != null && aadharPhotoBackUrl.isNotEmpty && !verified) ...[
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

  Widget _buildEmployeeIdProofSection(TenantDetailEntity? detail) {
    final proofUrl = ApiConstants.getImageUrl(detail?.employeeIdProof);
    if (proofUrl == null || proofUrl.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      'Employee Card ID Proof',
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
                  child: Icon(
                    Icons.badge_outlined,
                    size: 24.sp,
                    color: const Color(0xFF8E24AA),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Card / Work ID',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Uploaded Employment Proof',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 12.h),
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
                              proofUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
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
                                  'Failed to load Employee Card image',
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
                    proofUrl,
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
                            'Failed to load Employee Card image',
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
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CHECKED_IN':
      case 'CHECKED IN':
      case 'SUCCESS':
      case 'PAID':
        return const Color(0xFF27C26C);
      case 'PENDING':
        return Colors.orange;
      case 'CHECKED_OUT':
      case 'CHECKED OUT':
        return Colors.grey;
      case 'CANCELLED':
      case 'FAILED':
        return const Color(0xFFF04438);
      default:
        return AppColors.greyText;
    }
  }

  /// What the tenant owes right now on their latest rental: the unpaid
  /// payable, or the rent for every month since the booking ran out.
  ({
    double totalDue,
    bool hasExceededEndDate,
    double calculatedRentForRenewal,
    String renewCheckInDate,
    String renewCheckOutDate,
    String forthePeriod,
  })
  _computeDues(TenantRentalEntity item) {
    final now = DateTime.now();
    // final testNow = DateTime(now.year, now.month + 3, now.day);
    final today = DateTime(now.year, now.month, now.day);

    bool hasExceededEndDate = false;
    double calculatedRentForRenewal =  (item.booking?.rent ?? 0.0);
    String renewCheckInDate = '';
    String renewCheckOutDate = '';
    String forthePeriod = '';

    if (item.booking?.endDate != null && item.booking!.endDate!.isNotEmpty) {
      try {
        final endDt = DateTime.parse(item.booking!.endDate!).toLocal();
        final endDateOnly = DateTime(endDt.year, endDt.month, endDt.day);
        if (today.isAfter(endDateOnly)) {
          hasExceededEndDate = true;

          final newCheckInDt = endDt.add(const Duration(days: 1));

          int unpaidMonths = (today.year - newCheckInDt.year) * 12 +
              (today.month - newCheckInDt.month) +
              1;
          if (unpaidMonths < 1) unpaidMonths = 1;

          final targetEndDt = DateTime(newCheckInDt.year, newCheckInDt.month + unpaidMonths, 0);

          renewCheckInDate = DateFormat('yyyy-MM-dd').format(newCheckInDt);
          renewCheckOutDate = DateFormat('yyyy-MM-dd').format(targetEndDt);
          forthePeriod = DateFormat('MMMMyyyy').format(targetEndDt);

          final baseMonthlyRent =  (item.booking?.rent ?? 0.0);
          calculatedRentForRenewal = baseMonthlyRent * unpaidMonths;
        }
      } catch (_) {}
    }

    double totalDue = 0;
    if (!item.isPaid || hasExceededEndDate) {
      if (hasExceededEndDate) {
        totalDue = calculatedRentForRenewal;
      } else {
        totalDue = item.payableAmount > 0
            ? item.payableAmount
            : (item.bookingAmount > 0
                ? item.bookingAmount
                : (item.booking?.rent ?? 0.0));
      }
    }

    return (
      totalDue: totalDue,
      hasExceededEndDate: hasExceededEndDate,
      calculatedRentForRenewal: calculatedRentForRenewal,
      renewCheckInDate: renewCheckInDate,
      renewCheckOutDate: renewCheckOutDate,
      forthePeriod: forthePeriod,
    );
  }

  Widget _buildBillsSummary(List<TenantRentalEntity> rentals) {
    if (rentals.isEmpty) return const SizedBox.shrink();

    final item = rentals.first;
    final dues = _computeDues(item);
    final totalDue = dues.totalDue;
    final hasExceededEndDate = dues.hasExceededEndDate;
    final calculatedRentForRenewal = dues.calculatedRentForRenewal;
    final renewCheckInDate = dues.renewCheckInDate;
    final renewCheckOutDate = dues.renewCheckOutDate;
    final forthePeriod = dues.forthePeriod;

    final isDue = (totalDue > 0 || hasExceededEndDate);
    final pendingCount = isDue ? 1 : 0;

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
        child: Column(
          children: [
            Row(
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
                      Row(
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
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isDue ? totalDue.toStringAsFixed(0) : 'great_job'.tr(),
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
                if (pendingCount > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF04438),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'pending_due_summary'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (isDue) ...[
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () {
                      String checkInDateStr = renewCheckInDate;
                      String checkOutDateStr = renewCheckOutDate;
                      String forthePeriodStr = forthePeriod;

                      if (!hasExceededEndDate) {
                        checkInDateStr = item.booking?.checkInDate ??
                            item.booking?.startDate ??
                            '';
                        checkOutDateStr = item.booking?.endDate ?? '';
                        if (checkOutDateStr.isNotEmpty) {
                          try {
                            final endDt =
                                DateTime.parse(checkOutDateStr).toLocal();
                            forthePeriodStr =
                                DateFormat('MMMMyyyy').format(endDt);
                          } catch (_) {}
                        }
                      }

                      _openCollectPaymentForRental(
                        rent: hasExceededEndDate
                            ? calculatedRentForRenewal
                            : (item.bookingAmount > 0
                                ? item.bookingAmount
                                : (item.booking?.rent ?? 0.0)),
                        deposit: hasExceededEndDate
                            ? 0.0
                            : (item.deposit > 0
                                ? item.deposit
                                : (item.booking?.deposit ?? 0.0)),
                        maintenance: hasExceededEndDate
                            ? 0.0
                            : (item.maintenance > 0
                                ? item.maintenance
                                : (item.booking?.maintenance ?? 0.0)),
                        totalAmount: totalDue,
                        bookingId: item.booking?.id ?? item.id,
                        checkInDate: checkInDateStr,
                        checkOutDate: checkOutDateStr,
                        forthePeriod: forthePeriodStr,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        hasExceededEndDate ? 'Renew now' : 'Collect now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TenantPaymentItemEntity> _getPaymentItems(TenantDetailEntity? detail) {
    if (_rentals != null && _rentals!.isNotEmpty) {
      return _rentals!.map((r) => r.toTenantPaymentItemEntity()).toList();
    }
    return detail?.payments ?? [];
  }

  Widget _buildPaymentHistory(
    BuildContext context,
    TenantDetailEntity? detail,
  ) {
    final payments = _getPaymentItems(detail);
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
                  final color = _getStatusColor(p.status);
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: AppColors.roomCardBorder.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      _buildPaymentItem(p, color, detail),
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
                        tenantId: widget.tenantId,
                        dueAmount: (_rentals?.isNotEmpty ?? false)
                            ? _computeDues(_rentals!.first).totalDue
                            : null,
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
    TenantPaymentItemEntity item,
    Color statusColor,
    TenantDetailEntity? detail,
  ) {
    final statusUpper = item.status.toUpperCase();
    final isPending = statusUpper.contains('PENDING') || statusUpper == 'CHECKED IN';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatMonth(item.month),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
              if (item.paymentDate != null && item.paymentDate!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  _formatDate(item.paymentDate!),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                ),
              ],
            ],
          ),
          Row(
            children: [
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
                  item.status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPending) ...[
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () async {
                    DateTime initialStartDt = DateTime.now();
                    String rawStart = detail?.stay?.startDate ??
                        item.paymentDate ??
                        item.month;

                    final DateTime now = DateTime.now();

                    final DateTime firstDate = rawStart.isNotEmpty
                        ? DateTime(
                      DateTime.parse(rawStart).year,
                      DateTime.parse(rawStart).month,
                      1,
                    )
                        : DateTime(now.year, now.month, 1);

                    final DateTime lastDate = DateTime(
                      firstDate.year,
                      firstDate.month + 1,
                      0,
                    );

                    if (rawStart.isNotEmpty) {
                      try {
                        initialStartDt = DateTime.parse(rawStart).toLocal();
                      } catch (_) {}
                    }

                    final DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: initialStartDt,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      helpText: 'Select Start Date for Payment',
                    );

                    if (pickedStartDate == null) return;

                    final monthEndDt = DateTime(
                      pickedStartDate.year,
                      pickedStartDate.month + 1,
                      0,
                    );

                    final int daysInMonth = monthEndDt.day;
                    final int occupiedDays =
                        monthEndDt.day - pickedStartDate.day + 1;

                    final double baseRent =
                        item.rent ?? (detail?.stay?.rent ?? 0.0);
                    final double depositAmt =
                        item.deposit ?? (detail?.stay?.deposit ?? 0.0);
                    final double maintenanceAmt = item.maintenance ?? 0.0;

                    double calculatedProratedRent = baseRent;
                    if (daysInMonth > 0 &&
                        occupiedDays > 0 &&
                        occupiedDays < daysInMonth) {
                      calculatedProratedRent =
                          (baseRent / daysInMonth) * occupiedDays;
                    }

                    double calculatedTotalAmount =
                        calculatedProratedRent + depositAmt + maintenanceAmt;

                    String checkInDateStr =
                        DateFormat('yyyy-MM-dd').format(pickedStartDate);
                    String checkOutDateStr =
                        DateFormat('yyyy-MM-dd').format(monthEndDt);
                    String forthePeriodStr =
                        DateFormat('MMMMyyyy').format(monthEndDt);

                    _openCollectPaymentForRental(
                      rent: baseRent,
                      deposit: depositAmt,
                      maintenance: maintenanceAmt,
                      totalAmount: calculatedTotalAmount,
                      bookingId: item.id.isNotEmpty
                          ? item.id
                          : (detail?.stay?.bookingId),
                      checkInDate: checkInDateStr,
                      checkOutDate: checkOutDateStr,
                      forthePeriod: forthePeriodStr,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Collect now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

        ],
      ),
    );
  }

  void _showDlKycDetails(BuildContext context, DlKycEntity dlKyc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 0.75.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aadhaar Verified Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 28.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  // if (dlKyc.adharimg != null && dlKyc.adharimg!.isNotEmpty) ...[
                  //   Center(
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(10.r),
                  //       child: Image.network(
                  //         dlKyc.120.w,
                  //         height: 120.h,
                  //         width: double.infinity,
                  //         fit: BoxFit.contain,
                  //         errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  //       ),
                  //     ),
                  //   ),
                  //   SizedBox(height: 20.h),
                  // ],
                  _buildDlKycItem('Full Name', dlKyc.name),
                  _buildDlKycItem('Father\'s Name', dlKyc.fatherName),
                  _buildDlKycItem('Gender', dlKyc.gender),
                  _buildDlKycItem('DOB', dlKyc.dob),
                  _buildDlKycItem('Aadhaar No', dlKyc.maskedAadhaar ?? dlKyc.aadharNo),
                  _buildDlKycItem('Address', dlKyc.aadharAddress),
                  _buildDlKycItem('Verified On', dlKyc.dateTime != null ? _formatDate(dlKyc.dateTime!) : null),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDlKycItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
              letterSpacing: 0.5,
            ),
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
          SizedBox(height: 8.h),
          const Divider(height: 1),
        ],
      ),
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
      final dt = DateTime.parse(month).toLocal();
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
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
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
}
