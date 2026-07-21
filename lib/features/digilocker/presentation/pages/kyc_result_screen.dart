import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../profile/presentation/pages/account_settings_page.dart';
import '../../domain/entities/kyc_result.dart';
import '../widgets/kyc_result_card.dart';

/// Full-screen page shown after a successful DigiLocker verification.
/// Push this with the [KycResult] returned from DigiLockerVerificationScreen.
class KycResultScreen extends StatelessWidget {
  final KycResult result;

  const KycResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KycResultCard(result: result),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await saveDigiLockerDetails(result);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsPage(),
                  ),
                );
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  /// Save DigiLocker details
  static Future<void> saveDigiLockerDetails(KycResult result) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'digi_locker_details',
      jsonEncode(result.toJson()),
    );
  }
}
