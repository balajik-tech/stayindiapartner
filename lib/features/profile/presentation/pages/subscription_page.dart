import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../razorpay/presentation/bloc/razorpay_cubit.dart';
import '../../domain/entities/subscription_response.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/subscription_cubit.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/razorpay_payment_screen.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/payment_success_screen.dart';
import 'package:stayindia_owner/features/razorpay/presentation/screens/payment_failed_screen.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'my_invoices_page.dart';

import '../../../../injection_container.dart';
import '../models/plan_option.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Tracks the selected plan per hostel id
  final Map<String, String> _selectedPlan = {};
  int? _localSelectedIndex;

  // View state: false = Select Property screen, true = Select Service Duration screen
  bool _isSelectingPlan = false;

  // Search filter query
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
    final String email =
        profileState is ProfileLoaded ? profileState.profile.email : "";
    final String mobile =
        profileState is ProfileLoaded ? profileState.profile.phone : "";

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

  String _formatNumber(num n) {
    final s = n.toStringAsFixed(0);
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

  double calculateTotalAmount(
    double amount,
    double gst,
    bool priceIncludesGst,
  ) =>
      priceIncludesGst ? amount : amount + gst;

  Future<void> _callPhoneNumber(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint('Could not launch phone dialer');
      }
    } catch (e) {
      debugPrint('Call error: $e');
    }
  }

  Future<void> _shareOnWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) return;

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message ?? '')}',
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('WhatsApp is not installed');
      }
    } catch (e) {
      debugPrint('WhatsApp share error: $e');
    }
  }

  /// Determines subscription status text and colors
  _StatusInfo _getSubscriptionStatus(ActiveSubscription? activeSubscription) {
    if (activeSubscription == null) {
      return const _StatusInfo(
        label: 'Service Stopped',
        badgeBg: Color(0xFFFDE8E8),
        badgeFg: Color(0xFF991B1B),
      );
    }

    final now = DateTime.now();
    final endDate = activeSubscription.endDate;

    int daysRemaining = activeSubscription.daysRemaining ?? 0;
    if (activeSubscription.daysRemaining == null && endDate != null) {
      daysRemaining = endDate.difference(now).inDays;
    }

    final isExpired = daysRemaining <= 0 ||
        (endDate != null && (endDate.isBefore(now) || endDate.difference(now).inDays <= 0));

    final isStopped = activeSubscription.status == 'PAUSED' ||
        activeSubscription.status == 'EXPIRED' ||
        activeSubscription.status == 'CANCELLED' ||
        activeSubscription.status == 'INACTIVE' ||
        activeSubscription.status == 'STOPPED' ||
        isExpired;

    if (isStopped) {
      return const _StatusInfo(
        label: 'Service Stopped',
        badgeBg: Color(0xFFFDE8E8),
        badgeFg: Color(0xFF991B1B),
      );
    }

    if (activeSubscription.status == 'ACTIVE') {
      return const _StatusInfo(
        label: 'Running',
        badgeBg: Color(0xFFDCFCE7),
        badgeFg: Color(0xFF166534),
      );
    }

    if (activeSubscription.status == 'PENDING' ||
        activeSubscription.status == 'PENDING_PAYMENT') {
      return const _StatusInfo(
        label: 'Pending',
        badgeBg: Color(0xFFFEF3C7),
        badgeFg: Color(0xFFD97706),
      );
    }

    return const _StatusInfo(
      label: 'Service Stopped',
      badgeBg: Color(0xFFFDE8E8),
      badgeFg: Color(0xFF991B1B),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Subscription Info',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: Text(
          'Select a service duration plan for your property. Discount savings and GST are computed automatically based on total property beds.',
          style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
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
            listener: (context, state) {
              if (state is HostelLoaded && state.hostels.isNotEmpty) {
                if (_localSelectedIndex == null) {
                  final hostel = state.hostels[state.selectedHostelIndex];
                  _loadSubscriptionData(context, hostel.id);
                }
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
                  final selectedIdx =
                      _localSelectedIndex ?? hostelState.selectedHostelIndex;
                  final hostel = hostelState.hostels[selectedIdx];
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
              int globalIndex = hostelState.selectedHostelIndex;
              final selectedId = hostelState.selectedHostelId;
              if (selectedId != null) {
                final foundIndex =
                    hostels.indexWhere((h) => h.id == selectedId);
                if (foundIndex != -1) globalIndex = foundIndex;
              }
              selectedIndex = _localSelectedIndex ?? globalIndex;
            }

            return BlocBuilder<SubscriptionCubit, SubscriptionState>(
              builder: (context, subscriptionState) {
                final responses = subscriptionState.subscriptionResponses;

                if (subscriptionState is SubscriptionError &&
                    responses.isEmpty) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${subscriptionState.message}'),
                          SizedBox(height: 12.h),
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

                final selectedHostel = hostels.isNotEmpty &&
                        selectedIndex < hostels.length
                    ? hostels[selectedIndex]
                    : null;

                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    child: _isSelectingPlan && selectedHostel != null
                        ? _buildServiceDurationView(
                            context,
                            selectedHostel,
                            responses[selectedHostel.id],
                            subscriptionState,
                          )
                        : _buildSelectPropertyView(
                            context,
                            hostels,
                            selectedIndex,
                            responses,
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

  // =========================================================================
  // VIEW 1: SELECT PROPERTY SCREEN
  // =========================================================================
  Widget _buildSelectPropertyView(
    BuildContext context,
    List<Hostel> hostels,
    int selectedIndex,
    Map<String, SubscriptionResponse> responses,
  ) {
    final filteredHostels = hostels.where((h) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return h.name.toLowerCase().contains(query) ||
          h.address.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Top Header
        _buildHeader(
          context,
          title: 'Property Onboarding',
          key: '',
          onBack: () => Navigator.pop(context),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Properties Count & Search Bar
                Row(
                  children: [
                    Text(
                      '${filteredHostels.length} Properties',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search property or location',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color(0xFF53576F),
                              size: 18.sp,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 36.w,
                              minHeight: 40.h,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 10.w,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Property List Cards
                if (filteredHostels.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text(
                        'No properties found.',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredHostels.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final hostel = filteredHostels[index];
                      final originalIndex = hostels.indexOf(hostel);
                      final isSelected = originalIndex == selectedIndex;
                      final response = responses[hostel.id];
                      final statusInfo =
                          _getSubscriptionStatus(response?.activeSubscription);

                      return GestureDetector(
                        onTap: () {
                          _loadSubscriptionData(context, hostel.id);
                          setState(() {
                            _localSelectedIndex = originalIndex;
                            _isSelectingPlan = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEEF5FD) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : const Color(0xFFE5E9EC),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Property Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  width: 48.w,
                                  height: 48.w,
                                  color: Colors.blue.shade50,
                                  child: (hostel.coverImage != null &&
                                          hostel.coverImage!.isNotEmpty &&
                                          ApiConstants.getImageUrl(hostel.coverImage!) != null)
                                      ? Image(
                                          image: CachedNetworkImageProvider(
                                            ApiConstants.getImageUrl(hostel.coverImage!)!,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Image.asset(
                                            'assets/images/property_build.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/property_build.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Property Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hostel.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 12.sp,
                                          color: const Color(0xFF60677B),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Text(
                                            hostel.address,
                                            style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF60677B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3.h),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/bed_icon.png',
                                          width: 12.w,
                                          height: 12.w,
                                          color: const Color(0xFF60677B),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${hostel.totalBeds ?? 0} beds',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF60677B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),

                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildStatusPill(statusInfo),
                                      SizedBox(height: 6.h),
                                      _buildServiceValidityBadge(
                                        response?.activeSubscription,
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: AppColors.primaryBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // VIEW 2: SELECT SERVICE DURATION SCREEN
  // =========================================================================
  Widget _buildServiceDurationView(
    BuildContext context,
    Hostel hostel,
    SubscriptionResponse? response,
    SubscriptionState subscriptionState,
  ) {
    if (response == null) {
      return Column(
        children: [
          _buildHeader(
            context,
            title: 'Select Service Duration',
            key: 'plan',
            onBack: () => setState(() => _isSelectingPlan = false),
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final property = response.property;
    final activeSub = response.activeSubscription;
    final planOptions = response.plans.map(PlanOption.fromEntity).toList();

    if (planOptions.isEmpty) {
      return Column(
        children: [
          _buildHeader(
            context,
            title: 'Select Service Duration',
            key: 'plan',
            onBack: () => setState(() => _isSelectingPlan = false),
          ),
          Expanded(
            child: Center(
              child: Text(
                'No subscription plans available.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    String defaultKey = planOptions.first.key;

    if (activeSub != null &&
        _getSubscriptionStatus(activeSub).label == 'Running') {
      final activePlanCode = activeSub.planSnapshot.planCode.toLowerCase();
      final activePlanId = activeSub.plan;
      final activeSnapshotId = activeSub.planSnapshot.id;

      final matchedPlan = planOptions.firstWhere(
        (p) =>
            p.id == activePlanId ||
            p.id == activeSnapshotId ||
            p.key == activePlanCode ||
            p.key.contains(activePlanCode) ||
            activePlanCode.contains(p.key),
        orElse: () => planOptions.first,
      );
      defaultKey = matchedPlan.key;
    }

    final selectedKey = _planKeyFor(property.id, defaultKey);
    final selectedPlan = planOptions.firstWhere(
      (p) => p.key == selectedKey,
      orElse: () => planOptions.first,
    );

    final beds = property.totalBeds;
    final basePricePerBedMonth = selectedPlan.pricePerBed.round();

    final isProcessing = subscriptionState is SubscriptionProcessing &&
        subscriptionState.propertyId == property.id;

    final statusInfo = _getSubscriptionStatus(activeSub);
    final isRunning = statusInfo.label == 'Running';

    return Column(
      children: [
        // Top Header
        _buildHeader(
          context,
          title: 'Select Service Duration',
          key: 'plan',
          onBack: () => setState(() => _isSelectingPlan = false),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Banner Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FE),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: 54.w,
                          height: 54.w,
                          color: Colors.blue.shade100,
                          child: (hostel.coverImage != null &&
                                  hostel.coverImage!.isNotEmpty &&
                                  ApiConstants.getImageUrl(hostel.coverImage!) != null)
                              ? Image(
                                  image: CachedNetworkImageProvider(
                                    ApiConstants.getImageUrl(hostel.coverImage!)!,
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/property_build.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/property_build.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.name,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    property.address,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/bed_icon.png',
                                  width: 13.w,
                                  height: 13.w,
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '$beds Beds',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0EAF4),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 11.sp,
                                  color: const Color(0xFF485774),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Fixed Price',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF485774),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₹$basePricePerBedMonth ',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                TextSpan(
                                  text: 'per bed / month',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF576275),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Active Subscription Status Banner (Only when running)
                if (activeSub != null && isRunning) ...[
                  SizedBox(height: 12.h),
                  _buildActiveSubscriptionBanner(context, activeSub),
                ],

                SizedBox(height: 16.h),

                // Horizontal Service Duration Selector Tabs
                if (planOptions.length <= 2)
                  Row(
                    children: planOptions.map((plan) {
                      final isSelected = plan.key == selectedKey;
                      final isLast = plan == planOptions.last;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 10.w),
                          child: _buildHorizontalPlanSelectorCard(
                            property.id,
                            plan,
                            isSelected,
                            isDisabled: isRunning,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: planOptions.map((plan) {
                        final isSelected = plan.key == selectedKey;
                        final isLast = plan == planOptions.last;
                        return Container(
                          width: 170.w,
                          margin: EdgeInsets.only(right: isLast ? 0 : 10.w),
                          child: _buildHorizontalPlanSelectorCard(
                            property.id,
                            plan,
                            isSelected,
                            isDisabled: isRunning,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: 16.h),

                // Detailed Selected Plan Breakdown Card
                _buildDetailedPlanCard(
                  hostelId: property.id,
                  plan: selectedPlan,
                  beds: beds,
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),

        // Bottom Sticky Action Bar (Pay Service Button)
        if (!isRunning)
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
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
                            'Pay Service',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  // Horizontal Plan Option Selector Card (Top Row Tabs)
  Widget _buildHorizontalPlanSelectorCard(
    String hostelId,
    PlanOption plan,
    bool isSelected, {
    bool isDisabled = false,
  }) {
    final isShortTerm = plan.months <= 6;
    final subtitle = isShortTerm
        ? 'Ideal for short to medium term'
        : 'Best value for long term';
    final badgeBg = isShortTerm
        ? const Color(0xFF16A34A) // Green
        : const Color(0xFFEA580C); // Orange

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => setState(() => _selectedPlan[hostelId] = plan.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Radio dot
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade400,
                      width: isSelected ? 5.5.w : 1.5.w,
                    ),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${plan.months} Months',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    'Save ${plan.discountPercent}%',
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detailed Selected Plan Breakdown Card
  Widget _buildDetailedPlanCard({
    required String hostelId,
    required PlanOption plan,
    required int beds,
  }) {
    final months = plan.months;
    final pricePerBed = plan.pricePerBed;
    final mrpPerBed = plan.mrpPerBed;
    final discountPercent = plan.discountPercent;
    final gstPercentage = plan.gstPercentage;

    double mrpTotal;
    double subtotal;
    double discountAmount;
    double gstAmount;
    double totalPayable;

    if (plan.breakdown != null) {
      final bd = plan.breakdown!;
      mrpTotal = bd.mrpTotal > 0
          ? bd.mrpTotal
          : (mrpPerBed > 0 ? mrpPerBed * beds * months : pricePerBed * beds * months);
      subtotal = bd.taxableAmount > 0 ? bd.taxableAmount : (pricePerBed * beds * months);
      discountAmount = bd.discountAmount > 0
          ? bd.discountAmount
          : (mrpTotal - subtotal > 0 ? mrpTotal - subtotal : 0);
      gstAmount = bd.gstAmount;
      totalPayable = bd.totalAmount > 0 ? bd.totalAmount : (subtotal + gstAmount);
    } else {
      subtotal = pricePerBed * beds * months;
      if (mrpPerBed > pricePerBed) {
        mrpTotal = mrpPerBed * beds * months;
      } else if (discountPercent > 0) {
        mrpTotal = subtotal / (1 - (discountPercent / 100));
      } else {
        mrpTotal = subtotal;
      }
      discountAmount = mrpTotal - subtotal;
      if (discountAmount < 0) discountAmount = 0;
      gstAmount = plan.priceIncludesGst
          ? 0
          : (subtotal * gstPercentage / 100);
      totalPayable = subtotal + gstAmount;
    }

    final isShortTerm = months <= 6;
    final subtitle = isShortTerm
        ? 'Ideal for short to medium term'
        : 'Best value for long term';
    final badgeBg = isShortTerm
        ? const Color(0xFF16A34A) // Green
        : const Color(0xFFEA580C); // Orange

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section inside card
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$months Months Plan',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            size: 11.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Save Discount $discountPercent%',
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),

                // Detail Rows
                _buildDetailRowItem(
                  icon: Icons.king_bed_outlined,
                  label: 'Number of Beds',
                  value: '$beds',
                ),
                SizedBox(height: 10.h),
                _buildDetailRowItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Price per bed / month',
                  value: '₹${_formatNumber(pricePerBed.round())}',
                ),
                SizedBox(height: 10.h),
                _buildDetailRowItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Service Period',
                  value: '$months ${months == 1 ? 'Month' : 'Months'}',
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const _DottedLineDivider(),
                ),

                _buildDetailRowItem(
                  icon: Icons.calculate_outlined,
                  label: 'Total Amount (Before Discount)',
                  value: '₹${_formatNumber(mrpTotal.round())}',
                ),
                SizedBox(height: 10.h),
                _buildDetailRowItem(
                  icon: Icons.discount_outlined,
                  label: 'Save Discount ($discountPercent%)',
                  value: '- ₹${_formatNumber(discountAmount.round())}',
                  valueColor: const Color(0xFF16A34A),
                  textColor:const Color(0xFF16A34A),
                ),
                SizedBox(height: 10.h),
                _buildDetailRowItem(
                  icon: Icons.description_outlined,
                  label: 'Subtotal (After Discount)',
                  value: '₹${_formatNumber(subtotal.round())}',
                  valueColor: const Color(0xFF0F172A),
                  isBold: true,
                ),
                SizedBox(height: 10.h),
                _buildDetailRowItem(
                  icon: Icons.percent_rounded,
                  label: 'GST ($gstPercentage%)',
                  value: '+ ₹${_formatNumber(gstAmount.round())}',
                ),
              ],
            ),
          ),

          // Highlighted Bottom Blue Box inside card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      color: const Color(0xFF1D4ED8),
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Total Payable Amount',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatNumber(totalPayable.round())}',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                    Text(
                      '(₹${_formatNumber(subtotal.round())} + $gstPercentage% GST)',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? textColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: textColor ?? Colors.grey.shade500),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: textColor ?? const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  // Active Subscription Banner widget (for running/paused)
  Widget _buildActiveSubscriptionBanner(
    BuildContext context,
    ActiveSubscription subscription,
  ) {
    final statusInfo = _getSubscriptionStatus(subscription);
    final phoneNumber = subscription.supportCall;
    final whatsappUrl = subscription.supportWhatsappUrl;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Subscription',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              _buildStatusPill(statusInfo),
            ],
          ),
          SizedBox(height: 8.h),
          if (subscription.endDate != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valid till',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(subscription.endDate!),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callPhoneNumber(phoneNumber),
                    icon: Icon(
                      Icons.call_outlined,
                      size: 16.sp,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      'Call Support',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareOnWhatsApp(
                      phoneNumber: phoneNumber,
                      message: whatsappUrl,
                    ),
                    icon: Image.asset(
                      'assets/images/whatsapp_black.png',
                      width: 16.w,
                      height: 16.w,
                      color: Colors.white,
                    ),
                    label: Text(
                      'WhatsApp',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.freeGreen,
                      side: BorderSide(color: AppColors.freeGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Header Builder
  Widget _buildHeader(
    BuildContext context, {
    required String title,
    required String key,
    required VoidCallback onBack,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          if (key == 'plan') ...[
            GestureDetector(
              onTap: () => _showHelpDialog(context),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 18.sp,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ] else if (key.isEmpty) ...[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyInvoicesPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'MY INVOICES',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Status Pill Widget
  Widget _buildStatusPill(_StatusInfo statusInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusInfo.badgeBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: statusInfo.badgeFg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            statusInfo.label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: statusInfo.badgeFg,
            ),
          ),
        ],
      ),
    );
  }

  // Service Validity Widget
  Widget _buildServiceValidityBadge(ActiveSubscription? activeSubscription) {
    final now = DateTime.now();

    if (activeSubscription == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16.sp,
              color: const Color(0xFF991B1B),
            ),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Service Stopped on',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _formatDate(now),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final endDate = activeSubscription.endDate;
    int daysRemaining = activeSubscription.daysRemaining ?? 0;
    if (activeSubscription.daysRemaining == null && endDate != null) {
      daysRemaining = endDate.difference(now).inDays;
    }
    if (daysRemaining <= 0 &&
        activeSubscription.status == 'ACTIVE' &&
        endDate == null) {
      final months = activeSubscription.planSnapshot.durationMonths;
      daysRemaining = months * 30;
    }

    final isExpired = daysRemaining <= 0 ||
        (endDate != null && (endDate.isBefore(now) || endDate.difference(now).inDays <= 0));
    final isStopped = activeSubscription.status == 'PAUSED' ||
        activeSubscription.status == 'EXPIRED' ||
        activeSubscription.status == 'CANCELLED' ||
        activeSubscription.status == 'INACTIVE' ||
        activeSubscription.status == 'STOPPED' ||
        isExpired;

    final Color badgeBg;
    final Color badgeFg;
    final String titleText;
    final String valueText;

    if (isStopped) {
      titleText = 'Service Stopped on';
      final stoppedDate = endDate ??
          activeSubscription.cancelledAt ??
          activeSubscription.updatedAt ??
          now;
      valueText = _formatDate(stoppedDate);
      badgeBg = const Color(0xFFFDE8E8);
      badgeFg = const Color(0xFF991B1B);
    } else {
      titleText = 'Service Validity';
      valueText = '$daysRemaining Days';

      if (daysRemaining > 90) {
        badgeBg = const Color(0xFFDAEEFF);
        badgeFg = const Color(0xFF2563EB);
      } else if (daysRemaining > 15) {
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF166534);
      } else {
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFD97706);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 16.sp,
            color: badgeFg,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: badgeFg,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                valueText,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: badgeFg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color badgeBg;
  final Color badgeFg;

  const _StatusInfo({
    required this.label,
    required this.badgeBg,
    required this.badgeFg,
  });
}

class _DottedLineDivider extends StatelessWidget {
  const _DottedLineDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            );
          }),
        );
      },
    );
  }
}
