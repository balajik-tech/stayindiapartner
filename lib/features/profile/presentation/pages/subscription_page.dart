import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/text_utils.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import '../../../razorpay/presentation/bloc/razorpay_cubit.dart';
import '../../../razorpay/presentation/bloc/razorpay_state.dart';
import '../../domain/entities/subscription_response.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/subscription_cubit.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/razorpay_payment_screen.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/payment_success_screen.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/payment_failed_screen.dart';
import 'package:stayindia_owner/features/razorpay/domain/entities/razorpay_payment_result.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

import '../../../../injection_container.dart';
import '../models/plan_option.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Tracks the selected plan per hostel id for hostels not yet subscribed.
  final Map<String, String> _selectedPlan = {};
  final ScrollController _propertyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HostelCubit>().state;
      if (state is HostelLoaded) {
        _scrollToSelected(state.selectedHostelIndex);
      }
    });
  }

  @override
  void dispose() {
    _propertyScrollController.dispose();
    super.dispose();
  }

  String _planKeyFor(String hostelId, String defaultValue) =>
      _selectedPlan[hostelId] ?? defaultValue;

  void _loadSubscriptionData(BuildContext context, String hostelId) {
    context.read<SubscriptionCubit>().loadSubscriptionPlans(hostelId);
  }

  void _navigateToRazorpay(
    BuildContext context,
    ActiveSubscription subscription,
  ) {
    final int totalAmountToPay = (subscription.totalAmount * 100).round();

    final profileState = context.read<ProfileCubit>().state;
    final String email = profileState is ProfileLoaded ? profileState.profile.email : "";
    final String mobile = profileState is ProfileLoaded ? profileState.profile.phone : "";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => sl<RazorpayCubit>(),
          child: RazorpayPaymentScreen(
            apiKey: ApiConstants.razorpayKey,
            amount: totalAmountToPay,
            name: subscription.planSnapshot.planName,
            orderId: subscription.razorpayOrderId ?? '',
            description: 'Payment for ${subscription.planSnapshot.planName}',
            email: email,
            contact: mobile,
            onSuccess: (result) {
              Navigator.pop(context); // Pop RazorpayPaymentScreen
              context.read<SubscriptionCubit>().verifyPayment(
                    propertyId: subscription.property,
                    orderId: result.orderId ?? '',
                    paymentId: result.paymentId ?? '',
                    signature: result.signature ?? '',
                  );
            },
            onFailure: (error) {
              Navigator.pop(context); // Pop RazorpayPaymentScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SubscriptionCubit>(),
                    child: PaymentFailedScreen(
                      propertyId: subscription.property,
                      planId: subscription.plan,
                      planName: subscription.planSnapshot.planName,
                      amount: subscription.totalAmount,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildActiveNewCard(
    BuildContext context,
    SubscriptionProperty property,
    ActiveSubscription subscription,
  ) {
    final now = DateTime.now();
    final endDate = subscription.endDate ?? now;
    final daysRemaining = endDate.difference(now).inDays;

    final bool isPaused = subscription.status == 'PAUSED';
    final bool isExpiring =
        !isPaused && daysRemaining <= 7 && daysRemaining >= 0;

    String badgeText = 'Active';
    Color badgeBg = const Color(0xFFDCFCE7);
    Color badgeTextCol = const Color(0xFF166534);

    if (isPaused) {
      badgeText = 'Paused';
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextCol = const Color(0xFF6d4714);
    } else if (isExpiring) {
      badgeText = 'Ends in $daysRemaining days';
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextCol = const Color(0xFF6d4714);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPaused
              ? const Color(0xFFF59E0B).withOpacity(0.5)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    property.name,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: badgeTextCol,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${property.address} · ${property.totalBeds} beds',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.grayColor4,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 8.h),
            if (isPaused) ...[
              Text(
                'Bookings and listing tools are paused since ${_formatDate(subscription.updatedAt ?? now)}.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      'RK',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ravi Kumar',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Your account manager',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.call_outlined, size: 18.sp),
                      label: Text(
                        'Call',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: Image.asset(
                          'assets/images/whatsapp_black.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isExpiring) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Valid till',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.grayColor4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(endDate),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Auto-renew',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.grayColor4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subscription.autoRenew ? 'On' : 'Off',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.call_outlined, size: 18.sp),
                      label: Text(
                        'Call',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon:  SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: Image.asset(
                          'assets/images/whatsapp_black.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Valid till',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.grayColor4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(endDate),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = sl<SubscriptionCubit>();
        final hostelState = context.read<HostelCubit>().state;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          for (var hostel in hostelState.hostels) {
            cubit.loadSubscriptionPlans(hostel.id);
          }
        }
        return cubit;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<HostelCubit, HostelState>(
            listenWhen: (previous, current) {
              if (previous is HostelLoaded && current is HostelLoaded) {
                return previous.selectedHostelIndex !=
                    current.selectedHostelIndex;
              }
              return previous is! HostelLoaded && current is HostelLoaded;
            },
            listener: (context, state) {
              if (state is HostelLoaded && state.hostels.isNotEmpty) {
                final hostel = state.hostels[state.selectedHostelIndex];
                _loadSubscriptionData(context, hostel.id);
                _scrollToSelected(state.selectedHostelIndex);
              }
            },
          ),
          BlocListener<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionSubscribed) {
                final status = state.activeSubscription.status;
                if (status == 'PENDING' || status == 'PENDING_PAYMENT') {
                  _navigateToRazorpay(context, state.activeSubscription);
                }
              } else if (state is SubscriptionPaymentVerified) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentSuccessScreen(summary: state.summary),
                  ),
                );
              } else if (state is SubscriptionPaymentVerificationFailed) {
                final hostelState = context.read<HostelCubit>().state;
                String? propertyId;
                String? propertyName;
                String? planId;
                String? planName;
                double? amount;

                if (hostelState is HostelLoaded &&
                    hostelState.hostels.isNotEmpty) {
                  final hostel =
                      hostelState.hostels[hostelState.selectedHostelIndex];
                  propertyId = hostel.id;
                  propertyName = hostel.name;

                  final selectedKey = _selectedPlan[hostel.id];
                  final response = state.subscriptionResponses[hostel.id];
                  if (response != null && selectedKey != null) {
                    try {
                      final plan = response.plans.firstWhere(
                        (p) =>
                            p.planCode.toLowerCase() ==
                            selectedKey.toLowerCase(),
                        orElse: () => response.plans.first,
                      );
                      planId = plan.id;
                      planName = plan.planName;
                      amount = calculateTotalAmount(
                        plan.breakdown?.totalAmount ?? 0,
                        plan.breakdown?.gstAmount ?? 0,
                        plan.priceIncludesGst,
                      );
                    } catch (_) {}
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<SubscriptionCubit>(),
                      child: PaymentFailedScreen(
                        summary: state.summary,
                        propertyId: propertyId,
                        planId: planId,
                        propertyName: propertyName,
                        planName: planName,
                        amount: amount,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<HostelCubit, HostelState>(
          builder: (context, hostelState) {
            List<Hostel> hostels = [];
            int selectedIndex = 0;
            if (hostelState is HostelLoaded) {
              hostels = hostelState.hostels;
              
              // Determine selectedIndex based on selectedHostelId for robustness
              final selectedId = hostelState.selectedHostelId;
              if (selectedId != null) {
                final foundIndex = hostels.indexWhere((h) => h.id == selectedId);
                selectedIndex = foundIndex != -1 ? foundIndex : hostelState.selectedHostelIndex;
              } else {
                selectedIndex = hostelState.selectedHostelIndex;
              }
            }

            return BlocBuilder<SubscriptionCubit, SubscriptionState>(
              builder: (context, subscriptionState) {
                final subscriptionResponses =
                    subscriptionState.subscriptionResponses;

                int needsAttentionCount = 0;
                for (var hostel in hostels) {
                  final response = subscriptionResponses[hostel.id];
                  if (response?.activeSubscription != null) {
                    final sub = response!.activeSubscription!;
                    final now = DateTime.now();
                    final daysRemaining = sub.endDate != null
                        ? sub.endDate!.difference(now).inDays
                        : 0;
                    if (sub.status == 'PAUSED' ||
                        (sub.status == 'ACTIVE' && daysRemaining <= 7)) {
                      needsAttentionCount++;
                    }
                  } else if (response != null &&
                      response.activeSubscription == null) {
                    needsAttentionCount++;
                  }
                }

                if (subscriptionState is SubscriptionError &&
                    subscriptionResponses.isEmpty) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${subscriptionState.message}'),
                          ElevatedButton(
                            onPressed: () {
                              if (hostels.isNotEmpty) {
                                for (var h in hostels) {
                                  _loadSubscriptionData(context, h.id);
                                }
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          total: hostels.length,
                          needsAttention: needsAttentionCount,
                        ),
                        if (hostels.length > 1)
                          _buildPropertySelector(
                            hostels,
                            selectedIndex,
                            context,
                            subscriptionResponses,
                          ),
                        Expanded(
                          child: Container(
                            color: SubscriptionColors.backgroundColor,
                            child: hostels.isEmpty
                                ? Center(
                                    child: Text(
                                      'No properties added yet.',
                                      style: GoogleFonts.inter(
                                        color: AppColors.greyText,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                      20.w,
                                      16.h,
                                      20.w,
                                      MediaQuery.of(context).padding.bottom +
                                          24.h,
                                    ),
                                    itemCount: 2,
                                    itemBuilder: (builderContext, index) {
                                      if (index == 1) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 24.h,
                                          ),
                                          child: Text(
                                            'Billing is handled by your Stay India account team.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }

                                      final hostel = hostels[selectedIndex];
                                      final response =
                                          subscriptionResponses[hostel.id];

                                      if (response == null) {
                                        return Container(
                                          height: 100.h,
                                          margin: EdgeInsets.only(bottom: 16.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      return Container(
                                        padding: EdgeInsets.only(bottom: 0.h),
                                        child: Column(
                                          children: [
                                            if (response.activeSubscription !=
                                                    null &&
                                                (response
                                                            .activeSubscription!
                                                            .status ==
                                                        'ACTIVE' ||
                                                    response
                                                            .activeSubscription!
                                                            .status ==
                                                        'PAUSED'))
                                              _buildActiveNewCard(
                                                builderContext,
                                                response.property,
                                                response.activeSubscription!,
                                              )
                                            else
                                              _buildPlanSelectionCard(
                                                builderContext,
                                                response.property,
                                                response.plans,
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _scrollToSelected(int index) {
    if (!_propertyScrollController.hasClients) return;

    const double estimatedChipWidth = 120; // Adjust if needed
    final screenWidth = MediaQuery.of(context).size.width;

    final targetOffset =
        (index * estimatedChipWidth) -
        (screenWidth / 2) +
        (estimatedChipWidth / 2);

    _propertyScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _propertyScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPropertySelector(
    List<Hostel> hostels,
    int selectedIndex,
    BuildContext context,
    Map<String, SubscriptionResponse> responses,
  ) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(top: 8.h),
      child: ListView.builder(
        controller: _propertyScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: hostels.length,
        itemBuilder: (itemContext, index) {
          final hostelId = hostels[index].id;
          final isSelected = index == selectedIndex;
          final response = responses[hostelId];
          final isActive = response?.activeSubscription?.status == 'ACTIVE';
          final status = response?.activeSubscription?.status;
          final isPending = status == 'PENDING' || status == 'PENDING_PAYMENT';

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hostels[index].name,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : SubscriptionColors.navy,
                    ),
                  ),
                  if (isActive || isPending) ...[
                    SizedBox(width: 6.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isSelected
                                  ? Colors.white
                                  : SubscriptionColors.green)
                            : (isSelected
                                  ? Colors.white
                                  : AppColors.orangeColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  context.read<HostelCubit>().selectHostel(index);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSelected(index);
                  });
                }
              },
              selectedColor: SubscriptionColors.navy,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: isSelected
                      ? SubscriptionColors.navy
                      : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------
  Widget _buildHeader(
    BuildContext context, {
    int total = 0,
    int needsAttention = 0,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 16, top: 12, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Properties',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$total properties · $needsAttention needs attention',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared row builders
  // ---------------------------------------------------------------------
  Widget _buildStatusBadge(String label, Color fg, Color bg, {IconData? icon}) {
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
        Icon(
          Icons.location_on_outlined,
          size: 14.sp,
          color: AppColors.greyText,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: SubscriptionColors.grayText,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBedsRow(int beds) {
    return Row(
      children: [
        Image.asset('assets/images/bed_icon.png', width: 14.w, height: 14.w),
        SizedBox(width: 4.w),
        Text(
          '$beds Beds',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  double calculateTotalAmount(
    double amount,
    double gst,
    bool priceIncludesGst,
  ) => priceIncludesGst ? amount : amount + gst;

  // ---------------------------------------------------------------------
  // Not-subscribed card: plan picker + price breakup + pay button
  // ---------------------------------------------------------------------
  Widget _buildPlanSelectionCard(
    BuildContext context,
    SubscriptionProperty property,
    List<SubscriptionPlan> plans,
  ) {
    final beds = property.totalBeds;
    final planOptions = plans.map(PlanOption.fromEntity).toList();

    if (planOptions.isEmpty) {
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
              hostelName: property.name,
              status: 'Loading plans...',
              statusColor: SubscriptionColors.orange,
              backgroundColor: SubscriptionColors.orangeLight,
            ),
            SizedBox(height: 12.h),
            Text(
              'Please wait while subscription options are loaded.',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final defaultKey = planOptions.first.key;
    final selectedKey = _planKeyFor(property.id, defaultKey);
    final selectedPlan = planOptions.firstWhere(
      (p) => p.key == selectedKey,
      orElse: () => planOptions.first,
    );

    final totalToPay = calculateTotalAmount(
      selectedPlan.breakdown?.totalAmount ?? 0,
      selectedPlan.breakdown?.gstAmount ?? 0,
      selectedPlan.priceIncludesGst,
    );

    final subscriptionState = context.watch<SubscriptionCubit>().state;
    final isProcessing =
        subscriptionState is SubscriptionProcessing &&
        subscriptionState.propertyId == property.id;

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
            hostelName: property.name,
            status: 'Not subscribed',
            statusColor: AppColors.orangeColor,
            backgroundColor: SubscriptionColors.orangeLight,
          ),
          _buildLocationRow(property.address),
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
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.48,
            children: planOptions.map((plan) {
              final isSelected = plan.key == selectedKey;
              return _buildPlanTile(property.id, plan, isSelected);
            }).toList(),
          ),
          SizedBox(height: 20.h),
          _buildPriceBreakup(selectedPlan, beds),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      _selectedPlan[property.id] = selectedPlan.key;
                      context.read<SubscriptionCubit>().subscribe(
                        property.id,
                        selectedPlan.id,
                        'UPI',
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: isProcessing
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pay ₹${_formatNumber(totalToPay.round())}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18.sp,
                        ),
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
        _buildStatusBadge(status, statusColor, backgroundColor, icon: icon),
      ],
    );
  }

  Widget _buildPlanTile(String hostelId, PlanOption plan, bool isSelected) {
    final price = plan.pricePerBed.round();
    final priceColor = isSelected
        ? AppColors.orangeColor
        : SubscriptionColors.blue;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan[hostelId] = plan.key),
      child: Padding(
        padding: EdgeInsets.only(top: plan.isBestValue ? 10.h : 10.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? SubscriptionColors.orangeLight
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.orangeColor
                      : AppColors.roomCardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Plan Name
                  Text(
                    plan.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  /// Duration
                  Text(
                    TextUtils.capitalize(plan.duration),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyText,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// Price
                  Wrap(
                    spacing: 4.w,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '₹${plan.mrpPerBed.round()}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '₹$price',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: priceColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  /// Discount
                  Text(
                    'Save ${plan.discountPercent}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: SubscriptionColors.green,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            if (plan.isBestValue)
              Positioned(
                top: -10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orangeColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
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

  // Widget _buildPlanTile(
  //     String hostelId,
  //     PlanOption plan,
  //     bool isSelected,
  //     ) {
  //   final price = plan.pricePerBed.round();
  //   final priceColor = isSelected ? AppColors.orangeColor : SubscriptionColors.blue;
  //
  //   return GestureDetector(
  //     onTap: () => setState(() => _selectedPlan[hostelId] = plan.key),
  //     child: Padding(
  //       padding: EdgeInsets.only(
  //         top: plan.isBestValue ? 0.h : 0,
  //       ),
  //       child: Stack(
  //         clipBehavior: Clip.none,
  //         children: [
  //           Container(
  //             width: double.infinity,
  //             padding: EdgeInsets.all(12.w),
  //             decoration: BoxDecoration(
  //               color: isSelected
  //                   ? SubscriptionColors.orangeLight
  //                   : Colors.white,
  //               borderRadius: BorderRadius.circular(12.r),
  //               border: Border.all(
  //                 color: isSelected
  //                     ? AppColors.orangeColor
  //                     : AppColors.roomCardBorder,
  //                 width: isSelected ? 1.5 : 1,
  //               ),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   plan.label,
  //                   style: GoogleFonts.inter(
  //                     fontSize: 13.sp,
  //                     fontWeight: FontWeight.w800,
  //                     color: AppColors.darkText,
  //                   ),
  //                 ),
  //
  //                 SizedBox(height: 2.h),
  //
  //                 Text(
  //                   TextUtils.capitalize(plan.duration),
  //                   style: GoogleFonts.inter(
  //                     fontSize: 11.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: AppColors.greyText,
  //                   ),
  //                 ),
  //                 SizedBox(height: 12),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       '₹${plan.mrpPerBed.round()}',
  //                       style: GoogleFonts.inter(
  //                         fontSize: 12.sp,
  //                         color: AppColors.greyText,
  //                         fontWeight: FontWeight.w700,
  //                         decoration: TextDecoration.lineThrough,
  //                       ),
  //                     ),
  //                     SizedBox(width: 6.w),
  //                     Text(
  //                       '₹$price',
  //                       style: GoogleFonts.inter(
  //                         fontSize: 17.sp,
  //                         fontWeight: FontWeight.w800,
  //                         color: priceColor,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //
  //                 SizedBox(height: 2.h),
  //
  //                 Text(
  //                   'Save ${plan.discountPercent}%',
  //                   style: GoogleFonts.inter(
  //                     fontSize: 11.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: SubscriptionColors.green,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           if (plan.isBestValue)
  //             Positioned(
  //               top: -12.h,
  //               right: 12.w,
  //               child: Container(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 12.w,
  //                   vertical: 4.h,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.orangeColor,
  //                   borderRadius: BorderRadius.circular(20.r),
  //                 ),
  //                 child: Text(
  //                   'BEST VALUE',
  //                   style: GoogleFonts.inter(
  //                     fontSize: 9.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPriceBreakup(PlanOption plan, int beds) {
    final breakdown = plan.breakdown;
    if (breakdown == null) return const SizedBox.shrink();

    final mrpTotal = breakdown.mrpTotal;
    final discountAmount = breakdown.discountAmount;
    final gstAmount = breakdown.gstAmount;
    final baseAmount = breakdown.totalAmount;

    final totalToPay = calculateTotalAmount(
      baseAmount,
      gstAmount,
      plan.priceIncludesGst,
    );

    final savings = mrpTotal - totalToPay;

    String savingsAmount = breakdown.savingsText ?? "";
    if (!savingsAmount.contains('₹')) {
      // If it's just a number, format it
      final val = double.tryParse(savingsAmount);
      if (val != null) {
        savingsAmount = '₹${_formatNumber(val.round())}';
      } else {
        savingsAmount = '₹${_formatNumber(savings.round())}';
      }
    } else {
      savingsAmount =
          RegExp(r'₹[\d,]+(?:\.\d+)?').firstMatch(savingsAmount)?.group(0) ??
          "₹${_formatNumber(savings.round())}";
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: SubscriptionColors.priceBoxBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE BREAKUP · ${plan.label.toUpperCase()} PLAN',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: SubscriptionColors.grayText,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          _buildBreakupRow(
            'Total (${breakdown.formula ?? ''})',
            '₹${_formatNumber(mrpTotal.round())}',
            isStrikethrough: true,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/discount.png',
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.contain,
                    color: SubscriptionColors.green,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'You save (${plan.discountPercent}% off)',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF4E8B57),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '- ₹${_formatNumber(discountAmount.round())}',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF4E8B57),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (gstAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildBreakupRow(
              'GST (${plan.gstPercentage}%)',
              '+ ₹${_formatNumber(gstAmount.round())}',
              valueColor: SubscriptionColors.navy,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(height: 1, color: AppColors.roomCardBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total to pay',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${_formatNumber(totalToPay.round())}',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    '(Incl. GST)',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: SubscriptionColors.grayText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
              border: Border.all(color: const Color(0xFFADC8AF), width: 0.8),
            ),
            child: Text(
              "🎉 You're saving $savingsAmount with the ${plan.label.toLowerCase()}",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: SubscriptionColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakupRow(
    String label,
    String value, {
    bool isStrikethrough = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF5f616c),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: valueColor ?? const Color(0xFF5f616c),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCard(
    BuildContext context,
    SubscriptionProperty property,
    ActiveSubscription subscription,
  ) {
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
            hostelName: property.name,
            status: 'Payment Pending',
            statusColor: SubscriptionColors.orange,
            backgroundColor: SubscriptionColors.orangeLight,
            icon: Icons.hourglass_empty,
          ),
          _buildLocationRow(property.address),
          _buildBedsRow(property.totalBeds),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: SubscriptionColors.priceBoxBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount to Pay',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: SubscriptionColors.grayText,
                      ),
                    ),
                    Text(
                      '₹${_formatNumber(subscription.totalAmount.round())}',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToRazorpay(context, subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Complete Payment',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildActiveCard(
    BuildContext context,
    SubscriptionProperty property,
    ActiveSubscription subscription,
  ) {
    final beds = property.totalBeds;
    final planSnapshot = subscription.planSnapshot;
    final plan = PlanOption.fromEntity(planSnapshot);
    final price = plan.pricePerBed.round();

    final start = subscription.startDate ?? DateTime.now();
    final end =
        subscription.endDate ?? start.add(Duration(days: plan.months * 30));

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
            hostelName: property.name,
            status: 'Active',
            statusColor: SubscriptionColors.green,
            backgroundColor: SubscriptionColors.greenLight,
            icon: Icons.check_circle,
          ),
          _buildLocationRow(property.address),
          _buildBedsRow(beds),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: SubscriptionColors.navy,
                      ),
                    ),
                    Text(
                      '₹$price / bed / mo',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: SubscriptionColors.orange,
                      ),
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
                        Text(
                          'FROM',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: SubscriptionColors.grayText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDate(start),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TO',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: SubscriptionColors.grayText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDate(end),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildGradientProgress(progress),
                SizedBox(height: 8.h),
                Text(
                  '$daysRemaining days remaining · renews at ${plan.label.toLowerCase()} rate',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: SubscriptionColors.grayText,
                    fontWeight: FontWeight.w700,
                  ),
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
            // widthFactor: 0.8,
            widthFactor: progress.clamp(0.0, 1.0),
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
