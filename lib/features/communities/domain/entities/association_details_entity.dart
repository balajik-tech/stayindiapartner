import 'package:equatable/equatable.dart';

class AssociationDetailsEntity extends Equatable {
  final String name;
  final String address;
  final String email;
  final String phone;
  final String logo;
  final AssociationInfoEntity about;
  final AssociationInfoEntity bylaws;
  final AssociationFoundersSectionEntity founders;
  final AssociationInfoEntity? rulesRegulations;

  const AssociationDetailsEntity({
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    required this.logo,
    required this.about,
    required this.bylaws,
    required this.founders,
    this.rulesRegulations,
  });

  @override
  List<Object?> get props =>
      [name, address, email, phone, logo, about, bylaws, founders, rulesRegulations];
}

class AssociationInfoEntity extends Equatable {
  final String description;
  final List<AssociationContentEntity> contents;

  const AssociationInfoEntity({
    required this.description,
    required this.contents,
  });

  @override
  List<Object?> get props => [description, contents];
}

class AssociationContentEntity extends Equatable {
  final String title;
  final String subtitle;
  final List<String> descriptions;
  final String type;

  const AssociationContentEntity({
    required this.title,
    required this.subtitle,
    required this.descriptions,
    required this.type,
  });

  @override
  List<Object?> get props => [title, subtitle, descriptions, type];
}

class AssociationFoundersSectionEntity extends Equatable {
  final String description;
  final List<AssociationFounderEntity> founders;

  const AssociationFoundersSectionEntity({
    required this.description,
    required this.founders,
  });

  @override
  List<Object?> get props => [description, founders];
}

class AssociationFounderEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String profileImg;

  const AssociationFounderEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.profileImg,
  });

  @override
  List<Object?> get props => [id, name, role, profileImg];
}
