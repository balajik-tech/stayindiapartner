import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'screens/building_identity_screen.dart';
import 'screens/floor_config_screen.dart';
import 'screens/room_config_screen.dart';
import 'screens/price_master_screen.dart';
import 'screens/setup_success_screen.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class PropertySetupStepperPage extends StatefulWidget {
  final Hostel? existingHostel;
  final int initialStep;
  const PropertySetupStepperPage({super.key, this.existingHostel, this.initialStep = 0});

  @override
  State<PropertySetupStepperPage> createState() => _PropertySetupStepperPageState();
}

class _PropertySetupStepperPageState extends State<PropertySetupStepperPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalSteps = 4;

    return BlocProvider(
      create: (context) {
        final cubit = di.sl<PropertySetupCubit>();
        if (widget.existingHostel != null) {
          cubit.prefillFromHostel(widget.existingHostel!);
        } else {
          cubit.resetState();
        }
        if (widget.initialStep > 0) {
          cubit.setStep(widget.initialStep);
        }
        return cubit;
      },
      child: BlocListener<PropertySetupCubit, PropertySetupState>(
        listenWhen: (previous, current) => previous.currentStep != current.currentStep,
        listener: (context, state) {
          if (state.currentStep < totalSteps + 1) {
            _pageController.animateToPage(
              state.currentStep,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutQuart,
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF6F7F9),
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  _buildHeader(context, totalSteps),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        BuildingIdentityScreen(),
                        FloorConfigScreen(),
                        RoomConfigScreen(),
                        PriceMasterScreen(),
                        SetupSuccessScreen(),
                      ],
                    ),
                  ),
                  BlocBuilder<PropertySetupCubit, PropertySetupState>(
                    builder: (context, state) {
                      if (state.currentStep >= totalSteps) return const SizedBox.shrink();
                      return _buildBottomNavigation(totalSteps);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalSteps) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: const Color(0xFF0F172A), size: 28.sp),
                  ),
                  Expanded(
                    child: BlocBuilder<PropertySetupCubit, PropertySetupState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Text(
                              'Setup Property',
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (state.currentStep < totalSteps)
                              Text(
                                'Step ${state.currentStep + 1} of $totalSteps',
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 48.w), // Spacer for center alignment
                ],
              ),
            ),
            _buildProgressIndicator(totalSteps),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int totalSteps) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        double progress = ((state.currentStep + 1) / totalSteps).clamp(0.0, 1.0);
        if (state.currentStep >= totalSteps) progress = 1.0;

        return Container(
          height: 6.h,
          width: double.infinity,
          color: const Color(0xFFF1F5F9),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(3.r),
                    bottomRight: Radius.circular(3.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(int totalSteps) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        final isLastStep = state.currentStep == totalSteps - 1;
        final isValid = context.read<PropertySetupCubit>().isValidToFinish;

        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (state.currentStep > 0)
                Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: TextButton(
                    onPressed: () => context.read<PropertySetupCubit>().previousStep(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _PremiumButton(
                  onPressed: state.isSaving
                      ? null
                      : () {
                          if (isLastStep) {
                            if (isValid) {
                              context.read<PropertySetupCubit>().saveProperty();
                            } else {
                              final message = context.read<PropertySetupCubit>().state.validationMessage ?? 'Please complete all fields and pricing';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
                              );
                            }
                          } else if (state.currentStep == 1) {
                            final totalRooms = context.read<PropertySetupCubit>().totalRooms;
                            if (totalRooms == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please add at least 1 room to proceed'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              context.read<PropertySetupCubit>().nextStep();
                            }
                          } else {
                            context.read<PropertySetupCubit>().nextStep();
                          }
                        },
                  isLoading: state.isSaving,
                  text: isLastStep ? 'Finish Setup' : 'Continue',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const _PremiumButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
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
          height: 56.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFF5C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
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
