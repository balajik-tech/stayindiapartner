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
  final bool hasAcceptedPolicy;
  final String role;
  final String? verificationBadge;

  const OwnerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.isProfileComplete = false,
    this.bedLimit = 10,
    this.plan = 'free',
    this.hasAcceptedPolicy = false,
    this.role = 'owner',
    this.verificationBadge,
  });

  bool get isNewOwner => !isProfileComplete;
  bool get isPremium => plan != 'free';
  bool get isCook => role == 'cook';
  bool get isWarden => role == 'warden';
  bool get isManager => role == 'manager';
  bool get isAnyStaff => ['cook', 'warden', 'manager'].contains(role);

  bool hasPermission(String permission) {
    // Basic implementation, can be extended based on actual permission logic
    if (role == 'owner') return true;
    return false; 
  }

  OwnerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    bool? isProfileComplete,
    int? bedLimit,
    String? plan,
    bool? hasAcceptedPolicy,
    String? role,
    String? verificationBadge,
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
      hasAcceptedPolicy: hasAcceptedPolicy ?? this.hasAcceptedPolicy,
      role: role ?? this.role,
      verificationBadge: verificationBadge ?? this.verificationBadge,
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
        hasAcceptedPolicy,
        role,
        verificationBadge,
      ];
}
