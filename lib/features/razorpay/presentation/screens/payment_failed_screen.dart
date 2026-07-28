import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';

import '../../data/models/payment_failed_model.dart';


class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  /// Static data for this screen. Replace this with data from your
  /// API/state layer when wiring this screen up to a real payment flow.
  static final PaymentFailedModel _data = PaymentFailedModel(
    status: 'failed',
    title: 'Payment Failed',
    message:
        'Your money was not deducted. If it was, it will be auto-refunded '
        'in 5–7 business days.',
    amount: 29736,
    currencySymbol: '₹',
    attemptedOn: '28 Jul 2026, 4:42 PM',
    reason:
        'Transaction declined by your bank (insufficient funds or limit '
        'exceeded). Try another payment method or contact your bank.',
    details: const [
      PaymentFailedDetail(label: 'Property', value: 'Sunrise Boys PG · 42 beds'),
      PaymentFailedDetail(label: 'Plan', value: 'Annual · ₹59/bed/mo'),
      PaymentFailedDetail(label: 'Reference ID', value: 'SI2607284421877'),
    ],
    actions: const PaymentFailedActions(
      primary: 'Retry payment',
      secondary: 'Change payment method',
      tertiary: 'Contact support',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: _PaymentFailedBody(data: _data),
    );
  }
}

class _PaymentFailedBody extends StatelessWidget {
  const _PaymentFailedBody({required this.data});

  final PaymentFailedModel data;

  static const Color _orange = Color(0xFFF08C1D);
  static const Color _red = Color(0xFFE33B3B);
  static const Color _darkText = Color(0xFF1B2430);
  static const Color _greyText = Color(0xFF6B7280);
  static const Color _amountGrey = Color(0xFFB8BEC8);
  static const Color _blue = Color(0xFF1E2A6E);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----- Top pink gradient with failure icon -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 36, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFBE3E1), Color(0xFFF4F5F8)],
                ),
              ),
              child: Column(
                children: [
                  _FailureIcon(color: _red),
                  const SizedBox(height: 20),
                  Text(
                    data.title,
                    style:  GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      data.message,
                      textAlign: TextAlign.center,
                      style:  GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.4,
                        color: _greyText,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.formattedAmount,
                    style:  GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _amountGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Attempted on ${data.attemptedOn}',
                    style:  GoogleFonts.inter(
                      fontSize: 13,
                      color: _greyText,
                      fontWeight: FontWeight.w600
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
                  // ----- Reason warning box -----
                  _ReasonBox(reason: data.reason),
                  const SizedBox(height: 16),

                  // ----- Details card -----
                  _DetailsCard(details: data.details),
                  const SizedBox(height: 24),

                  // ----- Primary button -----
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.crop_square,
                          size: 18, color: Colors.white),
                      label: Text(
                        "Retry payment",
                        style:  GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ----- Secondary button -----
                  SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Change Payment Method",
                        style:  GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ----- Tertiary text button -----
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.crop_square,
                          size: 18, color: _greyText),
                      label: Text(
                        "Contact Support",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _greyText,
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

class _FailureIcon extends StatelessWidget {
  const _FailureIcon({required this.color});

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
              color: color.withValues(alpha: 0.12),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
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
                Icons.crop_square,
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

class _ReasonBox extends StatelessWidget {
  const _ReasonBox({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF1DE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3D9AE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.crop_square, size: 20, color: Color(0xFFB4690E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:  GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF9A5A0F),
                  fontWeight: FontWeight.w700
                ),
                children: [
                  TextSpan(
                    text: 'Reason: ',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: reason),
                ],
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

  final List<PaymentFailedDetail> details;

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
                  style:  GoogleFonts.inter(
                    fontSize: 14.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style:  GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2430),
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
