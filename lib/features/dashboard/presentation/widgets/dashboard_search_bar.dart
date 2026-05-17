import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardSearchBar extends StatefulWidget {
  const DashboardSearchBar({super.key});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: AnimatedScale(
                scale: _isFocused ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: _isFocused ? Colors.white : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: _isFocused ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.5),
                      width: _isFocused ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: _isFocused ? 0.08 : 0.04),
                        blurRadius: _isFocused ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.search_rounded, 
                          color: _isFocused ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.7), 
                          size: 24.sp
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          onChanged: (value) => context.read<DashboardCubit>().updateSearchQuery(value),
                          style: TextStyle(
                            fontSize: 15.sp, 
                            fontWeight: FontWeight.w700, 
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            hintText: StringUtils.translate('search_room_tenant', context: context),
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.5), 
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                          ),
                        ),
                      ),
                      if (state.searchQuery.isNotEmpty)
                        Semantics(
                          label: StringUtils.translate('clear_search', context: context),
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              context.read<DashboardCubit>().updateSearchQuery('');
                              _focusNode.unfocus();
                            },
                            child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20.sp),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            ViewModeToggle(
              isGridView: state.isGridView,
              onChanged: (isGrid) => context.read<DashboardCubit>().toggleViewType(isGrid),
            ),
          ],
        );
      },
    );
  }
}

class ViewModeToggle extends StatelessWidget {
  final bool isGridView;
  final Function(bool) onChanged;

  const ViewModeToggle({
    super.key,
    required this.isGridView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110.w,
      height: 56.h,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: StringUtils.translate('grid_view', context: context),
              selected: isGridView,
              button: true,
              child: BouncingWrapper(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onChanged(true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isGridView ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 20.sp,
                    color: isGridView ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              label: StringUtils.translate('list_view', context: context),
              selected: !isGridView,
              button: true,
              child: BouncingWrapper(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onChanged(false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isGridView ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.list_rounded,
                    size: 24.sp,
                    color: !isGridView ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
