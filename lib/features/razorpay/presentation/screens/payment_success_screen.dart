import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/subscription_page.dart';
import '../../data/models/payment_success_model.dart';


class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  /// Static data for this screen. Replace this with data from your
  /// API/state layer when wiring this screen up to a real payment flow.
  static const PaymentSuccessModel _data = PaymentSuccessModel(
    status: 'success',
    title: 'Payment successful!',
    message: 'Your subscription is now active',
    amount: 29736,
    currencySymbol: '₹',
    paidOn: '28 Jul 2026, 4:42 PM',
    details: [
      PaymentSuccessDetail(
        label: 'Property',
        value: 'Sunrise Boys PG · 42 beds',
      ),
      PaymentSuccessDetail(
        label: 'Plan',
        value: 'Annual · ₹59/bed/mo',
      ),
      PaymentSuccessDetail(
        label: 'Validity',
        value: '28 Jul 2026 → 27 Jul 2027',
      ),
      PaymentSuccessDetail(
        label: 'You saved',
        value: '₹20,160',
        highlight: true,
      ),
      PaymentSuccessDetail(
        label: 'Transaction ID',
        value: 'SI2607284421876',
      ),
    ],
    actions: PaymentSuccessActions(
      primary: 'Go to my subscriptions',
      secondary: 'Download invoice',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: const _PaymentSuccessBody(data: _data),
    );
  }
}

class _PaymentSuccessBody extends StatelessWidget {
  const _PaymentSuccessBody({required this.data});

  final PaymentSuccessModel data;

  static const Color _green = Color(0xFF2FA84F);
  static const Color _blue = Color(0xFF1E3A8A);
  static const Color _darkText = Color(0xFF1B2430);
  static const Color _greyText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
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
                  _SuccessIcon(color: _green),
                  const SizedBox(height: 20),
                  Text(
                    data.title,
                    style:  GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.message,
                    textAlign: TextAlign.center,
                    style:  GoogleFonts.inter(
                      fontSize: 15,
                      color: _greyText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.formattedAmount,
                    style:   GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paid on ${data.paidOn}',
                    style:   GoogleFonts.inter(
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
                  _DetailsCard(details: data.details),
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
                        style:  GoogleFonts.inter(
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
                      icon: const Icon(Icons.crop_square,
                          size: 20, color: AppColors.primaryBlue),
                      label: Text(
                        "Download Invoice",
                        style:  GoogleFonts.inter(
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
              color: color.withValues(alpha: 0.14),
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.details});

  final List<PaymentSuccessDetail> details;

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
                  style:  GoogleFonts.inter(fontSize: 14.5, color: labelColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style:  GoogleFonts.inter(
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
