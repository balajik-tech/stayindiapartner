import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/hostel_configuration_page.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';

import '../../../../tenants/presentation/widgets/AppLanguageStrings.dart';

class SetupSuccessScreen extends StatefulWidget {
  const SetupSuccessScreen({super.key});

  @override
  State<SetupSuccessScreen> createState() => _SetupSuccessScreenState();
}


class _SetupSuccessScreenState extends State<SetupSuccessScreen> {
  String selectedLanguage = "en";

  String tr(String key) {
    return AppLanguageStrings.languages[selectedLanguage]?[key] ??
        AppLanguageStrings.languages["en"]![key] ??
        key;
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext dialogContext) {
          Widget buildPolicySection({required String title, required String body}) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            );
          }

          bool isAccepted = false;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.shield_rounded,
                                color: const Color(0xFF2563EB),
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                tr('privacy_policy_title'),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          tr('privacy_policy_subtitle'),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              isExpanded: true,
                              icon: const Icon(Icons.language),
                              items: const [
                                DropdownMenuItem(
                                  value: "en",
                                  child: Text("English"),
                                ),
                                DropdownMenuItem(
                                  value: "te",
                                  child: Text("తెలుగు"),
                                ),
                                DropdownMenuItem(
                                  value: "hi",
                                  child: Text("हिन्दी"),
                                ),
                                DropdownMenuItem(
                                  value: "ta",
                                  child: Text("தமிழ்"),
                                ),
                                DropdownMenuItem(
                                  value: "kn",
                                  child: Text("ಕನ್ನಡ"),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  selectedLanguage = value;
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: EdgeInsets.all(14.w),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr('privacy_welcome'),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    buildPolicySection(
                                      title: tr('privacy_section_1_title'),
                                      body: tr('privacy_section_1_body'),
                                    ),
                                    buildPolicySection(
                                      title: tr('privacy_section_2_title'),
                                      body: tr('privacy_section_2_body'),
                                    ),
                                    buildPolicySection(
                                      title: tr('privacy_section_3_title'),
                                      body: tr('privacy_section_3_body'),
                                    ),
                                    buildPolicySection(
                                      title: tr('privacy_section_4_title'),
                                      body: tr('privacy_section_4_body'),
                                    ),
                                    buildPolicySection(
                                      title: tr('privacy_section_5_title'),
                                      body: tr('privacy_section_5_body'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAccepted = !isAccepted;
                            });
                          },
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color: isAccepted ? const Color(0xFF2563EB) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: isAccepted ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                    width: 2.w,
                                  ),
                                ),
                                child: isAccepted
                                    ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14.sp,
                                )
                                    : null,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  tr('privacy_accept_terms'),
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: isAccepted
                                ? const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                                : null,
                            color: isAccepted ? null : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: isAccepted
                                ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ]
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: isAccepted
                                ? () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('privacy_policy_accepted', true);

                                if (context.mounted) {
                                  Navigator.pop(dialogContext);
                                  context.read<HostelCubit>().getHostels(forceRefresh: true);
                                  context.read<PropertySetupCubit>().resetState();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HostelConfigurationPage(),
                                    ),
                                  );
                                }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              tr('privacy_accept_continue'),
                              style: TextStyle(
                                color: isAccepted ? Colors.white : const Color(0xFF94A3B8),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  void _handleContinueSetup() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('privacy_policy_accepted') ?? false;

    if (!accepted) {
      if (mounted) {
        _showPrivacyPolicyDialog(context);
      }
    } else {
      if (mounted) {
        context.read<HostelCubit>().getHostels(forceRefresh: true);
        context.read<PropertySetupCubit>().resetState();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HostelConfigurationPage(),
          ),
        );
      }
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    context.read<HostelCubit>().getHostels(forceRefresh: true);
    context.read<PropertySetupCubit>().resetState();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final setupState = context.watch<PropertySetupCubit>().state;
    final buildingName = setupState.buildingName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F4EA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: const Color(0xFF34A853),
                          size: 60.sp,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'property_added'.tr() == 'property_added'
                            ? 'Property added'
                            : 'property_added'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'property_added_desc'.tr(namedArgs: {'name': buildingName}) ==
                                'property_added_desc'
                            ? 'Next, add amenities, house rules and the food menu so tenants can find $buildingName.'
                            : 'property_added_desc'
                                .tr(namedArgs: {'name': buildingName}),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 48.h),
                      _PremiumActionButton(
                        onPressed: _handleContinueSetup,
                        text: 'continue_setup'.tr() == 'continue_setup'
                            ? 'Continue setup'
                            : 'continue_setup'.tr(),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                        ),
                        child: Text(
                          'skip_for_now'.tr() == 'skip_for_now'
                              ? 'Skip for now'
                              : 'skip_for_now'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _PremiumActionButton({required this.onPressed, required this.text});

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
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
      end: 0.96,
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
        child: Container(
          height: 60.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFF5C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
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
