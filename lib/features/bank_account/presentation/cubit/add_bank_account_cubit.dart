import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/usecases/add_bank_account.dart';
import '../../domain/usecases/lookup_ifsc.dart';

part 'add_bank_account_state.dart';

class AddBankAccountCubit extends Cubit<AddBankAccountState> {
  final AddBankAccount addBankAccount;
  final LookupIfsc lookupIfsc;

  Timer? _debounce;

  AddBankAccountCubit({
    required this.addBankAccount,
    required this.lookupIfsc,
  }) : super(const AddBankAccountState());

  /// Called on every IFSC field change; debounces the lookup so we don't
  /// hit the use case on every keystroke.
  void onIfscChanged(String ifscCode) {
    _debounce?.cancel();

    if (ifscCode.length != 11) {
      emit(state.copyWith(clearIfsc: true));
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isIfscLoading: true, clearIfsc: true));
      final result = await lookupIfsc(ifscCode);
      result.fold(
        (failure) => emit(state.copyWith(isIfscLoading: false, ifscError: failure.message)),
        (branch) => emit(state.copyWith(isIfscLoading: false, branchDetails: branch)),
      );
    });
  }

  Future<void> submit({
    required String propertyId,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));

    final result = await addBankAccount(
      AddBankAccountParams(
        propertyId: propertyId,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        accountHolderName: accountHolderName,
        accountType: accountType,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, submitError: failure.message)),
      (account) => emit(state.copyWith(isSubmitting: false, createdAccount: account)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
