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
  static const int _maxVisitorPolicyLength = 500;
  final _rulesController = TextEditingController();
  int _penaltyDate = 7;

  bool _isSaving = false;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  String _hostelName(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].name;
    }
    return 'Hostel';
  }

  void _populateFields(SettingsLoaded state) {
    final r = state.settings.houseRules;
    setState(() {
      _entryTimeController.text = r.entryTime;
      _visitorPolicyController.text = r.visitorPolicy;
      _penaltyDate = r.penaltyDate;

      if (r.customRules.isNotEmpty) {
        _rulesController.text = r.customRules.map((e) => e.text).join('\n\n');
      } else {
        final hostelName = _hostelName(context);
        final List<String> defaultLines = [];
        final len = HouseRulesConstants.stayIndiaStandardRules.length;
        for (int i = 0; i < len - 1; i++) {
          final ruleMap = HouseRulesConstants.stayIndiaStandardRules[i];
          final text = ruleMap[context.locale.languageCode] ?? ruleMap['en'] ?? '';
          final cleanedText = text
              .replaceAll("Stay India", hostelName)
              .replaceAll("STAY INDIA", hostelName.toUpperCase())
              .replaceAll("stay india", hostelName.toLowerCase());
          defaultLines.add(cleanedText);
        }
        _rulesController.text = defaultLines.join('\n\n');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) {
        final state = context.read<SettingsCubit>().state;
        if (state is SettingsLoaded) {
          _populateFields(state);
        }
        context.read<SettingsCubit>().loadSettings(hostelId);
      }
    });
  }

  @override
  void dispose() {
    _entryTimeController.dispose();
    _visitorPolicyController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          _populateFields(state);
        } else if (state is SettingsSaveSuccess) {
          context.read<HostelCubit>().getHostels(forceRefresh: true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
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
                      _buildCustomRulesSection(),
                      SizedBox(height: 24.h),
                      _buildEditableFieldsSection(),
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
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkText,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        StringUtils.translate('house_rules_settings', context: context),
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringUtils.translate('hostel_timings_penalty', context: context),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 20.h),
          _buildLabel(
            StringUtils.translate('entry_gate_closing_time', context: context),
          ),
          _buildTextField(
            _entryTimeController,
            hint: 'e.g. 10:00 PM',
            icon: Icons.access_time_rounded,
            readOnly: true,
            onTap: _selectTime,
          ),
          SizedBox(height: 20.h),
          _buildLabel(
            StringUtils.translate(
              'late_payment_penalty_date',
              context: context,
            ),
          ),
          _buildPenaltyDatePicker(),
          SizedBox(height: 20.h),
          _buildLabel(
            StringUtils.translate('visitor_policy', context: context),
          ),
          _buildTextField(
            _visitorPolicyController,
            hint: 'Enter visitor policy...',
            maxLines: 2,
            maxLength: _maxVisitorPolicyLength,
            icon: Icons.people_outline_rounded,
          ),
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
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          items: List.generate(28, (index) => index + 1).map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text(
                StringUtils.translate(
                  'every_month_ordinal',
                  namedArgs: {
                    'day': day.toString(),
                    'ordinal': _getOrdinal(day),
                  },
                  context: context,
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
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
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (_entryTimeController.text.isNotEmpty) {
      try {
        final format = DateFormat('hh:mm a');
        final dateTime = format.parse(_entryTimeController.text);
        initialTime = TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        // Fallback to now
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final format = DateFormat('hh:mm a');
      setState(() {
        _entryTimeController.text = format.format(dt);
      });
    }
  }

  Widget _buildCustomRulesSection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "${_hostelName(context)} Rules & Regulations",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _rulesController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: "Enter the hostel rules...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.r),
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
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
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    int? maxLength,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        // Shows a "n/max" counter and stops input at the limit.
        maxLength: maxLength,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
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
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      StringUtils.translate(
                        'save_rules_timings',
                        context: context,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final hostelId = _hostelId(context);
    if (hostelId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No properties has been created yet. Please create a property first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_rulesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringUtils.translate('please_enter_hostel_rules', context: context) != 'please_enter_hostel_rules' 
              ? StringUtils.translate('please_enter_hostel_rules', context: context) 
              : 'Please enter the hostel rules'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_entryTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringUtils.translate('please_select_entry_time', context: context) != 'please_select_entry_time'
              ? StringUtils.translate('please_select_entry_time', context: context)
              : 'Please select entry gate closing time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_visitorPolicyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringUtils.translate('please_enter_visitor_policy', context: context) != 'please_enter_visitor_policy'
              ? StringUtils.translate('please_enter_visitor_policy', context: context)
              : 'Please enter visitor policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<SettingsCubit>();
      final List<CustomRule> updatedCustomRules = [];

      final lines = _rulesController.text.split('\n');
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          updatedCustomRules.add(
            CustomRule(text: trimmed, photo: ""),
          );
        }
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

