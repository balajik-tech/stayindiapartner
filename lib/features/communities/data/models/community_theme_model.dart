import '../../domain/entities/community_theme_entity.dart';

class AssociateCommunityThemeModel extends CommunityThemeEntity {
  const AssociateCommunityThemeModel({
    required super.primaryColor,
    required super.primaryColorLight,
    required super.accentColor,
    required super.backgroundColor,
    required super.cardColor,
    required super.textOnPrimary,
    required super.textPrimary,
    required super.textSecondary,
    required super.badgeBackground,
    required super.badgeBorder,
    required super.badgeText,
  });

  /// Matches the shape you'll get back from the theme API later.
  factory AssociateCommunityThemeModel.fromJson(Map<String, dynamic> json) {
    return AssociateCommunityThemeModel(
      primaryColor: json['primaryColor'] as String,
      primaryColorLight: json['primaryColorLight'] as String,
      accentColor: json['accentColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      cardColor: json['cardColor'] as String,
      textOnPrimary: json['textOnPrimary'] as String,
      textPrimary: json['textPrimary'] as String,
      textSecondary: json['textSecondary'] as String,
      badgeBackground: json['badgeBackground'] as String,
      badgeBorder: json['badgeBorder'] as String,
      badgeText: json['badgeText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor,
    'primaryColorLight': primaryColorLight,
    'accentColor': accentColor,
    'backgroundColor': backgroundColor,
    'cardColor': cardColor,
    'textOnPrimary': textOnPrimary,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'badgeBackground': badgeBackground,
    'badgeBorder': badgeBorder,
    'badgeText': badgeText,
  };
}