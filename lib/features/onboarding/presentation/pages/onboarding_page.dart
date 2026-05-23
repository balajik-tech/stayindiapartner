import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Premium colors/gradients for each onboarding screen
  final List<List<Color>> _gradients = [
    [const Color(0xFFFFFFFF), const Color(0xFFF0F4FA)],
    [const Color(0xFFFFFFFF), const Color(0xFFEBF0F9)],
    [const Color(0xFFFDFDFE), const Color(0xFFF0F4FA)],
    [const Color(0xFFFFFFFF), const Color(0xFFEDF2FB)],
    [const Color(0xFFFFFFFF), const Color(0xFFF0EFFF)],
  ];

  String _tr(String key, String fallback) {
    final translated = key.tr();
    return translated == key ? fallback : translated;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradients[_currentIndex],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Skip Button
              _buildTopBar(),
              
              // Main content: Swipeable PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildPageContent(index);
                  },
                ),
              ),

              // Bottom Section containing indicators and buttons
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo_cropped.png',
                height: 24.h,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              SizedBox(width: 8.w),
              Text(
                'STAY INDIA',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          
          // Skip Button (only if not on the last screen)
          if (_currentIndex < 4)
            GestureDetector(
              onTap: widget.onComplete,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15), width: 1),
                ),
                child: Text(
                  _tr('btn_skip', 'Skip'),
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 50.w), // Dummy widget to keep constraints symmetric
        ],
      ),
    );
  }

  Widget _buildPageContent(int index) {
    String title = '';
    String subtitle = '';
    Widget animationWidget;

    switch (index) {
      case 0:
        title = _tr('onboarding_title_1', 'Onboard Properties Swiftly');
        subtitle = _tr(
          'onboarding_sub_1',
          'Configure hostel layouts, blocks, floors, rooms, and bed pricing structures in minutes.',
        );
        animationWidget = const _PropertySetupAnimation();
        break;
      case 1:
        title = _tr('onboarding_title_2', 'Smart Tenant Management');
        subtitle = _tr(
          'onboarding_sub_2',
          'Digitally register tenants, perform AI-backed face matches, and track active residents.',
        );
        animationWidget = const _TenantKYCAnimation();
        break;
      case 2:
        title = _tr('onboarding_title_3', 'Automated Rent & Finances');
        subtitle = _tr(
          'onboarding_sub_3',
          'Generate instant rent invoices, log cash/online payments, and view dynamic cashflow charts.',
        );
        animationWidget = const _FinanceAnalyticsAnimation();
        break;
      case 3:
        title = _tr('onboarding_title_4', 'Seamless Daily Operations');
        subtitle = _tr(
          'onboarding_sub_4',
          'Broadcast notices instantly to room categories, manage staff duties, and resolve tenant tickets.',
        );
        animationWidget = const _OperationsNoticeAnimation();
        break;
      case 4:
      default:
        title = _tr('onboarding_title_5', 'Global & Owner Communities');
        subtitle = _tr(
          'onboarding_sub_5',
          'Connect with owners globally. Discuss strategies, find buyers, or resolve disputes collectively.',
        );
        animationWidget = const _CommunitiesAnimation();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 12.h),
        
        // Title & Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.primaryBlue.withValues(alpha: 0.7),
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24.h),

        // Full Screen Animated Component (Expanded to take up all remaining space)
        Expanded(
          child: animationWidget,
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: MediaQuery.of(context).padding.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => _buildDot(index)),
          ),
          SizedBox(height: 20.h),
          
          // Action Button
          _OnboardingActionButton(
            text: _currentIndex == 4
                ? _tr('btn_onboard_start', 'Get Started')
                : _tr('btn_continue', 'Continue'),
            onPressed: () {
              if (_currentIndex == 4) {
                widget.onComplete();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutQuart,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 6.h,
      width: isActive ? 24.w : 6.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}

// ---------------------------------------------------------
// Screen 1: Property Layout Configurator Animation
// ---------------------------------------------------------
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
          
          // Animate floor block
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

// ---------------------------------------------------------
// Screen 2: Tenant KYC Face-Scan Animation
// ---------------------------------------------------------
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

    // Simulate validation matching
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
          // Face scanning frame
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular Scanning Frame Container
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
                  
                  // Scanning Line
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
                    
                  // Verified icon badge
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
          
          // Steps Panel
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
          
          // Verification badge
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

// ---------------------------------------------------------
// Screen 3: Revenue & Expense Analytics Animation
// ---------------------------------------------------------
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
          // Revenue Card
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
          
          // Chart section
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

          // Growing Bar Charts representation
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
          
          // Transaction ledger logs
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

// ---------------------------------------------------------
// Screen 4: Operational Notices & Tickets Console
// ---------------------------------------------------------
class _OperationsNoticeAnimation extends StatefulWidget {
  const _OperationsNoticeAnimation();

  @override
  State<_OperationsNoticeAnimation> createState() => _OperationsNoticeAnimationState();
}

class _OperationsNoticeAnimationState extends State<_OperationsNoticeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _statusController;
  int _statusStep = 0; // 0 = Assigned, 1 = In Progress, 2 = Fixed

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
    Color badgeColor = const Color(0xFFFBBF24); // Amber

    if (_statusStep == 1) {
      badgeText = 'In Progress';
      badgeColor = const Color(0xFF38BDF8); // Blue
    } else if (_statusStep == 2) {
      badgeText = 'Fixed';
      badgeColor = const Color(0xFF34D399); // Green
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
          
          // Complaint Ticket Card
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
          
          // Notice Announcement card
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

// ---------------------------------------------------------
// Screen 5: Communities Animation
// ---------------------------------------------------------
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
              // Connection Lines (Static for simplicity, behind the nodes)
              CustomPaint(
                size: Size(double.infinity, 350.h),
                painter: _NetworkLinesPainter(),
              ),
              
              // Central Globe
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
              
              // Animated Networking Nodes
              _buildNode(Icons.groups_rounded, const Color(0xFF10B981), 32.sp, 20.h, 40.w, 0.0),
              _buildNode(Icons.handshake_rounded, const Color(0xFFF59E0B), 28.sp, 30.h, 240.w, 2.0),
              _buildNode(Icons.store_rounded, const Color(0xFF3B82F6), 36.sp, 240.h, 30.w, 4.0),
              _buildNode(Icons.forum_rounded, const Color(0xFFEF4444), 24.sp, 220.h, 250.w, 1.0),
              _buildNode(Icons.lightbulb_rounded, const Color(0xFF8B5CF6), 28.sp, -10.h, 150.w, 3.0),
              
              // Verification badge
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
    
    // Draw lines to approximate node positions
    canvas.drawLine(center, Offset(40 + 20, 20 + 20), paint); // Top Left
    canvas.drawLine(center, Offset(240 + 20, 30 + 20), paint); // Top Right
    canvas.drawLine(center, Offset(30 + 20, 240 + 20), paint); // Bottom Left
    canvas.drawLine(center, Offset(250 + 20, 220 + 20), paint); // Bottom Right
    canvas.drawLine(center, Offset(150 + 20, -10 + 20), paint); // Top Center
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
