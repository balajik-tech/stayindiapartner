import 'package:equatable/equatable.dart';

import 'bank_account_entity.dart';

enum PropertyVerificationStatus { verified, pending }

extension PropertyVerificationStatusX on PropertyVerificationStatus {
  String get label => this == PropertyVerificationStatus.verified ? 'Verified' : 'Pending';
}

class PropertyEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final String code;
  final PropertyVerificationStatus verificationStatus;
  final List<BankAccountEntity> accounts;

  const PropertyEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.code,
    required this.verificationStatus,
    required this.accounts,
  });

  PropertyEntity copyWith({
    String? id,
    String? name,
    String? location,
    String? code,
    PropertyVerificationStatus? verificationStatus,
    List<BankAccountEntity>? accounts,
  }) {
    return PropertyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      code: code ?? this.code,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      accounts: accounts ?? this.accounts,
    );
  }

  @override
  List<Object?> get props => [id, name, location, code, verificationStatus, accounts];
}
