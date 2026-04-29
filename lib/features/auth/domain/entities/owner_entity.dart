import 'package:equatable/equatable.dart';



class OwnerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final bool isProfileComplete;
  final int bedLimit;
  final String plan;

  const OwnerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.isProfileComplete = false,
    this.bedLimit = 10,
    this.plan = 'free',
  });

  bool get isNewOwner => !isProfileComplete;
  bool get isPremium => plan != 'free';

  OwnerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    bool? isProfileComplete,
    int? bedLimit,
    String? plan,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      bedLimit: bedLimit ?? this.bedLimit,
      plan: plan ?? this.plan,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatar,
        isProfileComplete,
        bedLimit,
        plan,
      ];
}
