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
    super.rulesRegulations,
  });

  factory AssociationDetailsModel.fromJson(Map<String, dynamic> json) {
    String addressStr = '';
    final rawAddress = json['address'];
    if (rawAddress is String) {
      addressStr = rawAddress;
    } else if (rawAddress is Map<String, dynamic>) {
      final line1 = rawAddress['line1']?.toString() ?? '';
      final line2 = rawAddress['line2']?.toString() ?? '';
      final city = rawAddress['city']?.toString() ?? '';
      final state = rawAddress['state']?.toString() ?? '';
      final pincode = rawAddress['pincode']?.toString() ?? '';

      final parts = [
        if (line1.isNotEmpty) line1,
        if (line2.isNotEmpty) line2,
        if (city.isNotEmpty) city,
        if (state.isNotEmpty) state,
        if (pincode.isNotEmpty) pincode,
      ];
      addressStr = parts.join(', ');
    } else if (rawAddress != null) {
      addressStr = rawAddress.toString();
    }

    return AssociationDetailsModel(
      name: json['name']?.toString() ?? '',
      address: addressStr,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      about: _parseInfoSection(json['about']),
      bylaws: _parseInfoSection(json['bylaws']),
      founders: _parseFoundersSection(json['founders']),
      rulesRegulations: json['rulesRegulations'] != null ? _parseInfoSection(json['rulesRegulations']) : null,
    );
  }

  static AssociationInfoEntity _parseInfoSection(Object? raw) {
    if (raw == null) {
      return const AssociationInfoEntity(description: '', contents: []);
    }

    if (raw is List) {
      if (raw.isNotEmpty && raw.first is Map) {
        return AssociationInfoModel.fromJson(Map<String, dynamic>.from(raw.first));
      }
      return const AssociationInfoEntity(description: '', contents: []);
    }

    if (raw is Map<String, dynamic>) {
      return AssociationInfoModel.fromJson(raw);
    }

    if (raw is Map) {
      return AssociationInfoModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return const AssociationInfoEntity(description: '', contents: []);
  }

  static AssociationFoundersSectionEntity _parseFoundersSection(Object? raw) {
    if (raw == null) {
      return const AssociationFoundersSectionEntity(description: '', founders: []);
    }

    if (raw is List) {
      if (raw.isNotEmpty && raw.first is Map) {
        return AssociationFoundersSectionModel.fromJson(Map<String, dynamic>.from(raw.first));
      }
      return const AssociationFoundersSectionEntity(description: '', founders: []);
    }

    if (raw is Map<String, dynamic>) {
      return AssociationFoundersSectionModel.fromJson(raw);
    }

    if (raw is Map) {
      return AssociationFoundersSectionModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return const AssociationFoundersSectionEntity(description: '', founders: []);
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
