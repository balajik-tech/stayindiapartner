import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  BankAccountType _accountType = BankAccountType.savings;

  bool get _numbersMatch =>
      _confirmAccountNumberController.text.isNotEmpty &&
      _accountNumberController.text == _confirmAccountNumberController.text;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    // final hostelCubit = context.read<HostelCubit>();
    // final hostelState = hostelCubit.state;
    // final selectedHostelID = hostelState.selectedHostelId;

    context.read<AddBankAccountCubit>().submit(
          propertyId: widget.propertyId,
          accountNumber: _accountNumberController.text.trim(),
          confirmAccountNumber: _confirmAccountNumberController.text.trim(),
          ifscCode: _ifscController.text.trim().toUpperCase(),
          accountHolderName: _holderNameController.text.trim(),
          accountType: _accountType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AddBankAccountCubit, AddBankAccountState>(
          listener: (context, state) {
            if (state.submitError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitError!)),
              );
            }
            if (state.isSuccess) {
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close,color: Colors.black),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Add bank account',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,color: Colors.black)),
                            Text('Account details',
                                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
                      _FieldLabel('Account number'),
                      TextField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Confirm account number'),
                      TextField(
                        controller: _confirmAccountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                        onChanged: (_) => setState(() {}),
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
                      _FieldLabel('IFSC code'),
                      TextField(
                        controller: _ifscController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 11,
                        decoration: _inputDecoration().copyWith(counterText: ''),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Account holder name'),
                      TextField(
                        controller: _holderNameController,
                        decoration: _inputDecoration(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Must match the name on your PAN. Mismatches fail verification.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF565656)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Account type'),
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
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined, size: 18, color: Color(0xFF6B7280)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No documents needed. We verify by depositing ₹1 and matching the name your bank returns.',
                                style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.grey.shade300, // Grey border
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                        : const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
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
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF2E5AF5) : const Color(0xFFD1D5DB), width: selected ? 1.5 : 1),
          color: selected ? const Color(0xFFEAF1FF) : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF2E5AF5) : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
