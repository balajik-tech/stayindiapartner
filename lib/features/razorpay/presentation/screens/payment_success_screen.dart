import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/features/profile/domain/entities/payment_summary.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/subscription_usecases.dart';
import '../../../../injection_container.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/subscription_page.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final PaymentSummary? summary;

  const PaymentSuccessScreen({super.key, this.summary});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isDownloading = false;

  Future<void> _downloadInvoice() async {
    if (widget.summary?.id == null) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final useCase = sl<GetPaymentReceiptUseCase>();
      final result = await useCase(widget.summary!.id!);
      final fileUrl = result['fileUrl'];

      if (fileUrl != null && fileUrl.isNotEmpty) {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open the invoice URL.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.summary == null
          ? const Center(child: CircularProgressIndicator())
          : _PaymentSuccessBody(
              summary: widget.summary!,
              isDownloading: _isDownloading,
              onDownloadInvoice: _downloadInvoice,
            ),
    );
  }
}

class _PaymentSuccessBody extends StatelessWidget {
  final PaymentSummary summary;
  final bool isDownloading;
  final VoidCallback onDownloadInvoice;

  const _PaymentSuccessBody({
    required this.summary,
    required this.isDownloading,
    required this.onDownloadInvoice,
  });

  String _formatNumber(num n) {
    final s = n.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  String _formatValidity(DateTime start, DateTime end) {
    final fmt = DateFormat('dd MMM yyyy');
    return '${fmt.format(start)} → ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  SizedBox(height: 10.h),

                  // ----- Success Illustration -----
                  const _ConfettiSuccessIcon(),

                  SizedBox(height: 24.h),

                  // ----- Title & Subtitle -----
                  Text(
                    'Payment Successful!',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2430),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Your service invoice has been paid successfully.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ----- Invoice Card (Screen 5 design) -----
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Header Box
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Document Icon with check badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44.w,
                                    height: 44.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.article_outlined,
                                      color: const Color(0xFF2563EB),
                                      size: 24.sp,
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: const Color(0xFF22C55E),
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amount Paid',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '₹${_formatNumber(summary.amount.round())}',
                                    style: GoogleFonts.inter(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Bottom Checklist Section
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCheckRow('Payment processed securely'),
                              SizedBox(height: 10.h),
                              _buildCheckRow('Invoice updated automatically'),
                              SizedBox(height: 10.h),
                              _buildCheckRow(
                                'Confirmation sent to your email & WhatsApp',
                              ),
                            ],
                          ),
                        ),

                        // Compact Details Divider & Summary
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Property',
                                '${summary.propertyName} · ${summary.totalBeds} beds',
                              ),
                              SizedBox(height: 8.h),
                              _buildDetailRow(
                                'Plan',
                                summary.planName,
                              ),
                              SizedBox(height: 8.h),
                              _buildDetailRow(
                                'Validity',
                                _formatValidity(
                                  summary.startDate,
                                  summary.endDate,
                                ),
                              ),
                              if (summary.transactionId.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                _buildDetailRow(
                                  'Transaction ID',
                                  summary.transactionId,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // ----- Bottom Sticky Action Buttons -----
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Primary Button: View / Download Invoice
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isDownloading ? null : onDownloadInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: isDownloading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'View Invoice',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Secondary Outlined Button: Go to Home
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                    icon: Icon(
                      Icons.home_outlined,
                      size: 18.sp,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      'Go to Home',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
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

  Widget _buildCheckRow(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConfettiSuccessIcon extends StatelessWidget {
  const _ConfettiSuccessIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.w,
      height: 140.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withOpacity(0.08),
            ),
          ),
          // Middle halo
          Container(
            width: 115.w,
            height: 115.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withOpacity(0.15),
            ),
          ),
          // Solid green circle
          Container(
            width: 82.w,
            height: 82.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF22C55E),
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46.sp,
            ),
          ),

          // Confetti particles
          Positioned(
            top: 10.h,
            left: 30.w,
            child: _ConfettiDot(color: const Color(0xFF38BDF8), size: 7.r),
          ),
          Positioned(
            top: 14.h,
            right: 32.w,
            child: _ConfettiDot(color: const Color(0xFFF97316), size: 6.r),
          ),
          Positioned(
            top: 28.h,
            right: 14.w,
            child: _ConfettiDot(color: const Color(0xFF22C55E), size: 8.r),
          ),
          Positioned(
            top: 55.h,
            left: 10.w,
            child: _ConfettiDot(color: const Color(0xFF3B82F6), size: 7.r),
          ),
          Positioned(
            bottom: 40.h,
            left: 14.w,
            child: _ConfettiDot(color: const Color(0xFFF97316), size: 8.r),
          ),
          Positioned(
            bottom: 20.h,
            left: 30.w,
            child: _ConfettiDot(color: const Color(0xFFEC4899), size: 6.r),
          ),
          Positioned(
            top: 50.h,
            right: 8.w,
            child: _ConfettiDot(color: const Color(0xFFEF4444), size: 7.r),
          ),
          Positioned(
            bottom: 35.h,
            right: 12.w,
            child: _ConfettiDot(color: const Color(0xFF3B82F6), size: 6.r),
          ),
          Positioned(
            bottom: 18.h,
            right: 32.w,
            child: _ConfettiDot(color: const Color(0xFF22C55E), size: 8.r),
          ),
        ],
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  final Color color;
  final double size;

  const _ConfettiDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
