import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';

/// App-level KYC result, decoupled from the plugin's response shape so the
/// rest of the app (state management, storage, UI) doesn't depend directly
/// on a third-party package's types.
class KycResult {
  final String? name;
  final String? aadharNumber;
  final String? aadharAddress;
  final String? dob;
  final String? gender;
  final String? panNumber;
  final String? nameOnPan;
  final DateTime capturedAt;

  const KycResult({
    this.name,
    this.aadharNumber,
    this.aadharAddress,
    this.dob,
    this.gender,
    this.panNumber,
    this.nameOnPan,
    required this.capturedAt,
  });

  factory KycResult.fromDigiLockerResponse(DigiLockerResponse response) {
    final data = response.data;
    return KycResult(
      name: data?.name,
      aadharNumber: _maskAadhaar(data?.aadharNo),
      aadharAddress: data?.aadharAddress,
      dob: data?.dob,
      gender: data?.gender,
      panNumber: data?.panNumber,
      nameOnPan: data?.nameOnPan,
      capturedAt: DateTime.now(),
    );
  }

  /// Masks all but the last 4 digits — never display/store full Aadhaar
  /// numbers in logs or UI unless your compliance requirements say otherwise.
  static String? _maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.length < 4) return aadhaar;
    final last4 = aadhaar.substring(aadhaar.length - 4);
    return 'XXXX-XXXX-$last4';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'aadharNumber': aadharNumber,
        'aadharAddress': aadharAddress,
        'dob': dob,
        'gender': gender,
        'panNumber': panNumber,
        'nameOnPan': nameOnPan,
        'capturedAt': capturedAt.toIso8601String(),
      };
}
