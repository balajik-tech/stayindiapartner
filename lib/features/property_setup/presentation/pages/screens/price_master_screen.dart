import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class PriceMasterScreen extends StatefulWidget {
  const PriceMasterScreen({super.key});

  @override
  State<PriceMasterScreen> createState() => _PriceMasterScreenState();
}

class _PriceMasterScreenState extends State<PriceMasterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncMasters();
    });
  }

  void _syncMasters() {
    final roomState = context.read<RoomCubit>().state;
    if (roomState is RoomLoaded) {
      final masters = roomState.rooms.where((r) => r.isMaster).toList();
      if (masters.isNotEmpty) {
        context.read<PropertySetupCubit>().setRoomMasters(masters);
        context.read<PropertySetupCubit>().updatePricingFromMasters();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RoomCubit, RoomState>(
          listener: (context, state) {
            if (state is RoomLoaded) {
              final masters = state.rooms.where((r) => r.isMaster).toList();
              if (masters.isNotEmpty) {
                context.read<PropertySetupCubit>().setRoomMasters(masters);
                context.read<PropertySetupCubit>().updatePricingFromMasters();
              }
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncMasters());
          
          return BlocBuilder<PropertySetupCubit, PropertySetupState>(
            builder: (context, state) {
          return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('pricing_master'.tr(), 'pricing_master_desc'.tr()),
                  if (state.rooms.isNotEmpty)
                    BouncingWrapper(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showBulkPriceDialog(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                        color: const Color(0xFF2C5990).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF2C5990).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF2C5990).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_fix_high_rounded, color: const Color(0xFF2C5990), size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'bulk_edit'.tr().toUpperCase(),
                            style: TextStyle(color: const Color(0xFF2C5990), fontSize: 10.sp, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
    
              if (state.rooms.isEmpty)
                _buildEmptyState()
              else ...[
                _buildPricingSection(context, state, 'AC', Icons.ac_unit_rounded, const Color(0xFFE0F2FE), const Color(0xFF0EA5E9)),
                SizedBox(height: 24.h),
                _buildPricingSection(context, state, 'amenity_non_ac'.tr().toUpperCase(), Icons.mode_fan_off_rounded, const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                
                SizedBox(height: 32.h),
                _buildSyncInfo(context, state),
              ],
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
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
            color: const Color(0xFF2B5797),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_rounded, size: 48.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 24.h),
          Text(
            'no_rooms_found'.tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 8.h),
          Text(
            'no_rooms_found_sub'.tr(),
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, PropertySetupState state, String type, IconData icon, Color bgColor, Color iconColor) {
    final categoriesOfType = state.roomCategories.where((cat) {
      final isAC = cat['isAC'] == true;
      final matchType = type == 'AC' ? isAC : !isAC;
      if (!matchType) return false;

      final sharing = cat['sharingType'] ?? 2;
      return state.rooms.any((room) {
        final roomIsAC = (room['features'] as Map?)?['isAC'] == true;
        final roomSharing = room['sharingType'] ?? 2;
        return roomSharing == sharing && roomIsAC == isAC;
      });
    }).toList();

    if (categoriesOfType.isEmpty) return const SizedBox.shrink();

    final displayLabel = type;

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
              'rooms_type'.tr(namedArgs: {'type': displayLabel}).toUpperCase(),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF334155), letterSpacing: 0.5),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...categoriesOfType.map((cat) {
          final catIndex = state.roomCategories.indexWhere((c) => c['id'] == cat['id']);
          if (catIndex == -1) return const SizedBox.shrink();
          return _buildPricingCard(context, state, cat, catIndex);
        }),
      ],
    );
  }

  Widget _buildPricingCard(BuildContext context, PropertySetupState state, Map<String, dynamic> category, int catIndex) {
    final sharing = category['sharingType'] ?? 2;
    final isAC = category['isAC'] == true;

    final matches = state.roomMasters.where(
      (m) => m['sharingType'] == sharing && m['isAC'] == isAC,
    );
    final matchingMaster = matches.isNotEmpty ? matches.first : null;
    final masterRent = matchingMaster != null ? (double.tryParse(matchingMaster['rent']?.toString() ?? '') ?? 0.0) : 0.0;
    final masterDailyRent = matchingMaster != null ? (double.tryParse(matchingMaster['dailyRent']?.toString() ?? '') ?? 0.0) : 0.0;
    final masterDeposit = matchingMaster != null ? (double.tryParse(matchingMaster['deposit']?.toString() ?? '') ?? 0.0) : 0.0;
    final masterMaintenance = matchingMaster != null ? (double.tryParse(matchingMaster['maintenance']?.toString() ?? '') ?? 0.0) : 0.0;

    final hasRentInMaster = masterRent > 0 || category['monthlyRentLocked'] == true;
    final hasDailyRentInMaster = masterDailyRent > 0 || category['dailyRentLocked'] == true;
    final hasDepositInMaster = masterDeposit > 0 || category['securityDepositLocked'] == true;
    final hasMaintenanceInMaster = masterMaintenance > 0 || category['maintenanceLocked'] == true;

    return _PremiumCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people_alt_rounded, size: 18.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'sharing_count'.tr(namedArgs: {'count': sharing.toString()}),
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: const Color(0xFF334155)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5797).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'per_bed'.tr().toUpperCase(),
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2B5797)),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _PremiumPriceInput(
                  key: ValueKey('${category['id']}_monthly'),
                  label: 'monthly_rent'.tr(),
                  initialValue: category['monthlyRent']?.toString() ?? '',
                  hint: 'monthly_rent_hint'.tr(),
                  enabled: !hasRentInMaster,
                  onChanged: (val) {
                    context.read<PropertySetupCubit>().updateRoomCategory(catIndex, {'monthlyRent': val});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PremiumPriceInput(
                  key: ValueKey('${category['id']}_daily'),
                  label: 'daily_rent'.tr(),
                  initialValue: category['dailyRent']?.toString() ?? '',
                  hint: 'daily_rent_hint'.tr(),
                  enabled: !hasDailyRentInMaster,
                  onChanged: (val) {
                    context.read<PropertySetupCubit>().updateRoomCategory(catIndex, {'dailyRent': val});
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _PremiumPriceInput(
                  key: ValueKey('${category['id']}_deposit'),
                  label: 'deposit'.tr(),
                  initialValue: category['securityDeposit']?.toString() ?? '',
                  hint: 'security_deposit_hint'.tr(),
                  enabled: !hasDepositInMaster,
                  onChanged: (val) {
                    context.read<PropertySetupCubit>().updateRoomCategory(catIndex, {'securityDeposit': val});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PremiumPriceInput(
                  key: ValueKey('${category['id']}_maint'),
                  label: 'maintenance'.tr(),
                  initialValue: category['maintenance']?.toString() ?? '',
                  hint: 'maintenance_hint'.tr(),
                  enabled: !hasMaintenanceInMaster,
                  onChanged: (val) {
                    context.read<PropertySetupCubit>().updateRoomCategory(catIndex, {'maintenance': val});
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSyncInfo(BuildContext context, PropertySetupState state) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFE4C4)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: const Color(0xFFFF7A00), shape: BoxShape.circle),
            child: Icon(Icons.sync_rounded, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'prices_auto_apply'.tr(namedArgs: {'count': state.rooms.length.toString()}),
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9A3412), fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkPriceDialog(BuildContext context) {
    final TextEditingController rentController = TextEditingController();
    final TextEditingController depositController = TextEditingController();
    final TextEditingController maintenanceController = TextEditingController();
    final TextEditingController dailyRentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('apply_to_all_rooms'.tr(), style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF334155))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('apply_to_all_rooms_sub'.tr(), 
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              SizedBox(height: 20.h),
              _DialogTextField(controller: rentController, label: 'monthly_rent'.tr(), hint: '8000', icon: Icons.currency_rupee_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: depositController, label: 'deposit'.tr(), hint: '5000', icon: Icons.security_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: maintenanceController, label: 'maintenance'.tr(), hint: '500', icon: Icons.handyman_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: dailyRentController, label: 'daily_rent'.tr(), hint: '400', icon: Icons.today_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('btn_cancel'.tr(), style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: EdgeInsets.only(left: 8.w),
            child: ElevatedButton(
              onPressed: () {
                final rent = double.tryParse(rentController.text) ?? 0.0;
                final deposit = double.tryParse(depositController.text) ?? 0.0;
                final maintenance = double.tryParse(maintenanceController.text) ?? 0.0;
                final dailyRent = double.tryParse(dailyRentController.text) ?? 0.0;
                
                if (rent > 0) context.read<PropertySetupCubit>().applyPricingToAllRooms('rent', rent);
                if (deposit > 0) context.read<PropertySetupCubit>().applyPricingToAllRooms('deposit', deposit);
                if (maintenance > 0) context.read<PropertySetupCubit>().applyPricingToAllRooms('maintenance', maintenance);
                if (dailyRent > 0) context.read<PropertySetupCubit>().applyPricingToAllRooms('dailyRent', dailyRent);
                
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('bulk_prices_applied'.tr()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5797),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('btn_apply_all'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPriceInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final String hint;
  final Function(String) onChanged;
  final bool enabled;

  const _PremiumPriceInput({
    super.key,
    required this.label,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<_PremiumPriceInput> createState() => _PremiumPriceInputState();
}

class _PremiumPriceInputState extends State<_PremiumPriceInput> {
  bool _isFocused = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _PremiumPriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
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
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
        ),
        SizedBox(height: 4.h),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isEnabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _isFocused && isEnabled ? const Color(0xFFF98125) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text('₹', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: _isFocused && isEnabled ? const Color(0xFFF98125) : const Color(0xFF94A3B8))),
                SizedBox(width: 6.w),
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.number,
                    enabled: isEnabled,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: const Color(0xFFCBD5E1), fontSize: 14.sp, fontWeight: FontWeight.w600),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isEnabled ? const Color(0xFF334155) : const Color(0xFF94A3B8),
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

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _DialogTextField({required this.controller, required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF94A3B8), size: 24.sp),
          labelText: label,
          labelStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
          hintText: hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF334155)),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
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
          BoxShadow(
            color: const Color(0xFF2C5990).withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
