import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

import '../../../../injection_container.dart';
import '../../../razorpay/presentation/bloc/razorpay_cubit.dart';
import '../../../razorpay/presentation/screens/payment_failed_screen.dart';
import '../../../razorpay/presentation/screens/payment_success_screen.dart';
import '../../../razorpay/presentation/utils/razorpay_manager.dart';

class _PlanOption {
  final String key;
  final String label;
  final String duration;
  final int months;
  final int discountPercent;
  final bool isBestValue;

  const _PlanOption({
    required this.key,
    required this.label,
    required this.duration,
    required this.months,
    required this.discountPercent,
    this.isBestValue = false,
  });
}



const double _basePricePerBed = 99;

const List<_PlanOption> _planOptions = [
  _PlanOption(
    key: 'monthly',
    label: 'Monthly',
    duration: '1 month',
    months: 1,
    discountPercent: 10,
    isBestValue: false,
  ),
  _PlanOption(
    key: 'quarterly',
    label: 'Quarterly',
    duration: '3 months',
    months: 3,
    discountPercent: 20,
    isBestValue: false,
  ),
  _PlanOption(
    key: 'half_yearly',
    label: 'Half-yearly',
    duration: '6 months',
    months: 6,
    discountPercent: 30,
    isBestValue: false,
  ),
  _PlanOption(
    key: 'annual',
    label: 'Annual',
    duration: '12 months',
    months: 12,
    discountPercent: 40,
    isBestValue: true,
  ),
];

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Tracks the selected plan per hostel id for hostels not yet subscribed.
  final Map<String, String> _selectedPlan = {};

  String _planKeyFor(String hostelId) => _selectedPlan[hostelId] ?? 'annual';

  int _discountedPrice(_PlanOption plan) {
    return (_basePricePerBed * (1 - plan.discountPercent / 100)).round();
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        List<Hostel> hostels = [];
        if (state is HostelLoaded) {
          hostels = state.hostels;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Container(
                      color: SubscriptionColors.backgroundColor,
                      padding: const EdgeInsets.only(top: 8),
                      child: hostels.isEmpty
                          ? Center(
                        child: Text(
                          'No properties added yet.',
                          style: GoogleFonts.inter(color: AppColors.greyText, fontSize: 14.sp),
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          20.w,
                          8.h,
                          20.w,
                          MediaQuery.of(context).padding.bottom + 24.h,
                        ),
                        itemCount: hostels.length,
                        itemBuilder: (context, index) {
                          final hostel = hostels[index];
                          return Container(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Column(
                             children: [
                               _buildPlanSelectionCard(hostel),
                               _buildActiveCard(hostel),

                             ],
                            ),
                            // NOTE: `isSubscribed` is assumed on Hostel — see message below.
                            // child: hostel.isSubscribed
                            //     ? _buildActiveCard(hostel)
                            //     : _buildPlanSelectionCard(hostel),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4,right: 16,top: 12, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      // color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: SubscriptionColors.navy),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscriptions',
                  style: GoogleFonts.inter(
                    color: SubscriptionColors.navy,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // SizedBox(height: 2.h),
                Text(
                  'Per-bed plans for your properties',
                  style: GoogleFonts.inter(
                    color: SubscriptionColors.grayText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: SubscriptionColors.navy, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: SubscriptionColors.orange, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared row builders
  // ---------------------------------------------------------------------
  Widget _buildStatusBadge(
      String label,
      Color fg,
      Color bg, {
        IconData? icon,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: fg,
          width: 0.7, // instead of 0.2
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: fg),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String address) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.greyText),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.inter(fontSize: 13.sp, color: SubscriptionColors.grayText,fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBedsRow(int beds) {
    return Row(
      children: [
        Image.asset(
          'assets/images/bed_icon.png',
          width: 14.w,
          height: 14.w,
        ),
        SizedBox(width: 4.w),
        Text(
          '$beds Beds',
          style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: SubscriptionColors.blue),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Not-subscribed card: plan picker + price breakup + pay button
  // ---------------------------------------------------------------------
  Widget _buildPlanSelectionCard(Hostel hostel) {
    final beds = hostel.totalBeds ?? 0;
    final selectedKey = _planKeyFor(hostel.id);
    final selectedPlan = _planOptions.firstWhere((p) => p.key == selectedKey);
    final discountedPrice = _discountedPrice(selectedPlan);

    final fullTotal = (_basePricePerBed * beds * selectedPlan.months).round();
    final discountedTotal = discountedPrice * beds * selectedPlan.months;
    final savings = fullTotal - discountedTotal;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionHeader(
            hostelName: hostel.name,
            status: 'Not subscribed',
            statusColor: SubscriptionColors.orange,
            backgroundColor: SubscriptionColors.orangeLight,
          ),
          _buildLocationRow(hostel.address ?? ''),
          SizedBox(height: 0.h),
          _buildBedsRow(beds),
          SizedBox(height: 16.h),
          Text(
            'CHOOSE A PLAN · PRICE PER BED / MONTH',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.greyText,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.12,
            children: _planOptions.map((plan) {
              final isSelected = plan.key == selectedKey;
              return _buildPlanTile(hostel.id, plan, isSelected);
            }).toList(),
          ),
          SizedBox(height: 20.h),
          _buildPriceBreakup(selectedPlan, beds, fullTotal, discountedTotal, savings),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                sl<RazorpayManager>().openCheckout(
                  context: context,
                  amount: 1 * 100, // Amount in paise
                  name: "Stay India",
                  orderId: "order_TIwMGg77r0r8YC",
                  email: "balaji.k@stay.in",
                  contact: "9090909090",
                  description: "${selectedPlan.label} Subscription - ${hostel.name}",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay ₹${_formatNumber(discountedTotal)}',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionHeader({
    required String hostelName,
    required String status,
    required Color statusColor,
    required Color backgroundColor,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hostelName,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildStatusBadge(
          status,
          statusColor,
          backgroundColor,
          icon: icon,
        ),
      ],
    );
  }

  Widget _buildPlanTile(
      String hostelId,
      _PlanOption plan,
      bool isSelected,
      ) {
    final price = _discountedPrice(plan);
    final priceColor = isSelected ? SubscriptionColors.orange : SubscriptionColors.blue;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan[hostelId] = plan.key),
      child: Padding(
        padding: EdgeInsets.only(
          top: plan.isBestValue ? 0.h : 0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? SubscriptionColors.orangeLight
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? SubscriptionColors.orange
                      : AppColors.roomCardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.label,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    plan.duration,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyText,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '₹${_basePricePerBed.toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '₹$price',
                        style: GoogleFonts.inter(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: priceColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    'Save ${plan.discountPercent}%',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: SubscriptionColors.green,
                    ),
                  ),
                ],
              ),
            ),

            if (plan.isBestValue)
              Positioned(
                top: -12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: SubscriptionColors.orange2,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
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

  Widget _buildPriceBreakup(_PlanOption plan, int beds, int fullTotal, int discountedTotal, int savings) {
    return Container(
      padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: SubscriptionColors.priceBoxBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.roomCardBorder, // or any color you want
            width: 1,
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE BREAKUP · ${plan.label.toUpperCase()} PLAN',
            style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800, color: SubscriptionColors.grayText, letterSpacing: 0.5),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total (₹${_basePricePerBed.toInt()} × $beds beds × ${plan.months}mo)',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: Color(0xFF5f616c), fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '₹${_formatNumber(fullTotal)}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Color(0xFF5f616c),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/discount.png', // or .webp
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.contain,
                    color: SubscriptionColors.green,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'You save (${plan.discountPercent}% off)',
                    style: GoogleFonts.inter(fontSize: 13.sp, color:Color(0xFF4E8B57), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Text(
                '- ₹${_formatNumber(savings)}',
                style: GoogleFonts.inter(fontSize: 13.sp, color:Color(0xFF4E8B57), fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(height: 1, color: AppColors.roomCardBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total to pay', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              Text(
                '₹${_formatNumber(discountedTotal)}',
                style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: SubscriptionColors.greenLight,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Color(0xFFADC8AF), // Choose your border color
                width: 0.8,
              ),
            ),
            child: Text(
              "🎉 You're saving ₹${_formatNumber(savings)} with the ${plan.label.toLowerCase()} plan",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w800, color:SubscriptionColors.green, ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Active subscription card
  // ---------------------------------------------------------------------
  Widget _buildActiveCard(Hostel hostel) {
    final beds = hostel.totalBeds ?? 0;
    // NOTE: currentPlanKey / subscriptionStart / subscriptionEnd are assumed
    // fields — see message below for how to wire these up.
    final planKey = hostel.currentPlanKey ?? 'half_yearly';
    final plan = _planOptions.firstWhere((p) => p.key == planKey, orElse: () => _planOptions[2]);
    final price = _discountedPrice(plan);

    final start = hostel.subscriptionStart ?? DateTime.now();
    final end = hostel.subscriptionEnd ?? start.add(Duration(days: plan.months * 30));

    final now = DateTime.now();
    final totalDays = end.difference(start).inDays.clamp(1, 100000);
    final elapsedDays = now.difference(start).inDays.clamp(0, totalDays);
    final progress = elapsedDays / totalDays;
    final daysRemaining = end.difference(now).inDays.clamp(0, totalDays);

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionHeader(
            hostelName: hostel.name,
            status: 'Active',
            statusColor: SubscriptionColors.green,
            backgroundColor: SubscriptionColors.greenLight,
            icon: Icons.check_circle,
          ),
          _buildLocationRow(hostel.address ?? ''),
          _buildBedsRow(beds),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFCFCFD),
                  Color(0xFFF8F6F3),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${plan.label} plan',
                      style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold, color: SubscriptionColors.navy),
                    ),
                    Text(
                      '₹$price / bed / mo',
                      style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: SubscriptionColors.orange),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FROM', style: GoogleFonts.inter(fontSize: 10.sp, color: SubscriptionColors.grayText, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2.h),
                        Text(_formatDate(start), style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TO', style: GoogleFonts.inter(fontSize: 10.sp, color: SubscriptionColors.grayText, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2.h),
                        Text(_formatDate(end), style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildGradientProgress(progress),
                SizedBox(height: 8.h),
                Text(
                  '$daysRemaining days remaining · renews at ${plan.label.toLowerCase()} rate',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: SubscriptionColors.grayText,fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGradientProgress(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 6.h,
        color: const Color(0xFFE8ECF2), // Track color
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            // widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF3F5CA8), // Blue
                    Color(0xFF6A5F8F), // Blue-Purple
                    Color(0xFF9D6B66), // Brown
                    Color(0xFFD58B45), // Orange
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
