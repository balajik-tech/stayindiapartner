import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/bed_card.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}


class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_Page>[
    _Page(
      image: 'assets/images/onboardscreen1.png',
      title: 'Manage every bed\nin one place',
      body: "See who's staying, what's empty and which bed "
          'frees up tonight — across all your PGs.',
    ),
    _Page(
      image: 'assets/images/onboardscreen2.png',
      title: 'Verified tenants,\nunlimited leads',
      body: 'Get ID-checked tenant leads for life — no cap, no expiry, '
          'and never a rupee of broker commission.',
    ),
    _Page(
      image: 'assets/images/onboardscreen3.png',
      title: 'Collect rent\nthe easy way',
      body: 'Take UPI, cards or cash. Online rent settles straight to your '
          'bank, and every payment lands in one ledger.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onComplete();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Same logo on every page — never rebuilt per slide.
            Image.asset('assets/images/logo_partner.png', height: 55),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return Transform.translate(
                    offset: const Offset(0, -30),
                    child: _PageView(
                      page: _pages[i],
                    ),
                  );
                },
              ),
            ),

            _Dots(count: _pages.length, index: _index),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _PrimaryButton(label: 'Get started', onTap: _next),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- page body

class _Page {
  const _Page({required this.image, required this.title, required this.body});
  final String image, title, body;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration is exported at a logical width of 340pt.
          // It shrinks on small screens but never scales past its native size.
          Flexible(
            child: Image.asset(
              page.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'BricolageGrotesque',
                    fontWeight: FontWeight.w800,
                    fontSize: 31,
                    height: 1.14,
                    letterSpacing: -1.3,
                    color: Color(0xFF0F1D31),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    height: 1.55,
                    color: Color(0xFF6C7889),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}

// -------------------------------------------------------------------- dots

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count, index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          height: 7,
          width: active ? 22 : 7,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF17539B) : const Color(0xFFCFD6DE),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

// ------------------------------------------------------------------ button

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF79040), Color(0xFFD96D12)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8CD96D12),
              blurRadius: 26,
              offset: Offset(0, 14),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ colours

/// Brand palette, sampled from the logo.
abstract class StayIndiaColors {
  static const blue = Color(0xFF17539B);
  static const blueDeep = Color(0xFF103F78);
  static const blueWash = Color(0xFFE9F0F9);
  static const orange = Color(0xFFF38226);
  static const orangeDeep = Color(0xFFD96D12);
  static const ink = Color(0xFF0F1D31);
  static const muted = Color(0xFF6C7889);
}


class _PropertySetupAnimation extends StatefulWidget {
  const _PropertySetupAnimation();

  @override
  State<_PropertySetupAnimation> createState() => _PropertySetupAnimationState();
}

class _PropertySetupAnimationState extends State<_PropertySetupAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOutSine,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.12), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: AppColors.primaryBlue),
                    SizedBox(width: 8.w),
                    Text(
                      'Grand Heights Hostel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Block A',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'FLOORS & ROOM LAYOUTS',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 40.h * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildMockRoomCard('Room 101', '1st Floor', [
                      {'status': 'FREE'},
                      {'status': 'BOOKED', 'tenantName': 'Rahul K.', 'tenantAvatar': 'https://randomuser.me/api/portraits/men/32.jpg'},
                      {'status': 'FREE'}
                    ]),
                    SizedBox(height: 10.h),
                    _buildMockRoomCard('Room 102', '1st Floor', [
                      {'status': 'BOOKED', 'tenantName': 'Amit S.', 'tenantAvatar': 'https://randomuser.me/api/portraits/men/44.jpg'},
                      {'status': 'MAINTENANCE'}
                    ]),
                    SizedBox(height: 10.h),
                    _buildMockRoomCard('Room 103', '1st Floor', [
                      {'status': 'FREE'},
                      {'status': 'FREE'}
                    ]),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'All layout configurations verified & active.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildMockRoomCard(String roomName, String floor, List<Map<String, dynamic>> beds) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.door_front_door_rounded,
                      size: 16.sp,
                      color: AppColors.primaryBlue.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    roomName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  floor,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'BEDS CONFIGURATION',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: List.generate(beds.length, (index) {
              final bed = beds[index];
              return BedCard(
                bedNumber: (index + 1).toString(),
                status: bed['status'] as String,
                tenantName: bed['tenantName'] as String?,
                tenantAvatar: bed['tenantAvatar'] as String?,
                isSmall: true,
                labelColor: bed['status'] == 'FREE'
                    ? const Color(0xFF2DD4BF)
                    : bed['status'] == 'MAINTENANCE'
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFFF472B6),
                onTap: () {},
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TenantKYCAnimation extends StatefulWidget {
  const _TenantKYCAnimation();

  @override
  State<_TenantKYCAnimation> createState() => _TenantKYCAnimationState();
}

class _TenantKYCAnimationState extends State<_TenantKYCAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _scannerController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _isVerified = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isVerified ? const Color(0xFF34D399) : const Color(0xFF818CF8),
                        width: 3.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.face,
                        size: 100.sp,
                        color: _isVerified ? const Color(0xFF34D399) : AppColors.primaryBlue.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  
                  if (!_isVerified)
                    AnimatedBuilder(
                      animation: _scannerAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 40.h + (100.h * _scannerAnimation.value),
                          left: 40.w,
                          right: 40.w,
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF818CF8),
                              borderRadius: BorderRadius.circular(2.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF818CF8).withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                  if (_isVerified)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
            ),
            child: Column(
              children: [
                _buildKYCStep('1. Digital Aadhaar Verified', true),
                SizedBox(height: 12.h),
                _buildKYCStep('2. Facial Biometrics Check', _isVerified),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: _isVerified ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: (_isVerified ? const Color(0xFF10B981) : const Color(0xFF4F46E5)).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _isVerified ? 'VERIFICATION COMPLETED' : 'SCANNING FACIAL DATA...',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildKYCStep(String title, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
          color: isDone ? const Color(0xFF34D399) : AppColors.primaryBlue.withValues(alpha: 0.3),
          size: 18.sp,
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _FinanceAnalyticsAnimation extends StatefulWidget {
  const _FinanceAnalyticsAnimation();

  @override
  State<_FinanceAnalyticsAnimation> createState() => _FinanceAnalyticsAnimationState();
}

class _FinanceAnalyticsAnimationState extends State<_FinanceAnalyticsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartController;
  late Animation<double> _growAnimation;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _growAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.fastOutSlowIn,
    );
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL REVENUE INFLOW',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.primaryBlue.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹4,12,500',
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: Color(0xFF34D399), size: 16),
                      SizedBox(width: 4.w),
                      Text(
                        '+14.8%',
                        style: TextStyle(
                          color: const Color(0xFF34D399),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          Text(
            'MONTHLY LEDGER TARGETS',
            style: TextStyle(
              fontSize: 10.sp, 
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 12.h),

          Container(
            height: 125.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAnimatedBar('Rent', 65.h, const Color(0xFF3B82F6)),
                _buildAnimatedBar('Utilities', 35.h, const Color(0xFF0EA5E9)),
                _buildAnimatedBar('Staff', 50.h, const Color(0xFF6366F1)),
                _buildAnimatedBar('Savings', 25.h, const Color(0xFF34D399)),
              ],
            ),
          ),
          
          const Spacer(),
          
          _buildTransactionItem('J. Miller (Rent Paid)', '+₹12,500', const Color(0xFF34D399)),
          SizedBox(height: 8.h),
          _buildTransactionItem('Utility Bills (Electricity)', '-₹42,300', const Color(0xFFF87171)),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildAnimatedBar(String label, double maxHeight, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _growAnimation,
          builder: (context, child) {
            return Container(
              width: 32.w,
              height: maxHeight * _growAnimation.value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.6), fontSize: 9.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, Color amountColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.primaryBlue, fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            amount,
            style: TextStyle(color: amountColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _OperationsNoticeAnimation extends StatefulWidget {
  const _OperationsNoticeAnimation();

  @override
  State<_OperationsNoticeAnimation> createState() => _OperationsNoticeAnimationState();
}

class _OperationsNoticeAnimationState extends State<_OperationsNoticeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _statusController;
  int _statusStep = 0;

  @override
  void initState() {
    super.initState();
    _statusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _statusController.repeat();

    _statusController.addListener(() {
      final step = (_statusController.value * 3).floor();
      if (step != _statusStep && step < 3) {
        if (mounted) {
          setState(() {
            _statusStep = step;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String badgeText = 'Assigned';
    Color badgeColor = const Color(0xFFFBBF24);

    if (_statusStep == 1) {
      badgeText = 'In Progress';
      badgeColor = const Color(0xFF38BDF8);
    } else if (_statusStep == 2) {
      badgeText = 'Fixed';
      badgeColor = const Color(0xFF34D399);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ACTIVE MAINTENANCE TICKETS',
            style: TextStyle(
              fontSize: 10.sp, 
              color: AppColors.primaryBlue.withValues(alpha: 0.6), 
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WiFi Connection Issue',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Room 304 • Reported by Emily R.',
                  style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.6), fontSize: 11.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'No internet signal in the living room area.',
                  style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.8), fontSize: 11.sp),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          Text(
            'BROADCAST BOARD',
            style: TextStyle(
              fontSize: 10.sp, 
              color: AppColors.primaryBlue.withValues(alpha: 0.6), 
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          
          _buildNoticeCard('Elevator Maintenance Alert', 'Scheduled maintenance on Nov 15th, 10am-2pm.'),
          
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.sync_rounded, color: Color(0xFF34D399), size: 14),
              SizedBox(width: 8.w),
              Text(
                'Syncing real-time actions to staff devices...',
                style: TextStyle(
                  color: AppColors.primaryBlue.withValues(alpha: 0.5), 
                  fontSize: 10.sp, 
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(String title, String desc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_rounded, color: Color(0xFFEF4444)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.7), fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _OnboardingActionButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_OnboardingActionButton> createState() => _OnboardingActionButtonState();
}

class _OnboardingActionButtonState extends State<_OnboardingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunitiesAnimation extends StatefulWidget {
  const _CommunitiesAnimation();

  @override
  State<_CommunitiesAnimation> createState() => _CommunitiesAnimationState();
}

class _CommunitiesAnimationState extends State<_CommunitiesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildNode(IconData icon, Color color, double size, double top, double left, double phase) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final val = (math.sin((_pulseController.value * 2 * math.pi) + phase) + 1) / 2;
          return Transform.scale(
            scale: 0.9 + 0.2 * val,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 15 * val,
                    spreadRadius: 2 * val,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: size),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SizedBox(
          height: 350.h,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(double.infinity, 350.h),
                painter: _NetworkLinesPainter(),
              ),
              
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            blurRadius: 40 * _pulseAnimation.value,
                            spreadRadius: 10 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.public_rounded,
                        size: 80.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                },
              ),
              
              _buildNode(Icons.groups_rounded, const Color(0xFF10B981), 32.sp, 20.h, 40.w, 2.0),
              _buildNode(Icons.handshake_rounded, const Color(0xFFF59E0B), 28.sp, 20.h, 240.w, 2.0),
              _buildNode(Icons.store_rounded, const Color(0xFF3B82F6), 32.sp, 220.h, 30.w, 2.0),
              _buildNode(Icons.forum_rounded, const Color(0xFFEF4444), 28.sp, 220.h, 250.w, 2.0),
              _buildNode(Icons.lightbulb_rounded, const Color(0xFF8B5CF6), 28.sp, -5.h, 150.w, 2.0),
              
              Positioned(
                bottom: 10.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_tethering_rounded, color: AppColors.primaryBlue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '10,000+ Active Owners Connected',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawLine(center, Offset(40 + 20, 20 + 20), paint);
    canvas.drawLine(center, Offset(240 + 20, 30 + 20), paint);
    canvas.drawLine(center, Offset(30 + 20, 240 + 20), paint);
    canvas.drawLine(center, Offset(250 + 20, 220 + 20), paint);
    canvas.drawLine(center, Offset(150 + 20, -10 + 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
