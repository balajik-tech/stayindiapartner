import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';

import 'package:stayindia_owner/core/widgets/app_toast.dart';
import 'package:stayindia_owner/features/property_setup/presentation/widgets/max_input_text_formatter.dart';

class RoomPricingPage extends StatefulWidget {
  final Hostel hostel;
  final List<RoomDetail>? rooms;
  final String? floorName;

  const RoomPricingPage({
    super.key,
    required this.hostel,
    this.rooms,
    this.floorName,
  });

  @override
  State<RoomPricingPage> createState() => _RoomPricingPageState();
}

class _RoomPricingPageState extends State<RoomPricingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncMasters();
    });
  }

  void _syncMasters() {
    try {
      context.read<RoomCubit>().getRooms(
        isMaster: true,
        hostelId: widget.hostel.id,
      );

      final roomState = context.read<RoomCubit>().state;
      if (roomState is RoomLoaded) {
        final masters = roomState.rooms.where((r) => r.isMaster).toList();
        if (masters.isNotEmpty) {
          context.read<PropertySetupCubit>().setRoomMasters(masters);
          context.read<PropertySetupCubit>().updatePricingFromMasters();
        }
      }
    } catch (e) {
      debugPrint('Error syncing masters in RoomPricingPage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<PropertySetupCubit>()
                ..prefillFromHostel(widget.hostel, rooms: widget.rooms),
        ),
      ],
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncMasters());

          return MultiBlocListener(
            listeners: [
              BlocListener<RoomCubit, RoomState>(
                listener: (context, state) {
                  if (state is RoomLoaded) {
                    final masters = state.rooms
                        .where((r) => r.isMaster)
                        .toList();
                    if (masters.isNotEmpty) {
                      context.read<PropertySetupCubit>().setRoomMasters(
                        masters,
                      );
                      context
                          .read<PropertySetupCubit>()
                          .updatePricingFromMasters();
                    }
                  }
                },
              ),
              BlocListener<PropertySetupCubit, PropertySetupState>(
                listener: (context, state) {
                  if (state.currentStep == 5) {
                    context.read<DashboardCubit>().fetchDashboardData(
                      widget.hostel.id,
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      ),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('setup_complete_msg'.tr())),
                    );
                  } else if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'failed_save_pricing'.tr(
                            namedArgs: {'error': state.error.toString()},
                          ),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else if (state.validationMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.validationMessage!),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.darkText,
                    size: 18.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                  children: [
                    Text(
                      'setup_property'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF2C5990),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'step_4_of_4'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(6.h),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF98125),
                        ),
                        minHeight: 4.h,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),
                ),
              ),
              body: BlocBuilder<PropertySetupCubit, PropertySetupState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20.r),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'pricing_master'.tr(),
                          'pricing_master_desc'.tr(),
                        ),
                        SizedBox(height: 24.h),

                        if (state.rooms.isEmpty)
                          _buildEmptyState()
                        else ...[
                          _buildPricingSection(
                            context,
                            state,
                            'AC',
                            Icons.ac_unit_rounded,
                            const Color(0xFFE0F2FE),
                            const Color(0xFF0EA5E9),
                          ),
                          SizedBox(height: 24.h),
                          _buildPricingSection(
                            context,
                            state,
                            'NON-AC',
                            Icons.mode_fan_off_rounded,
                            const Color(0xFFF1F5F9),
                            const Color(0xFF64748B),
                          ),

                          SizedBox(height: 32.h),
                          _buildSyncInfo(state),
                        ],
                        SizedBox(height: 100.h),
                      ],
                    ),
                  );
                },
              ),
              bottomSheet: _buildBottomBar(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C5990),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Icon(
            Icons.payments_outlined,
            size: 64.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 16.h),
          Text(
            'no_rooms_pricing'.tr(),
            style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  int? get _resolvedFloorNum {
    if (widget.floorName == null) return null;
    final nameUpper = widget.floorName!.toUpperCase();
    if (nameUpper == 'GROUND_FLOOR' ||
        nameUpper == 'GROUND FLOOR' ||
        nameUpper == 'G' ||
        nameUpper == '0') {
      return 0;
    }
    return int.tryParse(widget.floorName!.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  Widget _buildPricingSection(
    BuildContext context,
    PropertySetupState state,
    String type,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    final resolvedFloor = _resolvedFloorNum;
    final roomsOfType = state.rooms.where((r) {
      final features = r['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] ?? false;
      if (resolvedFloor != null) {
        final roomFloorNum = int.tryParse(r['floor']?.toString() ?? '');
        if (roomFloorNum != resolvedFloor) return false;
      }
      return type == 'AC' ? isAC : !isAC;
    }).toList();

    if (roomsOfType.isEmpty) return const SizedBox.shrink();

    final uniqueSharingTypes = roomsOfType
        .map((r) => (r['sharingType'] ?? 2) as int)
        .toSet()
        .toList();
    uniqueSharingTypes.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'type_rooms_label'.tr(namedArgs: {'type': type}),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...uniqueSharingTypes.map(
          (sharing) => _buildPricingCard(context, state, type, sharing),
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    PropertySetupState state,
    String type,
    int sharing,
  ) {
    final sharingStr = sharing.toString();
    final pricing = state.masterPricing[type] ?? {};
    final config = pricing[sharingStr];

    double rent = 0.0;
    double deposit = 0.0;
    double maintenance = 0.0;
    double dailyRent = 0.0;

    if (config is Map) {
      rent = (config['rent'] ?? config['monthlyRent'] ?? 0.0).toDouble();
      deposit = (config['deposit'] ?? config['securityDeposit'] ?? 0.0)
          .toDouble();
      maintenance = (config['maintenance'] ?? 0.0).toDouble();
      dailyRent = (config['dailyRent'] ?? 0.0).toDouble();
    }

    final isAC = type == 'AC';
    final matches = state.roomMasters.where(
      (m) => m['sharingType'] == sharing && m['isAC'] == isAC,
    );
    final matchingMaster = matches.isNotEmpty ? matches.first : null;

    final masterRent = matchingMaster != null
        ? (double.tryParse(matchingMaster['rent']?.toString() ?? '') ?? 0.0)
        : 0.0;
    final masterDailyRent = matchingMaster != null
        ? (double.tryParse(matchingMaster['dailyRent']?.toString() ?? '') ??
              0.0)
        : 0.0;
    final masterDeposit = matchingMaster != null
        ? (double.tryParse(matchingMaster['deposit']?.toString() ?? '') ?? 0.0)
        : 0.0;
    final masterMaintenance = matchingMaster != null
        ? (double.tryParse(matchingMaster['maintenance']?.toString() ?? '') ??
              0.0)
        : 0.0;

    final hasRentInMaster = masterRent > 0;
    final hasDailyRentInMaster = masterDailyRent > 0;
    final hasDepositInMaster = masterDeposit > 0;
    final hasMaintenanceInMaster = masterMaintenance > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sharing_count_label'.tr(
                  namedArgs: {'count': sharing.toString()},
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5990).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'per_bed'.tr(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C5990),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _PriceInput(
                  label: 'monthly_rent'.tr(),
                  initialValue: rent > 0 ? rent.toInt().toString() : '',
                  enabled: !hasRentInMaster,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(
                      type,
                      sharingStr,
                      'rent',
                      price,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PriceInput(
                  label: 'daily_rent'.tr(),
                  initialValue: dailyRent > 0
                      ? dailyRent.toInt().toString()
                      : '',
                  enabled: !hasDailyRentInMaster,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(
                      type,
                      sharingStr,
                      'dailyRent',
                      price,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _PriceInput(
                  label: 'security_deposit'.tr(),
                  initialValue: deposit > 0 ? deposit.toInt().toString() : '',
                  enabled: !hasDepositInMaster,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(
                      type,
                      sharingStr,
                      'deposit',
                      price,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PriceInput(
                  label: 'maintenance'.tr(),
                  initialValue: maintenance > 0
                      ? maintenance.toInt().toString()
                      : '',
                  enabled: !hasMaintenanceInMaster,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(
                      type,
                      sharingStr,
                      'maintenance',
                      price,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSyncInfo(PropertySetupState state) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFE4C4)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_rounded, color: const Color(0xFFFF7A00), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'sync_prices_info'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF9A3412),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
          ),
        ),
        child: BlocBuilder<PropertySetupCubit, PropertySetupState>(
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(
                        color: Color(0xFF2C5990),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'back'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF2C5990),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () {
                            final cubit = context.read<PropertySetupCubit>();
                            if (cubit.isValidToFinish) {
                              cubit.saveProperty();
                            } else {
                              final message =
                                  cubit.state.validationMessage ??
                                  'incomplete_setup_sub'.tr();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
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
                                        style: const TextStyle(
                                          color: Color(0xFF2C5990),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5990),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 4,
                    ),
                    child: state.isSaving
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'finish_setup'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PriceInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;
  final bool enabled;
  final String prefix = '₹';

  const _PriceInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<_PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<_PriceInput> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && !_isFocused) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: isEnabled
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 6.h),
        Focus(
          onFocusChange: (hasFocus) {
            if (!isEnabled) return;
            setState(() => _isFocused = hasFocus);
            if (!hasFocus) {
              if (_controller.text != widget.initialValue) {
                widget.onChanged(_controller.text);
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _isFocused && isEnabled
                    ? const Color(0xFFF98125)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.prefix.isNotEmpty) ...[
                  Text(
                    widget.prefix,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: _isFocused && isEnabled
                          ? const Color(0xFFF98125)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.number,
                    enabled: isEnabled,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      MaxValueTextInputFormatter(
                        50000,
                        onExceeded: () => AppToast.show(
                          context,
                          'Maximum amount allowed is ₹50,000.',
                        ),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isEnabled
                          ? const Color(0xFF334155)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
