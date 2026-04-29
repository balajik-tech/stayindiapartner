import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/core/widgets/bouncing_button.dart';

class AddRoomMasterSheet extends StatefulWidget {
  final RoomDetail? room;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const AddRoomMasterSheet({super.key, this.room, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    RoomDetail? room,
    required RoomCubit roomCubit,
    required Future<void> Function(Map<String, dynamic> data) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: roomCubit,
        child: AddRoomMasterSheet(room: room, onSave: onSave),
      ),
    );
  }

  @override
  State<AddRoomMasterSheet> createState() => _AddRoomMasterSheetState();
}

class _AddRoomMasterSheetState extends State<AddRoomMasterSheet> {
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _rentController;
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

  static const List<String> _roomTypes = ['AC', 'NON-AC'];

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _nameController = TextEditingController(text: room?.roomTypename ?? '');
    _rentController = TextEditingController(
      text: room != null ? room.rent.toStringAsFixed(0) : '',
    );
    _depositController = TextEditingController(
      text: room != null ? room.deposit.toStringAsFixed(0) : '',
    );
    _maintenanceController = TextEditingController(
      text: room != null ? room.maintenance.toStringAsFixed(0) : '',
    );
    _selectedType = (room?.roomType == 'NON-AC') ? 'NON-AC' : 'AC';
    _selectedSharingType = _sharingTypeMap[room?.sharingType] ?? _sharingTypes.first;
    _selectedFloor = room?.floor ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 0.85.sh,
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isEditing),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Room Type Name *'),
                  _buildTextField(_nameController, hint: 'e.g. AC Double Sharing'),
                  SizedBox(height: 20.h),
                  _buildLabel('Sharing Type *'),
                  _buildDropdown(
                    value: _selectedSharingType,
                    items: _sharingTypes,
                    onChanged: (val) => setState(() => _selectedSharingType = val!),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Room Type *'),
                            _buildDropdown(
                              value: _selectedType,
                              items: _roomTypes,
                              onChanged: (val) => setState(() => _selectedType = val!),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Floor *'),
                            _buildDropdown(
                              value: _selectedFloor.toString(),
                              items: ['0', '1', '2', '3', '4', '5'],
                              displayLabels: {
                                '0': 'Ground Floor',
                                '1': '1st Floor',
                                '2': '2nd Floor',
                                '3': '3rd Floor',
                                '4': '4th Floor',
                                '5': '5th Floor',
                              },
                              onChanged: (val) =>
                                  setState(() => _selectedFloor = int.parse(val!)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildLabel('Financial Details'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _rentController,
                          label: 'Monthly Rent',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          _depositController,
                          label: 'Deposit',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    _maintenanceController,
                    label: 'Maintenance (per month)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 40.h),
                  _buildSaveButton(isEditing),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Edit Room Master' : 'Add Room Master',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 4.h),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    Map<String, String>? displayLabels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                displayLabels?[item] ?? item,
                style: TextStyle(fontSize: 14.sp, color: AppColors.darkText),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: BouncingButton(
        onTap: _isSaving
            ? null
            : () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a room type name')),
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

                  final mappedSharingType = sharingTypeMap[_selectedSharingType] ?? _selectedSharingType;

                  if (!isEditing) {
                    final roomState = context.read<RoomCubit>().state;
                    if (roomState is RoomLoaded) {
                      final exists = roomState.rooms.any((room) =>
                          room.isMaster &&
                          room.floor == _selectedFloor &&
                          room.sharingType == mappedSharingType &&
                          room.roomType == _selectedType);

                      if (exists) {
                        if (mounted) {
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Room master already exist.'),
                                backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                    }
                  }

                  await widget.onSave({
                    'roomTypename': _nameController.text.trim(),
                    'floor': _selectedFloor,
                    'sharingType': mappedSharingType,
                    'roomType': _selectedType,
                    'rent': double.tryParse(_rentController.text) ?? 0,
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
        backgroundColor: _isSaving ? AppColors.greyText : AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12.r),
        child: _isSaving
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditing ? 'Update Room Master' : 'Add Room Master',
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
