import 'package:flutter/material.dart';

import '../../domain/entities/kyc_result.dart';
import '../widgets/kyc_result_card.dart';

/// Full-screen page shown after a successful DigiLocker verification.
/// Push this with the [KycResult] returned from DigiLockerVerificationScreen.
class KycResultScreen extends StatelessWidget {
  final KycResult result;

  const KycResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KycResultCard(result: result),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, result),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
