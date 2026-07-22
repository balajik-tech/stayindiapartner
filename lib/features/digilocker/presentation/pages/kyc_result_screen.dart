import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../injection_container.dart' as di;
import '../../../profile/presentation/pages/account_settings_page.dart';
import '../../domain/entities/kyc_result.dart';
import '../cubit/digilocker_cubit.dart';
import '../cubit/digilocker_state.dart';
import '../widgets/kyc_result_card.dart';

/// Full-screen page shown after a successful DigiLocker verification.
/// Push this with the [KycResult] returned from DigiLockerVerificationScreen.
class KycResultScreen extends StatelessWidget {
  final KycResult result;

  const KycResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = di.sl<DigiLockerCubit>();
        cubit.loadKycResult(result);
        return cubit;
      },
      child: const _KycResultView(),
    );
  }
}

class _KycResultView extends StatelessWidget {
  const _KycResultView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Result')),
      body: BlocConsumer<DigiLockerCubit, DigiLockerState>(
        listener: (context, state) {
          if (state is DigiLockerSaved) {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is DigiLockerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is DigiLockerLoading || state is DigiLockerSaving) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DigiLockerLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KycResultCard(result: state.result),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is DigiLockerSaving
                        ? null
                        : () {
                      context.read<DigiLockerCubit>().saveKycResult(state.result);
                    },
                    child: state is DigiLockerSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Accept'),
                  ),
                ],
              ),
            );
          }

          if (state is DigiLockerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
