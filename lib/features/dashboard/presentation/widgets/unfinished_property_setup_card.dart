import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/services/app_bootstrapper.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/property_setup_stepper_page.dart';
import 'package:stayindia_owner/injection_container.dart';

/// Home card for an Add Property flow that was left unfinished (the app was
/// closed or crashed mid-setup). The draft is only saved on the phone until
/// Finish, so without this card Home gives no sign that it exists.
class UnfinishedPropertySetupCard extends StatefulWidget {
  const UnfinishedPropertySetupCard({super.key});

  @override
  State<UnfinishedPropertySetupCard> createState() =>
      _UnfinishedPropertySetupCardState();
}

class _UnfinishedPropertySetupCardState
    extends State<UnfinishedPropertySetupCard>
    with RouteAware {
  static const int _totalSteps = 5;

  PropertySetupState? _draft;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Coming back from Add Property: the draft may be finished or changed.
  @override
  void didPopNext() => _loadDraft();

  /// The setup cubit restores the saved draft when created; read it and
  /// close the instance again.
  void _loadDraft() {
    final cubit = sl<PropertySetupCubit>();
    final state = cubit.state;
    cubit.close();
    setState(() => _draft = state.hasUnfinishedDraft ? state : null);
  }

  Future<void> _resume() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PropertySetupStepperPage()),
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard property setup?'),
        content: const Text(
          'The details, photos and rooms you added for this property will be '
          'deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.sosRed),
            ),
          ),
        ],
      ),
    );
    if (discard != true) return;

    final cubit = sl<PropertySetupCubit>();
    cubit.resetState();
    await cubit.close();
    if (mounted) setState(() => _draft = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostelCubit, HostelState>(
      // A property saved from elsewhere ends the draft.
      listener: (_, state) {
        if (state is HostelLoaded) _loadDraft();
      },
      child: _draft == null ? const SizedBox.shrink() : _buildCard(_draft!),
    );
  }

  Widget _buildCard(PropertySetupState draft) {
    final name = draft.buildingName.trim();
    final step = (draft.currentStep + 1).clamp(1, _totalSteps);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions_rounded,
                color: const Color(0xFFEA580C),
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  name.isEmpty
                      ? 'Finish setting up your property'
                      : 'Finish setting up $name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Step $step of $_totalSteps · your progress is saved. '
            "This property isn't live until you finish.",
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Resume setup'),
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: _confirmDiscard,
                child: Text(
                  'Discard',
                  style: TextStyle(color: AppColors.greyText, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
