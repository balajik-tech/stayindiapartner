import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'screens/building_identity_screen.dart';
import 'screens/bulk_room_setup_screen.dart';
import 'screens/price_master_screen.dart';
import 'screens/setup_success_screen.dart';
import 'package:stayindia_owner/injection_container.dart' as di;

import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class PropertySetupStepperPage extends StatefulWidget {
  final Hostel? existingHostel;
  const PropertySetupStepperPage({super.key, this.existingHostel});

  @override
  State<PropertySetupStepperPage> createState() => _PropertySetupStepperPageState();
}

class _PropertySetupStepperPageState extends State<PropertySetupStepperPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExisting = widget.existingHostel != null;
    final int totalSteps = hasExisting ? 2 : 3;

    return BlocProvider(
      create: (context) {
        final cubit = di.sl<PropertySetupCubit>();
        if (widget.existingHostel != null) {
          cubit.prefillFromHostel(widget.existingHostel!);
        } else {
          cubit.resetState();
        }
        return cubit;
      },
      child: BlocListener<PropertySetupCubit, PropertySetupState>(
        listenWhen: (previous, current) => previous.currentStep != current.currentStep,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutQuart,
          );
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: _buildAppBar(context, totalSteps),
              body: Column(
                children: [
                  _buildProgressIndicator(totalSteps),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (!hasExisting) const BuildingIdentityScreen(),
                        const BulkRoomSetupScreen(),
                        const PriceMasterScreen(),
                        const SetupSuccessScreen(),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, int totalSteps) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<PropertySetupCubit, PropertySetupState>(
        buildWhen: (previous, current) => previous.currentStep != current.currentStep,
        builder: (context, state) {
          return Column(
            children: [
              Text(
                'Setup Property',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (state.currentStep < totalSteps)
                Text(
                  'Step ${state.currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          );
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator(int totalSteps) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        return Container(
          height: 4.h,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: ((MediaQuery.of(context).size.width / totalSteps) * (state.currentStep + 1)).clamp(0, MediaQuery.of(context).size.width),
                color: AppColors.primaryBlue,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (state.currentStep > 0)
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () => context.read<PropertySetupCubit>().previousStep(),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (state.currentStep > 0) SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (isLastStep && !isValid) || state.isSaving
                      ? null
                      : () {
                          if (isLastStep) {
                            context.read<PropertySetupCubit>().saveProperty();
                          } else {
                            context.read<PropertySetupCubit>().nextStep();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  child: state.isSaving
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isLastStep ? 'Finish' : 'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
