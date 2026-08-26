import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/app_exceptions.dart';
import '../../domain/repositories/digilocker_repository.dart';
import '../../domain/entities/kyc_result.dart';
import 'digilocker_state.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class DigiLockerCubit extends Cubit<DigiLockerState> {
  final DigiLockerRepository repository;
  final AuthRepository authRepository;

  DigiLockerCubit({
    required this.repository,
    required this.authRepository,
  }) : super(DigiLockerInitial());

  /// Load a KYC result into state (typically from navigation)
  void loadKycResult(KycResult result) {
    emit(DigiLockerLoaded(result));
  }

  /// Load KYC result from local storage
  Future<void> loadKycResultFromStorage() async {
    emit(DigiLockerLoading());
    try {
      final result = await repository.loadKycResult();
      result.fold(
        (failure) => emit(DigiLockerError(failure.message)),
        (kycResult) {
          if (kycResult != null) {
            emit(DigiLockerLoaded(kycResult));
          } else {
            emit(DigiLockerInitial());
          }
        },
      );
    } catch (e) {
      emit(DigiLockerError(GlobalErrorMapper.map(e).message));
    }
  }

  /// Save KYC result to API via AuthRepository
  Future<void> saveKycResult(
    KycResult result, {
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
  }) async {
    emit(DigiLockerSaving());
    try {
      // Split full name into first & last name
      final fullName = result.name?.trim() ?? '';
      final nameParts = fullName.split(RegExp(r'\s+'));

      final derivedFirstName = nameParts.isNotEmpty ? nameParts.first : null;
      final derivedLastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : null;
      // Build data map for API call
      final data = <String, dynamic>{
        if (fullName != null) 'firstName': fullName,
        'lastName': "",
        // if (phone != null) 'phone': phone,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (result.aadharAddress != null) 'address': result.aadharAddress,
        'dlKyc': {
          'is_aadhar_verified': true,
          'gender': result.gender,
          'masked_aadhaar': result.maskedAadhaar ??
              KycResult.maskAadhaar(result.aadharNumber),
          'dob': result.dob,
          'date_time': result.dateTime ??
              result.capturedAt.toIso8601String(),
          'aadhar_address': result.aadharAddress,
          'aadhar_no': result.aadharNumber,
          'name': result.name,
          'aadhar_filename': result.aadharFilename,
          'aadhar_img_filename': result.aadharImgFilename,
          'adharimg': result.adharImg,
          'fathername': result.fatherName,
        },
      };
      
      // Remove null values from top level only (keep dlKyc fields even if null)
      data.removeWhere((key, value) => value == null && key != 'dlKyc');
      
      // Call AuthRepository updateProfile API
      await authRepository.updateProfile(data);
      
      emit(DigiLockerSaved(result));
    } catch (e) {
      emit(DigiLockerError(GlobalErrorMapper.map(e).message));
    }
  }

  /// Reset the state to initial
  void reset() {
    emit(DigiLockerInitial());
  }
}
