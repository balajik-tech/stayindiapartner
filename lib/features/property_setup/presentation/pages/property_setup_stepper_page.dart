import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'screens/building_identity_screen.dart';
import 'screens/floor_config_screen.dart';
import 'screens/room_category_screen.dart';
import 'screens/room_config_screen.dart';
import 'screens/price_master_screen.dart';
import 'screens/setup_success_screen.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class PropertySetupStepperPage extends StatefulWidget {
  final Hostel? existingHostel;
  final int initialStep;
  const PropertySetupStepperPage({
    super.key,
    this.existingHostel,
    this.initialStep = 0,
  });

  @override
  State<PropertySetupStepperPage> createState() =>
      _PropertySetupStepperPageState();
}

class _PropertySetupStepperPageState extends State<PropertySetupStepperPage> {
  late final PageController _pageController;
  late final PropertySetupCubit _propertySetupCubit;

  @override
  void initState() {
    super.initState();
    _propertySetupCubit = di.sl<PropertySetupCubit>();
    if (widget.existingHostel != null) {
      _propertySetupCubit.prefillFromHostel(widget.existingHostel!);
    } else if (widget.existingHostel == null) {
      if (_propertySetupCubit.state.hostelId != null ||
          (_propertySetupCubit.state.rooms.isEmpty &&
              _propertySetupCubit.state.hostelId == null)) {
        _propertySetupCubit.resetState();
      }
    }
    if (widget.initialStep > 0) {
      _propertySetupCubit.setStep(widget.initialStep);
    }

    final cubitStep = _propertySetupCubit.state.currentStep;
    final startPage = widget.initialStep > 0 ? widget.initialStep : cubitStep;
    _pageController = PageController(initialPage: startPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _propertySetupCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int totalSteps = 5;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _propertySetupCubit),
        BlocProvider(
          create: (context) =>
              di.sl<RoomCubit>()
                ..getRooms(isMaster: true, hostelId: widget.existingHostel?.id),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PropertySetupCubit, PropertySetupState>(
            listenWhen: (previous, current) =>
                previous.currentStep != current.currentStep ||
                previous.error != current.error,
            listener: (context, state) {
              if (state.error != null && state.error!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
              if (state.currentStep < totalSteps + 1) {
                _pageController.animateToPage(
                  state.currentStep,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutQuart,
                );
              }
            },
          ),
          BlocListener<RoomCubit, RoomState>(
            listener: (context, roomState) {
              if (roomState is RoomLoaded) {
                final masters = roomState.rooms
                    .where((r) => r.isMaster)
                    .toList();
                context.read<PropertySetupCubit>().setRoomMasters(masters);
              }
            },
          ),
        ],
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
                      children: [
                        const BuildingIdentityScreen(),
                        const RoomCategoryScreen(),
                        const FloorConfigScreen(),
                        const RoomConfigScreen(),
                        const PriceMasterScreen(),
                        const SetupSuccessScreen(),
                      ],
                    ),
                  ),
                  BlocBuilder<PropertySetupCubit, PropertySetupState>(
                    builder: (context, state) {
                      if (state.currentStep >= totalSteps) {
                        return const SizedBox.shrink();
                      }
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF0F172A),
                      size: 24.sp,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: BlocBuilder<PropertySetupCubit, PropertySetupState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Text(
                              'setup_property'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (state.currentStep < totalSteps)
                              Text(
                                'step_x_of_y'.tr(
                                  namedArgs: {
                                    'current': (state.currentStep + 1)
                                        .toString(),
                                    'total': totalSteps.toString(),
                                  },
                                ),
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 24.w),
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
        double progress = ((state.currentStep + 1) / totalSteps).clamp(
          0.0,
          1.0,
        );
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Row(
                children: [
                  if (state.currentStep > 0)
                    Container(
                      margin: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        height: 50.h,
                        width: 105.w,
                        child: OutlinedButton(
                          onPressed: () => {
                            FocusScope.of(context).unfocus(),
                            context.read<PropertySetupCubit>().previousStep()
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF16539B),
                              width: 1.5,
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'btn_back'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF16539B),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _PremiumButton(
                      onPressed:
                          (state.isSaving ||
                              !context.read<PropertySetupCubit>().isStepValid)
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (isLastStep) {
                                if (isValid) {
                                  context
                                      .read<PropertySetupCubit>()
                                      .saveProperty();
                                } else {
                                  final message =
                                      context
                                          .read<PropertySetupCubit>()
                                          .state
                                          .validationMessage ??
                                      'incomplete_setup_sub'.tr();
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'incomplete_setup'.tr(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          height: 1.6,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(
                                            'btn_got_it'.tr(),
                                            style: TextStyle(
                                              color: const Color(0xFF16539B),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else if (state.currentStep == 0) {
                                final cubit = context.read<PropertySetupCubit>();
                                final s = cubit.state;
                                final exteriorImages = s.categorizedImages['Exterior'] ?? [];

                                String? error;
                                if (s.buildingName.isEmpty) {
                                  error = 'err_property_name_req'.tr();
                                } else if (s.lat == null || s.lng == null) {
                                  error = 'location_hint'.tr();
                                } else if (s.detailedAddress.isEmpty) {
                                  error = 'detailed_address_hint'.tr();
                                } else if (s.area.isEmpty || s.city.isEmpty || s.state.isEmpty || s.pincode.isEmpty) {
                                  error = 'validation_error'.tr();
                                } else if (exteriorImages.isEmpty) {
                                  error = 'err_exterior_image_req'.tr();
                                }

                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else {
                                  cubit.nextStep();
                                }
                              } else if (state.currentStep == 1) {
                                if (state.roomCategories.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('err_room_type_req'.tr()),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else {
                                  context.read<PropertySetupCubit>().nextStep();
                                }
                              } else if (state.currentStep == 2) {
                                final totalRooms = context
                                    .read<PropertySetupCubit>()
                                    .totalRooms;
                                if (totalRooms == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('err_room_req'.tr()),
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
                      text: isLastStep
                          ? 'btn_finish_setup'.tr()
                          : 'btn_continue'.tr(),
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

class _PremiumButtonState extends State<_PremiumButton>
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
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF16539B),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: widget.onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF16539B).withValues(alpha: 0.2),
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
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
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
