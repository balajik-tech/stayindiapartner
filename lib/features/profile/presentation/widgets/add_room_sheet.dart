import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';

class AddRoomSheet extends StatefulWidget {
  final RoomDetail? room;
  final int? initialFloor;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const AddRoomSheet({super.key, this.room, this.initialFloor, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    RoomDetail? room,
    int? initialFloor,
    required RoomCubit roomCubit,
    required Future<void> Function(Map<String, dynamic> data) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: roomCubit,
        child: AddRoomSheet(room: room, initialFloor: initialFloor, onSave: onSave),
      ),
    );
  }

  @override
  State<AddRoomSheet> createState() => _AddRoomSheetState();
}

class _AddRoomSheetState extends State<AddRoomSheet> {
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _rentController;
  late TextEditingController _dailyRentController;
  late TextEditingController _depositController;
  late TextEditingController _maintenanceController;
  late String _selectedType;
  late String _selectedSharingType;
  late int _selectedFloor;

  static const Map<String, String> _sharingTypeMap = {
    'SINGLE': 'Single Sharing',
    'DOUBLE': '2 Sharing',
    'TRIPLE': '3 Sharing',
    'QUADRUPLE': '4 Sharing',
    'QUINTUPLE': '5 Sharing',
  };

  static const List<String> _sharingTypes = [
    'Single Sharing',
    '2 Sharing',
    '3 Sharing',
    '4 Sharing',
    '5 Sharing',
  ];


  static const Map<int, String> _floorLabels = {
    0: 'Ground Floor',
    1: '1st Floor',
    2: '2nd Floor',
    3: '3rd Floor',
    4: '4th Floor',
    5: '5th Floor',
  };

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _nameController = TextEditingController(text: room?.roomTypename ?? '');
    _rentController = TextEditingController(
      text: room != null ? room.rent.toStringAsFixed(0) : '',
    );
    _dailyRentController = TextEditingController(
      text: room != null ? room.dailyRent.toStringAsFixed(0) : '',
    );
    _depositController = TextEditingController(
      text: room != null ? room.deposit.toStringAsFixed(0) : '',
    );
    _maintenanceController = TextEditingController(
      text: room != null ? room.maintenance.toStringAsFixed(0) : '',
    );
    _selectedType = (room?.roomType == 'NON-AC') ? 'NON-AC' : 'AC';
    _selectedSharingType = _sharingTypeMap[room?.sharingType] ?? _sharingTypes.first;
    _selectedFloor = widget.initialFloor ?? room?.floor ?? 0;
    
    
    if (room == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onMappingChanged();
      });
    }

    _rentController.addListener(_onRentChanged);
  }

  void _onRentChanged() {
    final monthly = double.tryParse(_rentController.text) ?? 0;
    final currentDaily = double.tryParse(_dailyRentController.text) ?? 0;
    
    
    if (monthly > 0 && currentDaily == 0) {
      final daily = (monthly / 30).round();
      _dailyRentController.text = daily.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _dailyRentController.dispose();
    _depositController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  void _onMappingChanged() {
    final state = context.read<RoomCubit>().state;
    if (state is RoomLoaded) {
      final sharingTypeMap = {
        'Single Sharing': 'SINGLE',
        '2 Sharing': 'DOUBLE',
        '3 Sharing': 'TRIPLE',
        '4 Sharing': 'QUADRUPLE',
        '5 Sharing': 'QUINTUPLE',
      };
      
      final backendSharingType = sharingTypeMap[_selectedSharingType] ?? _selectedSharingType;

      try {
        final template = state.rooms.firstWhere(
          (r) =>
              r.isMaster &&
              (r.floors.isEmpty
                  ? r.floor == _selectedFloor
                  : r.floors.contains(_selectedFloor)) &&
              r.roomType == _selectedType &&
              r.sharingType == backendSharingType,
        );

        setState(() {
          _rentController.text = template.rent.toStringAsFixed(0);
          _dailyRentController.text = template.dailyRent.toStringAsFixed(0);
          _depositController.text = template.deposit.toStringAsFixed(0);
          _maintenanceController.text = template.maintenance.toStringAsFixed(0);
        });
      } catch (e) {
        
        setState(() {
          _rentController.clear();
          _dailyRentController.clear();
          _depositController.clear();
          _maintenanceController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return Container(
      height: 0.9.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isEditing),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Details',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                  SizedBox(height: 16.h),
                  _buildLabel('Room Number / Name'),
                  _buildPremiumTextField(_nameController, hint: 'e.g. Room 101'),
                  SizedBox(height: 24.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Sharing Type'),
                            _buildPremiumDropdown(
                              value: _selectedSharingType,
                              items: _sharingTypes,
                              onChanged: (val) {
                                setState(() => _selectedSharingType = val!);
                                _onMappingChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                      if (widget.initialFloor == null) ...[
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Floor'),
                              _buildPremiumDropdown(
                                value: _selectedFloor.toString(),
                                items: _floorLabels.keys.map((k) => k.toString()).toList(),
                                displayLabels: _floorLabels.map((k, v) => MapEntry(k.toString(), v)),
                                onChanged: (val) {
                                  setState(() => _selectedFloor = int.parse(val!));
                                  _onMappingChanged();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 32.h),
                  Text(
                    'Features',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureIcon(
                        icon: Icons.ac_unit_rounded,
                        label: 'AC',
                        isSelected: _selectedType == 'AC',
                        onTap: () {
                          setState(() => _selectedType = 'AC');
                          _onMappingChanged();
                        },
                      ),
                      _buildFeatureIcon(
                        icon: Icons.mode_fan_off_rounded,
                        label: 'Non-AC',
                        isSelected: _selectedType == 'NON-AC',
                        onTap: () {
                          setState(() => _selectedType = 'NON-AC');
                          _onMappingChanged();
                        },
                      ),
                      _buildFeatureIcon(
                        icon: Icons.hot_tub_rounded,
                        label: 'Geyser',
                        isSelected: true, // Mocked for UI parity
                        onTap: () {},
                      ),
                      _buildFeatureIcon(
                        icon: Icons.wc_rounded,
                        label: 'Attached',
                        isSelected: true, // Mocked for UI parity
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),
                  Text(
                    'Financial Details',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                  SizedBox(height: 16.h),
                  _buildPriceInput(
                    label: 'Monthly Rent',
                    controller: _rentController,
                  ),
                  SizedBox(height: 12.h),
                  _buildPriceInput(
                    label: 'Daily Rent',
                    controller: _dailyRentController,
                  ),
                  SizedBox(height: 12.h),
                  _buildPriceInput(
                    label: 'Security Deposit',
                    controller: _depositController,
                  ),
                  SizedBox(height: 12.h),
                  _buildPriceInput(
                    label: 'Maintenance',
                    controller: _maintenanceController,
                  ),
                  
                  SizedBox(height: 40.h),
                  _buildSaveButton(isEditing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Edit Room' : 'Add New Room',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: AppColors.greyText, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.greyText,
        ),
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, {required String hint}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown({
    required String value,
    required List<String> items,
    Map<String, String>? displayLabels,
    required void Function(String?)? onChanged,
  }) {
    final isDisabled = onChanged == null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          disabledHint: Text(
            displayLabels?[value] ?? value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.greyText),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.greyText, size: 20.sp),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                displayLabels?[item] ?? item,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFeatureIcon({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200),
            ),
            child: Icon(icon, color: isSelected ? AppColors.primaryBlue : Colors.grey.shade400, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected ? AppColors.darkText : AppColors.greyText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput({required String label, required TextEditingController controller}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Text('₹', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return BouncingWrapper(
      onTap: _isSaving
          ? () {}
          : () async {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a room name')),
                );
                return;
              }

              setState(() => _isSaving = true);

              try {
                final sharingTypeMap = {
                  'Single Sharing': 'SINGLE',
                  '2 Sharing': 'DOUBLE',
                  '3 Sharing': 'TRIPLE',
                  '4 Sharing': 'QUADRUPLE',
                  '5 Sharing': 'QUINTUPLE',
                };

                await widget.onSave({
                  'roomTypename': _nameController.text.trim(),
                  'floor': _selectedFloor,
                  'sharingType': sharingTypeMap[_selectedSharingType] ?? _selectedSharingType,
                  'roomType': _selectedType,
                  'rent': double.tryParse(_rentController.text) ?? 0,
                  'dailyRent': double.tryParse(_dailyRentController.text) ?? 0,
                  'deposit': double.tryParse(_depositController.text) ?? 0,
                  'maintenance': double.tryParse(_maintenanceController.text) ?? 0,
                });

                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                }
              }
            },
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isSaving
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                isEditing ? 'Update Room Details' : 'Add Room to Floor',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
