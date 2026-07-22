import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String? dob;
  final String? gender;
  final String? avatar;
  final String? associationId;
  final bool isVerifiedOwner;
  final DlKycEntity? dlKyc;

  const ProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    this.dob,
    this.gender,
    this.avatar,
    this.associationId,
    this.isVerifiedOwner = false,
    this.dlKyc,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phone,
    email,
    address,
    dob,
    gender,
    avatar,
    associationId,
    isVerifiedOwner,
    dlKyc,
  ];
}
