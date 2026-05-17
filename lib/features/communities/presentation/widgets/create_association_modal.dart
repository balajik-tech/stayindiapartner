import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';

class CreateAssociationModal extends StatefulWidget {
  final List<Map<String, dynamic>> allStates;
  final String? initialStateId;
  final String? initialStateName;
  final String? initialDistrictId;
  final String? initialWardId;

  const CreateAssociationModal({
    super.key,
    required this.allStates,
    this.initialStateId,
    this.initialStateName,
    this.initialDistrictId,
    this.initialWardId,
  });

  @override
  State<CreateAssociationModal> createState() =>
      CreateAssociationModalState();
}

class CreateAssociationModalState extends State<CreateAssociationModal> {
  final _formKey = GlobalKey<FormState>();
  String _level = 'DISTRICT';
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedWardId;
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStateId = widget.initialStateId;
    _selectedDistrictId = widget.initialDistrictId;
    _selectedWardId = widget.initialWardId;

    if (_selectedWardId != null) {
      _level = 'WARD';
    } else if (_selectedDistrictId != null) {
      _level = 'DISTRICT';
    } else {
      _level = 'STATE';
    }

    if (_selectedStateId != null) {
      _fetchDistricts(_selectedStateId!);
    }
    if (_selectedDistrictId != null) {
      _fetchWards(_selectedDistrictId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchDistricts(String stateId) async {
    setState(() => _isLoadingDistricts = true);
    try {
      final results = await sl<GetAssociationsUseCase>().call(
        parentId: stateId,
        level: 'DISTRICT',
      );
      setState(() {
        _districts = results;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _fetchWards(String districtId) async {
    setState(() => _isLoadingWards = true);
    try {
      final results = await sl<GetAssociationsUseCase>().call(
        parentId: districtId,
        level: 'WARD',
      );
      setState(() {
        _wards = results;
        _isLoadingWards = false;
      });
    } catch (e) {
      setState(() => _isLoadingWards = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deepBlue = AppColors.primaryBlue;
    final orangeAccent = AppColors.accentOrange;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        12.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 40.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'establish_association'.tr(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: deepBlue,
              ),
            ),
            SizedBox(height: 24.h),

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: _imageFile != null
                          ? ResizeImage(FileImage(_imageFile!), width: 160, height: 160)
                          : null,
                      child: _imageFile == null
                          ? Icon(
                              Icons.add_a_photo_rounded,
                              size: 24.r,
                              color: deepBlue,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: orangeAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 12.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: orangeAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: orangeAccent,
                    size: 14.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Creating $_level level community',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Select State',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedStateId,
              decoration: _inputDecoration('Choose State'),
              items: widget.allStates
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: (s['_id'] ?? s['id'] ?? '').toString(),
                      child: Text(
                        s['name'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedStateId = val;
                  _selectedDistrictId = null;
                  _selectedWardId = null;
                  _districts = [];
                  _wards = [];
                  _level = 'STATE';
                });
                if (val != null) _fetchDistricts(val);
              },
              validator: (val) => val == null ? 'State is required' : null,
            ),
            SizedBox(height: 20.h),

            if (_level != 'STATE') ...[
              Text(
                'Select District',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _selectedStateId == null ? Colors.grey : deepBlue,
                ),
              ),
              SizedBox(height: 8.h),
              _isLoadingDistricts
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedDistrictId,
                      decoration: _inputDecoration(
                        _selectedStateId == null
                            ? 'Select State first'
                            : 'Choose District',
                      ),
                      items: _districts
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: (d['_id'] ?? d['id'] ?? '').toString(),
                              child: Text(
                                d['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _selectedStateId == null
                          ? null
                          : (val) {
                              setState(() {
                                _selectedDistrictId = val;
                                _selectedWardId = null;
                                _wards = [];
                                _level = val != null ? 'DISTRICT' : 'STATE';
                              });
                              if (val != null) _fetchWards(val);
                            },
                      validator: (val) => _level != 'STATE' && val == null
                          ? 'District is required'
                          : null,
                    ),
              SizedBox(height: 20.h),

              Text(
                'Select Ward',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _selectedDistrictId == null ? Colors.grey : deepBlue,
                ),
              ),
              SizedBox(height: 8.h),
              _isLoadingWards
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedWardId,
                      decoration: _inputDecoration(
                        _selectedDistrictId == null
                            ? 'Select District first'
                            : 'Choose Ward',
                      ),
                      items: _wards
                          .map(
                            (w) => DropdownMenuItem<String>(
                              value: (w['_id'] ?? w['id'] ?? '').toString(),
                              child: Text(
                                w['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _selectedDistrictId == null
                          ? null
                          : (val) {
                              setState(() {
                                _selectedWardId = val;
                                _level = val != null ? 'WARD' : 'DISTRICT';
                              });
                            },
                      validator: (val) => _level == 'WARD' && val == null
                          ? 'Ward is required'
                          : null,
                    ),
              SizedBox(height: 20.h),
            ],

            Text(
              'association_name'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                'Enter name (e.g. Hyderabad PG Association)',
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: 20.h),

            Text(
              'association_desc'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration('Enter association description...'),
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),

            BouncingWrapper(
              onTap: _isSubmitting ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                decoration: BoxDecoration(
                  color: _isSubmitting
                      ? AppColors.primaryBlue.withValues(alpha: 0.7)
                      : deepBlue,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
      isDense: false, 
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    String? sanitizeId(String? id) {
      if (id == null) return null;
      if (id.startsWith('VIRTUAL:')) return null;
      return id;
    }

    try {
      await sl<CreateOwnerCommunityUseCase>().call(
        name: _nameController.text,
        level: _level,
        stateId: sanitizeId(_selectedStateId),
        districtId: sanitizeId(_selectedDistrictId),
        wardId: sanitizeId(_selectedWardId),
        description: _descController.text,
        imagePath: _imageFile?.path,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(GlobalErrorMapper.map(e).message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
