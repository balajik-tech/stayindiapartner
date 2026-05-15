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
  final String? staffPropertyId;
  final List<String> permissions;

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
    this.staffPropertyId,
    this.permissions = const [],
  });

  bool get isNewOwner => !isProfileComplete;
  bool get isPremium => plan != 'free';
  bool get isManager => role == 'manager';
  bool get isWarden => role == 'warden';
  bool get isSecurity => role == 'security';
  bool get isCook => role == 'cook';
  bool get isCleaningStaff => role == 'cleaning_staff';
  bool get isAnyStaff => ['manager', 'warden', 'security', 'cook', 'cleaning_staff'].contains(role);

  bool hasPermission(String permission) {
    if (role == 'owner' || role == 'manager') return true;
    return permissions.contains(permission);
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
    String? staffPropertyId,
    List<String>? permissions,
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
      staffPropertyId: staffPropertyId ?? this.staffPropertyId,
      permissions: permissions ?? this.permissions,
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
        staffPropertyId,
        permissions,
      ];
}
