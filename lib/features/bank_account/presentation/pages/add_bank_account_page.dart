import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../injection_container.dart';
import '../../../profile/presentation/cubit/hostel_cubit.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../cubit/add_bank_account_cubit.dart';

class AddBankAccountPage extends StatelessWidget {
  final String propertyId;
  final String propertyName;

  const AddBankAccountPage({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddBankAccountCubit>(),
      child: _AddBankAccountView(propertyId: propertyId, propertyName: propertyName),
    );
  }
}

class _AddBankAccountView extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const _AddBankAccountView({required this.propertyId, required this.propertyName});

  @override
  State<_AddBankAccountView> createState() => _AddBankAccountViewState();
}

class _AddBankAccountViewState extends State<_AddBankAccountView> {
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _panController = TextEditingController();
  BankAccountType _accountType = BankAccountType.savings;
  bool _confirmDialogShown = false;
  bool _isPanVerifiedToastShown = false;

  @override
  void initState() {
    super.initState();
    _ifscController.addListener(_onIfscChanged);
    _panController.addListener(_onPanChanged);


    //Dialog testing

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     _showConfirmBankAccountDialogPreview(context);
    //   }
    // });
  }

  bool get _numbersMatch =>
      _confirmAccountNumberController.text.isNotEmpty &&
          _accountNumberController.text == _confirmAccountNumberController.text;

  bool get _isFormValid {
    return _accountNumberController.text.trim().isNotEmpty &&
        _confirmAccountNumberController.text.trim().isNotEmpty &&
        _numbersMatch &&
        _ifscController.text.trim().length == 11 &&
        _panController.text.trim().length == 10;
       // && _holderNameController.text.trim().isNotEmpty;
  }


  @override
  void dispose() {
    _ifscController.removeListener(_onIfscChanged);
    _panController.removeListener(_onPanChanged);
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _onIfscChanged() {
    final code = _ifscController.text.trim().toUpperCase();
    if (mounted) {
      context.read<AddBankAccountCubit>().resetPanVerification();
      context.read<AddBankAccountCubit>().lookupIfscCode(code);
    }
  }

  void _onPanChanged() {
    final currentPan = _panController.text.trim().toUpperCase();
    if (mounted && currentPan.isNotEmpty) {
      context.read<AddBankAccountCubit>().resetPanVerification();
    }
    setState(() {});
  }

  bool get _isPanValid {
    final pan = _panController.text.trim().toUpperCase();
    if (pan.length != 10) return false;
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return regex.hasMatch(pan);
  }

  String _panFieldHintText(AddBankAccountState state) {
    final pan = _panController.text.trim();

    if (pan.isEmpty) {
      return 'Entered pan number name should match with bank account name';
    }

    if (!_isPanValid) {
      return 'PAN number must be 10 characters and follow the valid format (e.g. ABCDE1234F).';
    }

    if (state.panVerifyError != null) {
      return state.panVerifyError!;
    }

    if (state.panVerifySuccess && state.panVerificationResult != null) {
      return 'PAN verified successfully';
    }

    return 'Enter pan number name should match with bank account name';
  }

  bool _panAndBankHolderNamesMatch(AddBankAccountState state) {
    final bankName = state.verificationResult?.beneficiaryName ?? '';
    final panName = state.panVerificationResult?.fullname ?? '';
    return areNamesEquivalent(bankName, panName);
  }

  String _panAndBankHolderNameError(AddBankAccountState state) {
    final bankName = state.verificationResult?.beneficiaryName ?? '';
    final panName = state.panVerificationResult?.fullname ?? '';

    if (bankName.trim().isEmpty || panName.trim().isEmpty) {
      return '';
    }

    return areNamesEquivalent(bankName, panName)
        ? ''
        : 'PAN name and bank account holder name do not match.';
  }

  void _submit(BuildContext context) {
    _isPanVerifiedToastShown = false;
    context.read<AddBankAccountCubit>().submit(
      propertyId: widget.propertyId,
      accountNumber: _accountNumberController.text.trim(),
      confirmAccountNumber: _confirmAccountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim().toUpperCase(),
      accountHolderName: _holderNameController.text.trim(),
      accountType: _accountType,
      panNumber: _panController.text.trim().toUpperCase(),
    );
  }

  void _verify(BuildContext context) {
    _confirmDialogShown = false;
    final accountNumber = _accountNumberController.text.trim();
    final ifscCode = _ifscController.text.trim().toUpperCase();
    final clientRefNum = '${widget.propertyId}_$accountNumber';

    context.read<AddBankAccountCubit>().verify(
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      clientRefNum: clientRefNum,
    );
  }

  void _verifyPan(BuildContext context) {
    final pan = _panController.text.trim().toUpperCase();
    context.read<AddBankAccountCubit>().verifyPan(pan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AddBankAccountCubit, AddBankAccountState>(
          listener: (context, state) {
            if (state.submitError != null && !_confirmDialogShown) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitError!)),
              );
            }
            if (state.verifyError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.verifyError!)),
              );
            }
            if (state.panVerifyError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.panVerifyError!)),
              );
            }
            if (state.verifySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bank account verified successfully.')),
              );
            }
            if (state.panVerifySuccess && state.panVerificationResult != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isPanVerifiedToastShown) {
                  _isPanVerifiedToastShown = true;
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('PAN verified successfully.')),
                  // );
                }
              });
            }
            if (state.verifySuccess &&
                state.verificationResult != null &&
                state.panVerificationResult != null &&
                _panAndBankHolderNamesMatch(state) &&
                !_confirmDialogShown) {
              _confirmDialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showConfirmBankAccountDialog(context, state);
                }
              });
            }
            if (state.isSuccess && !state.isSubmitting && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (_confirmDialogShown) {
                    Navigator.of(context).pop();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank account added successfully.')),
                  );
                  Navigator.of(context).pop(true);
                }
              });
            }
          },
          builder: (context, state) {
            final bool namesMatch = _panAndBankHolderNamesMatch(state);
            final bool canProceedToVerification = !state.isVerifying && _isFormValid && state.panVerifySuccess && namesMatch;
            final String nameMismatchError = _panAndBankHolderNameError(state);

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: (state.isSubmitting || state.isVerifying) ? null : () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close,color: Colors.black),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Add Bank Account',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,color: Colors.black)),
                                Text('Step 1 of 2 · Account details',
                                    style: TextStyle(fontSize: 13,  color: Color(0xFF5b5b5b),fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: LinearProgressIndicator(
                        value: 0,
                        minHeight: 1,
                        backgroundColor: Color(0xFFEDEEF1),
                        color: Color(0xFF2E5AF5),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          _FieldLabel('Account Number'),
                          TextField(
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(),
                            onChanged: (_) => setState(() {}),
                              style:  GoogleFonts.inter(
                                color: Colors.black,
                              ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Confirm Account Number'),
                          TextField(
                            controller: _confirmAccountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(),
                            onChanged: (_) => setState(() {}),
                            style:  GoogleFonts.inter(
                              color: Colors.black,
                            ),
                          ),
                          if (_confirmAccountNumberController.text.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  _numbersMatch ? Icons.check_circle : Icons.error_outline,
                                  size: 16,
                                  color: _numbersMatch ? const Color(0xFF1E8E42) : Colors.redAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _numbersMatch ? 'Numbers match' : 'Numbers do not match',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _numbersMatch ? const Color(0xFF1E8E42) : Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          _FieldLabel('IFSC Code'),
                          TextField(
                            controller: _ifscController,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 11,
                            decoration: _inputDecoration().copyWith(counterText: ''),
                            onChanged: (_) => setState(() {}),
                            style:  GoogleFonts.inter(
                              color: Colors.black,
                            ),
                          ),
                          if (state.isLookupLoading) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Looking up IFSC branch details…',
                                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ],
                          if (state.lookupError != null && _ifscController.text.trim().length == 11) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.lookupError!,
                              style:  GoogleFonts.inter(fontSize: 12.5, color: Colors.redAccent),
                            ),
                          ],
                          if (state.ifscLookupDetails != null && state.ifscLookupDetails!.displayLabel.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD9E1FF)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF2E5AF5)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.ifscLookupDetails!.displayLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: Color(0xFF293645),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _FieldLabel('PAN Number'),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _panController,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 10,
                                  decoration: _inputDecoration().copyWith(
                                    counterText: '',
                                    hintText: '',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: (!state.isVerifyingPan && _isPanValid)
                                      ? () => (state.panVerifySuccess)? null: _verifyPan(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.panVerifySuccess
                                        ? const Color(0xFF1E8E42)
                                        : Colors.white,
                                    foregroundColor: state.panVerifySuccess
                                        ? Colors.white
                                        : Colors.black,
                                    elevation: 0,
                                    side: BorderSide(
                                      color: _isPanValid
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: state.isVerifyingPan
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : state.panVerifySuccess
                                          ? const Icon(Icons.check, size: 20)
                                          : Text(
                                              'Verify',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: _isPanValid
                                                    ? Colors.black
                                                    : Colors.grey.shade500,
                                              ),
                                            ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _panFieldHintText(state),
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: state.panVerifySuccess && state.panVerificationResult != null
                                  ? const Color(0xFF1E8E42)
                                  : _panController.text.trim().isNotEmpty && !_isPanValid
                                      ? Colors.redAccent
                                      : state.panVerifyError != null
                                          ? Colors.redAccent
                                          : const Color(0xFF6B7280),
                              fontWeight: state.panVerifySuccess && state.panVerificationResult != null
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          if (state.panVerifySuccess && state.panVerificationResult != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F4EA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF1E8E42)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF1E8E42)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PAN Verified: ${state.panVerificationResult!.fullname}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            color: Color(0xFF1E8E42),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${state.panVerificationResult!.panStatus}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.5,
                                            color: Color(0xFF1E8E42),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // _FieldLabel('Account holder name'),
                          // TextField(
                          //   controller: _holderNameController,
                          //   decoration: _inputDecoration(),
                          // ),
                          // const Padding(
                          //   padding: EdgeInsets.only(top: 8),
                          //   child: Text(
                          //     'Must match the name on your PAN. Mismatches fail verification.',
                          //     style: TextStyle(fontSize: 12.5, color: Color(0xFF565656)),
                          //   ),
                          // ),
                          const SizedBox(height: 16),
                          _FieldLabel('Account Type'),
                          Row(
                            children: [
                              Expanded(
                                child: _AccountTypeChip(
                                  label: 'Savings',
                                  selected: _accountType == BankAccountType.savings,
                                  onTap: () => setState(() => _accountType = BankAccountType.savings),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AccountTypeChip(
                                  label: 'Current',
                                  selected: _accountType == BankAccountType.current,
                                  onTap: () => setState(() => _accountType = BankAccountType.current),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFfcfdfb),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF6B7280)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'No documents needed. We verify by depositing ₹1 and matching the name your bank returns.',
                                    style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    if (nameMismatchError.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          nameMismatchError,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton(
                        onPressed: (!state.isVerifying && _isFormValid  && state.panVerifySuccess)
                            ? () => _verify(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: BorderSide(
                            color: (!state.isVerifying && _isFormValid  && state.panVerifySuccess) ? Colors.grey.shade300 : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: (!state.isVerifying && _isFormValid  && state.panVerifySuccess) ? Colors.black : Colors.grey.shade500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                if (state.isSubmitting || state.isVerifying)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5AF5)),
      ),
    );
  }

  void _showConfirmBankAccountDialog(BuildContext context, AddBankAccountState state) {
    final result = state.verificationResult!;
    final accountTypeLabel =
    _accountType == BankAccountType.savings ? 'savings' : 'current';

    _showConfirmBankAccountDialogRaw(
      context,
      holderName: result.beneficiaryName,
      accountNumber: _accountNumberController.text.trim(),
      bankName: result.bankName,
      branchName: result.branchName,
      accountTypeLabel: accountTypeLabel,
      onConfirm: () => _submit(context),
    ).then((_) {
      if (mounted) {
        setState(() {
          _confirmDialogShown = false;
        });
      }
    });
  }

  /// Static preview dialog — for design/QA checking only, not wired to
  /// verification state. Call this from initState (or anywhere) to
  /// visually inspect the dialog without going through the real flow.
  // void _showConfirmBankAccountDialogPreview(BuildContext context) {
  //   _showConfirmBankAccountDialogRaw(
  //     context,
  //     holderName: 'Ramesh Kumar',
  //     accountNumber: '50100482196075',
  //     bankName: 'HDFC Bank',
  //     branchName: 'Koramangala 5th Block, Bengaluru',
  //     accountTypeLabel: 'savings',
  //     onConfirm: () {},
  //   );
  // }

  Future<void> _showConfirmBankAccountDialogRaw(
      BuildContext context, {
        required String holderName,
        required String accountNumber,
        required String bankName,
        required String branchName,
        required String accountTypeLabel,
        required VoidCallback onConfirm,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<AddBankAccountCubit>(),
          child: BlocBuilder<AddBankAccountCubit, AddBankAccountState>(
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Confirm Bank Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: state.isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close, color: Colors.black87, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Step 2 of 2 · Verification Complete',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(Icons.check_circle, size: 18, color: Color(0xFF1E8E42)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Name matched with bank records',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E8E42),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  label: 'Account Holder Name',
                                  value: holderName,
                                ),
                                _DetailRow(
                                  label: 'Account Number',
                                  value: accountNumber,
                                  monospace: true,
                                ),
                                _DetailRow(
                                  label: 'Bank Name',
                                  value: bankName,
                                ),
                                _DetailRow(
                                  label: 'Branch',
                                  value: branchName,
                                  showDivider: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Color(0xFF6B7280)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rentals will be sent to this account',
                                  style:  GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isSubmitting ? null : onConfirm,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: const Color(0xFF4C6EF5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Confirm and Add Account',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          if (state.submitError != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                state.submitError!,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton(
                              onPressed: state.isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                              child:  Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.isSubmitting)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4C6EF5),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

bool areNamesEquivalent(String? firstName, String? secondName) {
  final normalizedFirst = _normalizeName(firstName);
  final normalizedSecond = _normalizeName(secondName);

  if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) {
    return false;
  }

  if (normalizedFirst == normalizedSecond) {
    return true;
  }

  final firstWords = normalizedFirst.split(' ')..sort();
  final secondWords = normalizedSecond.split(' ')..sort();

  if (firstWords.length != secondWords.length) {
    return false;
  }

  for (var i = 0; i < firstWords.length; i++) {
    if (firstWords[i] != secondWords[i]) {
      return false;
    }
  }

  return true;
}

String _normalizeName(String? value) {
  return (value ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style:  GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600,color: Color(0xFF545454))),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.monospace = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child:
              Text(
                label,
                style:  GoogleFonts.inter(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              )),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _AccountTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AccountTypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF9ab2d4) : const Color(0xFFD1D5DB), width: selected ? 1.5 : 1),
          color:  Colors.white,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              color: selected ? const Color(0xFF4c6891) : Color(0xFF505050),
              fontWeight: FontWeight.w700,
              fontSize: 16
          ),
        ),
      ),
    );
  }
}
