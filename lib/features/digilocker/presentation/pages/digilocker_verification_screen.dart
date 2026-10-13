import 'package:flutter/material.dart';
import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';

import '../../domain/entities/digilocker_credentials.dart';
import '../../domain/entities/kyc_result.dart';

/// A self-contained screen that launches the DigiLocker verification flow
/// and returns a [KycResult] via [Navigator.pop] on success.
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<KycResult>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => DigiLockerVerificationScreen(
///       credentials: myCredentials,
///       documents: 'aadhaar,pan',
///     ),
///   ),
/// );
/// if (result != null) {
///   // save result, unlock next step, etc.
/// }
/// ```
class DigiLockerVerificationScreen extends StatefulWidget {
  final DigiLockerCredentials credentials;

  /// Comma-separated list, e.g. 'aadhaar,pan' or just 'aadhaar'.
  final String documents;

  /// Optional PAN pre-fill.
  final String panName;
  final String panNo;

  const DigiLockerVerificationScreen({
    super.key,
    required this.credentials,
    this.documents = 'aadhaar',
    this.panName = '',
    this.panNo = '',
  });

  @override
  State<DigiLockerVerificationScreen> createState() =>
      _DigiLockerVerificationScreenState();
}

class _DigiLockerVerificationScreenState
    extends State<DigiLockerVerificationScreen> {
  String? _errorMessage;

  late final DigiLockerConfig _config = DigiLockerConfig(
    companyName: widget.credentials.companyName,
    secretToken: widget.credentials.secretToken,
    redirectUrl: widget.credentials.redirectUrl,
    documents: widget.documents,
    panName: widget.panName,
    panNo: widget.panNo,
  );

  void _handleSuccess(DigiLockerResponse response) {
    if (!mounted) return;
    if (response.success != true) {
      _handleError(response.msg.isNotEmpty ? response.msg : 'Verification failed');
      return;
    }
    final result = _convertToKycResult(response);
    Navigator.of(context).pop<KycResult>(result);
  }

  KycResult _convertToKycResult(DigiLockerResponse response) {
    final data = response.data;
    return KycResult(
      isAadharVerified: response.success,
      name: data?.name,
      fatherName: data?.fathername,
      aadharNumber: data?.aadharNo,
      maskedAadhaar: KycResult.maskAadhaar(data?.aadharNo),
      aadharAddress: data?.aadharAddress,
      dob: data?.dob,
      gender: data?.gender,
      dateTime: DateTime.now().toIso8601String(),
      aadharFilename: data?.aadharFilename,
      aadharImgFilename: data?.aadharImgFilename,
      adharImg: data?.adharimg,
      // panNumber: data?.panNumber,
      // nameOnPan: data?.nameOnPan,
      capturedAt: DateTime.now(),
    );
  }

  void _handleError(String error) {
    if (!mounted) return;

    // Ignore non-fatal subresource errors (e.g. Chrome ORB blocking opaque cross-origin resources)
    if (_isNonFatalWebViewError(error)) {
      debugPrint('DigiLocker: Ignored non-fatal WebView error: $error');
      return;
    }

    setState(() {
      _errorMessage = error;
    });
  }

  /// Returns true for non-fatal web resource loading errors that shouldn't interrupt the user flow.
  bool _isNonFatalWebViewError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('err_blocked_by_orb') ||
        lower.contains('err_blocked_by_client') ||
        lower.contains('err_cache_miss') ||
        lower.contains('err_corp_failed') ||
        lower.contains('err_blocked_by_response') ||
        lower.contains('favicon');
  }

  void _handleClose() {
    if (!mounted) return;
    Navigator.of(context).pop<KycResult>(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DigiLocker Verification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DigiLockerWidget(
      config: _config,
      onSuccess: _handleSuccess,
      onError: _handleError,
      onClose: _handleClose,
    );
  }
}
