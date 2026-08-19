import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';

class _RecoveryBaseCard extends StatelessWidget {
  final Widget icon;
  final Color iconBgColor;
  final String title;
  final String description;
  final List<Widget> actions;

  const _RecoveryBaseCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF52514f),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          ...actions,
        ],
      ),
    );
  }
}

class RestoreAccountWithin30DaysView extends StatelessWidget {
  final String name;
  final String deletionDate;
  final String restoreUntilDate;
  final VoidCallback onRestore;
  final VoidCallback onStartFresh;

  const RestoreAccountWithin30DaysView({
    super.key,
    required this.name,
    required this.deletionDate,
    required this.restoreUntilDate,
    required this.onRestore,
    required this.onStartFresh,
  });

  @override
  Widget build(BuildContext context) {
    return _RecoveryBaseCard(
        icon: Transform.rotate(
          angle: 180 * math.pi / 180,
          child: Icon(
            Icons.refresh,
            color: const Color(0xFF92400E),
            size: 24.sp,
          ),
        ),
      iconBgColor: const Color(0xFFffeee0),
      title: 'Welcome back, $name',
      description:
          'You deleted this account on $deletionDate. Your membership details are still saved and can be restored until $restoreUntilDate.',
      actions: [
        _PrimaryButton(label: 'Restore my account', onPressed: onRestore),
        SizedBox(height: 12.h),
        _SecondaryButton(label: 'Start fresh instead', onPressed: onStartFresh),
      ],
    );
  }
}

class ConfirmStartFreshView extends StatelessWidget {
  final String deletionDate;
  final VoidCallback onGoBack;
  final VoidCallback onConfirm;

  const ConfirmStartFreshView({
    super.key,
    required this.deletionDate,
    required this.onGoBack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _RecoveryBaseCard(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: const Color(0xFFa42c31),
        size: 24.sp,
      ),
      iconBgColor: const Color(0xFFfed5d5),
      title: 'Delete old details permanently?',
      description:
          'Your membership record from $deletionDate will be removed and can\'t be recovered. You\'ll register as a new member.',
      actions: [
        _PrimaryButton(label: 'Go back', onPressed: onGoBack),
        SizedBox(height: 12.h),
        Center(
          child: TextButton(
            onPressed: onConfirm,
            child: Text(
              'Yes, register as new',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9b1921),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountRestoredView extends StatelessWidget {
  final VoidCallback onContinue;

  const AccountRestoredView({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _RecoveryBaseCard(
      icon: Icon(
        Icons.check_rounded,
        color: const Color(0xFF016600),
        size: 24.sp,
      ),
      iconBgColor: const Color(0xFFc2ebc4),
      title: 'Account restored',
      description:
          'Your membership is active again. Certificate and member directory are available now.',
      actions: [
        _PrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class Past30DaysRegisterView extends StatelessWidget {
  final VoidCallback onRegister;

  const Past30DaysRegisterView({
    super.key,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return _RecoveryBaseCard(
      icon: Image.asset(
        'assets/images/addcontact.png',
        width: 24.w,
        height: 24.h,
      ),
      iconBgColor: Color(0xFFe2edf8),
      title: 'Register as a new member',
      description:
          'This number was registered before, but the account was deleted more than 30 days ago and the details are no longer available.',
      actions: [
        _PrimaryButton(label: 'Register', onPressed: onRegister),
      ],
    );
  }
}

class RestoreFailedView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const RestoreFailedView({
    super.key,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return _RecoveryBaseCard(
      icon: Image.asset(
        'assets/images/reload_doublearrow.png',
        width: 24.w,
        height: 24.h,
        color: Color(0xFF7b4201),
      ),
      iconBgColor: const Color(0xFFfedb9c),
      title: 'Couldn\'t restore your account',
      description:
          'Something went wrong on our end. Your details are safe. Try again, or contact the association office.',
      actions: [
        _PrimaryButton(label: 'Try again', onPressed: onRetry),
        SizedBox(height: 12.h),
        _SecondaryButton(label: 'Cancel', onPressed: onCancel),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C599D),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFff8a21)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFa63e00),
          ),
        ),
      ),
    );
  }
}
