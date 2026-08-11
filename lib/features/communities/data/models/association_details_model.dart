import '../../domain/entities/association_details_entity.dart';

class AssociationDetailsModel extends AssociationDetailsEntity {
  const AssociationDetailsModel({
    required super.name,
    required super.address,
    required super.email,
    required super.phone,
    required super.logo,
    required super.about,
    required super.bylaws,
    required super.founders,
  });

  factory AssociationDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssociationDetailsModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      logo: json['logo'] ?? '',
      about: AssociationInfoModel.fromJson(json['about'] ?? {}),
      bylaws: AssociationInfoModel.fromJson(json['bylaws'] ?? {}),
      founders: AssociationFoundersSectionModel.fromJson(json['founders'] ?? {}),
    );
  }
}

class AssociationInfoModel extends AssociationInfoEntity {
  const AssociationInfoModel({
    required super.description,
    required super.contents,
  });

  factory AssociationInfoModel.fromJson(Map<String, dynamic> json) {
    return AssociationInfoModel(
      description: json['description'] ?? '',
      contents: (json['contents'] as List<dynamic>?)
              ?.map((e) => AssociationContentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AssociationContentModel extends AssociationContentEntity {
  const AssociationContentModel({
    required super.title,
    required super.subtitle,
    required super.descriptions,
    required super.type,
  });

  factory AssociationContentModel.fromJson(Map<String, dynamic> json) {
    return AssociationContentModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      descriptions: (json['description'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      type: json['type'] ?? '',
    );
  }
}

class AssociationFoundersSectionModel extends AssociationFoundersSectionEntity {
  const AssociationFoundersSectionModel({
    required super.description,
    required super.founders,
  });

  factory AssociationFoundersSectionModel.fromJson(Map<String, dynamic> json) {
    return AssociationFoundersSectionModel(
      description: json['description'] ?? '',
      founders: (json['founders'] as List<dynamic>?)
              ?.map((e) => AssociationFounderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AssociationFounderModel extends AssociationFounderEntity {
  const AssociationFounderModel({
    required super.id,
    required super.name,
    required super.role,
    required super.profileImg,
  });

  factory AssociationFounderModel.fromJson(Map<String, dynamic> json) {
    return AssociationFounderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      profileImg: json['profileimg'] ?? '',
    );
  }
}
