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

  /// Matches the shape of the theme API response and merges with defaults.
  factory AssociateCommunityThemeModel.fromJson(Map<String, dynamic> json) {
    // Extract dynamic colors from nested 'theme' object if it exists (API style)
    // or from top level (Legacy/Static style)
    final themeData = json['theme'] is Map ? json['theme'] as Map<String, dynamic> : json;

    final primaryColor = themeData['primaryColor']?.toString() ?? '#16305A';
    final accentColor = themeData['accentColor']?.toString() ?? '#6FA641';

    return AssociateCommunityThemeModel(
      primaryColor: primaryColor,
      primaryColorLight: themeData['primaryColorLight']?.toString() ?? '#1E4976',
      accentColor: accentColor,
      backgroundColor: themeData['backgroundColor']?.toString() ?? '#EEF1F6',
      cardColor: themeData['cardColor']?.toString() ?? '#FFFFFF',
      textOnPrimary: themeData['textOnPrimary']?.toString() ?? '#FFFFFF',
      textPrimary: themeData['textPrimary']?.toString() ?? '#1A1A1A',
      textSecondary: themeData['textSecondary']?.toString() ?? '#6B7280',
      badgeBackground: primaryColor ?? themeData['badgeBackground']?.toString() ?? '#E7F0DD',
      badgeBorder:primaryColor ?? themeData['badgeBorder']?.toString() ?? '#9CCB6B',
      badgeText: accentColor ?? themeData['badgeText']?.toString() ?? '#3E7A34',
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