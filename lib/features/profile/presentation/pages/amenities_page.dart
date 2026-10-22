import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/settings_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';

class AmenitiesPage extends StatefulWidget {
  const AmenitiesPage({super.key});

  @override
  State<AmenitiesPage> createState() => _AmenitiesPageState();
}

class _AmenitiesPageState extends State<AmenitiesPage> {
  List<Map<String, dynamic>> _amenities = [];
  final TextEditingController _customAmenityController =
      TextEditingController();

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
    _customAmenityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final hasNoProperty =
        hostelState is HostelLoaded && hostelState.hostels.isEmpty;

    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          setState(() {
            _amenities = state.settings.amenities
                .map<Map<String, dynamic>>(
                  (a) => {'name': a.name, 'isActive': a.enabled},
                )
                .toList();
          });
        } else if (state is SettingsSaveSuccess) {
          context.read<HostelCubit>().getHostels(forceRefresh: true);
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            StringUtils.translate('amenities_title', context: context),
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Divider(
              height: 1,
              color: AppColors.roomCardBorder.withValues(alpha: 0.5),
            ),
          ),
        ),
        body: hasNoProperty
            ? _buildNoPropertyPlaceholder()
            : BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return ListView.builder(
                      padding: EdgeInsets.all(24.w),
                      itemCount: 10,
                      itemBuilder: (context, index) =>
                          const TenantCardSkeleton(),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(24.w),
                          child: _buildAmenitiesList(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: _buildSaveButton(context, state),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNoPropertyPlaceholder() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_rounded,
                size: 64.sp,
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              StringUtils.translate('add_property_first', context: context),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              StringUtils.translate(
                'start_by_adding_property_desc',
                context: context,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('wifi')) return Icons.wifi_rounded;
    if (n.contains('ac') || n.contains('air cond')) {
      return Icons.ac_unit_rounded;
    }
    if (n.contains('laundry') || n.contains('washing')) {
      return Icons.local_laundry_service_rounded;
    }
    if (n.contains('tv') || n.contains('television')) return Icons.tv_rounded;
    if (n.contains('gym') || n.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (n.contains('backup') || n.contains('power')) return Icons.power_rounded;
    if (n.contains('security')) return Icons.security_rounded;
    if (n.contains('cctv') || n.contains('camera')) {
      return Icons.videocam_rounded;
    }
    if (n.contains('food') || n.contains('meal')) {
      return Icons.restaurant_rounded;
    }
    if (n.contains('parking')) return Icons.local_parking_rounded;
    if (n.contains('elevator') || n.contains('lift')) {
      return Icons.elevator_rounded;
    }
    if (n.contains('water')) return Icons.water_drop_rounded;
    if (n.contains('cleaning') || n.contains('housekeeping')) {
      return Icons.cleaning_services_rounded;
    }
    if (n.contains('induction') || n.contains('stove')) {
      return Icons.microwave_rounded;
    }
    if (n.contains('fridge') || n.contains('refrigerator')) {
      return Icons.kitchen_rounded;
    }
    if (n.contains('geyser') || n.contains('hot water')) {
      return Icons.hot_tub_rounded;
    }
    if (n.contains('cupboard') || n.contains('wardrobe')) {
      return Icons.inventory_2_rounded;
    }
    if (n.contains('study') || n.contains('desk')) return Icons.desk_rounded;
    return Icons.check_circle_outline_rounded;
  }

  Color _getAmenityBaseColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('wifi')) return const Color(0xFF0284C7);
    if (n.contains('ac') || n.contains('air cond')) {
      return const Color(0xFF0D9488);
    }
    if (n.contains('laundry') || n.contains('washing')) {
      return const Color(0xFF7C3AED);
    }
    if (n.contains('tv') || n.contains('television')) {
      return const Color(0xFF4F46E5);
    }
    if (n.contains('gym') || n.contains('fitness')) {
      return const Color(0xFFEA580C);
    }
    if (n.contains('backup') || n.contains('power')) {
      return const Color(0xFFEAB308);
    }
    if (n.contains('security')) return const Color(0xFFE11D48);
    if (n.contains('cctv') || n.contains('camera')) {
      return const Color(0xFFDB2777);
    }
    if (n.contains('food') || n.contains('meal')) {
      return const Color(0xFF16A34A);
    }
    if (n.contains('parking')) return const Color(0xFF2563EB);
    if (n.contains('elevator') || n.contains('lift')) {
      return const Color(0xFFB45309);
    }
    if (n.contains('water')) return const Color(0xFF06B6D4);
    if (n.contains('cleaning') || n.contains('housekeeping')) {
      return const Color(0xFF059669);
    }
    if (n.contains('induction') || n.contains('stove')) {
      return const Color(0xFFDC2626);
    }
    if (n.contains('fridge') || n.contains('refrigerator')) {
      return const Color(0xFF0891B2);
    }
    if (n.contains('geyser') || n.contains('hot water')) {
      return const Color(0xFFF43F5E);
    }
    if (n.contains('cupboard') || n.contains('wardrobe')) {
      return const Color(0xFF9A3412);
    }
    if (n.contains('study') || n.contains('desk')) {
      return const Color(0xFF6366F1);
    }
    return _customAmenityColor;
  }

  // Amenities that don't match a predefined type (i.e. ones the owner typed
  // in) get this color, and can be deleted.
  static const Color _customAmenityColor = Color(0xFF8B5CF6);

  bool _isCustomAmenity(String name) =>
      _getAmenityBaseColor(name) == _customAmenityColor;

  Widget _buildAmenitiesList() {
    if (_amenities.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _amenities.length,
          itemBuilder: (context, index) {
            final amenity = _amenities[index];
            final bool isActive = amenity['isActive'];
            final String name = amenity['name'];
            final Color baseColor = _getAmenityBaseColor(name);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: isActive
                    ? baseColor.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isActive
                      ? baseColor.withValues(alpha: 0.25)
                      : AppColors.roomCardBorder.withValues(alpha: 0.8),
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? baseColor.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.01),
                    blurRadius: isActive ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 6.h,
                ),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isActive
                        ? baseColor.withValues(alpha: 0.15)
                        : baseColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getAmenityIcon(name),
                    color: isActive
                        ? baseColor
                        : baseColor.withValues(alpha: 0.5),
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? AppColors.darkText
                        : const Color(0xFF64748B),
                    letterSpacing: -0.2,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCustomAmenity(name))
                      IconButton(
                        tooltip: 'Remove',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.sosRed,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _amenities.removeAt(index));
                        },
                      ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: isActive,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() => amenity['isActive'] = value);
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: baseColor,
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        GestureDetector(
          onTap: _showAddCustomAmenityDialog,
          child: Container(
            margin: EdgeInsets.only(top: 4.h, bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  StringUtils.translate('add_custom_amenity', context: context),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCustomAmenityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          StringUtils.translate('add_custom_amenity', context: context),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _customAmenityController,
          decoration: InputDecoration(
            hintText: StringUtils.translate(
              'custom_amenity_hint',
              context: context,
            ),
            hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customAmenityController.clear();
              Navigator.pop(context);
            },
            child: Text(
              StringUtils.translate('cancel', context: context),
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _customAmenityController.text.trim();
              if (name.isNotEmpty) {
                final exists = _amenities.any(
                  (a) =>
                      a['name'].toString().toLowerCase() == name.toLowerCase(),
                );
                if (!exists) {
                  setState(() {
                    _amenities.add({'name': name, 'isActive': true});
                  });
                }
                _customAmenityController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              StringUtils.translate('btn_add', context: context),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, SettingsState state) {
    final isSaving = state is SettingsSaving;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving
            ? null
            : () {
                final hostelId = _hostelId(context);
                if (hostelId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        StringUtils.translate(
                          'no_hostel_selected',
                          context: context,
                        ),
                      ),
                    ),
                  );
                  return;
                }
                final enabled = _amenities
                    .where((a) => a['isActive'] == true)
                    .map((a) => a['name'] as String)
                    .toList();
                context.read<SettingsCubit>().updateAmenities(
                  hostelId,
                  enabled,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        icon: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.save_outlined, color: Colors.white, size: 20.sp),
        label: Text(
          StringUtils.translate('save_changes', context: context),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
