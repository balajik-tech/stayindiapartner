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
      name: data?.name,
      aadharNumber: KycResult.maskAadhaar(data?.aadharNo),
      aadharAddress: data?.aadharAddress,
      dob: data?.dob,
      gender: data?.gender,
      panNumber: data?.panNumber,
      nameOnPan: data?.nameOnPan,
      capturedAt: DateTime.now(),
    );
  }

  void _handleError(String error) {
    if (!mounted) return;
    setState(() {
      _errorMessage = error;
    });
  }

  void _handleClose() {
    if (!mounted) return;
    Navigator.of(context).pop<KycResult>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DigiLocker Verification')),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
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
            )
          else
            DigiLockerWidget(
              config: _config,
              onSuccess: _handleSuccess,
              onError: _handleError,
              onClose: _handleClose,
            ),
        ],
      ),
    );
  }
}
