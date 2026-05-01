import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class PriceMasterScreen extends StatelessWidget {
  const PriceMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildSectionHeader('Pricing Master', 'Set standard rent and deposits.'),
                  if (state.rooms.isNotEmpty)
                    BouncingWrapper(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showBulkPriceDialog(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFFFE4C4)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFFF7A00).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_fix_high_rounded, color: const Color(0xFFFF7A00), size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'BULK EDIT',
                              style: TextStyle(color: const Color(0xFFFF7A00), fontSize: 10.sp, fontWeight: FontWeight.w900),
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
                _buildPricingSection(context, state, 'Non-AC', Icons.mode_fan_off_rounded, const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                
                SizedBox(height: 32.h),
                _buildSyncInfo(context, state),
              ],
              SizedBox(height: 40.h),
            ],
          ),
        );
      }
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
            color: const Color(0xFF0F172A),
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
            'No Rooms Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Go back to Step 2 to add rooms.',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, PropertySetupState state, String type, IconData icon, Color bgColor, Color iconColor) {
    final roomsOfType = state.rooms.where((r) {
      final features = r['features'] as Map<String, dynamic>? ?? {};
      final isAC = features['isAC'] ?? false;
      return type == 'AC' ? isAC : !isAC;
    }).toList();
    
    if (roomsOfType.isEmpty) return const SizedBox.shrink();

    final uniqueSharingTypes = roomsOfType.map((r) => (r['sharingType'] ?? 2) as int).toSet().toList();
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
              '$type ROOMS',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 0.5),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...uniqueSharingTypes.map((sharing) => _buildPricingCard(context, state, type, sharing)),
      ],
    );
  }

  Widget _buildPricingCard(BuildContext context, PropertySetupState state, String type, int sharing) {
    final sharingStr = sharing.toString();
    final pricing = state.masterPricing[type] ?? {};
    final config = pricing[sharingStr];
    
    double rent = 0.0;
    double deposit = 0.0;
    double maintenance = 0.0;
    double dailyRent = 0.0;

    if (config is Map) {
      rent = (config['rent'] ?? 0.0).toDouble();
      deposit = (config['deposit'] ?? 0.0).toDouble();
      maintenance = (config['maintenance'] ?? 0.0).toDouble();
      dailyRent = (config['dailyRent'] ?? 0.0).toDouble();
    }

    return _PremiumCard(
      child: Column(
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
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people_alt_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '$sharing Sharing',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'PER BED',
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: const Color(0xFFFF7A00)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _PremiumPriceInput(
            label: 'Monthly Rent',
            initialValue: rent > 0 ? rent.toInt().toString() : '',
            hint: 'e.g. 8500',
            onChanged: (val) {
              final price = double.tryParse(val) ?? 0.0;
              context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'rent', price);
            },
          ),
          SizedBox(height: 16.h),
          _PremiumPriceInput(
            label: 'Security Deposit',
            initialValue: deposit > 0 ? deposit.toInt().toString() : '',
            hint: 'e.g. 5000',
            onChanged: (val) {
              final price = double.tryParse(val) ?? 0.0;
              context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'deposit', price);
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _PremiumPriceInput(
                  label: 'Maintenance',
                  initialValue: maintenance > 0 ? maintenance.toInt().toString() : '',
                  hint: '500',
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'maintenance', price);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PremiumPriceInput(
                  label: 'Daily Rent',
                  initialValue: dailyRent > 0 ? dailyRent.toInt().toString() : '',
                  hint: '500',
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0.0;
                    context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'dailyRent', price);
                  },
                ),
              ),
            ],
          ),
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
              'Prices will automatically apply to all ${state.rooms.length} rooms.',
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
        title: Text('Apply to All Rooms', style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter prices to apply globally to every room sharing type.', 
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              SizedBox(height: 20.h),
              _DialogTextField(controller: rentController, label: 'Monthly Rent', hint: '8000', icon: Icons.currency_rupee_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: depositController, label: 'Security Deposit', hint: '5000', icon: Icons.security_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: maintenanceController, label: 'Maintenance', hint: '500', icon: Icons.handyman_rounded),
              SizedBox(height: 12.h),
              _DialogTextField(controller: dailyRentController, label: 'Daily Rent', hint: '400', icon: Icons.today_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
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
                  const SnackBar(content: Text('Bulk prices applied!'), backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('Apply All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

  const _PremiumPriceInput({
    required this.label,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_PremiumPriceInput> createState() => _PremiumPriceInputState();
}

class _PremiumPriceInputState extends State<_PremiumPriceInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
        ),
        SizedBox(height: 8.h),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _isFocused ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                width: _isFocused ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Text('₹', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: _isFocused ? const Color(0xFFFF7A00) : const Color(0xFF94A3B8))),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.initialValue,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: const Color(0xFFCBD5E1), fontSize: 14.sp, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
          labelText: label,
          labelStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
          hintText: hint,
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
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
        ],
      ),
      child: child,
    );
  }
}
