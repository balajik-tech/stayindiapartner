import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';




class OwnerModel extends OwnerEntity {
  const OwnerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.avatar,
    super.isProfileComplete,
    super.bedLimit,
    super.plan,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullName = (json['name'] ?? json['fullName'] ?? '').toString().trim();
    final name = fullName.isNotEmpty
        ? fullName
        : [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final ownerProfile = json['ownerProfile'] is Map ? json['ownerProfile'] as Map : {};
    final subscription = ownerProfile['subscription'] is Map
        ? ownerProfile['subscription'] as Map
        : {};

    final bedLimitRaw = subscription['bedLimit'];
    final bedLimit = bedLimitRaw is int
        ? bedLimitRaw
        : int.tryParse(bedLimitRaw?.toString() ?? '') ?? 10;

    return OwnerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: name,
      phone: (json['phone'] ?? json['mobile'] ?? '').toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      isProfileComplete:
          json['isProfileComplete'] == true || json['is_profile_complete'] == true,
      bedLimit: bedLimit,
      plan: subscription['plan']?.toString() ?? 'free',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        'isProfileComplete': isProfileComplete,
        'bedLimit': bedLimit,
        'plan': plan,
      };

  
  factory OwnerModel.fromEntity(OwnerEntity entity) => OwnerModel(
        id: entity.id,
        name: entity.name,
        phone: entity.phone,
        email: entity.email,
        avatar: entity.avatar,
        isProfileComplete: entity.isProfileComplete,
        bedLimit: entity.bedLimit,
        plan: entity.plan,
      );
}
