import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:url_launcher/url_launcher.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:open_filex/open_filex.dart';

class AddBulkTenantPage extends StatefulWidget {
  const AddBulkTenantPage({super.key});

  @override
  State<AddBulkTenantPage> createState() => _AddBulkTenantPageState();
}

class _AddBulkTenantPageState extends State<AddBulkTenantPage> {
  late AddTenantCubit _addTenantCubit;

  File? _csvFile;

  @override
  void initState() {
    super.initState();
    _addTenantCubit = di.sl<AddTenantCubit>();
  }

  @override
  void dispose() {
    _addTenantCubit.close();
    super.dispose();
  }

  Future<void> _pickCSVFile() async {
    try {
      // Use FilePicker.platform.pickFiles if available, otherwise try FilePicker.pickFiles
      // Some environments might have conflicting definitions or version issues.
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final ext = path.split('.').last.toLowerCase();
        if (ext == 'csv' || ext == 'xlsx') {
          setState(() {
            _csvFile = File(path);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a valid .csv or .xlsx file'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _downloadSampleCSV() async {
    final hostelState = context.read<HostelCubit>().state;
    String? hostelId;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    }

    if (hostelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a property first'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final String csvUrl = ApiConstants.baseUrl + ApiConstants.tenantImportTemplate(hostelId);

    try {
      final dio = di.sl<Dio>();
      // Use ApplicationDocumentsDirectory for better compatibility and visibility for OpenFilex
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/tenant_import_template_$hostelId.csv';


      debugPrint('Downloading CSV from: $csvUrl to: $filePath');

      final response = await dio.download(
        csvUrl,
        filePath,
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        final exists = await file.exists();

        if (exists && mounted) {
          final messenger = ScaffoldMessenger.of(context);

          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('Template downloaded successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Open',
                  textColor: Colors.white,
                  onPressed: () async {
                    try {
                      await OpenFilex.open(filePath);
                    } catch (e) {
                      debugPrint('Error opening file: $e');
                    }
                  },
                ),
              ),
            );

          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              messenger.removeCurrentSnackBar();
            }
          });
        }
      } else {
        debugPrint('❌ Failed to download CSV: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error downloading CSV: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error downloading template'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _submitBulkTenantUpload() async {
    if (_csvFile == null) {
      debugPrint('❌ Bulk Upload: No file selected');
      return;
    }

    final path = _csvFile!.path;
    final extension = path.split('.').last.toLowerCase();

    if (extension != 'csv' && extension != 'xlsx') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid file format. Please upload a .csv or .xlsx file.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      debugPrint('❌ File does not exist: $path');
      return;
    }

    final hostelState = context.read<HostelCubit>().state;
    String? hostelId;
    if (hostelState is HostelLoaded) {
      hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    }

    if (hostelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a property first'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _addTenantCubit.bulkUpload(file, hostelId);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildBulkUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Bulk Tenant Upload'),
        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _csvFile != null
                  ? Colors.green.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              if (_csvFile != null) ...[
                Row(
                  children: [
                    Icon(
                      _csvFile!.path.toLowerCase().endsWith('.csv')
                          ? Icons.insert_drive_file_rounded
                          : Icons.table_view_rounded,
                      color: Colors.green,
                      size: 32.sp,
                    ),
                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _csvFile!.path.split('/').last,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'File Ready',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        setState(() => _csvFile = null);
                      },
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Upload a CSV file containing tenant details for bulk registration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 16.h),

                ElevatedButton.icon(
                  onPressed: _pickCSVFile,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _downloadSampleCSV,
            icon: Icon(
              Icons.download_rounded,
              size: 14.sp,
              color: AppColors.primaryBlue,
            ),
            label: Text(
              'Download Generated CSV File',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),

        // Submit button
        if (_csvFile != null) ...[
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _submitBulkTenantUpload,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: Text(
                'Submit Bulk Upload',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addTenantCubit,
      child: BlocListener<AddTenantCubit, AddTenantState>(
        listener: (context, state) {
          if (state is AddTenantSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'tenant_added_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _csvFile = null;
            });
            _addTenantCubit.reset();
          } else if (state is AddTenantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
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
              'Bulk Tenant Upload',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<AddTenantCubit, AddTenantState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulkUploadSection(),
                      if (state is AddTenantSubmitting) ...[
                        SizedBox(height: 16.h),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
