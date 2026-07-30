import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/features/profile/domain/entities/payment_summary.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/subscription_page.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentSummary? summary;

  const PaymentSuccessScreen({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : _PaymentSuccessBody(summary: summary!),
    );
  }
}

class _PaymentSuccessBody extends StatelessWidget {
  final PaymentSummary summary;

  const _PaymentSuccessBody({required this.summary});

  static const Color _green = Color(0xFF2FA84F);
  static const Color _blue = Color(0xFF1E3A8A);
  static const Color _darkText = Color(0xFF1B2430);
  static const Color _greyText = Color(0xFF6B7280);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, h:mm a').format(date);
  }

  String _formatValidity(DateTime start, DateTime end) {
    final fmt = DateFormat('dd MMM yyyy');
    return '${fmt.format(start)} → ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----- Top green-tinted gradient with success icon -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 36, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE1F3E4), Color(0xFFF4F5F8)],
                ),
              ),
              child: Column(
                children: [
                  const _SuccessIcon(color: _green),
                  const SizedBox(height: 20),
                  Text(
                    'Payment successful!',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your subscription is now active',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _greyText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currencyFormat.format(summary.amount),
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paid on ${_formatDate(summary.paymentDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: _greyText,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ----- Details card -----
                  _DetailsCard(
                    details: [
                      _DetailItem(label: 'Property', value: '${summary.propertyName} · ${summary.totalBeds} beds'),
                      _DetailItem(label: 'Plan', value: '${summary.planName} · ₹${summary.pricePerBedPerMonth.round()}/bed/mo'),
                      _DetailItem(label: 'Validity', value: _formatValidity(summary.startDate, summary.endDate)),
                      if (summary.savedAmount > 0)
                        _DetailItem(
                          label: 'You saved',
                          value: currencyFormat.format(summary.savedAmount),
                          highlight: true,
                        ),
                      _DetailItem(label: 'Transaction ID', value: summary.transactionId),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ----- Primary button -----
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Go to my subscriptions",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ----- Secondary button -----
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 20, color: AppColors.primaryBlue),
                      label: Text(
                        "Download Invoice",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final bool highlight;

  _DetailItem({required this.label, required this.value, this.highlight = false});
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.details});

  final List<_DetailItem> details;

  static const Color _greyText = Color(0xFF6B7280);
  static const Color _darkText = Color(0xFF1B2430);
  static const Color _green = Color(0xFF2FA84F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E9EE)),
      ),
      child: Column(
        children: List.generate(details.length, (index) {
          final item = details[index];
          final bool isLast = index == details.length - 1;
          final Color labelColor = item.highlight ? _green : _greyText;
          final Color valueColor = item.highlight ? _green : _darkText;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFEEF0F3)),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(fontSize: 14.5, color: labelColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
