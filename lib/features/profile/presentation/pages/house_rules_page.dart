import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/core/house_rules_constants.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel_settings.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/settings_cubit.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class HouseRulesPage extends StatefulWidget {
  const HouseRulesPage({super.key});

  @override
  State<HouseRulesPage> createState() => _HouseRulesPageState();
}

class _HouseRulesPageState extends State<HouseRulesPage> {
  final _entryTimeController = TextEditingController();
  final _visitorPolicyController = TextEditingController();
  int _penaltyDate = 7;
  List<CustomRuleItem> _customRules = [];

  bool _isSaving = false;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) {
        context.read<SettingsCubit>().loadSettings(hostelId);
      }
    });
  }

  @override
  void dispose() {
    _entryTimeController.dispose();
    _visitorPolicyController.dispose();
    for (var rule in _customRules) {
      rule.controller.dispose();
    }
    super.dispose();
  }

  void _addCustomRule() {
    setState(() {
      _customRules.add(CustomRuleItem(controller: TextEditingController()));
    });
  }

  void _removeCustomRule(int index) {
    setState(() {
      _customRules[index].controller.dispose();
      _customRules.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          final r = state.settings.houseRules;
          _entryTimeController.text = r.entryTime;
          _visitorPolicyController.text = r.visitorPolicy;
          _penaltyDate = r.penaltyDate;
          
          setState(() {
             _customRules = r.customRules.map((e) => CustomRuleItem(
              controller: TextEditingController(text: e.text),
            )).toList();
          });
        } else if (state is SettingsSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is SettingsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStandardRulesSection(),
                      SizedBox(height: 24.h),
                      _buildEditableFieldsSection(),
                      SizedBox(height: 24.h),
                      _buildCustomRulesSection(),
                    ],
                  ),
                ),
                _buildSaveButtonOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        StringUtils.translate('house_rules_settings', context: context),
        style: TextStyle(color: AppColors.darkText, fontSize: 18.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildStandardRulesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, color: AppColors.primaryBlue, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  StringUtils.translate('stay_india_standard_rules', context: context),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10.r)),
                child: Text(StringUtils.translate('fixed_tag', context: context), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF64748B))),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: HouseRulesConstants.stayIndiaStandardRules.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final rule = HouseRulesConstants.stayIndiaStandardRules[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      rule[context.locale.languageCode] ?? rule['en'] ?? '',
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFieldsSection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringUtils.translate('hostel_timings_penalty', context: context),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
          ),
          SizedBox(height: 20.h),
          _buildLabel(StringUtils.translate('entry_gate_closing_time', context: context)),
          _buildTextField(_entryTimeController, hint: 'e.g. 10:00 PM', icon: Icons.access_time_rounded),
          SizedBox(height: 20.h),
          _buildLabel(StringUtils.translate('late_payment_penalty_date', context: context)),
          _buildPenaltyDatePicker(),
          SizedBox(height: 20.h),
          _buildLabel(StringUtils.translate('visitor_policy', context: context)),
          _buildTextField(_visitorPolicyController, hint: 'Enter visitor policy...', maxLines: 2, icon: Icons.people_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildPenaltyDatePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _penaltyDate,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: List.generate(28, (index) => index + 1).map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text(
                StringUtils.translate('every_month_ordinal', namedArgs: {'day': day.toString(), 'ordinal': _getOrdinal(day)}, context: context),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _penaltyDate = val!),
        ),
      ),
    );
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildCustomRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                StringUtils.translate('custom_house_rules', context: context),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
              ),
            ),
            SizedBox(width: 12.w),
            BouncingWrapper(
              onTap: _addCustomRule,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.primaryBlue, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(StringUtils.translate('add_rule', context: context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (_customRules.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                StringUtils.translate('no_custom_rules_yet', context: context),
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customRules.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _buildCustomRuleCard(index),
          ),
      ],
    );
  }

  Widget _buildCustomRuleCard(int index) {
    final rule = _customRules[index];
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: rule.controller,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
                  decoration: InputDecoration(
                    hintText: StringUtils.translate('type_custom_rule_hint', context: context),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20.sp),
                onPressed: () => _removeCustomRule(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String hint, int maxLines = 1, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildSaveButtonOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BouncingWrapper(
          onTap: _isSaving ? null : () => _handleSave(context),
          child: Container(
            height: 56.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(StringUtils.translate('save_rules_timings', context: context), style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final hostelId = _hostelId(context);
    if (hostelId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<SettingsCubit>();
      final List<CustomRule> updatedCustomRules = [];

      for (var rule in _customRules) {
        updatedCustomRules.add(CustomRule(
          text: rule.controller.text,
          photo: "", 
        ));
      }

      await cubit.updateHouseRules(
        hostelId,
        entryTime: _entryTimeController.text,
        visitorPolicy: _visitorPolicyController.text,
        otherRules: "", 
        penaltyDate: _penaltyDate,
        customRules: updatedCustomRules,
      );
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }
}

class CustomRuleItem {
  final TextEditingController controller;

  CustomRuleItem({required this.controller});
}
