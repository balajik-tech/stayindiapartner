import 'package:flutter/material.dart';

import '../../domain/entities/digilocker_credentials.dart';
import '../../domain/entities/kyc_result.dart';
import '../pages/digilocker_verification_screen.dart';
import '../pages/kyc_result_screen.dart';

/// A reusable navigation helper for DigiLocker verification flow.
/// 
/// This class provides a simple, reusable way to launch the DigiLocker
/// verification process from anywhere in the app.
/// 
/// Usage:
/// ```dart
/// await DigiLockerNavigator.verifyWithDigiLocker(
///   context,
///   credentials: myCredentials,
///   documents: 'aadhaar',
///   onResult: (result) {
///     if (result != null) {
///       // Handle successful verification
///     }
///   },
/// );
/// ```
class DigiLockerNavigator {
  /// Launches the DigiLocker verification flow.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [credentials]: DigiLocker API credentials
  /// - [documents]: Comma-separated document types (e.g., 'aadhaar' or 'aadhaar,pan')
  /// - [panName]: Optional PAN name pre-fill
  /// - [panNo]: Optional PAN number pre-fill
  /// - [showResultScreen]: Whether to show the result screen after successful verification
  /// - [onResult]: Callback with the verification result (null if cancelled/failed)
  static Future<void> verifyWithDigiLocker({
    required BuildContext context,
    required DigiLockerCredentials credentials,
    required String documents,
    String panName = '',
    String panNo = '',
    bool showResultScreen = true,
    Function(KycResult?)? onResult,
  }) async {
    final result = await Navigator.push<KycResult>(
      context,
      MaterialPageRoute(
        builder: (_) => DigiLockerVerificationScreen(
          credentials: credentials,
          documents: documents,
          panName: panName,
          panNo: panNo,
        ),
      ),
    );

    // Call the callback with the result
    onResult?.call(result);

    // Show result screen if verification succeeded and showResultScreen is true
    if (result != null && showResultScreen) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KycResultScreen(result: result)),
      );
    } else if (result == null) {
      // Show error message if verification failed/cancelled
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification cancelled or failed')),
      );
    }
  }

  /// Launches DigiLocker verification with Aadhaar only.
  static Future<void> verifyAadhaar({
    required BuildContext context,
    required DigiLockerCredentials credentials,
    bool showResultScreen = true,
    Function(KycResult?)? onResult,
  }) {
    return verifyWithDigiLocker(
      context: context,
      credentials: credentials,
      documents: 'aadhaar',
      showResultScreen: showResultScreen,
      onResult: onResult,
    );
  }

  /// Launches DigiLocker verification with both Aadhaar and PAN.
  static Future<void> verifyAadhaarAndPan({
    required BuildContext context,
    required DigiLockerCredentials credentials,
    String panName = '',
    String panNo = '',
    bool showResultScreen = true,
    Function(KycResult?)? onResult,
  }) {
    return verifyWithDigiLocker(
      context: context,
      credentials: credentials,
      documents: 'aadhaar,pan',
      panName: panName,
      panNo: panNo,
      showResultScreen: showResultScreen,
      onResult: onResult,
    );
  }
}
