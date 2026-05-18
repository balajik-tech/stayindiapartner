import '../entities/owner_entity.dart';
import '../repositories/auth_repository.dart';

class ProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String? avatarPath;

  const ProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    this.avatarPath,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    if (avatarPath != null) 'avatar': avatarPath,
  };
}

class CompleteProfileUseCase {
  final AuthRepository repository;

  const CompleteProfileUseCase(this.repository);

  Future<OwnerEntity> call(ProfileParams params) =>
      repository.completeProfile(params.toJson());
}
