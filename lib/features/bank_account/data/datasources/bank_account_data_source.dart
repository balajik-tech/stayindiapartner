import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/entities/property_entity.dart';
import '../models/bank_account_model.dart';
import '../models/property_model.dart';

abstract class BankAccountDataSource {
  Future<List<PropertyModel>> getProperties();

  Future<BankAccountModel> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
  });

  Future<void> setPrimaryAccount({required String propertyId, required String accountId});

  Future<BankBranchDetails> lookupIfsc(String ifscCode);
}

/// In-memory implementation seeded with the demo data shown in design.
/// Replace with `BankAccountRemoteDataSourceImpl` (http/dio calls to your
/// backend) once the API is ready — the repository only depends on the
/// [BankAccountDataSource] contract above, so no other layer needs to change.
class BankAccountLocalDataSourceImpl implements BankAccountDataSource {
  final List<PropertyModel> _properties = [
    PropertyModel(
      id: 'prop_1',
      name: 'Sunrise Residency',
      location: 'Koramangala',
      code: 'PG10428',
      verificationStatus: PropertyVerificationStatus.verified,
      accounts: [
        const BankAccountModel(
          id: 'acc_1',
          propertyId: 'prop_1',
          bankName: 'HDFC Bank',
          branchName: 'Koramangala 5th Block, Bengaluru',
          accountNumber: '50100482194821',
          ifscCode: 'HDFC0001234',
          accountHolderName: 'Ramesh Kumar',
          accountType: BankAccountType.savings,
          isPrimary: true,
          verificationStatus: AccountVerificationStatus.verified,
        ),
        const BankAccountModel(
          id: 'acc_2',
          propertyId: 'prop_1',
          bankName: 'ICICI Bank',
          branchName: 'Koramangala, Bengaluru',
          accountNumber: '00040051239075',
          ifscCode: 'ICIC0000456',
          accountHolderName: 'Ramesh Kumar',
          accountType: BankAccountType.savings,
          isPrimary: false,
          verificationStatus: AccountVerificationStatus.verified,
        ),
      ],
    ),
    PropertyModel(
      id: 'prop_2',
      name: 'Green Nest PG',
      location: 'HSR Layout',
      code: 'PG10933',
      verificationStatus: PropertyVerificationStatus.pending,
      accounts: [
        const BankAccountModel(
          id: 'acc_3',
          propertyId: 'prop_2',
          bankName: 'Axis Bank',
          branchName: 'HSR Layout, Bengaluru',
          accountNumber: '91802003343390',
          ifscCode: 'UTIB0002211',
          accountHolderName: 'Ramesh Kumar',
          accountType: BankAccountType.savings,
          isPrimary: true,
          verificationStatus: AccountVerificationStatus.pending,
        ),
      ],
    ),
  ];

  /// A tiny fake IFSC directory purely for demo purposes.
  static const Map<String, BankBranchDetails> _ifscDirectory = {
    'HDFC0001234': BankBranchDetails(bankName: 'HDFC Bank', branchName: 'Koramangala 5th Block, Bengaluru'),
    'ICIC0000456': BankBranchDetails(bankName: 'ICICI Bank', branchName: 'Koramangala, Bengaluru'),
    'UTIB0002211': BankBranchDetails(bankName: 'Axis Bank', branchName: 'HSR Layout, Bengaluru'),
  };

  @override
  Future<List<PropertyModel>> getProperties() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _properties;
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final branch = _ifscDirectory[ifscCode];
    final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
    if (propertyIndex == -1) {
      throw Exception('Property not found');
    }

    final newAccount = BankAccountModel(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      bankName: branch?.bankName ?? 'Bank',
      branchName: branch?.branchName ?? '',
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolderName: accountHolderName,
      accountType: accountType,
      isPrimary: _properties[propertyIndex].accounts.isEmpty,
      verificationStatus: AccountVerificationStatus.pending,
    );

    final updatedAccounts = [..._properties[propertyIndex].accounts, newAccount];
    _properties[propertyIndex] = PropertyModel(
      id: _properties[propertyIndex].id,
      name: _properties[propertyIndex].name,
      location: _properties[propertyIndex].location,
      code: _properties[propertyIndex].code,
      verificationStatus: _properties[propertyIndex].verificationStatus,
      accounts: updatedAccounts,
    );

    return newAccount;
  }

  @override
  Future<void> setPrimaryAccount({required String propertyId, required String accountId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
    if (propertyIndex == -1) throw Exception('Property not found');

    final updatedAccounts = _properties[propertyIndex]
        .accounts
        .map((a) => BankAccountModel.fromEntity(a.copyWith(isPrimary: a.id == accountId)))
        .toList();

    _properties[propertyIndex] = PropertyModel(
      id: _properties[propertyIndex].id,
      name: _properties[propertyIndex].name,
      location: _properties[propertyIndex].location,
      code: _properties[propertyIndex].code,
      verificationStatus: _properties[propertyIndex].verificationStatus,
      accounts: updatedAccounts,
    );
  }

  @override
  Future<BankBranchDetails> lookupIfsc(String ifscCode) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final branch = _ifscDirectory[ifscCode];
    if (branch == null) {
      throw Exception('IFSC code not found');
    }
    return branch;
  }
}
